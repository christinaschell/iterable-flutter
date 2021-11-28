import Flutter
import UIKit
import IterableSDK

public class SwiftIterablePlugin: NSObject, FlutterPlugin {

  var iterable: IterableAPI?
  static var channel: FlutterMethodChannel?

  public static func register(with registrar: FlutterPluginRegistrar) {
    channel = FlutterMethodChannel(name: "iterable", binaryMessenger: registrar.messenger())
    let instance = SwiftIterablePlugin()
    guard let channel = channel else {
      return
    }
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if call.method == "initialize" {
      initialize(call: call, result: result)
    } else if call.method == "setEmail" {
      setEmail(call: call)
    } else if call.method == "getEmail" {
      getEmail(result: result)
    } else if call.method == "updateEmail" {
      updateEmail(call: call, result: result)
    } else if call.method == "setUserId" {
      setUserId(call: call)
    } else if call.method == "getUserId" {
      getUserId(result: result)
    } else if call.method == "updateUser" {
      updateUser(call: call, result: result)
    } else if call.method == "setEmailAndUserId" {
      setEmailAndUserId(call: call, result: result)
    } else if call.method == "trackEvent" {
      trackEvent(call: call)
    } else if call.method == "updateCart" {
      updateCart(call: call)
    } else if call.method == "trackPurchase" {
      trackPurchase(call: call)
    } else if call.method == "getLastPushPayload" {
      getLastPushPayload(result: result)
    } else {
      result(FlutterMethodNotImplemented);
    }
  }

  func initialize(call: FlutterMethodCall, result: @escaping FlutterResult) {
      guard let arguments = call.arguments as? [String: Any], 
      let apiKey = arguments[IterableConstants.apiKey] as? String,
      let config = arguments[IterableConstants.config] as? [AnyHashable: Any],
      let version = arguments[IterableConstants.version] as? String else {
        // TODO log error
          return result(false)
      }
      let apiEndPointOverride = arguments[IterableConstants.apiEndPointOverride] as? String
      
      internalInitialize(withApiKey: apiKey,
          config: config,
          version: version,
          apiEndPointOverride: apiEndPointOverride,
          result: result)
  }
                           
  func setEmail(call: FlutterMethodCall) {
    guard let arguments = call.arguments as? [String: Any],
     let email = arguments["email"] as? String else {
       return
     }
    //ITBInfo()
    IterableAPI.email = email
  } 

  func getEmail(result: @escaping FlutterResult) {
    //ITBInfo()
    result(IterableAPI.email ?? "")
  }

  func updateEmail(call: FlutterMethodCall, result: @escaping FlutterResult) {
    //ITBInfo()
    guard let arguments = call.arguments as? [String: Any],
     let email = arguments["email"] as? String else {
       return
     }
    IterableAPI.updateEmail(email, onSuccess: { data in
      result(data?.stringified)
    }, onFailure: { [weak self] reason, data in
        result(self?.failure(from: data, fallback: "Failed to update email. Reason: \(reason ?? "")"))
    })
  }

  func setUserId(call: FlutterMethodCall) {
    guard let arguments = call.arguments as? [String: Any],
     let userId = arguments["userId"] as? String else {
       return
     }
    //ITBInfo()
    IterableAPI.userId = userId
  } 

  func getUserId(result: @escaping FlutterResult) {
    //ITBInfo()
    result(IterableAPI.userId ?? "")
  }

  func updateUser(call: FlutterMethodCall, result: @escaping FlutterResult) {
    //ITBInfo()
    guard let arguments = call.arguments as? [String: Any],
     let dataFields = arguments["dataFields"] as? [AnyHashable: Any] else {
       return
     }
    let mergeNestedObjects = arguments["mergeNestedObjects"] as? Bool ?? true
    IterableAPI.updateUser(dataFields, mergeNestedObjects: mergeNestedObjects, onSuccess: { data in
      result(data?.stringified)
    }, onFailure: { [weak self] reason, data in
        result(self?.failure(from: data, fallback: "Failed to update user. Reason: \(reason ?? "")"))
    })
  }

  func setEmailAndUserId(call: FlutterMethodCall, result: @escaping FlutterResult) {
    //ITBInfo()
    guard let arguments = call.arguments as? [String: Any],
     let email = arguments["email"] as? String,
     let userId = arguments["userId"] as? String else {
       return
     }
    IterableAPI.updateEmail(email, onSuccess: { _ in
      IterableAPI.updateUser(["userId": userId], mergeNestedObjects: true, onSuccess: { data in 
        IterableAPI.userId = userId
        result(data?.stringified)
      }, onFailure: { [weak self] reason, data in 
        result(self?.failure(from: data, fallback: "Failed to set email/id. Reason: \(reason ?? "")"))
      })
    }, onFailure: { [weak self] reason, data in
        result(self?.failure(from: data, fallback: "Failed to set email/id. Reason: \(reason ?? "")"))
    })
  }

  func trackEvent(call: FlutterMethodCall) {
    guard let arguments = call.arguments as? [String: Any],
     let name = arguments["eventName"] as? String,
      let dataFields = arguments["dataFields"] as? [AnyHashable: Any] else {
      return
    }

    //ITBInfo()
        
    IterableAPI.track(event: name, dataFields: dataFields)
  }

  func updateCart(call: FlutterMethodCall) {
    guard let arguments = call.arguments as? [String: Any],
     let items = arguments["items"] as? [[AnyHashable: Any]] else {
      return
    }
    IterableAPI.updateCart(items: items.compactMap { CommerceItem.from($0) })
  }

  func trackPurchase(call: FlutterMethodCall) {
    guard let arguments = call.arguments as? [String: Any],
    let total = arguments["total"] as? NSNumber,
     let items = arguments["items"] as? [[AnyHashable: Any]] else {
      return
    }
    let dataFields = arguments["dataFields"] as? [AnyHashable: Any]
    IterableAPI.track(purchase: total, items: items.compactMap { CommerceItem.from($0) }, dataFields: dataFields)
  }

  func getLastPushPayload(result: @escaping FlutterResult) {
    //ITBInfo()
    result(IterableAPI.lastPushPayload?.stringified ?? "")
  }

    // MARK: Private
    private func internalInitialize(withApiKey apiKey: String,
                            config configDict: [AnyHashable: Any],
                            version: String,
                            apiEndPointOverride: String? = nil,
                            result: @escaping FlutterResult) {
      //ITBInfo()
        
      let launchOptions = createLaunchOptions(from: configDict)
      let iterableConfig = IterableConfig.from(configDict)
       if let urlHandlerPresent = configDict[IterableConstants.urlHandlerPresent] as? Bool, urlHandlerPresent == true {
           iterableConfig.urlDelegate = self
       }

       if let customActionHandlerPresent = configDict[IterableConstants.customActionHandlerPresent] as? Bool, customActionHandlerPresent == true {
           iterableConfig.customActionDelegate = self
       }

       if let inAppHandlerPresent = configDict[IterableConstants.inAppHandlerPresent] as? Bool, inAppHandlerPresent == true {
           iterableConfig.inAppDelegate = self
       }

       if let authHandlerPresent = configDict[IterableConstants.authHandlerPresent] as? Bool, authHandlerPresent {
           iterableConfig.authDelegate = self
       }
        
        DispatchQueue.main.async {
            IterableAPI.initialize2(apiKey: apiKey,
                                    launchOptions: launchOptions,
                                    config: iterableConfig,
                                    apiEndPointOverride: apiEndPointOverride) { completionResult in
                result(completionResult)
            }
            IterableAPI.setDeviceAttribute(name: IterableConstants.sdkVersion, value: version)
        }
    }
    
    private func createLaunchOptions(from config: [AnyHashable: Any]) -> [UIApplication.LaunchOptionsKey: Any]? {
        var result = [UIApplication.LaunchOptionsKey: Any]()
        result[UIApplication.LaunchOptionsKey.remoteNotification] = config[IterableConstants.remoteNotificationsEnabled]
        return result
    }

    private func failure(from data: Data?, fallback message: String) -> String {
      if let json = data?.stringified {
          return json
        } else {
          return message
        }
    }

}

extension SwiftIterablePlugin: IterableURLDelegate {
    public func handle(iterableURL url: URL, inContext context: IterableActionContext) -> Bool {
        // ITBInfo()
        
        // guard shouldEmit else {
        //     return false
        // }
        
        // let contextDict = ReactIterableAPI.contextToDictionary(context: context)
        // sendEvent(withName: EventName.handleUrlCalled.rawValue,
        //           body: ["url": url.absoluteString,
        //                  "context": contextDict])
        
        return true
    }

    private static func contextToDictionary(context: IterableActionContext) -> [AnyHashable: Any] {
        var result = [AnyHashable: Any]()
        
        let actionDict = actionToDictionary(action: context.action)
        result["action"] = actionDict
        result["source"] = context.source.rawValue
        
        return result
    }
    
    private static func actionToDictionary(action: IterableAction) -> [AnyHashable: Any] {
        var actionDict = [AnyHashable: Any]()
        
        actionDict["type"] = action.type
        
        if let data = action.data {
            actionDict["data"] = data
        }
        
        if let userInput = action.userInput {
            actionDict["userInput"] = userInput
        }
        
        return actionDict
    }
}

extension SwiftIterablePlugin: IterableCustomActionDelegate {
    public func handle(iterableCustomAction action: IterableAction, inContext context: IterableActionContext) -> Bool {
        // ITBInfo()
        
        // let actionDict = ReactIterableAPI.actionToDictionary(action: action)
        // let contextDict = ReactIterableAPI.contextToDictionary(context: context)
        
        // sendEvent(withName: EventName.handleCustomActionCalled.rawValue, body: ["action": actionDict, "context": contextDict])
        
        return true
    }
}

extension SwiftIterablePlugin: IterableInAppDelegate {
    public func onNew(message: IterableInAppMessage) -> InAppShowResponse {
        // ITBInfo()
        
        // guard shouldEmit else {
        //     return .show
        // }
        
        // let messageDict = message.toDict()
        // sendEvent(withName: EventName.handleInAppCalled.rawValue, body: messageDict)
        // let timeoutResult = inAppHandlerSemaphore.wait(timeout: .now() + 2.0)
        
        // if timeoutResult == .success {
        //     ITBInfo("inAppShowResponse: \(inAppShowResponse == .show)")
        //     return inAppShowResponse
        // } else {
        //     ITBInfo("timed out")
        //     return .show
        // }

        return .show
    }
}

extension SwiftIterablePlugin: IterableAuthDelegate {
    public func onAuthTokenRequested(completion: @escaping AuthTokenRetrievalHandler) {
        // ITBInfo()
        
    //     DispatchQueue.global(qos: .userInitiated).async {
    //         self.sendEvent(withName: EventName.handleAuthCalled.rawValue,
    //                   body: nil)
            
    //         let authTokenRetrievalResult = self.authHandlerSemaphore.wait(timeout: .now() + 30.0)
            
    //         if authTokenRetrievalResult == .success {
    //             ITBInfo("authTokenRetrieval successful")
                
    //             DispatchQueue.main.async {
    //                 completion(self.passedAuthToken)
    //             }
    //         } else {
    //             ITBInfo("authTokenRetrieval timed out")
                
    //             DispatchQueue.main.async {
    //                 completion(nil)
    //             }
    //         }
    //     }
    }
}
