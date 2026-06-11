@_exported import Coordinator
@_exported import BaseKit
@_exported import AppFoundation
@_exported import RswiftResources

@MainActor
public enum AppUI {
    public static func ensureInitialized() {
        AppDebugger.setup()
        AppDecorator.setup()
    }
}

public extension RswiftResources.ImageResource {
    static var appImage: _R.image {
        R.image
    }
}

public extension RswiftResources.ColorResource {
    static var appColor: _R.color {
        R.color
    }
}
