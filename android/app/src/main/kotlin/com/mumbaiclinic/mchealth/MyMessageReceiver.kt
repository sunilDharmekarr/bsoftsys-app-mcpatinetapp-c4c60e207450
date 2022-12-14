package com.mumbaiclinic.mchealth

import android.app.NotificationManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent

class MyMessageReceiver: BroadcastReceiver() {

    override fun onReceive(p0: Context?, p1: Intent?) {
        Utils.log("onReceive: $p1")
        p1?.let {
            if (it.action == Constants.KEY_ACTION_RECEIVER) {
                // cancel notification
                if (it.hasExtra(Constants.KEY_NOTIFICATION_ID)) {
                    val id = it.getIntExtra(Constants.KEY_NOTIFICATION_ID, -1);
                    if (id != -1) {
                        val notificationManager: NotificationManager =
                                p0?.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
                        notificationManager?.cancel(id)
                    }
                }
            }
        }
    }
}