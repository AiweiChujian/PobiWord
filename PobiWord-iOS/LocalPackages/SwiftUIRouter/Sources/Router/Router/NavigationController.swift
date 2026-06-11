//
//  NavigationController.swift
//
//
//  Created by Avery on 2024/9/3.
//

import Foundation
import SwiftUI
import Combine

public enum NavigationController {
    @MainActor
    static func new<R: Router, V: View>(
        _ type: R.Type,
        last: (any Router)?,
        router: R? = nil,
        rootTitle: String = #function,
        rootView: V
    ) -> some View {
        WrappedNavigationStack<R, V>(
            router: router,
            last: last,
            rootTitle: rootTitle,
            rootView: rootView
        )
    }

    @MainActor
    public static func new<R: Router, V: View>(
        _ type: R.Type,
        last: (any Router)?,
        router: R? = nil,
        rootTitle: String = #function,
        @ViewBuilder rootBuilder: () -> V
    ) -> some View {
        new(
            type,
            last: last,
            router: router,
            rootTitle: rootTitle,
            rootView: rootBuilder()
        )
    }

    @MainActor
    public fileprivate(set) static var topMostRouter: (any Router)?
}

struct WrappedNavigationStack<R: Router, V: View>: View {
    @StateObject
    var router: R

    let last: (any Router)?

    let rootTitle: String

    let rootView: V

    init(
        router: R?,
        last: (any Router)?,
        rootTitle: String,
        rootView: V
    ) {
        self._router = .init(wrappedValue: router ?? .init())
        self.last = last
        self.rootTitle = rootTitle
        self.rootView = rootView
    }

    private struct SheetState {
        var isActivated = false
        var routerSheet: RouterSheet?
    }

    @State
    private var sheetState =  SheetState()

    private struct ScreenCoverState {
        var isActivated = false
        var routerCover: RouterScreenCover?
    }

    @State
    private var coverState = ScreenCoverState()

    var body: some View {
        contentView.environmentObject(router)
    }

    @ViewBuilder
    var contentView: some View {
        NavigationStack(path: $router.navigationNodes) {
            rootView
                .navigationDestination(for: Router.Node.self) { node in
                    node.destinationBuilder()
                }
        }
        .onAppear {
            NavigationController.topMostRouter = router
            router.assistant.last = last
            router.assistant.rootTitle = rootTitle
        }
        .onReceive(router.assistant.dismissSubject) { _ in
            // Sheet 和 FullScreenCover 是互斥的
            sheetState = .init(isActivated: false)
            coverState = .init(isActivated: false)
        }
        .sheet(isPresented: $sheetState.isActivated) {
            if sheetState.isActivated, let sheet = sheetState.routerSheet {
                sheet.sheetBuilder()
                    .presentationDetents(sheet.detents)
            }
        }
        .onReceive(router.assistant.sheetContentSubject) { value in
            if coverState.isActivated {
                coverState = .init(isActivated: false)
            }
            Task {
                sheetState = .init(isActivated: true, routerSheet: value)
            }
        }
        .onChange(of: sheetState.isActivated) { old, new in
            if new == false {
                sheetState.routerSheet = nil
                router.assistant.sheetInactivated()
            }
        }
#if os(iOS)
        .fullScreenCover(isPresented: $coverState.isActivated, onDismiss: coverState.routerCover?.onDismiss) {
            if coverState.isActivated, let cover = coverState.routerCover {
                cover.screenCoverBuilder()
            }
        }
#endif
        .onReceive(router.assistant.screenCoverSubject) { value in
            if sheetState.isActivated {
                sheetState = .init(isActivated: false)
            }
            Task {
                coverState = .init(isActivated: true, routerCover: value)
            }
        }
        .onChange(of: coverState.isActivated) { old, new in
            if new == false {
                coverState.routerCover = nil
                router.assistant.coverInactivated()
            }
        }
    }
}
