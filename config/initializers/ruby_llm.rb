RubyLLM.configure do |config|
  config.gemini_api_key = ENV["GOOGLE_AI_STUDIO"]
  config.default_model = "gemini-2.5-flash"
  config.openai_api_key = ENV["OPENAI_API_KEY"]
end
