//
//  RouterAssistant.swift
//  MVVMRedux
//
//  Created by Avery on 2024/11/21.
//

import Foundation
import SwiftUI
import Combine

struct RouterSheet {
    var detents: Set<PresentationDetent>

    var sheetBuilder: () -> AnyView
}

struct RouterScreenCover {
    var screenCoverBuilder: () -> AnyView

    var onDismiss: (() -> Void)?
}

@MainActor
public final class RouterAssistant<R: Router> {
    public init() {}

    weak var last: (any Router)?

    var rootTitle: String?

    private var sheetTitle: String?

    private var coverTitle: String?

    var presentedTitles: [String] {
        var titles: [String] = []
        if let sheetTitle = sheetTitle {
            titles.append(sheetTitle)
        }
        if let coverTitle = coverTitle {
            titles.append(coverTitle)
        }
        return titles
    }

    let sheetContentSubject = PassthroughSubject<RouterSheet, Never>()

    let dismissSubject = PassthroughSubject<Void, Never>()

    let screenCoverSubject = PassthroughSubject<RouterScreenCover, Never>()

    func dismiss() {
        dismissSubject.send(())
    }
}

extension RouterAssistant {
    func presentSheet(_ sheet: RouterSheet, sheetTitle: String) {
        sheetContentSubject.send(sheet)
        self.sheetTitle = sheetTitle
    }

    func sheetInactivated() {
        sheetTitle = nil
    }
}

extension RouterAssistant {
    func presentCover(_ cover: RouterScreenCover, coverTitle: String) {
        screenCoverSubject.send(cover)
        self.coverTitle = coverTitle
    }

    func coverInactivated() {
        coverTitle = nil
    }
}
