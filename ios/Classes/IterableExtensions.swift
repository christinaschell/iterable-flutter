import Foundation
import IterableSDK

public extension IterableConfig {
    static func from(_ dictionary: [String: Any]?) -> IterableConfig {
        let config = IterableConfig()
        
        guard let dictionary = dictionary else {
            return config
        }
        
        if let pushIntegrationName = dictionary[.pushIntegrationName] as? String {
            config.pushIntegrationName = pushIntegrationName
        }
        
        if let logLevelNumber = dictionary[.logLevel] as? NSNumber {
            config.logDelegate = createLogDelegate(logLevelNumber: logLevelNumber)
        }

        if let allowedProtocols = dictionary[.allowedProtocols] as? [String] {
            config.allowedProtocols = allowedProtocols
        }
        
        config.autoPushRegistration = dictionary[.autoPushRegistration] as? Bool ?? true
        config.inAppDisplayInterval = dictionary[.inAppDisplayInterval] as? Double ?? 30.0
        config.expiringAuthTokenRefreshPeriod = dictionary[.expiringAuthTokenRefreshPeriod] as? Double ?? 60.0
        
        return config
    }
    
    private static func createLogDelegate(logLevelNumber: NSNumber) -> IterableLogDelegate {
        DefaultLogDelegate(minLogLevel: LogLevel.from(number: logLevelNumber))
    }
}

extension CommerceItem {
    static func from(_ dictionary: [AnyHashable: Any]) -> CommerceItem? {
        guard let id = dictionary["id"] as? String else {
            return nil
        }
        
        guard let name = dictionary["name"] as? String else {
            return nil
        }
        
        guard let price = dictionary["price"] as? NSNumber else {
            return nil
        }
        
        guard let quantity = dictionary["quantity"] as? UInt else {
            return nil
        }
        
        let sku = dictionary["sku"] as? String
        let description = dictionary["description"] as? String
        let url = dictionary["url"] as? String
        let imageUrl = dictionary["imageUrl"] as? String
        let categories = dictionary["categories"] as? [String]
        let dataFields = dictionary["dataFields"] as? [AnyHashable: Any]
        
        return CommerceItem(id: id,
                            name: name,
                            price: price,
                            quantity: quantity,
                            sku: sku,
                            description: description,
                            url: url,
                            imageUrl: imageUrl,
                            categories: categories,
                            dataFields: dataFields)
    }
}

extension LogLevel {
    static func from(number: NSNumber) -> LogLevel {
        if let value = number as? Int {
            return LogLevel(rawValue: value) ?? .info
        } else {
            return .info
        }
    }
}

extension Data {
    var stringified: String? {
        guard /*let json = try? JSONSerialization.jsonObject(with: self, options: []),*/
        let jsonString = String(data: self, encoding: .utf8) else {
            return nil
        }
        return jsonString
    }
}

extension Date {
    var integer: Int {
        Int(self.timeIntervalSince1970 * 1000)
    }
}

extension Int {
    var toDate: Date {
        let seconds = Double(self) / 1000.0 // ms -> seconds
        return Date(timeIntervalSince1970: seconds)
    }
}

extension Dictionary where Key == AnyHashable, Value == Any {
    var stringified: String? {
        guard let data = try? JSONSerialization.data(withJSONObject: self, options: .prettyPrinted),
              let jsonString = String(data: data, encoding: .utf8) else {
            return nil
        }
        return jsonString
    }
}

extension Encodable {
  var encoded: [String: Any]? {
    guard let data = try? JSONEncoder().encode(self) else { return nil }
    return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)).flatMap { $0 as? [String: Any] }
  }
}

extension IterableInAppTrigger {
    var dictionary: [AnyHashable: Any] {
        var dict = [AnyHashable: Any]()
        dict["type"] = self.type.rawValue
        return dict
    }
}

extension UIEdgeInsets {
    var dictionary: [AnyHashable: Any] {
        var dict = [AnyHashable: Any]()
        dict["top"] = top
        dict["left"] = left
        dict["bottom"] = bottom
        dict["right"] = right
        return dict
    }
}

extension IterableInboxMetadata {
    var dictionary: [AnyHashable: Any]? {
        var dict = [AnyHashable: Any]()
        dict["title"] = title
        dict["subtitle"] = subtitle
        dict["icon"] = icon
        return dict
    }
}

extension IterableInAppMessage {
    var dictionary: [AnyHashable: Any] {
        var dict = [AnyHashable: Any]()
        guard let content = content as? IterableHtmlInAppContent else {
            return dict
        }
        dict["messageId"] = messageId
        dict["campaignId"] = campaignId
        dict["content"] = content.dictionary
        dict["trigger"] = trigger.dictionary
        dict["createdAt"] = createdAt?.integer
        dict["expiresAt"] = expiresAt?.integer
        dict["saveToInbox"] = saveToInbox
        dict["inboxMetadata"] = inboxMetadata?.dictionary
        dict["customPayload"] = customPayload
        dict["read"] = read
        dict["priorityLevel"] = priorityLevel
        return dict
    }
}

extension IterableHtmlInAppContent {
    var dictionary: [AnyHashable: Any] {
        var dict = [AnyHashable: Any]()
        dict["type"] = type.rawValue
        dict["edgeInsets"] = edgeInsets.dictionary
        dict["html"] = html
        return dict
    }
}

extension InAppLocation {
    static func from(number: NSNumber) -> InAppLocation {
        if let value = number as? Int {
            return InAppLocation(rawValue: value) ?? .inApp
        } else {
            return .inApp
        }
    }
}

extension InAppCloseSource {
    static func from(number: NSNumber) -> InAppCloseSource? {
        guard let value = number as? Int else {
            return nil
        }
        
        return InAppCloseSource(rawValue: value)
    }
}

extension InAppDeleteSource {
    static func from(number: NSNumber) -> InAppDeleteSource? {
        guard let value = number as? Int else {
            return nil
        }
        
        return InAppDeleteSource(rawValue: value)
    }
}

extension InAppShowResponse {
    static func from(number: NSNumber) -> InAppShowResponse {
        if let value = number as? Int {
            return InAppShowResponse(rawValue: value) ?? .show
        } else {
            return .show
        }
    }
}

extension IterableAction {
    var dictionary: [String: Any] {
        var result = [String: Any]()
                
        result["type"] = self.type
        
        guard let data = self.data else {
            return result
        }
        
        result["data"] = data
        
        guard let userInput = self.userInput else {
            return result
        }
        
        result["userInput"] = userInput
        
        return result
    }
}

extension IterableActionContext {
    var dictionary: [String: Any] {
        var result = [String: Any]()

        let actionDict = self.action.dictionary
        result["action"] = actionDict
        result["source"] = self.source.rawValue
        
        return result
    }
}

public extension Dictionary where Key: ExpressibleByStringLiteral {
    subscript(key: IterableConstants.Config) -> Value? {
        get {
            return self[key.rawValue as! Key]
        }
    }
    subscript(key: IterableConstants.Delegates) -> Value? {
        get {
            return self[key.rawValue as! Key]
        }
    }
}
