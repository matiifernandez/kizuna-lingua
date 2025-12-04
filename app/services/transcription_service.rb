class TranscriptionService
  def self.call(audio_source)
    new(audio_source).call
  end

  def initialize(audio_source)
    @audio_source = audio_source
  end

  def call
    audio_path = resolve_audio_path
    prompt = <<~PROMPT
        Return a **JSON array** of sentences only.

        REQUIREMENTS:
        - Output must be valid JSON.
        - No explanation, no surrounding text.
        - Japanese must be in Japanese characters.
        - English must be in the Latin alphabet.

        Respond ONLY with the JSON array.
      PROMPT

    begin
      transcript = RubyLLM.transcribe(
        audio_path,
        model: "gemini-2.5-flash",
        prompt: prompt
      )

      # Clean markdown code fences and parse as JSON array
      clean_text = transcript.text.gsub(/```json\n?|```\n?/, '').strip
      parsed = JSON.parse(clean_text)

      { success: true, transcript: parsed }
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
