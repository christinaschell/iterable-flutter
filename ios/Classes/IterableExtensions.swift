import Foundation
import IterableSDK

public extension IterableConfig {
    static func from(_ dictionary: [AnyHashable: Any]?) -> IterableConfig {
        let config = IterableConfig()
        
        guard let dictionary = dictionary else {
            return config
        }
        
        if let pushIntegrationName = dictionary["pushIntegrationName"] as? String {
            config.pushIntegrationName = pushIntegrationName
        }
        
        if let autoPushRegistration = dictionary["autoPushRegistration"] as? Bool {
            config.autoPushRegistration = autoPushRegistration
        }
        
        if let inAppDisplayInterval = dictionary["inAppDisplayInterval"] as? Double {
            config.inAppDisplayInterval = inAppDisplayInterval
        }

        if let expiringAuthTokenRefreshPeriod = dictionary["expiringAuthTokenRefreshPeriod"] as? Double {
            config.expiringAuthTokenRefreshPeriod = expiringAuthTokenRefreshPeriod
        }
        
        if let logLevelNumber = dictionary["logLevel"] as? NSNumber {
            config.logDelegate = createLogDelegate(logLevelNumber: logLevelNumber)
        }
        
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

extension Dictionary where Key == AnyHashable, Value == Any {
    var stringified: String? {
        guard let data = try? JSONSerialization.data(withJSONObject: self, options: .prettyPrinted),
              let jsonString = String(data: data, encoding: .utf8) else {
            return nil
        }
        return jsonString
    }
}
