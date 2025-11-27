class TopicGenerationService
  def self.call(user, topic_title)
    new(user, topic_title).call
  end

  def initialize(user, topic_title)
    @user = user
    @topic_title = topic_title
    @llm = LLM::OpenAI.new
  end

  # Main logic method
  def call
    messages = build_prompt
    response = @llm.chat(
      messages: messages,
      temperature: 0.7,
      response_format: { type: "json_object" }
    )
    parsed_response = response.completion
    return { success: false, error: "Failed to parse AI response" } unless parsed_response

    # Persist the data to the database (WE NEED THIS so the response from AI doesn't fail when saving and breaks the whole thing)
    persist_data(parsed_response)
  rescue JSON::ParserError => e
    { success: false, error: "AI returned invalid JSON: #{e.message}" }
  rescue ActiveRecord::RecordInvalid => e
    { success: false, error: "Failed to save records: #{e.message}" }
  end

  private

  # This is the method that I mentioned we need above.
  def persist_data(data)
    new_topic = nil
    ActiveRecord::Base.transaction do
      # Create the Topic
      new_topic = Topic.create!(
        name: @topic_title,
        content: data["topic_content"]
      )

      # Create the associated Challenges
      data["challenges"].each do |challenge_data|
        new_topic.challenges.create!(
          content: challenge_data["content"],
          conversation: challenge_data["conversation"]
        )
      end

      # Find or Create GrammarPoints and associate them with the Topic
      data["grammar_points"].each do |gp_data|
        # Use find_or_create_by to avoid duplicate grammar points
        grammar_point = GrammarPoint.find_or_create_by!(
          title: gp_data["title"],
          language: gp_data["language"],
          level: gp_data["level"]
        ) do |gp|
          gp.explanation = gp_data["explanation"]
          gp.examples = gp_data["examples"]
        end
        # Associate the grammar point with our new topic
        TopicGrammarPoint.create!(topic: new_topic, grammar_point: grammar_point)
      end
    end
    { success: true, topic: new_topic }
  end

  # Defines the AI's role and the required JSON output structure.
  def system_prompt
    <<~PROMPT
    You are an expert language learning assistant. Your task is to generate a topic, personalized challenges, and associated grammar points for two language learners.
    You MUST respond with a single, valid JSON object and nothing else.
    The JSON object must follow this exact structure:
    {
      "topic_content": { "eng": "...", "jpn": "..." },
      "challenges": [
        { "target_level": "...", "content": { "en": "...", "jp": "..." }, "conversation": { "en": "...", "jp": "..." } },
        { "target_level": "...", "content": { "en": "...", "jp": "..." }, "conversation": { "en": "...", "jp": "..." } }
      ],
      "grammar_points": [ { "title": "...", "level": "...", "explanation": "...", "examples": "...", "language": "..." } ]
    }
    PROMPT
  end

  # Constructs the specific user request with details for both partners.
  def user_prompt(user_one_profile, user_two_profile)
    <<~PROMPT
    Generate learning content based on an existing topic title for a language-learning partnership.

    - Topic Title: "#{@topic_title}"

    - User 1 Profile: Level "#{user_one_profile[:level]}", Learning Language "#{user_one_profile[:lang]}"
    - User 2 Profile: Level "#{user_two_profile[:level]}", Learning Language "#{user_two_profile[:lang]}"

    Based on the provided topic title, generate:
    1. A single `topic_content` summary in both English and Japanese.
    2. An array called `challenges` containing TWO separate challenge objects:
      - The first challenge MUST be tailored for the User 1 Profile. Include their level in the `target_level` field.
      - The second challenge MUST be tailored for the User 2 Profile. Include their level in the `target_level` field.
    3. An array of `grammar_points`:
      - 1-2 grammar points relevant to the User 1 Profile level and language.
      - 1-2 grammar points relevant to the User 2 Profile level and language.
    PROMPT
  end

  # Prepares the full message payload for the AI.
  def build_prompt
    partner = ([@user.partnership.user_one, @user.partnership.user_two] - [@user]).first

    # Handle case where there is no partner
    unless partner
      # You can decide how to handle this case. For now, we'll just use the single user's profile twice.
      partner = @user
    end

    user_one_profile = { id: @user.id, level: @user.learning_level, lang: @user.learning_language }
    user_two_profile = { id: partner.id, level: partner.learning_level, lang: partner.learning_language }

    [
      { role: "system", content: system_prompt },
      { role: "user", content: user_prompt(user_one_profile, user_two_profile) }
    ]
  end
end
