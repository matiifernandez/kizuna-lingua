class ApplicationNotifier < Noticed::Event
  deliver_by :database

  deliver_by :action_cable do |config|
    config.channel = "NotificationChannel"
    config.stream = -> { recipient }
    config.message = -> {
      {
        event_type: self.class.name,
        params: params,
        recipient_id: recipient.id,
        unread_count: recipient.notifications.unread.count
      }
    }
  end
end
