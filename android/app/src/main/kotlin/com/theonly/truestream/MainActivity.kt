package com.theonly.truestream

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import com.chaquo.python.Python
import com.chaquo.python.android.AndroidPlatform
import kotlinx.coroutines.*
import java.io.File

class MainActivity : FlutterActivity() {
    private val ENGINE_CHANNEL = "com.theonly.truestream/engine"
    private val PROGRESS_CHANNEL = "com.theonly.truestream/progress"

    private var eventSink: EventChannel.EventSink? = null
    private val scope = CoroutineScope(Dispatchers.Main + SupervisorJob())

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, ENGINE_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "paths/set" -> {
                    val dataDir = call.argument<String>("data_dir")
                    val outputDir = call.argument<String>("output_dir")
                    val ffmpegPath = call.argument<String>("ffmpeg_path")
                    val cacheDir = call.argument<String>("cache_dir")
                    val cookiesPath = call.argument<String>("cookies_path")
                    val aria2cPath = call.argument<String>("aria2c_path")
                    val poToken = call.argument<String>("po_token")

                    // Ensure binaries are executable
                    if (ffmpegPath != null) {
                        val file = File(ffmpegPath)
                        if (file.exists()) {
                            file.setExecutable(true, false)
                        }
                    }
                    if (aria2cPath != null) {
                        val file = File(aria2cPath)
                        if (file.exists()) {
                            file.setExecutable(true, false)
                        }
                    }

                    initPython()

                    scope.launch(Dispatchers.IO) {
                        try {
                            val py = Python.getInstance()
                            val engine = py.getModule("truestream_engine")
                            engine.callAttr("set_paths", dataDir, outputDir, ffmpegPath, cacheDir, cookiesPath, aria2cPath, poToken)
                            withContext(Dispatchers.Main) {
                                result.success(mapOf("success" to true))
                            }
                        } catch (e: Exception) {
                            withContext(Dispatchers.Main) {
                                result.error("ERROR_INVALID_PATH", e.message, null)
                            }
                        }
                    }
                }
                "engine/bootstrap" -> {
                    initPython()
                    scope.launch(Dispatchers.IO) {
                        try {
                            val py = Python.getInstance()
                            val engine = py.getModule("truestream_engine")
                            val bootstrapResult = engine.callAttr("bootstrap")
                            val mapResult = bootstrapResult.asMap()
                            val resultMap = mapResult.mapKeys { it.key.toString() }.mapValues { it.value.toJava() }
                            withContext(Dispatchers.Main) {
                                result.success(resultMap)
                            }
                        } catch (e: java.lang.Exception) {
                            withContext(Dispatchers.Main) {
                                result.error("ERROR_BOOTSTRAP_FAILED", e.message, null)
                            }
                        }
                    }
                }
                "download/start" -> {
                    val url = call.argument<String>("url")
                    val downloadId = call.argument<String>("download_id")
                    val config = call.argument<Map<String, Any>>("config")
                    val networkType = call.argument<String>("network_type")

                    initPython()
                    scope.launch(Dispatchers.IO) {
                        try {
                            val py = Python.getInstance()
                            val engine = py.getModule("truestream_engine")
                            
                            val startResult = engine.callAttr("start_download", url, downloadId, config, networkType)
                            val resultMap = startResult.asMap().mapKeys { it.key.toString() }.mapValues { it.value.toJava() }
                            
                            startProgressPolling(downloadId!!)
                            
                            withContext(Dispatchers.Main) {
                                result.success(resultMap)
                            }
                        } catch (e: Exception) {
                            withContext(Dispatchers.Main) {
                                result.error("ERROR_START_FAILED", e.message, null)
                            }
                        }
                    }
                }
                "download/cancel" -> {
                    val downloadId = call.argument<String>("download_id")
                    initPython()
                    scope.launch(Dispatchers.IO) {
                        try {
                            val py = Python.getInstance()
                            val engine = py.getModule("truestream_engine")
                            val cancelResult = engine.callAttr("cancel_download", downloadId)
                            val resultMap = cancelResult.asMap().mapKeys { it.key.toString() }.mapValues { it.value.toJava() }
                            withContext(Dispatchers.Main) {
                                result.success(resultMap)
                            }
                        } catch (e: Exception) {
                            withContext(Dispatchers.Main) {
                                result.error("ERROR_CANCEL_FAILED", e.message, null)
                            }
                        }
                    }
                }
                "formats/get" -> {
                    val url = call.argument<String>("url")
                    val config = call.argument<Map<String, Any>>("config")
                    initPython()
                    scope.launch(Dispatchers.IO) {
                        try {
                            val py = Python.getInstance()
                            val engine = py.getModule("truestream_engine")
                            val formatsResult = engine.callAttr("get_formats", url, config)
                            val resultMap = formatsResult.asMap().mapKeys { it.key.toString() }.mapValues { it.value.toJava() }
                            withContext(Dispatchers.Main) {
                                result.success(resultMap)
                            }
                        } catch (e: Exception) {
                            withContext(Dispatchers.Main) {
                                result.error("ERROR_FORMATS_FAILED", e.message, null)
                            }
                        }
                    }
                }
                "playlist/info" -> {
                    val url = call.argument<String>("url")
                    val config = call.argument<Map<String, Any>>("config")
                    initPython()
                    scope.launch(Dispatchers.IO) {
                        try {
                            val py = Python.getInstance()
                            val engine = py.getModule("truestream_engine")
                            val playlistResult = engine.callAttr("get_playlist_info", url, config)
                            val resultMap = playlistResult.asMap().mapKeys { it.key.toString() }.mapValues { it.value.toJava() }
                            withContext(Dispatchers.Main) {
                                result.success(resultMap)
                            }
                        } catch (e: Exception) {
                            withContext(Dispatchers.Main) {
                                result.error("ERROR_PLAYLIST_FAILED", e.message, null)
                            }
                        }
                    }
                }
                "resume/scan" -> {
                    val cacheDir = call.argument<String>("cache_dir")
                    initPython()
                    scope.launch(Dispatchers.IO) {
                        try {
                            val py = Python.getInstance()
                            val engine = py.getModule("truestream_engine")
                            val resumeResult = engine.callAttr("scan_resume_candidates", cacheDir)
                            val resultMap = resumeResult.asMap().mapKeys { it.key.toString() }.mapValues { it.value.toJava() }
                            withContext(Dispatchers.Main) {
                                result.success(resultMap)
                            }
                        } catch (e: Exception) {
                            withContext(Dispatchers.Main) {
                                result.error("ERROR_RESUME_FAILED", e.message, null)
                            }
                        }
                    }
                }
                else -> result.notImplemented()
            }
        }

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, PROGRESS_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                }

                override fun onCancel(arguments: Any?) {
                    eventSink = null
                }
            }
        )
    }

    private fun initPython() {
        if (!Python.isStarted()) {
            Python.start(AndroidPlatform(applicationContext))
        }
    }

    @Suppress("UNCHECKED_CAST")
    private fun startProgressPolling(downloadId: String) {
        scope.launch(Dispatchers.IO) {
            val py = Python.getInstance()
            val downloader = py.getModule("truestream_engine.downloader")
            val activeDownloads = downloader.get("_active_downloads")?.asMap() as? Map<String, PyObject>
            val downloadInfo = activeDownloads?.get(downloadId)?.asMap() as? Map<String, PyObject>
            val progressQueue = downloadInfo?.get("progress_queue")
            val resultQueue = downloadInfo?.get("result_queue")

            if (progressQueue == null || resultQueue == null) return@launch

            var isDone = false
            while (!isDone && coroutineContext.isActive) {
                val empty = progressQueue.callAttr("empty").asBoolean()
                if (!empty) {
                    try {
                        val item = progressQueue.callAttr("get_nowait")
                        val jsonStr = item.toString()
                        withContext(Dispatchers.Main) {
                            eventSink?.success(jsonStr)
                        }
                    } catch (e: Exception) {
                        // ignore queue empty
                    }
                }

                val resultEmpty = resultQueue.callAttr("empty").asBoolean()
                if (!resultEmpty) {
                    try {
                        val resultVal = resultQueue.callAttr("get_nowait")
                        val resultObj: Map<String, Any?> = resultVal.asMap().mapKeys { it.key.toString() }.mapValues { it.value.toJava() }
                        val isSuccess = resultObj["success"] as? Boolean ?: false
                        val eventJson = if (isSuccess) {
                            "{\"type\": \"event\", \"event\": \"finished\", \"download_id\": \"$downloadId\"}"
                        } else {
                            val errType = resultObj["error_type"] ?: "ERROR_UNKNOWN"
                            val errMsg = resultObj["error_message"] ?: "Unknown error"
                            "{\"type\": \"event\", \"event\": \"error\", \"download_id\": \"$downloadId\", \"error_type\": \"$errType\", \"error_message\": \"$errMsg\", \"recoverable\": true}"
                        }
                        withContext(Dispatchers.Main) {
                            eventSink?.success(eventJson)
                        }
                        isDone = true
                    } catch (e: Exception) {
                        // ignore
                    }
                }

                if (!isDone) {
                    delay(100)
                }
            }
        }
    }

    override fun onDestroy() {
        scope.cancel()
        super.onDestroy()
    }
}
