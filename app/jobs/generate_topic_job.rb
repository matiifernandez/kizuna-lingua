class GenerateTopicJob < ApplicationJob
  queue_as :default

  def perform(user, topic_title)
    result = TopicGenerationService.call(user, topic_title)
    if result[:success]
      topic = result[:topic]

      content_to_display = if user.learning_language == "japanese"
                            topic.content["eng"]
                          else
                            topic.content["jpn"]
                          end
      Turbo::StreamsChannel.broadcast_prepend_to(
        "topics",
        target: "topics-list",
        partial: "topics/topic", locals: { partnership_topic: PartnershipTopic.new, topic:topic, content_to_display: content_to_display })
    end
  end
end
