package com.example.slm_poc

import android.util.Log
import ai.onnxruntime.*
import org.json.JSONObject
import java.io.File

object EmbeddingEngine {

    private var env: OrtEnvironment? = null
    private var session: OrtSession? = null
    private var tokenizer: Tokenizer? = null
    private var isInitialized = false

    private const val TAG = "EmbeddingEngine"

    // ---------------------------------------------------------------
    // PUBLIC: Load model + tokenizer
    // ---------------------------------------------------------------
    fun loadModel(folderPath: String): Boolean {
        try {
            Log.i(TAG, "🔍 Loading embedding model from: $folderPath")

            val modelFile = File("$folderPath/model.onnx")
            val tokenizerFile = File("$folderPath/tokenizer.json")

            if (!modelFile.exists() || !tokenizerFile.exists()) {
                Log.e(TAG, "❌ Missing model or tokenizer json.")
                return false
            }

            env = OrtEnvironment.getEnvironment()

            val sessionOptions = OrtSession.SessionOptions().apply {
                setIntraOpNumThreads(2)
                setInterOpNumThreads(2)
                registerCustomOpLibrary("")
            }

            session = env!!.createSession(modelFile.absolutePath, sessionOptions)
            tokenizer = Tokenizer(tokenizerFile.readText())

            isInitialized = true
            Log.i(TAG, "✅ Embedding model initialized successfully")
            return true

        } catch (e: Exception) {
            Log.e(TAG, "❌ Failed to load embedding model: ${e.message}")
            isInitialized = false
            return false
        }
    }

    // ---------------------------------------------------------------
    // PUBLIC: Embed text → float[]  
    // ---------------------------------------------------------------
    fun embed(text: String): FloatArray {
        if (!isInitialized) {
            throw IllegalStateException("EmbeddingEngine not initialized")
        }

        try {
            // -------- Tokenize Input --------
            val encoded = tokenizer!!.encode(text)
            val inputIds = encoded.inputIds
            val attentionMask = encoded.attentionMask

            val env = env!!
            val session = session!!

            val shape = longArrayOf(1, inputIds.size.toLong())

            val inputTensor = OnnxTensor.createTensor(env, arrayOf(inputIds))
            val maskTensor = OnnxTensor.createTensor(env, arrayOf(attentionMask))

            val inputs = mapOf(
                "input_ids" to inputTensor,
                "attention_mask" to maskTensor
            )

            // -------- Run ONNX Inference --------
            val results = session.run(inputs)
            val output = results[0].value

            val embedding = when (output) {
                is Array<*> -> {
                    // shape = [1, seq_len, hidden]
                    val matrix = output[0] as Array<FloatArray>
                    meanPool(matrix)
                }
                is FloatArray -> {
                    // shape = [hidden]
                    output
                }
                else -> {
                    throw RuntimeException("Unexpected output type: ${output::class.java}")
                }
            }

            results.close()
            return embedding

        } catch (e: Exception) {
            Log.e(TAG, "❌ Embedding error: ${e.message}")
            throw e
        }
    }

    // ---------------------------------------------------------------
    // Mean Pooling for [1, seq_len, hidden] output
    // ---------------------------------------------------------------
    private fun meanPool(matrix: Array<FloatArray>): FloatArray {
        val dim = matrix[0].size
        val out = FloatArray(dim)

        for (vec in matrix) {
            for (i in 0 until dim) {
                out[i] += vec[i]
            }
        }
        for (i in 0 until dim) {
            out[i] /= matrix.size
        }
        return out
    }
}
