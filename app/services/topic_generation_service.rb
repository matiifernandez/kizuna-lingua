class TopicGenerationService
  def self.call(user, topic_title)
    new(user, topic_title).call
  end

  def initialize(user, topic_title)
    @user = user
    @topic_title = topic_title
    @llm = RubyLLM.chat(model: ENV["AI_MODEL"])
  end

  def call
    partner = ([@user.partnership.user_one, @user.partnership.user_two] - [@user]).first || @user
    user_one_profile = { level: @user.learning_level, lang: @user.learning_language }
    user_two_profile = { level: partner.learning_level, lang: partner.learning_language }

    system_instructions = create_system_prompt
    user_request = create_user_prompt(user_one_profile, user_two_profile)

        llm_response = @llm.with_instructions(system_instructions).ask(user_request)

        return { success: false, error: "AI returned an empty response." } unless llm_response&.content

        parsed_data = JSON.parse(llm_response.content)
    persist_data(parsed_data)

  rescue JSON::ParserError => e
    { success: false, error: "AI returned invalid JSON." }
  rescue => e
    { success: false, error: "An unexpected error occurred: #{e.message}" }
  end

  private

  def persist_data(data)
    new_topic = nil
    ActiveRecord::Base.transaction do
      new_topic = Topic.create!(
        name: @topic_title,
        content: data["topic_content"]
      )
      data["challenges"].each do |challenge_data|
        new_topic.challenges.create!(
          content: challenge_data["content"],
          conversation: challenge_data["conversation"]
        )
      end
      data["grammar_points"].each do |gp_data|
        grammar_point = GrammarPoint.find_or_create_by!(
          title: gp_data["title"],
          language: gp_data["language"].downcase,
          level: gp_data["level"]
        ) do |gp|
          gp.explanation = gp_data["explanation"]
          gp.examples = gp_data["examples"]
        end
        TopicGrammarPoint.create!(topic: new_topic, grammar_point: grammar_point)
      end
    end
    { success: true, topic: new_topic }
  end

  def create_user_prompt(user_one_profile, user_two_profile)
    <<~PROMPT
    Generate learning content based on an existing topic title for a language-learning partnership.
    - Topic Title: "#{@topic_title}"
    - User 1 Profile: Native Language "#{user_one_profile[:native_language]}" Level "#{user_one_profile[:level]}", Learning Language "#{user_one_profile[:lang]}"
    - User 2 Profile: Native Language "#{user_two_profile[:native_language]}" Level "#{user_two_profile[:level]}", Learning Language "#{user_two_profile[:lang]}"
    Generate:
    1. A single `topic_content` summary in both English and Japanese.
    2. An array challenges with TWO separate, exciting, multi-step challenge objects:
      - The first challenge MUST be tailored for the User 1 Profile.
      - The second challenge MUST be tailored for the User 2 Profile.
    3. An array grammar_points containing a comprehensive list of grammar points relevant to the topic for ALL major levels the names of the levels must be: beginner, intermediate, advanced and fluent. For example, for
      Japanese.
    PROMPT
  end

  def create_system_prompt
    <<~PROMPT
    You are an expert language learning assistant. You MUST respond with a single, valid JSON object and nothing else. Do not include any text, explanations, or markdown formatting like ```json before or after the JSON object.
    The JSON object must follow this exact structure and all fields must be present in every response:
    {
      "topic_content": { "eng": "...", "jpn": "..." },
      "challenges": [
        { "target_level": "...", "content": { "en": "...", "jp": "..." }, "conversation": { "en": "...", "jp": "..." } },
        { "target_level": "...", "content": { "en": "...", "jp": "..." }, "conversation": { "en": "...", "jp": "..." } }
      ],
      "grammar_points": [ { "title": "...", "level": "...", "explanation": "...", "examples": "...", "language": "..." } ]
    }
    CRITICAL RULES FOR "grammar_points":
    - The "explanation" for a grammar point MUST be in the native language of the learner. For example, if the grammar point's "language" is 'japanese', its "explanation" MUST be
      in 'english'. If the grammar point's "language" is 'english', its "explanation" MUST be in 'japanese'.

      CRITICAL RULES FOR "challenges":
      - Challenges must be exciting, creative, and scenario-based. Avoid boring tasks like "translate this".
      - Good examples: "Imagine you are ordering food at a restaurant...", "Plan a weekend trip with a friend...", "Debate the pros and cons of...".
      - Challenges should contain multiple steps or questions to guide the user.
      PROMPT
  end
end
