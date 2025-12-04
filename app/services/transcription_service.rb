class TranscriptionService
  def self.call(audio_source)
    new(audio_source).call
  end

  def initialize(audio_source)
    @audio_source = audio_source
  end

  def call
    audio_path = resolve_audio_path

    begin
      # Step 1: Transcribe audio with Gemini (handles multilingual)
      transcript = RubyLLM.transcribe(
        audio_path,
        model: "gemini-2.0-flash",
        prompt: "Transcribe this audio exactly word-for-word. Do not paraphrase or summarize. Include all languages spoken (English, Japanese, etc)."
      )

      Rails.logger.info "Gemini raw output: #{transcript.text}"

      raw_text = transcript.text.strip
      return { success: true, transcript: [] } if raw_text.empty?

      # Step 2: Use LLM to split into sentences (preserving exact text)
      format_prompt = <<~PROMPT
        Split the following transcription into individual sentences.
        Return ONLY a valid JSON array of strings, nothing else.

        IMPORTANT: Do NOT modify the text in any way.
        Keep all words, spacing, and punctuation exactly as given.
        Preserve Japanese in Japanese characters and English in Latin alphabet.

        Transcription:
        #{raw_text}
      PROMPT

      response = RubyLLM.chat(model: "gemini-2.5-flash").ask(format_prompt)
      clean_text = response.content.gsub(/```json\n?|```\n?/, '').strip
      parsed = JSON.parse(clean_text)

      { success: true, transcript: parsed }
    rescue JSON::ParserError => e
      # If LLM response isn't valid JSON, fall back to single-element array
      { success: true, transcript: [raw_text] }
    rescue ArgumentError => e
      { success: false, error: e.message }
    rescue => e
      { success: false, error: "Transcription failed: #{e.message}" }
    ensure
      cleanup_tempfile
    end
  end

  private

  def resolve_audio_path
    case @audio_source
    when String
      @audio_source
    when ActiveStorage::Blob
      download_blob_to_tempfile
    when ActiveStorage::Attached::One
      download_blob_to_tempfile(@audio_source.blob)
    when ActionDispatch::Http::UploadedFile
      @audio_source.tempfile.path
    else
      raise ArgumentError, "Unsupported audio source type: #{@audio_source.class}"
    end
  end

  def download_blob_to_tempfile(blob = @audio_source)
    @tempfile = Tempfile.new(["audio", File.extname(blob.filename.to_s)])
    @tempfile.binmode
    @tempfile.write(blob.download)
    @tempfile.rewind
    @tempfile.path
  end

  def cleanup_tempfile
    @tempfile&.close
    @tempfile&.unlink
  end
end
