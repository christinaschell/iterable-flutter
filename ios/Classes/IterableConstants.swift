import Foundation

public enum IterableConstants {
    static let sdkVersion = "flutterSDKVersion"

    // Initial Config
    public enum Config: String {
        case apiKey
        case apiEndPointOverride
        case config
        case version
        //case remoteNotificationsEnabled
        case expiringAuthTokenRefreshPeriod
        case inAppDisplayInterval
        case autoPushRegistration
        case pushIntegrationName
        case logLevel
    }

    // Delegates
    public enum Delegates: String {
        case urlHandlerPresent
        case customActionHandlerPresent
        case inAppHandlerPresent
        case authHandlerPresent
    }

    // Events
    enum Events: String, CaseIterable  {
        case emitterName = "emitterName";
        case inAppDelegate = "IterableFlutter.InAppDelegateEvent"
        case urlDelegate = "IterableFlutter.UrlDelegateEvent"
        case authDelegate = "IterableFlutter.AuthDelegateEvent"
    }
}
