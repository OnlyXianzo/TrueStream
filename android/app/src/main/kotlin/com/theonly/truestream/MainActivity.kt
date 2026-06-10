package com.theonly.truestream

import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import com.chaquo.python.PyObject
import com.chaquo.python.Python
import com.chaquo.python.android.AndroidPlatform
import kotlinx.coroutines.*
import java.io.File

class MainActivity : FlutterActivity() {
    private val ENGINE_CHANNEL = "com.theonly.truestream/engine"
    private val PROGRESS_CHANNEL = "com.theonly.truestream/progress"

    private var eventSink: EventChannel.EventSink? = null
    private val scope = CoroutineScope(Dispatchers.Main + SupervisorJob())
    private var methodChannel: MethodChannel? = null
    private var sharedUrl: String? = null

    private fun handleSendText(intent: Intent?) {
        if (intent == null) return
        if (intent.action == Intent.ACTION_SEND && intent.type == "text/plain") {
            intent.getStringExtra(Intent.EXTRA_TEXT)?.let { sharedText ->
                val urlRegex = "(https?://[\\w\\d:#@%/;$~()'*&+-=\\?\\.\\!\\[\\]]+)".toRegex()
                val match = urlRegex.find(sharedText)
                if (match != null) {
                    sharedUrl = match.value
                    scope.launch(Dispatchers.Main) {
                        methodChannel?.invokeMethod("intent/shared_url", mapOf("url" to sharedUrl))
                    }
                }
            }
        }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        handleSendText(intent)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        if (!Python.isStarted()) {
            Python.start(AndroidPlatform(applicationContext))
        }
        setupChannels(flutterEngine)
        handleSendText(intent)
    }

    private fun setupChannels(flutterEngine: FlutterEngine) {
        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, ENGINE_CHANNEL)
        methodChannel = channel
        channel.setMethodCallHandler { call, result ->
            when (call.method) {
                "intent/get_shared" -> {
                    result.success(mapOf("url" to sharedUrl))
                    sharedUrl = null
                }
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
                    scope.launch(Dispatchers.IO) {
                        try {
                            val py = Python.getInstance()
                            val engine = py.getModule("truestream_engine")
                            val bootstrapResult = engine.callAttr("bootstrap")
                            val resultMap = pyTojava(bootstrapResult)
                            withContext(Dispatchers.Main) {
                                result.success(resultMap)
                            }
                        } catch (e: java.lang.Exception) {
                            withContext(Dispatchers.Main) {
                                result.error("ERROR_BOOTSTRAP_FAILED", e.message, e.message ?: e.toString())
                            }
                        }
                    }
                }
                "download/start" -> {
                    val url = call.argument<String>("url")
                    val downloadId = call.argument<String>("download_id")
                    val config = call.argument<Map<String, Any>>("config")
                    val networkType = call.argument<String>("network_type")

                    scope.launch(Dispatchers.IO) {
                        try {
                            val py = Python.getInstance()
                            val engine = py.getModule("truestream_engine")
                            
                            val startResult = engine.callAttr("start_download", url, downloadId, config, networkType)
                            val resultMap = pyTojava(startResult)
                            
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
                    scope.launch(Dispatchers.IO) {
                        try {
                            val py = Python.getInstance()
                            val engine = py.getModule("truestream_engine")
                            val cancelResult = engine.callAttr("cancel_download", downloadId)
                            val resultMap = pyTojava(cancelResult)
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
                    scope.launch(Dispatchers.IO) {
                        try {
                            val py = Python.getInstance()
                            val engine = py.getModule("truestream_engine")
                            val formatsResult = engine.callAttr("get_formats", url, config)
                            val resultMap = pyTojava(formatsResult)
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
                    scope.launch(Dispatchers.IO) {
                        try {
                            val py = Python.getInstance()
                            val engine = py.getModule("truestream_engine")
                            val playlistResult = engine.callAttr("get_playlist_info", url, config)
                            val resultMap = pyTojava(playlistResult)
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
                    scope.launch(Dispatchers.IO) {
                        try {
                            val py = Python.getInstance()
                            val engine = py.getModule("truestream_engine")
                            val resumeResult = engine.callAttr("scan_resume_candidates", cacheDir)
                            val resultMap = pyTojava(resumeResult)
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

    private fun pyTojava(obj: Any?): Any? {
        if (obj == null) return null
        if (obj is PyObject) {
            val typeName = try {
                obj.type().getAttr("__name__").toString()
            } catch (e: Exception) {
                ""
            }
            when (typeName) {
                "dict" -> {
                    val map = obj.asMap()
                    val result = mutableMapOf<String, Any?>()
                    for (entry in map.entries) {
                        result[entry.key.toString()] = pyTojava(entry.value)
                    }
                    return result
                }
                "list", "tuple" -> {
                    val list = obj.asList()
                    val result = mutableListOf<Any?>()
                    for (item in list) {
                        result.add(pyTojava(item))
                    }
                    return result
                }
                "str" -> return obj.toJava(String::class.java)
                "int" -> return obj.toJava(Long::class.java)
                "float" -> return obj.toJava(Double::class.java)
                "bool" -> return obj.toJava(Boolean::class.java)
                "NoneType" -> return null
                else -> {
                    return try {
                        val map = obj.asMap()
                        val result = mutableMapOf<String, Any?>()
                        for (entry in map.entries) {
                            result[entry.key.toString()] = pyTojava(entry.value)
                        }
                        result
                    } catch (e: Exception) {
                        try {
                            val list = obj.asList()
                            val result = mutableListOf<Any?>()
                            for (item in list) {
                                result.add(pyTojava(item))
                            }
                            result
                        } catch (e2: Exception) {
                            try {
                                obj.toJava(Any::class.java)
                            } catch (e3: Exception) {
                                obj.toString()
                            }
                        }
                    }
                }
            }
        } else if (obj is Map<*, *>) {
            val result = mutableMapOf<String, Any?>()
            for (entry in obj.entries) {
                result[entry.key.toString()] = pyTojava(entry.value)
            }
            return result
        } else if (obj is List<*>) {
            val result = mutableListOf<Any?>()
            for (item in obj) {
                result.add(pyTojava(item))
            }
            return result
        } else if (obj is Array<*>) {
            val result = mutableListOf<Any?>()
            for (item in obj) {
                result.add(pyTojava(item))
            }
            return result
        }
        return obj
    }

    @Suppress("UNCHECKED_CAST")
    private fun startProgressPolling(downloadId: String) {
        scope.launch(Dispatchers.IO) {
            val py = Python.getInstance()
            val downloader = py.getModule("truestream_engine.downloader")
            val rawDownloadsMap = downloader.get("_active_downloads")?.asMap()
            val downloads = rawDownloadsMap as? Map<Any?, Any?>
            val downloadInfo = downloads?.get(downloadId)?.let {
                (it as? PyObject)?.asMap()
            }
            val progressQueue = (downloadInfo as? Map<Any?, Any?>)?.get("progress_queue") as? PyObject
            val resultQueue = (downloadInfo as? Map<Any?, Any?>)?.get("result_queue") as? PyObject

            if (progressQueue == null || resultQueue == null) return@launch

            var isDone = false
            while (!isDone && coroutineContext.isActive) {
                val isEmpty = progressQueue.callAttr("empty").toJava(Boolean::class.java) as Boolean
                if (!isEmpty) {
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

                val isResultEmpty = resultQueue.callAttr("empty").toJava(Boolean::class.java) as Boolean
                if (!isResultEmpty) {
                    try {
                        val resultVal = resultQueue.callAttr("get_nowait")
                        val resultObj = pyTojava(resultVal) as? Map<*, *> ?: mapOf<Any?, Any?>()
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
