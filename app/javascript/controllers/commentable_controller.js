import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    journalId: Number
  }

  static targets = ["button", "transcript"]

  connect() {
    this.handleSelectionChange = this.handleSelectionChange.bind(this)
    this.selectionTimeout = null
    this.currentSelection = null
    this.currentTranscript = null

    // selectionchange works both on desktop and mobile (including PWAs)
    document.addEventListener("selectionchange", this.handleSelectionChange)
  }

  disconnect() {
    document.removeEventListener("selectionchange", this.handleSelectionChange)
  }

  // Fired whenever browser selection changes (mouse, touch, keyboard, etc.)
  handleSelectionChange() {
    clearTimeout(this.selectionTimeout)


    this.selectionTimeout = setTimeout(() => {

      const selection = window.getSelection()
      if (!selection || selection.isCollapsed) {
        this.hideButton()
        this.currentSelection = null
        return
      }

      const range = selection.getRangeAt(0)

      // Only react if selection is inside one of our transcript containers
      const transcriptContainer = this.transcriptTargets.find(target =>
        target.contains(range.commonAncestorContainer)
      )
      if (!transcriptContainer) {
        this.hideButton()
        this.currentSelection = null
        return
      }

      // Store which transcript the selection is in
      this.currentTranscript = transcriptContainer

      const selectedText = selection.toString().trim()
      if (!selectedText) {
        this.hideButton()
        this.currentSelection = null
        return
      }

      // Save selection info so we can use it when the user taps the button
      this.currentSelection = { range, selectedText }


      this.positionButton(range)
      this.showButton()
    }, 250) // small debounce so mobile selection handles settle
  }

  positionButton(range) {
    const rect = range.getBoundingClientRect()
    const button = this.buttonTarget

    // Fallback if browser gives empty rect
    if (!rect || (rect.top === 0 && rect.left === 0 && rect.width === 0 && rect.height === 0)) {
      this.hideButton()
      return
    }

    const scrollY = window.scrollY || document.documentElement.scrollTop
    const scrollX = window.scrollX || document.documentElement.scrollLeft

    // Position slightly above the selection
    button.style.top = `${rect.top + scrollY - button.offsetHeight - 8}px`
    button.style.left = `${rect.left + scrollX}px`
  }

  showButton() {


    this.buttonTarget.classList.remove("hidden")


  }

  hideButton() {
    this.buttonTarget.classList.add("hidden")
  }

  // Called when user taps/clicks the floating "+ Comment" button
  addComment() {
    if (!this.currentSelection) return

    const { range, selectedText } = this.currentSelection
    console.log(this.currentSelection);

    const { start, end } = this.getOffsets(range)
    if (start === end) return

    const transcriptIndex = this.currentTranscript.dataset.transcriptIndex

    const body = window.prompt(`Comment for: "${selectedText}"`)
    if (!body) return

    this.createComment({
      start_index: start,
      end_index: end,
      transcript_index: transcriptIndex,
      selected_text: selectedText,
      body: body
    })

    // Clear selection & button
    const selection = window.getSelection()
    if (selection) selection.removeAllRanges()
    this.currentSelection = null
    this.hideButton()
  }

  // Translate DOM range to character offsets in the transcript text
  getOffsets(range) {
    const transcript = this.currentTranscript

    const preRange = range.cloneRange()
    preRange.selectNodeContents(transcript)
    preRange.setEnd(range.startContainer, range.startOffset)
    const start = preRange.toString().length

    const fullRange = range.cloneRange()
    fullRange.selectNodeContents(transcript)
    fullRange.setEnd(range.endContainer, range.endOffset)
    const end = fullRange.toString().length

    return { start, end }
  }

  createComment(data) {
    const token = document.querySelector('meta[name="csrf-token"]').content

    fetch(`/journals/${this.journalIdValue}/comments`, {
      method: "POST",
      headers: {
        "X-CSRF-Token": token,
        "Content-Type": "application/json",
        "Accept": "application/json"
      },
      body: JSON.stringify({
        comment: {
          journal_id: this.journalIdValue,
          start_index: data.start_index,
          end_index: data.end_index,
          transcript_index: data.transcript_index,
          body: data.body
        }
      })
    }).then(response => {
      if (response.ok) {
        // MVP: just reload. Later you can Turbo-Stream this.
        window.location.reload()
      } else {
        console.error("Failed to create comment")
      }
    })
  }
}
