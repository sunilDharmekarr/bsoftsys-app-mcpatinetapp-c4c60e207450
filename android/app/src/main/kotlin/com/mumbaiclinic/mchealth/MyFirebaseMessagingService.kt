package com.mumbaiclinic.mchealth

import android.annotation.SuppressLint
import android.app.ActivityManager
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.media.AudioManager
import android.media.RingtoneManager
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import androidx.core.app.NotificationCompat
import androidx.core.content.ContextCompat
import com.google.firebase.messaging.FirebaseMessagingService
import com.google.firebase.messaging.RemoteMessage

class MyFirebaseMessagingService: FirebaseMessagingService() {

    override fun onMessageReceived(message: RemoteMessage) {
        super.onMessageReceived(message)
        Utils.log("MyFirebaseMessagingService: onMessageReceived: ${message.data}")
        val isAppRunning = Constants.appState != Constants.APP_STATE_CLOSED //isAppRunning()
        Utils.log("MyFirebaseMessagingService: isAppRunning: $isAppRunning")
        Utils.log("MyFirebaseMessagingService: AppState: ${Constants.appState}")

        if (message.notification == null) {
            val channelId = message.data?.get(Constants.KEY_NOTIFICATION_CHANNEL_ID) ?: Constants.NOTIFICATION_NAME_VIDEO_CALL
            if (channelId != Constants.NOTIFICATION_NAME_VIDEO_CALL) {
                createNormalNotification(message)
            } else {
                if (Build.VERSION.SDK_INT >= 29) {
                    if (Constants.appState == Constants.APP_STATE_FOREGROUND || (Constants.appState == Constants.APP_STATE_BACKGROUND && Settings.canDrawOverlays(this)) ) {
                        openNotificationScreen(this, message)
                    } else {
                        createBackgroundNotification(message)
                    }
                } else {
                    openNotificationScreen(this, message)
                }
            }
        } else {
            createNormalNotification(message)
        }
    }

    private fun createBackgroundNotification(message: RemoteMessage) {

        val pm = this.getSystemService(Context.POWER_SERVICE) as PowerManager
        val isScreenOn = pm.isScreenOn
        if (!isScreenOn) {
            @SuppressLint("InvalidWakeLockTag") val wl = pm.newWakeLock(PowerManager.FULL_WAKE_LOCK or PowerManager.ACQUIRE_CAUSES_WAKEUP or PowerManager.ON_AFTER_RELEASE, "MyLock")
            wl.acquire(10000)
            @SuppressLint("InvalidWakeLockTag") val wl_cpu = pm.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "MyCpuLock")
            wl_cpu.acquire(10000)
        }

        val soundUri = Uri.parse("android.resource://" + applicationContext
                .packageName.toString() + "/" + R.raw.ring)
        val ringtoneUri = RingtoneManager.getActualDefaultRingtoneUri(applicationContext, RingtoneManager.TYPE_RINGTONE)
        createNotificationChannel(ringtoneUri ?: soundUri)

        val id = System.currentTimeMillis().toInt()

        val intent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK
            putExtra(Constants.KEY_NOTIFICATION_DATA, message)
            putExtra(Constants.KEY_NOTIFICATION_ID, id)
            putExtra(Constants.KEY_NOTIFICATION_TYPE, getNotificationType(message))
        }
        val pendingIntent: PendingIntent = PendingIntent.getActivity(this, id+100, intent, 0)

        val answerIntent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK
            putExtra(Constants.KEY_CALL_RESPONSE, true)
            putExtra(Constants.KEY_NOTIFICATION_ID, id)
            putExtra(Constants.KEY_NOTIFICATION_DATA, message)
            putExtra(Constants.KEY_NOTIFICATION_TYPE, getNotificationType(message))
        }
        val answerPendingIntent: PendingIntent = PendingIntent.getActivity(this, id+101, answerIntent, 0)

        val rejectIntent = Intent(this, MyMessageReceiver::class.java).apply {
            action = Constants.KEY_ACTION_RECEIVER
            putExtra(Constants.KEY_NOTIFICATION_ID, id)
        }
        val rejectPendingIntent: PendingIntent = PendingIntent.getBroadcast(this, id+102, rejectIntent, 0)


        var builder = NotificationCompat.Builder(this, "video_call")
                .setSmallIcon(R.drawable.notification_icon)
                .setContentTitle(message.data[Constants.KEY_TITLE])
                .setContentText(message.data[Constants.KEY_BODY])
                .setPriority(NotificationCompat.PRIORITY_HIGH)
                .setAutoCancel(true)
                .setContentIntent(pendingIntent)
                .setSound(soundUri, AudioManager.STREAM_RING)
                .setCategory(NotificationCompat.CATEGORY_CALL)
                .setFullScreenIntent(pendingIntent, true)
                .setOngoing(true)
                .setTimeoutAfter(30000)
                .setColor(ContextCompat.getColor(this, R.color.red))
                .addAction(android.R.drawable.ic_menu_call, "Answer", answerPendingIntent)
                .addAction(android.R.drawable.ic_menu_close_clear_cancel, "Reject", rejectPendingIntent)

        val notificationManager: NotificationManager =
                getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.notify(id, builder.build())
    }

    private fun createNormalNotification(message: RemoteMessage) {

        createNotificationChannel(null)

        val intent = Intent(this, MainActivity::class.java).apply {
            flags = Intent.FLAG_ACTIVITY_NEW_TASK
            putExtra(Constants.KEY_NOTIFICATION_DATA, message)
            putExtra(Constants.KEY_NOTIFICATION_TYPE, getNotificationType(message))
        }
        val pendingIntent: PendingIntent = PendingIntent.getActivity(this, System.currentTimeMillis().toInt(), intent, 0)

        var builder = NotificationCompat.Builder(this, "generic")
                .setSmallIcon(R.drawable.notification_icon)
                .setContentTitle(message.notification?.title ?: message.data[Constants.KEY_TITLE])
                .setContentText(message.notification?.body ?: message.data[Constants.KEY_BODY])
                .setStyle(NotificationCompat.BigTextStyle()
                        .bigText(message.notification?.body ?: ""))
                .setPriority(NotificationCompat.PRIORITY_MAX)
                .setAutoCancel(true)
                .setColor(ContextCompat.getColor(this, R.color.red))
                .setContentIntent(pendingIntent)

        val notificationManager: NotificationManager =
                getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.notify(System.currentTimeMillis().toInt(), builder.build())
    }

    private fun isAppRunning(): Boolean {
        val mngr: ActivityManager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
        val taskList: List<ActivityManager.RunningTaskInfo> = mngr.getRunningTasks(10)
        for (taskList1 in taskList) {
            if (taskList1.baseActivity?.className == MainActivity::class.java.name) {
                return true
            }
        }
        return false
    }

    private fun createNotificationChannel(soundUri: Uri?) {
        // Create the NotificationChannel, but only on API 26+ because
        // the NotificationChannel class is new and not in the support library
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val name = "Video Call"
            val descriptionText = "This channel is used to push the video call notifications."
            val importance = NotificationManager.IMPORTANCE_HIGH
            val channelVideo = NotificationChannel(Constants.NOTIFICATION_NAME_VIDEO_CALL, "Video Call", importance).apply {
                description = "This channel is used to push the video call notifications."
            }
            channelVideo.enableVibration(true)
            channelVideo.enableLights(true)
            channelVideo.vibrationPattern = longArrayOf(100, 200, 300, 400, 500, 400, 300, 200, 400)
            if (soundUri != null) {
                val audioAttributes: AudioAttributes = AudioAttributes.Builder()
                        .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                        .setUsage(AudioAttributes.USAGE_NOTIFICATION_RINGTONE)
                        .build()
                channelVideo.setSound(soundUri, audioAttributes)
            }

            val channelChat = NotificationChannel(Constants.NOTIFICATION_NAME_CHAT, "Chat Notifications", importance).apply {
                description = "This channel is used to push the chat notifications."
            }
            channelChat.enableVibration(true)
            channelChat.enableLights(true)

            val channelGeneric = NotificationChannel(Constants.NOTIFICATION_NAME_GENERIC, "Generic Notifications", importance).apply {
                description = "This channel is used to push the generic/promotional notifications."
            }
            channelGeneric.enableVibration(true)
            channelGeneric.enableLights(true)

            // Register the channel with the system
            val notificationManager: NotificationManager =
                    getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channelVideo)
            notificationManager.createNotificationChannel(channelChat)
            notificationManager.createNotificationChannel(channelGeneric)
        }
    }

    private fun openNotificationScreen(context: Context, message: RemoteMessage) {
        val pm = context.getSystemService(Context.POWER_SERVICE) as PowerManager
        val isScreenOn = pm.isScreenOn
        if (!isScreenOn) {
            @SuppressLint("InvalidWakeLockTag") val wl = pm.newWakeLock(PowerManager.FULL_WAKE_LOCK or PowerManager.ACQUIRE_CAUSES_WAKEUP or PowerManager.ON_AFTER_RELEASE, "MyLock")
            wl.acquire(10000)
            @SuppressLint("InvalidWakeLockTag") val wl_cpu = pm.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, "MyCpuLock")
            wl_cpu.acquire(10000)
        }
        //notificationManager.notify(0, notificationBuilder.build());
        val allowVisitor = Intent(context, MainActivity::class.java)
        allowVisitor.flags = Intent.FLAG_ACTIVITY_NEW_TASK
        allowVisitor.putExtra(Constants.KEY_NOTIFICATION_DATA, message)
        allowVisitor.putExtra(Constants.KEY_NOTIFICATION_TYPE, getNotificationType(message))
        context.startActivity(allowVisitor)
    }

    private fun getNotificationType(message: RemoteMessage): String {
        return if (message.notification != null) {
            getNotificationTypeFromNotification(message.notification)
        } else {
            message.data?.get(Constants.KEY_NOTIFICATION_CHANNEL_ID) ?: Constants.NOTIFICATION_NAME_VIDEO_CALL
        }
    }

    private fun getNotificationTypeFromNotification(notification: RemoteMessage.Notification?): String {
        if (notification != null) {
            if (notification.channelId == Constants.NOTIFICATION_NAME_CHAT) {
                return Constants.NOTIFICATION_NAME_CHAT
            } else if (notification.channelId == Constants.NOTIFICATION_NAME_GENERIC) {
                return Constants.NOTIFICATION_NAME_GENERIC
            } else if (notification.channelId == Constants.NOTIFICATION_NAME_VIDEO_CALL) {
                return Constants.NOTIFICATION_NAME_VIDEO_CALL
            }
        } else {
            return Constants.NOTIFICATION_NAME_VIDEO_CALL
        }

        return Constants.NOTIFICATION_NAME_GENERIC
    }
}