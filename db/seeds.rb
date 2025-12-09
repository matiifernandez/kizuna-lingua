puts "Cleaning up the database..."
TopicGrammarPoint.destroy_all
PartnershipTopic.destroy_all
Topic.destroy_all
Challenge.destroy_all
GrammarPoint.destroy_all
Partnership.destroy_all
Journal.destroy_all
User.destroy_all
puts "database cleaned"

puts "Creating Users"
john = User.create!(email: "test@mail.com", password: "123456", password_confirmation: "123456", name: "John", native_language: "english", learning_language: "japanese", learning_level: "intermediate")
aki = User.create!(email: "testjpn@mail.com", password: "123456", password_confirmation: "123456", name: "Aki", native_language: "japanese", learning_language: "english", learning_level: "fluent")
ASSETS_PATH = Rails.root.join("app", "assets", "images")
john_image_path = ASSETS_PATH.join("john.jpg")
if File.exist?(john_image_path)
  File.open(john_image_path, 'rb') do |file|
    john.photo.attach(
      io: file,
      filename: "john.jpg",
      content_type: "image/jpeg"
    )
    puts "Attached photo to John."
  end
else
  puts "Skipped attaching photo to John: file not found at #{john_image_path}"
end
aki_image_path = ASSETS_PATH.join("aki.jpg")
if File.exist?(aki_image_path)
  File.open(aki_image_path, 'rb') do |file|
    aki.photo.attach(
      io: file,
      filename: "aki.jpg",
      content_type: "image/jpeg"
    )
    puts "Attached photo to Aki."
  end
else
  puts "Skipped attaching photo to Aki: file not found at #{aki_image_path}"
end
partnership = Partnership.new
partnership.user_one = john
partnership.user_two = aki
partnership.save!
puts "Created Users: #{User.first.email}, #{User.last.email}"

puts "\n" + "=" * 50
puts "Generating Topics with AI..."
puts "=" * 50

topic_titles = ["Ordering Food at a Restaurant", "Planning a Weekend Trip"]

topic_titles.each do |topic_title|
  puts "\nGenerating topic: '#{topic_title}'..."
  puts "  - Calling AI to generate content, challenges, and grammar points..."

  result = TopicGenerationService.call(john, topic_title)

  if result[:success]
    topic = result[:topic]
    puts "  ✓ Topic '#{topic.name}' created successfully!"
    puts "    - Challenges: #{topic.challenges.count}"
    puts "    - Grammar Points: #{topic.grammar_points.count}"
    puts "    - Image attached: #{topic.image.attached? ? 'Yes' : 'No'}"
  else
    puts "  ✗ Failed to generate topic: #{result[:error]}"
  end
end

puts "\n" + "=" * 50
puts "Seed Summary:"
puts "=" * 50
puts "Users created: #{User.count}"
puts "Partnerships created: #{Partnership.count}"
puts "Topics created: #{Topic.count}"
puts "Challenges created: #{Challenge.count}"
puts "Grammar Points created: #{GrammarPoint.count}"
puts "Topic-Grammar associations: #{TopicGrammarPoint.count}"
puts "=" * 50
