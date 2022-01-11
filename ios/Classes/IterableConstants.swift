import Foundation

typealias ITBEmitter = IterableConstants.Events

public enum IterableConstants {
    static let sdkVersion = "flutterSDKVersion"

    // Initial Config
    public enum Config: String {
        case apiKey
        case apiEndPointOverride
        case config
        case version
        case expiringAuthTokenRefreshPeriod
        case inAppDisplayInterval
        case autoPushRegistration
        case pushIntegrationName
        case logLevel
        case allowedProtocols
    }

    // Delegates
    public enum Delegates: String {
        case urlHandlerPresent
        case customActionHandlerPresent
        case inAppHandlerPresent
        case authHandlerPresent
    }

    // Events
    public enum Events {
        static let emitterName = "emitterName"
        static let inAppDelegate = "IterableFlutter.InAppDelegateEvent"
        static let customActionDelegate = "IterableFlutter.CustomActionDelegateEvent"
        static let urlDelegate = "IterableFlutter.UrlDelegateEvent"
        static let authDelegate = "IterableFlutter.AuthDelegateEvent"
    }
}
