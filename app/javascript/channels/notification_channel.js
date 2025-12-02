import consumer from "./consumer"

consumer.subscriptions.create("NotificationChannel", {
  connected() {},

  disconnected() {},

  received(data) {
    // Update the badge count
    const badge = document.getElementById("notification-badge")
    if (badge) {
      badge.textContent = data.unread_count
      badge.className = "notification-badge"
    } else {
      // Badge doesn't exist, create it
      const bellIcon = document.querySelector("#notifications .link")
      if (bellIcon && data.unread_count > 0) {
        const newBadge = document.createElement("span")
        newBadge.id = "notification-badge"
        newBadge.className = "notification-badge"
        newBadge.textContent = data.unread_count
        bellIcon.appendChild(newBadge)
      }
    }

    // Reload the page to show the new notification
    window.location.reload()
  }
})
