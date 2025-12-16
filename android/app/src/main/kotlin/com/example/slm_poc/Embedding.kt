class EmbeddingWrapper {
    private lateinit var model: Model
    private lateinit var tokenizer: Tokenizer

    fun loadEmbeddingModel(path: String): Boolean {
        model = Model(path)
        tokenizer = Tokenizer(model)
        return true
    }

    fun getEmbedding(text: String): FloatArray {
        val tokens = tokenizer.encode(text)
        val session = model.createSession()
        val output = session.run(tokens).first().value as FloatArray
        return output
    }
}
