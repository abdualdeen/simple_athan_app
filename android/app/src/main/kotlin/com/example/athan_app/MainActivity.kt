package com.example.athan_app

import android.media.MediaPlayer
import android.media.RingtoneManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var player: MediaPlayer? = null
    private var channel: MethodChannel? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        channel = MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "athan_app/sound_preview"
        ).also {
            it.setMethodCallHandler { call, result ->
                when (call.method) {
                    "play" -> {
                        play(call.arguments as? String)
                        result.success(null)
                    }
                    "stop" -> {
                        stopPlayback()
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }
        }
    }

    private fun play(soundName: String?) {
        stopPlayback()
        val created = when (soundName) {
            "makkahAliMullah" -> MediaPlayer.create(this, R.raw.makkah_ali_mullah)
            "madinaMuhammadQassas" -> MediaPlayer.create(this, R.raw.madina_muhammad_qassas)
            "system" -> RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
                ?.let { MediaPlayer.create(this, it) }
            else -> null
        } ?: return

        created.setOnCompletionListener { mp ->
            if (mp === player) player = null
            mp.release()
            channel?.invokeMethod("onPreviewComplete", soundName)
        }
        created.start()
        player = created
    }

    private fun stopPlayback() {
        player?.let { current ->
            try {
                current.stop()
            } catch (_: IllegalStateException) {
                // The player was never started or is already stopped.
            }
            current.release()
        }
        player = null
    }

    override fun onDestroy() {
        stopPlayback()
        channel = null
        super.onDestroy()
    }
}
