import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["comments"]

  connect() {

    this.element.addEventListener("click", this.onClick.bind(this))
  }

  onClick(event) {
    const highlight = event.target.closest(".journal-highlight")
    if (!highlight) return

    const id = highlight.dataset.commentId
    if (!id) return

    const commentCard = this.commentsTarget.querySelector(
      `[data-comment-id="${id}"]`
    )

    if (commentCard) {
      commentCard.scrollIntoView({ behavior: "smooth", block: "center" })
      commentCard.classList.add("journal-comment-card--active")
      setTimeout(() => commentCard.classList.remove("journal-comment-card--active"), 1500)
    }
  }
}
