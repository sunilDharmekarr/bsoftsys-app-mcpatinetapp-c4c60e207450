package com.mumbaiclinic.mchealth

import android.app.KeyguardManager
import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import android.view.WindowManager
import androidx.annotation.NonNull
import com.google.firebase.messaging.FirebaseMessaging
import com.google.firebase.messaging.RemoteMessage
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant


class MainActivity: FlutterActivity() {

    val ACTION_MANAGE_OVERLAY_PERMISSION_REQUEST_CODE = 5469

    var fcmMethodChannel: MethodChannel? = null

    var notificationData: RemoteMessage? = null

    var messageReceiver: MyMessageReceiver? = null

    var fcmToken: String? = ""

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
//        Utils.log("onCreate: In")
        clearNotification(intent)
        setDataFromIntent(intent, false)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        clearNotification(intent)
        setDataFromIntent(intent)
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        //super.configureFlutterEngine(flutterEngine)
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        setFCMChannel(flutterEngine)
        setAppVersionChannel(flutterEngine)
    }

    override fun onStart() {
        super.onStart()
        Constants.appState = Constants.APP_STATE_FOREGROUND
        //registerMessageReceiver()
    }

    override fun onStop() {
        super.onStop()
        Constants.appState = Constants.APP_STATE_BACKGROUND
        //unregisterMessageReceiver()
    }

    override fun onDestroy() {
        super.onDestroy()
        Constants.appState = Constants.APP_STATE_CLOSED
        clearScreenOnFlag()
    }

    private fun setDataFromIntent(intent: Intent?, sendData: Boolean = true) {
        Utils.log("setDataFromIntent: intent: $intent, extra: ${intent?.extras}")
        intent?.let {
            val notificationData = intent.getParcelableExtra<RemoteMessage>(Constants.KEY_NOTIFICATION_DATA)
            val notificationType = intent.getStringExtra(Constants.KEY_NOTIFICATION_TYPE) ?: Constants.NOTIFICATION_NAME_GENERIC
            val answer = intent.getBooleanExtra(Constants.KEY_CALL_RESPONSE, false)
            if (notificationType == Constants.NOTIFICATION_NAME_VIDEO_CALL) {
                setScreenOnFlag()
            }
            notificationData?.apply {
                data[Constants.KEY_NOTIFICATION_TYPE] = notificationType
                if (answer) {
                    data[Constants.KEY_CALL_RESPONSE] = answer.toString()
                }
            }
            Utils.log("setDataFromIntent: sendData: $sendData, data: $notificationData, type: $notificationType")
            if (sendData) {
                notificationData?.let {
                    sendData(it)
                }
            } else {
                this.notificationData = notificationData
            }
            intent.removeExtra(Constants.KEY_NOTIFICATION_DATA)
            intent.removeExtra(Constants.KEY_NOTIFICATION_TYPE)
            intent.removeExtra(Constants.KEY_NOTIFICATION_ID)
            intent.removeExtra(Constants.KEY_CALL_RESPONSE)
        }
    }

    private fun clearNotification(intent: Intent?) {
        intent?.let {
            if (it.hasExtra(Constants.KEY_NOTIFICATION_ID)) {
                val id = it.getIntExtra(Constants.KEY_NOTIFICATION_ID, -1);
                if (id != -1) {
                    val notificationManager: NotificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                    notificationManager.cancel(id)
                }
            }
        }
    }

    private fun setFCMChannel(@NonNull flutterEngine: FlutterEngine) {
        FirebaseMessaging.getInstance().token.addOnCompleteListener {
            Utils.log("setFCMChannel: FCM Token callback: ${it.result}")
            fcmToken = it.result
        }
        fcmMethodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, Constants.FCM_CHANNEL_NAME)
        fcmMethodChannel?.setMethodCallHandler {
            call, result ->
            Utils.log("setMethodCallHandler: ${call.method}")
            when (call.method) {
                Constants.METHOD_GET_DATA -> result.success(notificationData?.data)
                Constants.METHOD_GET_TOKEN -> result.success(fcmToken)
                Constants.METHOD_HAS_OVERLAY_PERMISSION -> result.success(hasOverlayPermission())
                Constants.METHOD_GET_OVERLAY_PERMISSION -> {
                    checkOverlyPermission()
                    result.success(true)
                }
                Constants.METHOD_REMOVE_DATA -> {
                    notificationData = null
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun sendData(message: RemoteMessage?) {
        Utils.log("sendData: ${message?.data}")
        message?.let {
            fcmMethodChannel?.invokeMethod(Constants.METHOD_SEND_DATA, message.data)
        }
    }

    private fun setScreenOnFlag() {
        Utils.log("ScreenFlag: turn on screen flag")
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
        } else {
            window.addFlags(WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD);
            window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON or WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON);
        }
        val keyguardManager = getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
           keyguardManager.requestDismissKeyguard(this, null)
        }
    }

    private fun clearScreenOnFlag() {
        Utils.log("ScreenFlag: turn off screen flag")
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(false)
            setTurnScreenOn(false)
        } else {
            window.clearFlags(WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED or WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD)
            window.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON or WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON)
        }
    }

    private fun checkOverlyPermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (!Settings.canDrawOverlays(this)) {
                val intent = Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
                        Uri.parse("package:$packageName"))
                intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                startActivityForResult(intent, ACTION_MANAGE_OVERLAY_PERMISSION_REQUEST_CODE)
            }
        }
    }

    private fun hasOverlayPermission(): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            return Settings.canDrawOverlays(this)
        }
        return true
    }

    private fun setAppVersionChannel(@NonNull flutterEngine: FlutterEngine) {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, Constants.APP_VERSION_CHANNEL_NAME).setMethodCallHandler {
            call, result ->
            when {
                call.method == "getAppVersionName" -> result.success(BuildConfig.VERSION_NAME)
                call.method == "getAppVersionCode" -> result.success(BuildConfig.VERSION_CODE)
                else -> result.notImplemented()
            }
        }
    }
}
