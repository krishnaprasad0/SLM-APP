package com.example.slm_poc
import android.content.Context
import android.util.Log
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.io.File
import com.ml.shubham0204.sentence_embeddings.SentenceEmbedding

class EmbeddingHandler(private val context: Context) {

    private var embedder: SentenceEmbedding? = null
    private var isLoaded = false

    fun handle(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "initEmbedder" -> initEmbedder(call, result)
            "embedText" -> embedText(call, result)
            else -> result.notImplemented()
        }
    }

    private fun initEmbedder(call: MethodCall, result: MethodChannel.Result) {

        val modelPath = call.argument<String>("path")
        Log.e("DEBUG_TEST", "initEmbedder called $modelPath")

        if (modelPath.isNullOrEmpty()) {
            result.error("NULL_PATH", "Model path is null", null)
            return
        }

        val file = File(modelPath)
        if (!file.exists()) {
            result.error("NOT_FOUND", "Model not found: $modelPath", null)
            return
        }

        CoroutineScope(Dispatchers.IO).launch {
            try {
                val modelBytes = file.readBytes()

                val emb = SentenceEmbedding()

                emb.init(
                    modelPath,
                    modelBytes,
                    false,
                    "sentence_embedding",
                    true,
                    false,
                    false
                )

                embedder = emb
                isLoaded = true

                withContext(Dispatchers.Main) { result.success(true) }

            } catch (e: Exception) {
                Log.e("DEBUG_TEST", "init error: ${e.message}")
                withContext(Dispatchers.Main) {
                    result.error("INIT_ERROR", e.message, null)
                }
            }
        }
    }

    private fun embedText(call: MethodCall, result: MethodChannel.Result) {
        if (!isLoaded || embedder == null) {
            result.error("NOT_LOADED", "Embedder not initialized", null)
            return
        }

        val text = call.argument<String>("text") ?: ""
        if (text.isEmpty()) {
            result.error("EMPTY_TEXT", "Text empty", null)
            return
        }

        CoroutineScope(Dispatchers.IO).launch {
            try {
                val vec = embedder!!.encode(text)
                val list = vec.map { it.toDouble() }

                withContext(Dispatchers.Main) {
                    result.success(list)
                }

            } catch (e: Exception) {
                Log.e("DEBUG_TEST", "embed error: ${e.message}")
                withContext(Dispatchers.Main) {
                    result.error("EMBED_ERROR", e.message, null)
                }
            }
        }
    }
}
