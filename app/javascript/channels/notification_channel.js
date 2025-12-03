import consumer from "channels/consumer"

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

    // Refresh the notifications list
    const notificationsList = document.getElementById("notifications-list")
    if (notificationsList) {
      fetch("/notifications", {
        headers: { "Accept": "text/html" }
      })
        .then(response => response.text())
        .then(html => {
          notificationsList.innerHTML = html
        })
    }
  }
})
