package com.mumbaiclinic.mchealth

import android.util.Log

object Utils {

    fun log(msg: String?) {
        Log.d("MCM", msg ?: "null")
    }
}