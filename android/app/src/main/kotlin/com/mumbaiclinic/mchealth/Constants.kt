package com.mumbaiclinic.mchealth

object Constants {

    val APP_STATE_CLOSED = 0;
    val APP_STATE_FOREGROUND = 1
    val APP_STATE_BACKGROUND = 2

    val NOTIFICATION_NAME_GENERIC = "generic"
    val NOTIFICATION_NAME_CHAT = "chat"
    val NOTIFICATION_NAME_VIDEO_CALL = "video_call"

    val KEY_NOTIFICATION_CHANNEL_ID = "android_channel_id"
    val KEY_NOTIFICATION_DATA = "notificationData"
    val KEY_NOTIFICATION_TYPE = "notificationType"
    val KEY_CALL_RESPONSE = "callResponse"
    val KEY_TITLE = "title"
    val KEY_BODY = "body"

    val KEY_ACTION_RECEIVER = "patient.mumbaiclinic.action.receiver.message"
    val KEY_NOTIFICATION_ID = "notificationId"

    val FCM_CHANNEL_NAME = "patient.mumbaiclinic/fcm"
    val APP_VERSION_CHANNEL_NAME = "patient.mumbaiclinic/appVersion"

    val METHOD_GET_OVERLAY_PERMISSION = "getOverlayPermission"
    val METHOD_HAS_OVERLAY_PERMISSION = "hasOverlayPermission"
    val METHOD_GET_DATA = "getMessageData"
    val METHOD_GET_TOKEN = "getToken"
    val METHOD_REMOVE_DATA = "removeMessageData"
    val METHOD_SEND_DATA = "onMessageReceived"

    var appState = APP_STATE_CLOSED
}