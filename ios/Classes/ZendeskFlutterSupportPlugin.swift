import Flutter
import UIKit
import os.log
import ZendeskCoreSDK
import SupportSDK
import SupportProvidersSDK
import ChatSDK
import ChatProvidersSDK
import AnswerBotSDK
import AnswerBotProvidersSDK
import MessagingSDK
import MessagingAPI
import SDKConfigurations
import CommonUISDK

public class SwiftZendeskFlutterSupportPlugin: NSObject, FlutterPlugin {
    var chatAPIConfig: ChatAPIConfiguration?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "zendesk_flutter_support", binaryMessenger: registrar.messenger())
    let instance = SwiftZendeskFlutterSupportPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let dic = call.arguments as? Dictionary<String, Any>
        
        switch call.method {
        case "getPlatformVersion":
            result("iOS " + UIDevice.current.systemVersion)
        case "initialize":
            initialize(dictionary: dic!)
            result(true)
        case "setVisitorInfo":
            setVisitorInfo(dictionary: dic!)
            result(true)
        case "startChat":
            do {
                try startChat(dictionary: dic!)
            } catch _ {
                os_log("error:")
            }
            result(true)
        case "startChatWithCondition":
            do {
                try startChat(dictionary: dic!)
            } catch _ {
                os_log("error:")
            }
            result(true)
        case "openTicketHistory":
            listChat()
            result(true)
        case "createTicket":
            do {
                try createTicket(dictionary: dic!)
            } catch _ {
                os_log("error:")
            }
            result(true)
        // case "addTags":
        //     addTags(dictionary: dic!)
        //     result(true)
        // case "removeTags":
        //     removeTags(dictionary: dic!)
        //     result(true)
        default:
            result("iOS " + UIDevice.current.systemVersion)
        }
    }

  func initialize(dictionary: Dictionary<String, Any>) {
        guard let accountKey = dictionary["accountKey"] as? String,
              let appId = dictionary["appId"] as? String,
              let clientId = dictionary["clientId"] as? String,
              let zendeskUrl = dictionary["zendeskUrl"] as? String
        else { return }
        
        Zendesk.initialize(appId: appId, clientId: clientId, zendeskUrl: zendeskUrl)
        Support.initialize(withZendesk: Zendesk.instance)
        AnswerBot.initialize(withZendesk: Zendesk.instance, support: Support.instance!)
        
        Chat.initialize(accountKey: accountKey, appId: appId)
        initChatConfig()
    }

    func setVisitorInfo(dictionary: Dictionary<String, Any>) {
        guard let name = dictionary["name"] as? String,
              let email = dictionary["email"] as? String,
              let phoneNumber = dictionary["phoneNumber"] as? String
        else { return }
        let department = dictionary["department"] as? String ?? ""

        chatAPIConfig?.department = department
        chatAPIConfig?.visitorInfo = VisitorInfo(name: name, email: email, phoneNumber: phoneNumber)
        Chat.instance?.configuration = chatAPIConfig!

        let identity = Identity.createAnonymous(name: name, email: email)
        Zendesk.instance?.setIdentity(identity)
    }

    func startChat(dictionary: Dictionary<String, Any>) throws {
        guard let isPreChatFormEnabled = dictionary["isPreChatFormEnabled"] as? Bool,
              let isAgentAvailabilityEnabled = dictionary["isAgentAvailabilityEnabled"] as? Bool,
              let isChatTranscriptPromptEnabled = dictionary["isChatTranscriptPromptEnabled"] as? Bool,
              let isOfflineFormEnabled = dictionary["isOfflineFormEnabled"] as? Bool,
              let isChatEngineEnabled = dictionary["isChatEngineEnabled"] as? Bool,
              let isSupportEngineEnabled = dictionary["isSupportEngineEnabled"] as? Bool,
              let isAnswerBotEngineEnabled = dictionary["isAnswerBotEngineEnabled"] as? Bool
        else {return}
              let ticketTag = dictionary["ticketTag"] as? Array<String> ?? []
              let botName = dictionary["botName"] as? String ?? "Chat Bot"
              let ticketSubject = dictionary["ticketSubject"] as? String ?? ""
              let title = dictionary["title"] as? String ?? "Chat"
        
        CommonTheme.currentTheme.primaryColor = UIColor(red: 0.0/255, green: 175.0/255, blue: 65.0/255, alpha: 0.8)
        
        // Name for Bot messages
        let messagingConfiguration = MessagingConfiguration()
        let supportEngine = try SupportEngine.engine()
        let answerBotEngine = try AnswerBotEngine.engine()

        // Set up Bot
        messagingConfiguration.name = botName
        messagingConfiguration.isMultilineResponseOptionsEnabled = true
        
        let requestConfiguration = RequestUiConfiguration()
        requestConfiguration.tags = ticketTag
        requestConfiguration.subject = ticketSubject

        //Chat configuration
        let chatConfiguration = ChatConfiguration()
        chatConfiguration.chatMenuActions = []
        chatConfiguration.isPreChatFormEnabled = isPreChatFormEnabled
        chatConfiguration.isAgentAvailabilityEnabled = isAgentAvailabilityEnabled
        chatConfiguration.isChatTranscriptPromptEnabled = isChatTranscriptPromptEnabled
        chatConfiguration.isOfflineFormEnabled = isOfflineFormEnabled
        let chatEngine = try ChatEngine.engine()
        
        var listengines = [Engine]()

        if isAnswerBotEngineEnabled {
         listengines.append(answerBotEngine)
        }
        if isChatEngineEnabled {
            listengines.append(chatEngine)
        } 
        if isSupportEngineEnabled {
         listengines.append(supportEngine)
        }
        
        let viewController = try Messaging.instance.buildUI(engines: listengines, configs: [messagingConfiguration,requestConfiguration])
        viewController.title = title

        // Present view controller
        let rootViewController = UIApplication.shared.windows.filter({ (w) -> Bool in
            return w.isHidden == false
        }).first?.rootViewController
        presentViewController(rootViewController: rootViewController, view: viewController);
    }

    func startChatWithCondition(dictionary: Dictionary<String, Any>) throws {
        guard let isPreChatFormEnabled = dictionary["isPreChatFormEnabled"] as? Bool,
              let isAgentAvailabilityEnabled = dictionary["isAgentAvailabilityEnabled"] as? Bool,
              let isChatTranscriptPromptEnabled = dictionary["isChatTranscriptPromptEnabled"] as? Bool,
              let isOfflineFormEnabled = dictionary["isOfflineFormEnabled"] as? Bool,
              let isChatEngineEnabled = dictionary["isChatEngineEnabled"] as? Bool,
              let isSupportEngineEnabled = dictionary["isSupportEngineEnabled"] as? Bool,
              let isAnswerBotEngineEnabled = dictionary["isAnswerBotEngineEnabled"] as? Bool
        else {return}
              let ticketTag = dictionary["ticketTag"] as? Array<String> ?? []
              let botName = dictionary["botName"] as? String ?? "Chat Bot"
              let ticketSubject = dictionary["ticketSubject"] as? String ?? ""
              let title = dictionary["title"] as? String ?? "Chat"
        
        CommonTheme.currentTheme.primaryColor = UIColor(red: 0.0/255, green: 175.0/255, blue: 65.0/255, alpha: 0.8)
        
        // Name for Bot messages
        let messagingConfiguration = MessagingConfiguration()
        let supportEngine = try SupportEngine.engine()
        let answerBotEngine = try AnswerBotEngine.engine()

        // Set up Bot
        messagingConfiguration.name = botName
        messagingConfiguration.isMultilineResponseOptionsEnabled = true
        
        let requestConfiguration = RequestUiConfiguration()
        requestConfiguration.tags = ticketTag
        requestConfiguration.subject = ticketSubject

        //Chat configuration
        let chatConfiguration = ChatConfiguration()
        chatConfiguration.chatMenuActions = []
        chatConfiguration.isPreChatFormEnabled = isPreChatFormEnabled
        chatConfiguration.isAgentAvailabilityEnabled = isAgentAvailabilityEnabled
        chatConfiguration.isChatTranscriptPromptEnabled = isChatTranscriptPromptEnabled
        chatConfiguration.isOfflineFormEnabled = isOfflineFormEnabled
        let chatEngine = try ChatEngine.engine()
        
        var listengines = [Engine]()

        if isChatEngineEnabled {
            listengines.append(chatEngine)
        } 
        if isSupportEngineEnabled {
         listengines.append(supportEngine)
        }
        if isAnswerBotEngineEnabled {
         listengines.append(answerBotEngine)
        }

        let viewController = try Messaging.instance.buildUI(engines: listengines, configs: [messagingConfiguration])
        viewController.title = title

        // Present view controller
        let rootViewController = UIApplication.shared.windows.filter({ (w) -> Bool in
            return w.isHidden == false
        }).first?.rootViewController
        presentViewController(rootViewController: rootViewController, view: viewController);
    }

    func listChat()  {
        CommonTheme.currentTheme.primaryColor = UIColor(red: 0.0/255, green: 175.0/255, blue: 65.0/255, alpha: 0.8)
        
        let requestListController = RequestUi.buildRequestList()
        // Present list controller
        let rootViewController = UIApplication.shared.windows.filter({ (w) -> Bool in
            return w.isHidden == false
        }).first?.rootViewController
        presentViewController(rootViewController: rootViewController, view: requestListController);
    }

    func presentViewController(rootViewController: UIViewController?, view: UIViewController) {
        if (rootViewController is UINavigationController) {
            (rootViewController as! UINavigationController).pushViewController(view, animated: true)
        } else {
            let navigationController: UINavigationController! = UINavigationController(rootViewController: view)
            rootViewController?.present(navigationController, animated: true, completion: nil)
        }
    }

    func createTicket(dictionary: Dictionary<String, Any>) {
        guard let subject = dictionary["subject"] as? String,
              let requestDescription = dictionary["requestDescription"] as? String
        else { return }
              let tags = dictionary["tags"] as? Array<String> ?? []
        let provider = ZDKRequestProvider()

        var request = ZDKCreateRequest()
        request.subject = subject
        request.requestDescription = requestDescription
        request.tags = tags

        provider.createRequest(request) { result, error in
        }
    }

    func uiColorFromHex(rgbValue: Int) -> UIColor {
        let red =   CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue =  CGFloat(rgbValue & 0x0000FF) / 255.0
        let alpha = CGFloat(1.0)
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    func initChatConfig() {
        if (chatAPIConfig == nil) {
            chatAPIConfig = ChatAPIConfiguration()
        }
    }

}
