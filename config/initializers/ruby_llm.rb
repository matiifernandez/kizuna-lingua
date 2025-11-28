RubyLLM.configure do |config|
  config.openai_api_key = ENV["GOOGLE_AI_STUDIO"]
  config.openai_api_base = "https://models.inference.ai.azure.com"
  # config.openai_api_key = ENV["OPENAI_API_KEY"]
end
