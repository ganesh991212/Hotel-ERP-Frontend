package com.hotelerp.hotel_erp

import android.app.NotificationChannel
import android.app.NotificationManager
import android.media.AudioAttributes
import android.net.Uri
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        createLoudChannels()
    }

    /**
     * Push channels for kitchen/floor alerts. The server targets channel "orders_loud" (new order) and
     * "orders_ready" is reserved for the ready chime. USAGE_ALARM plays on the alarm stream, so the alert is
     * loud even when the ringer/notification volume is low (it still respects Do Not Disturb unless the user
     * allows alarms). A channel's sound cannot change after creation; bump the id to change it.
     */
    private fun createLoudChannels() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) return
        val nm = getSystemService(NotificationManager::class.java) ?: return
        val attrs = AudioAttributes.Builder()
            .setUsage(AudioAttributes.USAGE_ALARM)
            .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
            .build()
        fun channel(id: String, name: String, raw: String) = NotificationChannel(
            id, name, NotificationManager.IMPORTANCE_HIGH
        ).apply {
            description = name
            setSound(Uri.parse("android.resource://$packageName/raw/$raw"), attrs)
            enableVibration(true)
            vibrationPattern = longArrayOf(0, 600, 300, 600, 300, 600)
            lockscreenVisibility = android.app.Notification.VISIBILITY_PUBLIC
        }
        nm.createNotificationChannel(channel("orders_loud", "New orders (loud)", "kitchen_alert"))
        nm.createNotificationChannel(channel("orders_ready", "Orders ready to serve", "ready_alert"))
    }
}
