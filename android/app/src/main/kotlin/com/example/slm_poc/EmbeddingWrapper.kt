package com.example.slm_poc

import ai.onnxruntime.OnnxTensor
import ai.onnxruntime.OrtEnvironment
import ai.onnxruntime.OrtSession
import java.nio.LongBuffer

/**
 * Wrapper for a sentence-embedding ONNX model.
 * Flutter calls this via MethodChannel("embedding_channel"):
 *  - "loadEmbeddingModel"  -> init(modelPath)
 *  - "generateEmbedding"   -> embed(text) -> List<Double>
 */
class EmbeddingWrapper {

    private var env: OrtEnvironment? = null
    private var session: OrtSession? = null

    @Synchronized
    fun init(modelPath: String): Boolean {
        return try {
            close()
            val e = OrtEnvironment.getEnvironment()
            val s = e.createSession(modelPath, OrtSession.SessionOptions())
            env = e
            session = s
            true
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }

    /**
     * Convert a sentence into a fixed-size embedding vector.
     *
     * TODO: Replace tokenize() and input/output names with those
     * of your actual model (e.g. BGE / MiniLM / E5).
     */
    @Synchronized
    fun embed(text: String): FloatArray {
        val e = env ?: error("Embedding environment not initialized")
        val s = session ?: error("Embedding session not initialized")

        // ---- 1. Tokenize text -> ids, mask ----
        val tokenIds = tokenize(text)
        val attentionMask = LongArray(tokenIds.size) { 1L }

        val shape = longArrayOf(1, tokenIds.size.toLong())

        val inputIdsTensor = OnnxTensor.createTensor(
            e,
            LongBuffer.wrap(tokenIds),
            shape
        )
        val attentionMaskTensor = OnnxTensor.createTensor(
            e,
            LongBuffer.wrap(attentionMask),
            shape
        )

        val inputs = mapOf(
            // ⚠️ CHANGE THESE NAMES to match your ONNX model
            "input_ids" to inputIdsTensor,
            "attention_mask" to attentionMaskTensor
        )

        s.run(inputs).use { results ->
            // ⚠️ CHANGE THIS ACCESS to match your model output
            // Example: [1, hidden_size] -> FloatArray
            val first = results[0].value

            return when (first) {
                is Array<*> -> {
                    // e.g. [1, hidden] as Array<FloatArray>
                    val arr = first as Array<FloatArray>
                    arr[0]
                }
                is FloatArray -> first
                else -> error("Unexpected embedding output type: ${first!!::class.java}")
            }
        }
    }

    /**
     * Very naive fake tokenizer to make the code compile.
     * You must replace with a proper tokenizer matching your model.
     */
    private fun tokenize(text: String): LongArray {
        val tokens = text.trim().split(Regex("\\s+"))
        val ids = mutableListOf<Long>()
        ids.add(101L) // [CLS] example
        tokens.forEachIndexed { i, t ->
            // completely fake id mapping – replace with real tokenizer
            ids.add(1000L + (t.hashCode().toLong() and 0x7FFFFFFF) % 10000L)
        }
        ids.add(102L) // [SEP]
        return ids.toLongArray()
    }

    @Synchronized
    fun close() {
        try {
            session?.close()
        } catch (_: Exception) {
        }
        try {
            env?.close()
        } catch (_: Exception) {
        }
        session = null
        env = null
    }
}
