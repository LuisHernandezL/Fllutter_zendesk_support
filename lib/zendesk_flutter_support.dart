
import 'package:flutter/services.dart';

import 'zendesk_flutter_support_platform_interface.dart';

class ZendeskFlutterSupport {
  static const MethodChannel _channel = MethodChannel('zendesk_flutter_support');
  Future<String?> getPlatformVersion() {
    return ZendeskFlutterSupportPlatform.instance.getPlatformVersion();
  }

  static Future<void> initialize(String accountKey, String appId, String clientId, String zendeskUrl) async {
    await _channel.invokeMethod<void>('initialize', {
      'accountKey': accountKey,
      'appId': appId,
      'clientId': clientId,
      'zendeskUrl': zendeskUrl
    });
  }

  static Future<void> setVisitorInfo({
    String? name,
    String? email,
    String? phoneNumber,
    String? department,
  }) async {
    await _channel.invokeMethod<void>('setVisitorInfo', {
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'department': department,
    });
  }

  static Future<void> startChat({
    bool isPreChatFormEnabled = true,
    bool isAgentAvailabilityEnabled = true,
    bool isChatTranscriptPromptEnabled = true,
    bool isOfflineFormEnabled = true,
    List<String>? ticketTag,
    String? ticketSubject,
    String? botName,
    String? title,
    bool isChatEngineEnabled = true,
    bool isSupportEngineEnabled = true,
    bool isAnswerBotEngineEnabled = true
  }) async {
    await _channel.invokeMethod<void>('startChat', {
      'isPreChatFormEnabled': isPreChatFormEnabled,
      'isAgentAvailabilityEnabled': isAgentAvailabilityEnabled,
      'isChatTranscriptPromptEnabled': isChatTranscriptPromptEnabled,
      'isOfflineFormEnabled': isOfflineFormEnabled,
      'ticketTag' : ticketTag,
      'ticketSubject' : ticketSubject,
      'botName' : botName,
      'title' : title,
      'isChatEngineEnabled' : isChatEngineEnabled,
      'isSupportEngineEnabled' : isSupportEngineEnabled,
      'isAnswerBotEngineEnabled' : isAnswerBotEngineEnabled,
    });
  }

  static Future<void> startChatWithCondition({
    bool isPreChatFormEnabled = true,
    bool isAgentAvailabilityEnabled = true,
    bool isChatTranscriptPromptEnabled = true,
    bool isOfflineFormEnabled = true,
    List<String>? ticketTag,
    String? ticketSubject,
    String? botName,
    String? title,
    bool isChatEngineEnabled = true,
    bool isSupportEngineEnabled = true,
    bool isAnswerBotEngineEnabled = true
  }) async {
    await _channel.invokeMethod<void>('startChatWithCondition', {
      'isPreChatFormEnabled': isPreChatFormEnabled,
      'isAgentAvailabilityEnabled': isAgentAvailabilityEnabled,
      'isChatTranscriptPromptEnabled': isChatTranscriptPromptEnabled,
      'isOfflineFormEnabled': isOfflineFormEnabled,
      'ticketTag' : ticketTag,
      'ticketSubject' : ticketSubject,
      'botName' : botName,
      'title' : title,
      'isChatEngineEnabled' : isChatEngineEnabled,
      'isSupportEngineEnabled' : isSupportEngineEnabled,
      'isAnswerBotEngineEnabled' : isAnswerBotEngineEnabled,
    });
  }

  static Future<void> createTicket({
    List<String>? tag,
    String? subject = "Chat",
    String? requestDescription = "Hello",
  }) async {
    await _channel.invokeMethod<void>('createTicket', {
      'tag' : tag,
      'subject' : subject,
      'requestDescription' : requestDescription,
    });
  }

  static Future<void> openTicketHistory() async {
    await _channel.invokeMethod<void>('openTicketHistory');
  }
}
