package com.example.slm_poc

import ai.onnxruntime.genai.GenAIException
import ai.onnxruntime.genai.Generator
import ai.onnxruntime.genai.GeneratorParams
import ai.onnxruntime.genai.Model
import ai.onnxruntime.genai.Tokenizer
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.util.concurrent.atomic.AtomicBoolean

class GenAIWrapper {

    private var model: Model? = null
    private var tokenizer: Tokenizer? = null
    private val isStopped = AtomicBoolean(false)

    // 🔥 ASYNC model loading (prevents ANR)
    suspend fun loadModelAsync(modelPath: String): Boolean = withContext(Dispatchers.Default) {
        return@withContext try {
            val m = Model(modelPath)         // heavy work!
            val t = Tokenizer(m)

            model = m
            tokenizer = t
            true
        } catch (e: GenAIException) {
            e.printStackTrace()
            false
        }
    }

    fun stopGeneration() {
        isStopped.set(true)
    }

    // 🔥 INFERENCE (non-blocking, correct streaming)
    suspend fun inference(
        prompt: String,
        params: Map<String, Double>,
        onToken: (String) -> Unit
    ): Boolean {

        val model = model ?: return false
        val tokenizer = tokenizer ?: return false

        isStopped.set(false)

        return try {
            val stream = tokenizer.createStream()
            val generatorParams = GeneratorParams(model).apply {
                setSearchOption("max_length", 1000.0)
                params.forEach { (k, v) -> setSearchOption(k, v) }
            }
            val generator = Generator(model, generatorParams)

            try {
                generator.appendTokenSequences(tokenizer.encode(prompt))

                while (!generator.isDone && !isStopped.get()) {
                    for (tokenId in generator) {
                        if (isStopped.get()) break
                        val token = stream.decode(tokenId)

                        withContext(Dispatchers.Main) {
                            onToken(token)
                        }
                    }
                }

                !isStopped.get()
            } finally {
                generator.close()
                generatorParams.close()
                stream.close()
            }

        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }

    fun unload() {
        try {
            model?.close()
            tokenizer?.close()
        } catch (_: Exception) { }
        
        model = null
        tokenizer = null
    }
}
