import Flutter
import UIKit
import IterableSDK

public class SwiftIterablePlugin: NSObject, FlutterPlugin {

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
      switch call.method {
      case "initialize":
        initialize(call: call, result: result)
      case "setEmail":
        setEmail(call: call)
      case "getEmail":
        getEmail(result: result)
      case "updateEmail":
        updateEmail(call: call, result: result)
      case "setUserId":
        setUserId(call: call)
      case "getUserId":
        getUserId(result: result)
      case "updateUser":
        updateUser(call: call, result: result)
      case "updateSubscriptions":
        updateSubscriptions(call: call)
      case "setEmailAndUserId":
        setEmailAndUserId(call: call, result: result)
      case "getAttributionInfo":
        getAttributionInfo(result: result)
      case "setAttributionInfo":
        setAttributionInfo(call: call)
      case "trackEvent":
        trackEvent(call: call)
      case "updateCart":
        updateCart(call: call)
      case "trackPurchase":
        trackPurchase(call: call)
      case "getLastPushPayload":
        getLastPushPayload(result: result)
      case "disableDeviceForCurrentUser":
        disableDeviceForCurrentUser()
      case "trackPushOpen":
        trackPushOpen(call: call)
      case "trackInAppOpen":
        trackInAppOpen(call: call)
      case "trackInAppClick":
        trackInAppClick(call: call)
      case "trackInAppClose":
        trackInAppClose(call: call)
      case "inAppConsume":
        inAppConsume(call: call)
      case "getInAppMessages":
        getInAppMessages(result: result)
      case "showMessage":
        showMessage(call: call, result: result)
      case "removeMessage":
        removeMessage(call: call)
      case "setReadForMessage":
        setReadForMessage(call: call)
      case "getHtmlContentForMessage":
        getHtmlInAppContent(call: call, result: result)
      case "handleAppLink":
        handleAppLink(call: call, result: result)
      case "setAutoDisplayPaused":
        setAutoDisplayPaused(call: call)
      case "setInAppShowResponse":
          setInAppShowResponse(call: call)
      case "setAuthToken":
          setAuthToken(call: call)
      case "wakeApp":
          // Android Only
          print("wakeApp")
      default:
        result(FlutterMethodNotImplemented)
      }
   
  }

  func initialize(call: FlutterMethodCall, result: @escaping FlutterResult) {
      guard let arguments = call.arguments as? [String: Any], 
      let apiKey = arguments[.apiKey] as? String,
      let config = arguments[.config] as? [String: Any],
      let version = arguments[.version] as? String else {
        // TODO log error
          return result(false)
      }

      // Not available in Android - should we keep?
      let apiEndPointOverride = arguments[.apiEndPointOverride] as? String
      
      internalInitialize(withApiKey: apiKey,
          config: config,
          version: version,
          apiEndPointOverride: apiEndPointOverride,
          result: result)
  }
                           
  func setEmail(call: FlutterMethodCall) {
    guard let arguments = call.arguments as? [String: Any] else {
       return
     }
    
    IterableAPI.email = arguments["email"] as? String
  } 

  func getEmail(result: @escaping FlutterResult) {
    result(IterableAPI.email ?? "")
  }

  func updateEmail(call: FlutterMethodCall, result: @escaping FlutterResult) {
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
    guard let arguments = call.arguments as? [String: Any] else {
       return
     }
    IterableAPI.userId = arguments["userId"] as? String
  } 

  func getUserId(result: @escaping FlutterResult) {
    result(IterableAPI.userId ?? "")
  }

  func updateUser(call: FlutterMethodCall, result: @escaping FlutterResult) {
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

  func updateSubscriptions(call: FlutterMethodCall) {
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

  func getAttributionInfo(result: @escaping FlutterResult) {
    result(IterableAPI.attributionInfo?.encoded)
  }

  func setAttributionInfo(call: FlutterMethodCall) {
    guard let arguments = call.arguments as? [String: Any],
     let attrInfo = arguments["attributionInfo"] as? [AnyHashable: Any],
      let campaignId = attrInfo["campaignId"] as? NSNumber,
      let templateId = attrInfo["templateId"] as? NSNumber,
      let messageId = attrInfo["messageId"] as? String else {
       return
     }
      IterableAPI.attributionInfo = IterableAttributionInfo(campaignId: campaignId, templateId: templateId, messageId: messageId)
  }

  func trackEvent(call: FlutterMethodCall) {
    guard let arguments = call.arguments as? [String: Any],
     let name = arguments["eventName"] as? String else {
      return
    }

    let dataFields = arguments["dataFields"] as? [AnyHashable: Any]
        
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
    result(IterableAPI.lastPushPayload as? [String: Any] ?? [String: Any]())
  }

  func disableDeviceForCurrentUser() {
    IterableAPI.disableDeviceForCurrentUser()
  }

  func trackPushOpen(call: FlutterMethodCall) {
    guard let arguments = call.arguments as? [String: Any],
    let campaignId = arguments["campaignId"] as? NSNumber,
     let templateId = arguments["templateId"] as? NSNumber,
     let messageId = arguments["messageId"] as? String,
     let appAlreadyRunning = arguments["appAlreadyRunning"] as? Bool else {
      return
    }
    let dataFields = arguments["dataFields"] as? [AnyHashable: Any]
    IterableAPI.track(pushOpen: campaignId,
                          templateId: templateId,
                          messageId: messageId,
                          appAlreadyRunning: appAlreadyRunning,
                          dataFields: dataFields)
  }

  func trackInAppOpen(call: FlutterMethodCall) {
    guard let arguments = call.arguments as? [String: Any],
    let messageId = arguments["messageId"] as? String,
    let message = IterableAPI.inAppManager.getMessage(withId: messageId),
     let location = arguments["location"] as? NSNumber else {
      return
    }
        
    IterableAPI.track(inAppOpen: message, location: InAppLocation.from(number: location))
  }

  func trackInAppClick(call: FlutterMethodCall) {
    guard let arguments = call.arguments as? [String: Any],
    let messageId = arguments["messageId"] as? String,
    let message = IterableAPI.inAppManager.getMessage(withId: messageId),
     let location = arguments["location"] as? NSNumber,
     let clickedUrl = arguments["clickedUrl"] as? String else {
      return
    }
    
    IterableAPI.track(inAppClick: message, location: InAppLocation.from(number: location), clickedUrl: clickedUrl)
  }

  func trackInAppClose(call: FlutterMethodCall) {
    guard let arguments = call.arguments as? [String: Any],
    let messageId = arguments["messageId"] as? String,
    let message = IterableAPI.inAppManager.getMessage(withId: messageId),
     let location = arguments["location"] as? NSNumber,
     let source = arguments["source"] as? NSNumber else {
      return
    }
    
    let clickedUrl = arguments["clickedUrl"] as? String 

    if let inAppCloseSource = InAppCloseSource.from(number: source) {
            IterableAPI.track(inAppClose: message,
                              location: InAppLocation.from(number: location),
                              source: inAppCloseSource,
                              clickedUrl: clickedUrl)
        } else {
            IterableAPI.track(inAppClose: message,
                              location: InAppLocation.from(number: location),
                              clickedUrl: clickedUrl)
        }
  }

  func inAppConsume(call: FlutterMethodCall) {
    guard let arguments = call.arguments as? [String: Any],
    let messageId = arguments["messageId"] as? String,
    let message = IterableAPI.inAppManager.getMessage(withId: messageId),
     let location = arguments["location"] as? NSNumber,
     let source = arguments["source"] as? NSNumber else {
      return
    }

    if let inAppDeleteSource = InAppDeleteSource.from(number: source) {
            IterableAPI.inAppConsume(message: message,
                              location: InAppLocation.from(number: location),
                              source: inAppDeleteSource)
        } else {
            IterableAPI.inAppConsume(message: message,
                              location: InAppLocation.from(number: location))
        }

  }
    
    // MARK: In-App Manager methods
    func getInAppMessages(result: @escaping FlutterResult) {
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
            return
        }
        
        guard let content = message.content as? IterableHtmlInAppContent else {
            ITBError("Could not parse message content as HTML")
            return
        }
        
        result(content.dictionary.stringified)
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

    func setInAppShowResponse(call: FlutterMethodCall) {
      guard let arguments = call.arguments as? [String: Any],
            let showResponseNumber = arguments["showResponse"] as? NSNumber else {
            return
       }
       self.inAppShowResponse = InAppShowResponse.from(number: showResponseNumber)
       inAppHandlerSemaphore.signal()
    }

    func handleAppLink(call: FlutterMethodCall, result: @escaping FlutterResult) {
      guard let arguments = call.arguments as? [String: Any],
      let appLink = arguments["link"] as? String, 
      let url = URL(string: appLink) else {
                  return
      }
      result(IterableAPI.handle(universalLink: url))
    }

    func setAuthToken(call: FlutterMethodCall) {
      guard let arguments = call.arguments as? [String: Any],
      let authToken = arguments["token"] as? String else {
          return
      }
      passedAuthToken = authToken
      authHandlerSemaphore.signal()
    }

    // MARK: Private

    // Handling in-app delegate
    private var inAppShowResponse = InAppShowResponse.show
    private var inAppHandlerSemaphore = DispatchSemaphore(value: 0)

    // Handling custom action delegate
    private var passedAuthToken: String?
    private var authHandlerSemaphore = DispatchSemaphore(value: 0)

    private func internalInitialize(withApiKey apiKey: String,
                            config configDict: [String: Any],
                            version: String,
                            apiEndPointOverride: String? = nil,
                            result: @escaping FlutterResult) {

      let iterableConfig = IterableConfig.from(configDict)
        if let urlHandlerPresent = configDict[.urlHandlerPresent] as? Bool, urlHandlerPresent == true {
           iterableConfig.urlDelegate = self
       }

       if let customActionHandlerPresent = configDict[.customActionHandlerPresent] as? Bool, customActionHandlerPresent == true {
           iterableConfig.customActionDelegate = self
       }

      if let inAppHandlerPresent = configDict[.inAppHandlerPresent] as? Bool, inAppHandlerPresent == true {
           iterableConfig.inAppDelegate = self
      }

       if let authHandlerPresent = configDict[.authHandlerPresent] as? Bool, authHandlerPresent {
           iterableConfig.authDelegate = self
       }
        
        DispatchQueue.main.async {
            IterableAPI.initialize2(apiKey: apiKey,
                                    launchOptions: nil,
                                    config: iterableConfig,
                                    apiEndPointOverride: apiEndPointOverride) { _ in
                result(true)
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

        SwiftIterablePlugin
          .channel?
          .invokeMethod("callListener",
                        arguments: ["url": url.absoluteString,
                                    "context": context.dictionary,
                                    ITBEmitter.emitterName: ITBEmitter.urlDelegate])
        return true
    }
}

extension SwiftIterablePlugin: IterableCustomActionDelegate {
    public func handle(iterableCustomAction action: IterableAction, inContext context: IterableActionContext) -> Bool {
        
        SwiftIterablePlugin
          .channel?
          .invokeMethod("callListener",
                        arguments: ["action": action.dictionary,
                        "context": context.dictionary,
                                    ITBEmitter.emitterName: ITBEmitter.customActionDelegate])
        return true
    }
}

extension SwiftIterablePlugin: IterableInAppDelegate {
    public func onNew(message: IterableInAppMessage) -> InAppShowResponse {
        var messageDict = message.dictionary
        messageDict[ITBEmitter.emitterName] =  ITBEmitter.inAppDelegate
        SwiftIterablePlugin.channel?.invokeMethod("callListener", arguments: messageDict)

        let timeoutResult = inAppHandlerSemaphore.wait(timeout: .now() + 2.0)
        
        guard timeoutResult == .success else {
            ITBInfo("timed out")
            return .show
        }
        
        ITBInfo("inAppShowResponse: \(inAppShowResponse == .show)")
        return inAppShowResponse
    }
}

extension SwiftIterablePlugin: IterableAuthDelegate {
    public func onAuthTokenRequested(completion: @escaping AuthTokenRetrievalHandler) {
        DispatchQueue.global(qos: .userInitiated).async {
            
            SwiftIterablePlugin
              .channel?
              .invokeMethod("callListener",
                            arguments: [ITBEmitter.emitterName: ITBEmitter.authDelegate])
            
            // 30 sec too long?
            let authTokenRetrievalResult = self.authHandlerSemaphore.wait(timeout: .now() + 30.0)
            
            if authTokenRetrievalResult == .success {
                ITBInfo("authTokenRetrieval successful")
                DispatchQueue.main.async {
                    completion(self.passedAuthToken)
                }
            } else {
                ITBInfo("authTokenRetrieval timed out")
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
    }
}
