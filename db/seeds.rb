puts "Cleaning up the database..."
Topic.destroy_all
GrammarPoint.destroy_all
Partnership.destroy_all
Journal.destroy_all
User.destroy_all
puts "database cleaned"

puts "Creating Users"
john = User.create!(email: "test@mail.com", password: "123456", password_confirmation: "123456", name: "John KizunaEng", native_language: "english", learning_language: "japanese", learning_level: "intermediate")
aki = User.create!(email: "testjpn@mail.com", password: "123456", password_confirmation: "123456", name: "Aki KizunaJpn", native_language: "japanese", learning_language: "english", learning_level: "fluent")
partnership = Partnership.new
partnership.user_one = john
partnership.user_two = aki
partnership.save!
puts "Created Users: #{User.first.email}, #{User.last.email}"

puts "Creating Topics:"
routine = Topic.create!(
  name: "Daily Routines",
  content: {
    eng: "In this topic, you will talk about the activities you do every day—your mornings, evenings, and everything in between. This will help you describe habits, schedules, and the flow of your day in Japanese.",
    jpn: "このトピックでは、あなたが毎日行っていること、朝の習慣や夜の過ごし方などを話します。英語で自分のルーティンやスケジュールを自然に説明できるようになる練習です。"
    }
)

food = Topic.create!(
  name: "Food & Eating Out",
  content: {
    eng: "Use this topic to talk about your favorite foods, restaurants you enjoy, and meals you want to try. You’ll practice expressing preferences, describing flavors, and making simple recommendations in Japanese.",
    jpn: "このトピックでは、好きな食べ物やよく行くレストラン、食べてみたい料理について話します。英語で好みを伝えたり、味を表現したり、おすすめを言う練習になります。"
  }
)

work = Topic.create!(
  name: "Work & Productivity",
  content: {
    eng: "Use this topic to talk about your work habits, tasks you handle, and how you stay productive. This helps you describe responsibilities, workplace routines, and goals in Japanese.",
    jpn: "このトピックでは、仕事の習慣、担当している業務、生産性を保つ方法について話します。英語で職場での責任や日々のルーティン、目標を説明する練習になります。"
  }
)

social = Topic.create!(
  name: "Socializing & Relationships",
  content: {
    eng: "In this topic, you will talk about how you connect with others—friends, coworkers, partners—and how you spend time together. This helps you express feelings, preferences, and personal interactions in Japanese.",
    jpn: "このトピックでは、友人や同僚、パートナーなど他の人との関わり方や一緒に過ごす時間について話します。英語で気持ちや好み、人とのやり取りを説明する練習になります。"
  }
)

family = Topic.create!(
  name: "Family & Relationships",
  content: {
    eng: "In this topic, you’ll describe the important people in your life and talk about how you spend time together. This helps you practice describing relationships and explaining connections in Japanese.",
    jpn: "このトピックでは、あなたの家族や大切な人について紹介し、どのように一緒に過ごしているかを話します。英語で人間関係や家族構成を説明する練習になります。"
  }
)

hobbies = Topic.create!(
  name: "Hobbies & Free Time",
  content: {
    eng: "Talk about the activities you enjoy in your free time. Whether it's sports, music, games, or creative interests, this topic helps you express what you like to do and why in Japanese.",
    jpn: "このトピックでは、自由な時間に楽しんでいる趣味や活動について話します。スポーツでも音楽でもゲームでも、自分の好きなことを英語で説明し、その理由を伝える練習になります。"
  }
)

puts "Created #{Topic.all.length} Topics"

puts "adding projects to partnership"

routine_part = PartnershipTopic.create!(
  partnership_id: partnership.id,
  topic_id: routine.id
)

food_part = PartnershipTopic.create!(
  partnership_id: partnership.id,
  topic_id: food.id
)

work_part = PartnershipTopic.create!(
  partnership_id: partnership.id,
  topic_id: work.id
)

social_part = PartnershipTopic.create!(
  partnership_id: partnership.id,
  topic_id: social.id
)

puts "Creating Grammar points"

routine_jp_b = GrammarPoint.create!(
  title: "〜ます form",
  level: "beginner",
  explanation: "Use polite present tense to describe your daily actions.",
  examples: "7時に起きます。コーヒーを飲みます。",
  language: "japanese"
)

routine_jp_i = GrammarPoint.create!(
  title: "〜前に / 〜後で",
  level: "intermediate",
  explanation: "Use these to say 'before doing' or 'after doing' something.",
  examples: "寝る前に本を読みます。仕事の後で買い物します。",
  language: "japanese"
)

routine_jp_a = GrammarPoint.create!(
  title: "〜ようにしています",
  level: "advanced",
  explanation: "Use this to describe habits you intentionally try to maintain.",
  examples: "早く寝るようにしています。毎日運動するようにしています。",
  language: "japanese"
)

routine_jp_f = GrammarPoint.create!(
  title: "〜とは限らない",
  level: "fluent",
  explanation: "Use this to express nuance or exceptions about habits.",
  examples: "毎日忙しいとは限らない。早起きがいつも良いとは限らない。",
  language: "japanese"
)

food_jp_b = GrammarPoint.create!(
  title: "〜が好きです",
  level: "beginner",
  explanation: "Use this to say you like certain foods.",
  examples: "寿司が好きです。辛い食べ物が好きです。",
  language: "japanese"
)

food_jp_i = GrammarPoint.create!(
  title: "〜をおすすめします",
  level: "intermediate",
  explanation: "Use this to recommend food or restaurants.",
  examples: "このラーメンをおすすめします。ここは安くておいしいですよ。",
  language: "japanese"
)

food_jp_a = GrammarPoint.create!(
  title: "〜で作られています",
  level: "advanced",
  explanation: "Use this to explain ingredients.",
  examples: "これは豆腐で作られています。",
  language: "japanese"
)

food_jp_f = GrammarPoint.create!(
  title: "〜気分です",
  level: "advanced",
  explanation: "Use this to express what you feel like eating.",
  examples: "今日はパスタの気分です。甘いものの気分です。",
  language: "japanese"
)

work_jp_b = GrammarPoint.create!(
  title: "〜をします (to do ~)",
  level: "beginner",
  explanation: "A very common way to describe actions related to work or tasks. You attach を to the object and add します to express 'do'.",
  examples: "レポートをします。",
  language: "japanese"
)

work_jp_i = GrammarPoint.create!(
  title: "〜なければなりません (must / have to)",
  level: "intermediate",
  explanation: "Used to express obligation. It is more formal than 〜なきゃ and is commonly used in professional settings.",
  examples: "この仕事を終わらせなければなりません。",
  language: "japanese"
)

work_jp_a = GrammarPoint.create!(
  title: "〜ようにしています (I make an effort to ~)",
  level: "advanced",
  explanation: "Expresses a habit you intentionally try to maintain. Often used when talking about work routines or productivity habits.",
  examples: "毎日メモを取るようにしています。",
  language: "japanese"
)

work_jp_f = GrammarPoint.create!(
  title: "〜ことになっています (it is decided/expected that ~)",
  level: "fluent",
  explanation: "Used to describe official rules, company policies, or expected procedures. Common in workplace communication.",
  examples: "会議は毎週月曜日に行うことになっています。",
  language: "japanese"
)

social_jp_i = GrammarPoint.create!(
  title: "〜と思います (I think ~)",
  level: "intermediate",
  explanation: "Useful for expressing opinions during social interactions or discussions. Attach と思います after a casual sentence.",
  examples: "そのアイデアはいいと思います。",
  language: "japanese"
)

social_jp_a = GrammarPoint.create!(
  title: "〜てくれてありがとう (thank you for doing ~)",
  level: "advanced",
  explanation: "Used to express gratitude directly to someone for their action. Important for maintaining relationships in Japanese culture.",
  examples: "手伝ってくれてありがとう。",
  language: "japanese"
)

social_jp_f = GrammarPoint.create!(
  title: "〜ように感じます (I feel that ~)",
  level: "fluent",
  explanation: "A nuanced and natural way to express subtle impressions or personal feelings, often used in deeper conversations.",
  examples: "彼はとても親切な人のように感じます。",
  language: "japanese"
)

hobbies_jp_b = GrammarPoint.create!(
  title: "〜ています",
  level: "beginner",
  explanation: "Use this to describe ongoing or habitual actions.",
  examples: "働いています。日本語を勉強しています。",
  language: "japanese"
)

routine_en_b = GrammarPoint.create!(
  title: "I usually ___",
  level: "beginner",
  explanation: "日常的に行う習慣を表すときに使います。'usually' は頻度を表す副詞で、基本的に動詞の前に置かれます。",
  examples: "I usually drink coffee in the morning.",
  language: "english"
)

routine_en_i = GrammarPoint.create!(
  title: "I’m used to ___ing",
  level: "intermediate",
  explanation: "過去からの習慣が身についており、それに慣れていることを表します。後ろには動名詞（動詞＋ing）が続きます。",
  examples: "I'm used to waking up early.",
  language: "english"
)

routine_en_a = GrammarPoint.create!(
  title: "I make it a habit to ___",
  level: "advanced",
  explanation: "意識的に習慣化している行動を丁寧に説明する表現です。フォーマルな場面でも使えます。",
  examples: "I make it a habit to review my schedule every night.",
  language: "english"
)

routine_en_f = GrammarPoint.create!(
  title: "I tend to ___",
  level: "fluent",
  explanation: "特定の傾向やよくやってしまう行動を自然な英語で表す表現です。ネイティブが日常的によく使用します。",
  examples: "I tend to work late when I’m focused on a project.",
  language: "english"
)

food_en_b = GrammarPoint.create!(
  title: "I like ___",
  level: "beginner",
  explanation: "好きな食べ物や飲み物を表す基本的な表現。動詞を続ける場合は動名詞（～ing形）になります。",
  examples: "I like sushi.",
  language: "english"
)

food_en_i = GrammarPoint.create!(
  title: "I’d like to ___",
  level: "intermediate",
  explanation: "丁寧な依頼や希望を表します。レストランで注文するときにもよく使われます。",
  examples: "I'd like to order the pasta.",
  language: "english"
)

food_en_a = GrammarPoint.create!(
  title: "I'm craving ___",
  level: "advanced",
  explanation: "強く何かを食べたい気分を表す自然でネイティブらしい表現です。",
  examples: "I'm craving something spicy.",
  language: "english"
)

food_en_f = GrammarPoint.create!(
  title: "I'm in the mood for ___",
  level: "fluent",
  explanation: "「～の気分だ」というニュアンスで、食べたいものを柔らかく表現します。ネイティブがよく使う自然な言い回しです。",
  examples: "I'm in the mood for ramen tonight.",
  language: "english"
)

work_en_b = GrammarPoint.create!(
  title: "I have to ___",
  level: "beginner",
  explanation: "義務やしなければならないことを表します。日常会話や仕事でよく使用されます。",
  examples: "I have to finish this report.",
  language: "english"
)

work_en_i = GrammarPoint.create!(
  title: "I'm working on ___",
  level: "intermediate",
  explanation: "現在取り組んでいる仕事やプロジェクトを説明するときに使います。",
  examples: "I'm working on a new presentation.",
  language: "english"
)

work_en_f = GrammarPoint.create!(
  title: "I’ve been meaning to ___",
  level: "fluent",
  explanation: "「前から～しようと思っていた」という自然で流暢な表現で、先延ばしにしてきたことを述べるときに使います。",
  examples: "I've been meaning to update my portfolio.",
  language: "english"
)

work_en_a = GrammarPoint.create!(
  title: "I’m responsible for ___",
  level: "advanced",
  explanation: "職務内容や担当業務を説明する際の丁寧でビジネス向けの表現です。",
  examples: "I'm responsible for managing our marketing team.",
  language: "english"
)

social_en_b = GrammarPoint.create!(
  title: "I want to ___",
  level: "beginner",
  explanation: "したいことや希望を伝える最も基本的な表現です。",
  examples: "I want to meet new people.",
  language: "english"
)

social_en_i = GrammarPoint.create!(
  title: "I get along with ___",
  level: "intermediate",
  explanation: "人間関係が良好であることを説明する際の表現。人との相性の話をする時によく使われます。",
  examples: "I get along with my coworkers.",
  language: "english"
)

social_en_a = GrammarPoint.create!(
  title: "I appreciate ___",
  level: "advanced",
  explanation: "相手への感謝や行動に対する評価を丁寧に伝える表現です。人間関係を円滑にする自然な言い回しです。",
  examples: "I appreciate your help with this project.",
  language: "english"
)

social_en_f = GrammarPoint.create!(
  title: "I value ___",
  level: "fluent",
  explanation: "人との関係や大切にしていることを深く表現する語彙力の高い表現です。",
  examples: "I value honest communication.",
  language: "english"
)

puts "Generated #{GrammarPoint.all.length} Grammar points"

puts "Adding Grammar points to topics"

routine1 = TopicGrammarPoint.create!(
  topic_id: routine.id,
  grammar_point_id: routine_en_a.id
)

routine2 = TopicGrammarPoint.create!(
  topic_id: routine.id,
  grammar_point_id: routine_en_b.id
)

routine3 = TopicGrammarPoint.create!(
  topic_id: routine.id,
  grammar_point_id: routine_en_i.id
)

routine4 = TopicGrammarPoint.create!(
  topic_id: routine.id,
  grammar_point_id: routine_en_f.id
)

routine5 = TopicGrammarPoint.create!(
  topic_id: routine.id,
  grammar_point_id: routine_jp_a.id
)

routine6 = TopicGrammarPoint.create!(
  topic_id: routine.id,
  grammar_point_id: routine_jp_b.id
)

routine7 = TopicGrammarPoint.create!(
  topic_id: routine.id,
  grammar_point_id: routine_jp_f.id
)

routine8 = TopicGrammarPoint.create!(
  topic_id: routine.id,
  grammar_point_id: routine_jp_i.id
)

food1 = TopicGrammarPoint.create!(
  topic_id: food.id,
  grammar_point_id: food_en_a.id
)

food2 = TopicGrammarPoint.create!(
  topic_id: food.id,
  grammar_point_id: food_en_b.id
)

food3 = TopicGrammarPoint.create!(
  topic_id: food.id,
  grammar_point_id: food_en_f.id
)

food4 = TopicGrammarPoint.create!(
  topic_id: food.id,
  grammar_point_id: food_en_i.id
)

food5 = TopicGrammarPoint.create!(
  topic_id: food.id,
  grammar_point_id: food_jp_a.id
)

food6 = TopicGrammarPoint.create!(
  topic_id: food.id,
  grammar_point_id: food_jp_b.id
)

food7 = TopicGrammarPoint.create!(
  topic_id: food.id,
  grammar_point_id: food_jp_f.id
)

food8 = TopicGrammarPoint.create!(
  topic_id: food.id,
  grammar_point_id: food_jp_i.id
)

work1 = TopicGrammarPoint.create!(
  topic_id: work.id,
  grammar_point_id: work_en_a.id
)

work2 = TopicGrammarPoint.create!(
  topic_id: work.id,
  grammar_point_id: work_en_b.id
)

work3 = TopicGrammarPoint.create!(
  topic_id: work.id,
  grammar_point_id: work_en_f.id
)

work4 = TopicGrammarPoint.create!(
  topic_id: work.id,
  grammar_point_id: work_en_i.id
)

work5 = TopicGrammarPoint.create!(
  topic_id: work.id,
  grammar_point_id: work_jp_a.id
)

work6 = TopicGrammarPoint.create!(
  topic_id: work.id,
  grammar_point_id: work_jp_b.id
)

work7 = TopicGrammarPoint.create!(
  topic_id: work.id,
  grammar_point_id: work_jp_f.id
)

work8 = TopicGrammarPoint.create!(
  topic_id: work.id,
  grammar_point_id: work_jp_i.id
)

social1 = TopicGrammarPoint.create!(
  topic_id: social.id,
  grammar_point_id: social_en_a.id
)

social2 = TopicGrammarPoint.create!(
  topic_id: social.id,
  grammar_point_id: social_en_b.id
)

social3 = TopicGrammarPoint.create!(
  topic_id: social.id,
  grammar_point_id: social_en_f.id
)

social4 = TopicGrammarPoint.create!(
  topic_id: social.id,
  grammar_point_id: social_en_i.id
)

social5 = TopicGrammarPoint.create!(
  topic_id: social.id,
  grammar_point_id: social_jp_a.id
)

social6 = TopicGrammarPoint.create!(
  topic_id: social.id,
  grammar_point_id: social_jp_f.id
)

social7 = TopicGrammarPoint.create!(
  topic_id: social.id,
  grammar_point_id: social_jp_i.id
)

social8 = TopicGrammarPoint.create!(
  topic_id: social.id,
  grammar_point_id: food_jp_b.id
)

puts "Created references"

puts "Generating challenges"

routine_challenge = Challenge.create!(
  content: {
    en: "Describe your weekday routine and how it differs from your weekend routine. Write 4–6 sentences.",
    jp: "平日のルーティンと週末のルーティンの違いを4〜6文で説明してください。"
  },
  conversation: {
    en: "Take turns explaining your weekday routine and your weekend routine. Ask each other follow-up questions, such as why certain habits are important or how your routines affect your day.",
    jp: "平日のルーティンと週末のルーティンについてお互いに説明し合ってください。なぜその習慣が大事なのか、どのように1日に影響するのかなど、追加の質問もしてみてください。"
  },
  topic_id: routine.id
)

food_challenge = Challenge.create!(
  content: {
    en: "Describe a restaurant you enjoy. Explain what you usually order and what makes the place special.",
    jp: "あなたが好きなレストランについて書いてください。普段注文する料理や、その店の特別な点を説明してください。"
  },
  conversation: {
    en: "Describe a restaurant you like, and explain what you usually order there. Then ask your partner about their favorite place and compare what you both enjoy about eating out.",
    jp: "あなたが好きなレストランについて話し、普段そこで何を注文するか説明してください。その後、パートナーにもお気に入りの店について尋ね、外食で好きな点をお互いに比べてみてください。"
  },
  topic_id: food.id
)

work_challenge = Challenge.create!(
  content: {
    en: "Describe a normal workday and explain one task you must finish. Use 4–6 sentences.",
    jp: "普段の仕事の流れと、必ず終わらせなければならない作業について、4〜6文で書いてください。"
  },
  conversation: {
    en: "Talk about what a typical workday looks like for you and describe one task you always have to finish. Ask each other questions about responsibilities, challenges, or what makes a productive day.",
    jp: "あなたの普段の仕事の流れや、必ず終わらせなければならない作業について話してください。お互いに責任、難しい点、生産的だと感じる瞬間などについて質問し合ってください。"
  },
  topic_id: work.id
)

social_challenge = Challenge.create!(
  content: {
    en: "Describe how you usually spend time with friends or your partner. Write 4–6 sentences.",
    jp: "友人やパートナーと普段どのように過ごしているか、4〜6文で説明してください。"
  },
  conversation: {
    en: "Explain how you usually spend time with friends or your partner. Share one activity you enjoy together and ask each other questions about why it’s meaningful or fun.",
    jp: "友人やパートナーと普段どのように過ごしているか話してください。一緒に楽しんでいる活動を1つ紹介し、それがなぜ大切なのか、なぜ楽しいのかをお互いに質問し合ってください。"
  },
  topic_id: social.id
)

puts "Generated #{Challenge.all.length} challenges"
puts "Generated seeds"
puts "complete!!!"
