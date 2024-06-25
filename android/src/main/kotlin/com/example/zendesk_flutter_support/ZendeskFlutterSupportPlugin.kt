package com.example.zendesk_flutter_support

import androidx.annotation.NonNull

import android.os.Bundle;
import android.view.View;
import android.app.Activity
import android.widget.Button;
import androidx.appcompat.app.AppCompatActivity;
import com.google.android.material.internal.ContextUtils.getActivity

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding

import com.zendesk.logger.Logger
import zendesk.core.AnonymousIdentity
import zendesk.core.Identity
import zendesk.core.Zendesk
import zendesk.support.*
import zendesk.support.requestlist.RequestListActivity
import zendesk.support.request.RequestActivity
import zendesk.answerbot.*
import zendesk.chat.*
import zendesk.classic.messaging.MessagingActivity

/** ZendeskFlutterSupportPlugin */
class ZendeskFlutterSupportPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var activity: Activity
  private lateinit var requestProvider: RequestProvider
  private lateinit var providerStore: ProviderStore

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "zendesk_flutter_support")
    channel.setMethodCallHandler(this)
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  override fun onDetachedFromActivity() {
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
      activity = binding.activity
  }

  override fun onDetachedFromActivityForConfigChanges() {
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when (call.method) {
      "getPlatformVersion" -> {
          result.success("Android ${android.os.Build.VERSION.RELEASE}")
      }
      "initialize" -> {
        initialize(call)
        result.success(true)
      }
      "setVisitorInfo" -> {
        setVisitorInfo(call)
        result.success(true)
      }
      "startChat" -> {
        startChat(call)
        result.success(true)
      }
      "startChatWithCondition" -> {
        startChatWithCondition(call)
        result.success(true)
      }
      "createTicket" -> {
        createTicket(call)
        result.success(true)
      }
      "openTicketHistory" -> {
        openTicketHistory(call)
        result.success(true)
      }
      // "addTags" -> {
      //   addTags(call)
      //   result.success(true)
      // }
      // "removeTags" -> {
      //   removeTags(call)
      //   result.success(true)
      // }
      else -> {
        result.notImplemented()
      }
    }
  }

  fun initialize(call: MethodCall) {
    // Logger.setLoggable(BuildConfig.DEBUG)
    val accountKey = call.argument<String>("accountKey") ?: ""
    val applicationId = call.argument<String>("appId") ?: ""
    val clientId = call.argument<String>("clientId") ?: ""
    val zendeskUrl = call.argument<String>("zendeskUrl") ?: ""

    Chat.INSTANCE.init(activity, accountKey, applicationId)
    Zendesk.INSTANCE.init(activity, zendeskUrl,applicationId,clientId);
    Support.INSTANCE.init(Zendesk.INSTANCE);
    AnswerBot.INSTANCE.init(Zendesk.INSTANCE, Support.INSTANCE);
    providerStore = Support.INSTANCE.provider()!!
    requestProvider = providerStore.requestProvider()
  }

  fun setVisitorInfo(call: MethodCall) {
    val name = call.argument<String>("name") ?: ""
    val email = call.argument<String>("email") ?: ""
    val phoneNumber = call.argument<String>("phoneNumber") ?: ""
    val department = call.argument<String>("department") ?: ""

    val profileProvider = Chat.INSTANCE.providers()?.profileProvider()
    val chatProvider = Chat.INSTANCE.providers()?.chatProvider()
    val visitorInfo = VisitorInfo.builder()
                                    .withName(name)
                                    .withEmail(email)
                                    .withPhoneNumber(phoneNumber) // numeric string
                                    .build()
    profileProvider?.setVisitorInfo(visitorInfo, null)
    chatProvider?.setDepartment(department, null)
    val identity = AnonymousIdentity.Builder()
        .withNameIdentifier(name)
        .withEmailIdentifier(email)
        .build();
    Zendesk.INSTANCE.setIdentity(identity);
    Support.INSTANCE.init(Zendesk.INSTANCE);
  }

  fun startChat(call: MethodCall) {
    val isPreChatFormEnabled = call.argument<Boolean>("isPreChatFormEnabled") ?: true
    val isAgentAvailabilityEnabled = call.argument<Boolean>("isAgentAvailabilityEnabled") ?: true
    val isChatTranscriptPromptEnabled = call.argument<Boolean>("isChatTranscriptPromptEnabled") ?: true
    val isOfflineFormEnabled = call.argument<Boolean>("isOfflineFormEnabled") ?: true
    val isChatEngineEnabled = call.argument<Boolean>("isChatEngineEnabled") ?: true
    val isSupportEngineEnabled = call.argument<Boolean>("isSupportEngineEnabled") ?: true
    val isAnswerBotEngineEnabled = call.argument<Boolean>("isAnswerBotEngineEnabled") ?: true
    val ticketTag = call.argument<List<String>>("ticketTag") ?: listOf<String>()
    val botName = call.argument<String>("botName") ?: "Chat Bot"
    val title = call.argument<String>("title") ?: "Contact Us"
    val ticketSubject = call.argument<String>("ticketSubject") ?: ""

    val chatConfigurationBuilder = ChatConfiguration.builder()
    chatConfigurationBuilder
        .withAgentAvailabilityEnabled(isAgentAvailabilityEnabled)
        .withTranscriptEnabled(isChatTranscriptPromptEnabled)
        .withOfflineFormEnabled(isOfflineFormEnabled)
        .withPreChatFormEnabled(isPreChatFormEnabled)
        .withChatMenuActions(ChatMenuAction.END_CHAT)
    val chatConfiguration = chatConfigurationBuilder.build()

    val requestConfiguration = RequestActivity.builder()
        .withRequestSubject(ticketSubject)
        .withTags(ticketTag)
        .config();

    val listOfEngine = listOf(AnswerBotEngine.engine(),ChatEngine.engine(),SupportEngine.engine())
    if (isAnswerBotEngineEnabled == false) {
      if(isChatEngineEnabled == false) {
        if(isSupportEngineEnabled == true) {
          MessagingActivity.builder()
            .withBotLabelString(botName)
            .withEngines(listOfEngine.get(2))
            .withMultilineResponseOptionsEnabled(true)
            .withToolbarTitle(title)
            .show(activity,chatConfiguration,requestConfiguration)
        }
      }else{
        if(isSupportEngineEnabled == true) {
          MessagingActivity.builder()
            .withBotLabelString(botName)
            .withEngines(listOfEngine.get(1),listOfEngine.get(2))
            .withMultilineResponseOptionsEnabled(true)
            .withToolbarTitle(title)
            .show(activity,chatConfiguration,requestConfiguration)
        }else{
          MessagingActivity.builder()
            .withBotLabelString(botName)
            .withEngines(listOfEngine.get(1))
            .withMultilineResponseOptionsEnabled(true)
            .withToolbarTitle(title)
            .show(activity,chatConfiguration,requestConfiguration)
        }
      }
    }else{
      if(isChatEngineEnabled == false) {
        if(isSupportEngineEnabled == true) {
          MessagingActivity.builder()
            .withBotLabelString(botName)
            .withEngines(listOfEngine.get(0),listOfEngine.get(2))
            .withMultilineResponseOptionsEnabled(true)
            .withToolbarTitle(title)
            .show(activity,chatConfiguration,requestConfiguration)
        }else{
          MessagingActivity.builder()
            .withBotLabelString(botName)
            .withEngines(listOfEngine.get(0))
            .withMultilineResponseOptionsEnabled(true)
            .withToolbarTitle(title)
            .show(activity,chatConfiguration,requestConfiguration)
        }
      }else{
        if(isSupportEngineEnabled == true) {
          MessagingActivity.builder()
            .withBotLabelString(botName)
            .withEngines(listOfEngine.get(0),listOfEngine.get(1),listOfEngine.get(2))
            .withMultilineResponseOptionsEnabled(true)
            .withToolbarTitle(title)
            .show(activity,chatConfiguration,requestConfiguration)
        }else{
          MessagingActivity.builder()
            .withBotLabelString(botName)
            .withEngines(listOfEngine.get(0),listOfEngine.get(1))
            .withMultilineResponseOptionsEnabled(true)
            .withToolbarTitle(title)
            .show(activity,chatConfiguration,requestConfiguration)
        }
      }
    }
  }

  fun startChatWithCondition(call: MethodCall) {
    val isPreChatFormEnabled = call.argument<Boolean>("isPreChatFormEnabled") ?: true
    val isAgentAvailabilityEnabled = call.argument<Boolean>("isAgentAvailabilityEnabled") ?: true
    val isChatTranscriptPromptEnabled = call.argument<Boolean>("isChatTranscriptPromptEnabled") ?: true
    val isOfflineFormEnabled = call.argument<Boolean>("isOfflineFormEnabled") ?: true
    val isChatEngineEnabled = call.argument<Boolean>("isChatEngineEnabled") ?: true
    val isSupportEngineEnabled = call.argument<Boolean>("isSupportEngineEnabled") ?: true
    val isAnswerBotEngineEnabled = call.argument<Boolean>("isAnswerBotEngineEnabled") ?: true
    val ticketTag = call.argument<List<String>>("ticketTag") ?: listOf<String>()
    val botName = call.argument<String>("botName") ?: "Chat Bot"
    val title = call.argument<String>("title") ?: "Contact Us"
    val ticketSubject = call.argument<String>("ticketSubject") ?: ""

    val chatConfigurationBuilder = ChatConfiguration.builder()
    chatConfigurationBuilder
        .withAgentAvailabilityEnabled(isAgentAvailabilityEnabled)
        .withTranscriptEnabled(isChatTranscriptPromptEnabled)
        .withOfflineFormEnabled(isOfflineFormEnabled)
        .withPreChatFormEnabled(isPreChatFormEnabled)
        .withChatMenuActions(ChatMenuAction.END_CHAT)
    val chatConfiguration = chatConfigurationBuilder.build()

    val requestConfiguration = RequestActivity.builder()
        .withRequestSubject(ticketSubject)
        .withTags(ticketTag)
        .config();

    val listOfEngine = listOf(AnswerBotEngine.engine(),ChatEngine.engine(),SupportEngine.engine())
    if (isAnswerBotEngineEnabled == false) {
      if(isChatEngineEnabled == false) {
        if(isSupportEngineEnabled == true) {
          MessagingActivity.builder()
            .withBotLabelString(botName)
            .withEngines(listOfEngine.get(2))
            .withMultilineResponseOptionsEnabled(true)
            .withToolbarTitle(title)
            .show(activity,chatConfiguration,requestConfiguration)
        }
      }else{
        if(isSupportEngineEnabled == true) {
          MessagingActivity.builder()
            .withBotLabelString(botName)
            .withEngines(listOfEngine.get(1),listOfEngine.get(2))
            .withMultilineResponseOptionsEnabled(true)
            .withToolbarTitle(title)
            .show(activity,chatConfiguration,requestConfiguration)
        }else{
          MessagingActivity.builder()
            .withBotLabelString(botName)
            .withEngines(listOfEngine.get(1))
            .withMultilineResponseOptionsEnabled(true)
            .withToolbarTitle(title)
            .show(activity,chatConfiguration,requestConfiguration)
        }
      }
    }else{
      if(isChatEngineEnabled == false) {
        if(isSupportEngineEnabled == true) {
          MessagingActivity.builder()
            .withBotLabelString(botName)
            .withEngines(listOfEngine.get(0),listOfEngine.get(2))
            .withMultilineResponseOptionsEnabled(true)
            .withToolbarTitle(title)
            .show(activity,chatConfiguration,requestConfiguration)
        }else{
          MessagingActivity.builder()
            .withBotLabelString(botName)
            .withEngines(listOfEngine.get(0))
            .withMultilineResponseOptionsEnabled(true)
            .withToolbarTitle(title)
            .show(activity,chatConfiguration,requestConfiguration)
        }
      }else{
        if(isSupportEngineEnabled == true) {
          MessagingActivity.builder()
            .withBotLabelString(botName)
            .withEngines(listOfEngine.get(0),listOfEngine.get(1),listOfEngine.get(2))
            .withMultilineResponseOptionsEnabled(true)
            .withToolbarTitle(title)
            .show(activity,chatConfiguration,requestConfiguration)
        }else{
          MessagingActivity.builder()
            .withBotLabelString(botName)
            .withEngines(listOfEngine.get(0),listOfEngine.get(1))
            .withMultilineResponseOptionsEnabled(true)
            .withToolbarTitle(title)
            .show(activity,chatConfiguration,requestConfiguration)
        }
      }
    }
  }

  fun openTicketHistory(call: MethodCall) {
    RequestListActivity.builder()
    .show(activity);
  }

  fun createTicket(call: MethodCall) {
    val tag = call.argument<List<String>>("tag") ?: listOf<String>()
    val subject = call.argument<String>("subject") ?: "Chat"
    val requestDescription = call.argument<String>("requestDescription") ?: "Hello"

    RequestActivity.builder()
    .withRequestSubject(subject)
    .withTags(tag)
    .show(activity);
  }

}
