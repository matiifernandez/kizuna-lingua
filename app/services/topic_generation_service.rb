class TopicGenerationService
  def self.call(user, topic_title)
    new(user, topic_title).call
  end

  def initialize(user, topic_title)
    @user = user
    @topic_title = topic_title
    @llm = RubyLLM.chat
  end

  def call
    partner = ([@user.partnership.user_one, @user.partnership.user_two] - [@user]).first || @user
    user_one_profile = { level: @user.learning_level, lang: @user.learning_language, native_language: @user.native_language }
    user_two_profile = { level: partner.learning_level, lang: partner.learning_language, native_language: partner.native_language }

    system_instructions = create_system_prompt
    user_request = create_user_prompt(user_one_profile, user_two_profile)

        llm_response = @llm.with_instructions(system_instructions).ask(user_request)

        return { success: false, error: "AI returned an empty response." } unless llm_response&.content

        parsed_data = JSON.parse(llm_response.content)
        @generated_image = generate_image
    persist_data(parsed_data)

  rescue JSON::ParserError => e
    { success: false, error: "AI returned invalid JSON." }
  rescue => e
    { success: false, error: "An unexpected error occurred: #{e.message}" }
  end

  private

  def persist_data(data)
    new_topic = nil
    challenge_data = data["challenge"]
    return { success: false, error: "Missing topic content in AI response." } unless data["topic_content"]
    return { success: false, error: "Missing single challenge object in AI response." } unless challenge_data
    ActiveRecord::Base.transaction do
      new_topic = Topic.create!(
        name: @topic_title,
        content: data["topic_content"]
      )
      if @generated_image
        new_topic.image.attach(
        io: @generated_image,
        filename: "#{@topic_title.parameterize}.png",
        content_type: "image/png"
        )
      end
      new_topic.challenges.create!(
        content: challenge_data["content"],
        conversation: challenge_data["conversation"]
        )
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

      PartnershipTopic.find_or_create_by!(
        partnership: @user.partnership,
        topic: new_topic
      ) do |pt|
        pt.status = "in progress"
      end
    end
    { success: true, topic: new_topic }
  end

  def generate_image
    prompt = "A simple, clean illustration representing the concept of '#{@topic_title}' for language learning. Minimalist style, suitable as a topic header image. Do not include any words or letters."
    image_chat = RubyLLM.chat(model: "gemini-2.5-flash-image")
    reply = image_chat.ask(prompt)
    reply.content[:attachments][0].source
  rescue => e
    Rails.logger.error("Image generation failed for topic '#{@topic_title}': #{e.message}")
    nil
  end

  def create_user_prompt(user_one_profile, user_two_profile)
    <<~PROMPT
    Generate comprehensive language learning content for the topic: "#{@topic_title}".

    CONTEXT FOR GENERATION:
    The challenges and grammar must accommodate the partnership's needs.
    - User 1 Profile: Native Language "#{user_one_profile[:native_language]}", Learning Level "#{user_one_profile[:level]}", Learning Language "#{user_one_profile[:lang]}"
    - User 2 Profile: Native Language "#{user_two_profile[:native_language]}", Learning Level "#{user_two_profile[:level]}", Learning Language "#{user_two_profile[:lang]}"

    Generate:
      1. A single `topic_content` summary in both English and Japanese.
      2. A single `challenge` object containing content for the **beginner, intermediate, and advanced** levels.
      3. An array `grammar_points` containing a comprehensive list of grammar points relevant to the topic. The list **MUST include at least 1, and up to 2, distinct grammar points for EACH of the three levels (beginner, intermediate, advanced) for BOTH English and Japanese.**
    CRITICAL INSTRUCTION:
    Ensure the generated content for the 'beginner', 'intermediate', and 'advanced' levels is relevant and challenging for the learning levels specified in the profiles above. The 'grammar_points' must cover both English and Japanese and include all levels from **beginner** to **advanced**.
    PROMPT
  end

  def create_system_prompt
    <<~PROMPT
    You are an expert language learning assistant. You MUST respond with a single, valid JSON object and nothing else. Do not include any text, explanations, or markdown formatting like ```json before or after the JSON object.

      The JSON object must follow this exact structure and all fields must be present in every response:
      {
        "topic_content": { "eng": "...", "jpn": "..." },
        "challenge": {
          "content": {
            "beginner": { "en": "...", "jp": "..." },
            "intermediate": { "en": "...", "jp": "..." },
            "advanced": { "en": "...", "jp": "..." }
          },
          "conversation": { "en": "...", "jp": "..." }
        },
        "grammar_points": [ { "title": "...", "level": "...", "explanation": "...", "examples": "...", "language": "..." } ]
      }
      CRITICAL RULE: NO FOREIGN CHARACTERS IN TITLES
      - The "title" of any grammar point MUST ONLY contain characters from the language of the grammar point (English/Latin alphabet for "english" points, Japanese characters for "japanese" points).
      - **DO NOT** include parenthetical translations or non-English/non-Japanese characters (e.g., Arabic, Russian, Korean, etc.) in the "title" field.

      CRITICAL RULES FOR "challenge" CONTENT:
      - The 'content' field MUST contain exactly three nested objects, one for each level: **beginner, intermediate, and advanced**.
      - For EACH nested level object, the content MUST contain parallel text for **both "en" (English) and "jp" (Japanese)**.
      - The instructions within the content MUST clearly outline the scenario, expected output, and mandatory functional language points tailored to that specific level.

      CRITICAL RULE: CHALLENGE LANGUAGE MAPPING
      - This rule maps the grammar requirements to the user's native language instruction:
          1. The **'en' instruction text** must list the **titles of the 'grammar_points' where "language": "japanese"** (This guides the Japanese learner).
          2. The **'jp' instruction text** must list the **titles of the 'grammar_points' where "language": "english"** (This guides the English learner).

      CRITICAL RULE: CHALLENGE-GRAMMAR DEPENDENCY
      - The functional language points listed in the "Must use:" requirement of the 'content' for a specific level MUST be sourced directly from the 'title' of the 'grammar_points' generated for that exact same level.

      CRITICAL RULES FOR "grammar_points":
      - The 'grammar_points' array MUST contain grammar for both "english" and "japanese" languages.
      - The array MUST contain a minimum of **one** and a maximum of **two** distinct grammar points for **EACH** of the following levels: **beginner, intermediate, and advanced**. (This means a total minimum of 6 points and a total maximum of 12 points).

      - The "explanation" for a grammar point **MUST** be written in the language **OPPOSITE** to the grammar point's "language" field:
          - If "language" is **"english"**, the "explanation" MUST be in **Japanese**.
          - If "language" is **"japanese"**, the "explanation" MUST be in **English**.
      PROMPT
  end
end
