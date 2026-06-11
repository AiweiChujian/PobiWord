//
//  File.swift
//  BaseKit
//
//  Created by Avery on 2026/4/20.
//

import Foundation
import UIKit

// MARK: - Delegate

public protocol MasonryLayoutDelegate: UICollectionViewDelegate {
    func masonryLayout(
        _ layout: MasonryLayout,
        heightForItemAt indexPath: IndexPath,
        columnWidth: CGFloat
    ) -> CGFloat
}

// MARK: - MasonryLayout

public final class MasonryLayout: UICollectionViewLayout {

    // MARK: - Configuration

    public struct Configuration {
        public var columnCount: Int
        public var interItemSpacing: CGFloat
        public var columnSpacing: CGFloat
        public var sectionInset: UIEdgeInsets

        public init(
            columnCount: Int = 2,
            interItemSpacing: CGFloat = 8,
            columnSpacing: CGFloat = 8,
            sectionInset: UIEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        ) {
            self.columnCount = columnCount
            self.interItemSpacing = interItemSpacing
            self.columnSpacing = columnSpacing
            self.sectionInset = sectionInset
        }

        public static let `default` = Configuration()
    }

    // MARK: - Public

    public var configuration: Configuration = .default {
        didSet { invalidateLayout() }
    }

    // MARK: - Private

    private var delegate: MasonryLayoutDelegate? {
        collectionView?.delegate as? MasonryLayoutDelegate
    }

    private var cache: [IndexPath: UICollectionViewLayoutAttributes] = [:]
    private var columnHeights: [CGFloat] = []
    private var computedContentSize: CGSize = .zero

    private var columnCount: Int { max(1, configuration.columnCount) }
    private var inset: UIEdgeInsets { configuration.sectionInset }

    private func columnWidth(in collectionView: UICollectionView) -> CGFloat {
        let totalSpacing = configuration.columnSpacing * CGFloat(columnCount - 1)
        let availableWidth = collectionView.bounds.width
            - inset.left - inset.right
            - totalSpacing
        return max(0, availableWidth / CGFloat(columnCount))
    }

    // MARK: - UICollectionViewLayout Overrides

    override public func prepare() {
        super.prepare()
        guard let collectionView = collectionView else { return }

        let colWidth = columnWidth(in: collectionView)
        resetCache()

        for section in 0..<collectionView.numberOfSections {
            for item in 0..<collectionView.numberOfItems(inSection: section) {
                let indexPath = IndexPath(item: item, section: section)
                cache[indexPath] = layoutAttributes(for: indexPath, columnWidth: colWidth)
            }
        }

        computedContentSize = calculateContentSize(in: collectionView)
    }

    override public var collectionViewContentSize: CGSize {
        computedContentSize
    }

    override public func layoutAttributesForItem(
        at indexPath: IndexPath
    ) -> UICollectionViewLayoutAttributes? {
        cache[indexPath]
    }

    override public func layoutAttributesForElements(
        in rect: CGRect
    ) -> [UICollectionViewLayoutAttributes]? {
        cache.values.filter { rect.intersects($0.frame) }
    }

    override public func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        collectionView.map { newBounds.width != $0.bounds.width } ?? false
    }

    // MARK: - Core Layout Logic

    private func resetCache() {
        cache.removeAll()
        columnHeights = Array(repeating: inset.top, count: columnCount)
    }

    private func layoutAttributes(
        for indexPath: IndexPath,
        columnWidth: CGFloat
    ) -> UICollectionViewLayoutAttributes {
        let colIndex = shortestColumnIndex()

        let xOffset = inset.left + CGFloat(colIndex) * (columnWidth + configuration.columnSpacing)
        let yOffset = columnHeights[colIndex]
        let height = itemHeight(for: indexPath, columnWidth: columnWidth)

        columnHeights[colIndex] = yOffset + height + configuration.interItemSpacing

        let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        attributes.frame = CGRect(x: xOffset, y: yOffset, width: columnWidth, height: height)
        return attributes
    }

    private func calculateContentSize(in collectionView: UICollectionView) -> CGSize {
        let contentHeight = columnHeights[longestColumnIndex()]
            - configuration.interItemSpacing
            + inset.bottom
        return CGSize(width: collectionView.bounds.width, height: max(0, contentHeight))
    }

    // MARK: - Column Helpers

    private func shortestColumnIndex() -> Int {
        columnHeights.enumerated().min { $0.element < $1.element }?.offset ?? 0
    }

    private func longestColumnIndex() -> Int {
        columnHeights.enumerated().max { $0.element < $1.element }?.offset ?? 0
    }

    private func itemHeight(for indexPath: IndexPath, columnWidth: CGFloat) -> CGFloat {
        delegate?.masonryLayout(self, heightForItemAt: indexPath, columnWidth: columnWidth) ?? 0
    }
}

// MARK: - Usage Example

/*

class ViewController: UIViewController, MasonryLayoutDelegate {

    private lazy var layout: MasonryLayout = {
        let l = MasonryLayout()
        l.configuration = MasonryLayout.Configuration(
            columnCount: 2,
            interItemSpacing: 10,
            columnSpacing: 10,
            sectionInset: UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        )
        return l
    }()

    private lazy var collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: layout
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
    }

    // MARK: - MasonryLayoutDelegate

    func masonryLayout(
        _ layout: MasonryLayout,
        heightForItemAt indexPath: IndexPath,
        columnWidth: CGFloat
    ) -> CGFloat {
        let ratio = items[indexPath.item].imageAspectRatio
        return columnWidth * ratio
    }
}

*/
