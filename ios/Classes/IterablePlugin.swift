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
    } else if call.method == "updateSubscriptions" {
      updateSubscriptions(call: call)
    } else if call.method == "setEmailAndUserId" {
      setEmailAndUserId(call: call, result: result)
    } else if call.method == "getAttributionInfo" {
      getAttributionInfo(result: result)
    } else if call.method == "setAttributionInfo" {
      setAttributionInfo(call: call)
    } eelse if call.method == "trackEvent" {
      trackEvent(call: call)
    } else if call.method == "updateCart" {
      updateCart(call: call)
    } else if call.method == "trackPurchase" {
      trackPurchase(call: call)
    } else if call.method == "getLastPushPayload" {
      getLastPushPayload(result: result)
    } else if call.method == "disableDeviceForCurrentUser" {
      disableDeviceForCurrentUser()
    } else if call.method == "getInAppMessages" {
      getInAppMessages(result: result)
    } else if call.method == "showMessage" {
      showMessage(call: call, result: result)
    } else if call.method == "removeMessage" {
      removeMessage(call: call)
    } else if call.method == "setReadForMessage" {
      setReadForMessage(call: call)
    } else if call.method == "getHtmlInAppContent" {
      getHtmlInAppContent(call: call, result: result)
    } else if call.method == "setAutoDisplayPaused" {
      setAutoDisplayPaused(call: call)
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

  func updateSubscriptions(call: FlutterMethodCall) {
    //ITBInfo()
    guard let arguments = call.arguments as? [String: Any] else {
       return
     }

     let campaignId = arguments["campaignId"] as? NSNumber
     let templateId = arguments["templateId"] as? NSNumber
     let emailListIds = arguments["emailListIds"] as? [NSNumber]
     let unsubscribedChannelIds = arguments["unsubscribedChannelIds"] as? [NSNumber]
     let unsubscribedMessageTypeIds = arguments["unsubscribedMessageTypeIds"] as? [NSNumber]
     let subscribedMessageTypeIds = arguments["subscribedMessageTypeIds"] as? [NSNumber]

      IterableAPI.updateSubscriptions(emailListIds,
                                      unsubscribedChannelIds: unsubscribedChannelIds,
                                      unsubscribedMessageTypeIds: unsubscribedMessageTypeIds,
                                      subscribedMessageTypeIds: subscribedMessageTypeIds,
                                      campaignId: campaignId,
                                      templateId: templateId)
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

  func getAttributionInfo(result: @escaping FlutterResult) {
    //ITBInfo()
    result(IterableAPI.attributionInfo.dictionary)
  }

  func setAttributionInfo(call: FlutterMethodCall) {
    guard let arguments = call.arguments as? [String: Any],
     let attrInfo = arguments["attributionInfo"] as? [AnyHashable: Any] else {
       return
     }
    IterableAPI.setAttributionInfo(IterableDecoder.decode(attrInfo))
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

  func disableDeviceForCurrentUser() {
    //ITBInfo()
    IterableAPI.disableDeviceForCurrentUser()
  }
    
    // MARK: In-App Manager methods
    func getInAppMessages(result: @escaping FlutterResult) {
        //ITBInfo()
        result(IterableAPI.inAppManager.getMessages().map { $0.dictionary })
    }

    func showMessage(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let messageId = arguments["messageId"] as? String,
              let consume = arguments["consume"] as? Bool else {
                  return
              }
        
        guard let message = IterableAPI.inAppManager.getMessage(withId: messageId) else {
            ITBError("Could not find message with id: \(messageId)")
            return
        }

        IterableAPI.inAppManager.show(message: message, consume: consume) { url in
            result(url.map({$0.absoluteString}))
        }
    }

    func removeMessage(call: FlutterMethodCall) {
        guard let arguments = call.arguments as? [String: Any],
              let messageId = arguments["messageId"] as? String,
              let location = arguments["location"] as? NSNumber,
              let source = arguments["source"] as? NSNumber else {
                  return
        }
        
        guard let message = IterableAPI.inAppManager.getMessage(withId: messageId) else {
            ITBError("Could not find message with id: \(messageId)")
            return
        }
        
        if let inAppDeleteSource = InAppDeleteSource.from(number: source) {
            IterableAPI.inAppManager.remove(message: message,
                                            location: InAppLocation.from(number: location),
                                            source: inAppDeleteSource)
        } else {
            IterableAPI.inAppManager.remove(message: message,
                                            location: InAppLocation.from(number: location))
        }
    }

    func setReadForMessage(call: FlutterMethodCall) {
        guard let arguments = call.arguments as? [String: Any],
              let messageId = arguments["messageId"] as? String,
              let read = arguments["read"] as? Bool else {
                  return
        }
        
        guard let message = IterableAPI.inAppManager.getMessage(withId: messageId) else {
            ITBError("Could not find message with id: \(messageId)")
            return
        }
        
        IterableAPI.inAppManager.set(read: read, forMessage: message)
    }

    func getHtmlInAppContent(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let arguments = call.arguments as? [String: Any],
              let messageId = arguments["messageId"] as? String else {
                  return
        }
        
        guard let message = IterableAPI.inAppManager.getMessage(withId: messageId) else {
            ITBError("Could not find message with id: \(messageId)")
            //result("Could not find message with id: \(messageId)")
            return
        }
        
        guard let content = message.content as? IterableHtmlInAppContent else {
            ITBError("Could not parse message content as HTML")
            //result("Could not parse message content as HTML")
            return
        }
        
        result(content.dictionary)
    }

    func setAutoDisplayPaused(call: FlutterMethodCall) {
        guard let arguments = call.arguments as? [String: Any],
              let paused = arguments["paused"] as? Bool else {
                  return
        }
        
        DispatchQueue.main.async {
            IterableAPI.inAppManager.isAutoDisplayPaused = paused
        }
    }

    func setInAppShowResponse(number: NSNumber) {
        ITBInfo()
        
//        self.inAppShowResponse = InAppShowResponse.from(number: number)
//        
//        inAppHandlerSemaphore.signal()
    }

    // MARK: Private
    private func internalInitialize(withApiKey apiKey: String,
                            config configDict: [AnyHashable: Any],
                            version: String,
                            apiEndPointOverride: String? = nil,
                            result: @escaping FlutterResult) {
      //ITBInfo()
        
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
                                    launchOptions: nil,
                                    config: iterableConfig,
                                    apiEndPointOverride: apiEndPointOverride) { completionResult in
                result(completionResult)
            }

            IterableAPI.setDeviceAttribute(name: IterableConstants.sdkVersion, value: version)
        }
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
