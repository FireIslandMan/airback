package com.airback

import android.app.Application
import android.content.Context
import android.os.Build
import android.provider.Settings
import androidx.core.content.edit
import dagger.hilt.android.HiltAndroidApp

@HiltAndroidApp
class AirPlayApp : Application() {

    override fun onCreate() {
        super.onCreate()
        seedServerName()
    }

    // First launch only: advertise under the name the user gave this device in system settings
    // (for example "Living Room TV") instead of a generic name. Two receivers on one LAN with
    // the same generic name collide in mDNS, and a sender that cached the old record connects
    // to the wrong device and spins.
    private fun seedServerName() {
        val prefs = getSharedPreferences(Prefs.NAME, Context.MODE_PRIVATE)
        if (prefs.contains(Prefs.SERVER_NAME.key)) return
        val name = deviceName()?.trim()?.takeIf { it.isNotBlank() && it.length <= 63 } ?: return
        prefs.edit { putString(Prefs.SERVER_NAME.key, name) }
    }

    private fun deviceName(): String? = try {
        val global = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N_MR1)
            Settings.Global.getString(contentResolver, Settings.Global.DEVICE_NAME) else null
        global ?: Settings.Secure.getString(contentResolver, "bluetooth_name")
    } catch (_: Exception) {
        null
    }
}
