import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["display", "startButton", "turnIndicator", "playIcon", "pauseIcon"]

  static values = {
    duration: { type: Number, default: 120 },
    userLanguage: { type: String, default: "Your Language" },
    partnerLanguage: { type: String, default: "Partner's Language" }
  }

  connect() {
    this.remainingTime = this.durationValue
    this.isPartnerTurn = false
    this.isTimerRunning = false
    this.updateDisplay()
  }

  toggleTimer() {
    if (this.isTimerRunning) {
      this.pauseTimer()
    } else {
      this.startTimer()
    }
  }

  startTimer() {
    this.isTimerRunning = true
    this.playIconTarget.classList.add('d-none')
    this.pauseIconTarget.classList.remove('d-none')
    this.setTurnIndicator(this.isPartnerTurn)

    this.timerInterval = setInterval(() => {
      this.remainingTime -= 1
      this.updateDisplay()

      if (this.remainingTime <= 0) {
        this.switchTurn()
      }
    }, 1000)
  }

  pauseTimer() {
    if (this.timerInterval) {
      clearInterval(this.timerInterval)
    }
    this.isTimerRunning = false
    this.pauseIconTarget.classList.add('d-none')
    this.playIconTarget.classList.remove('d-none')
  }

  stopTimer() {
    if (this.timerInterval) {
      clearInterval(this.timerInterval)
    }
    this.isTimerRunning = false
  }

  switchTurn() {
    this.isPartnerTurn = !this.isPartnerTurn
    this.remainingTime = this.durationValue
    this.setTurnIndicator(this.isPartnerTurn)
    this.updateDisplay()
  }

  manualSwitch() {
    this.switchTurn()
  }

  updateDisplay() {
    const minutes = Math.floor(this.remainingTime / 60)
    const seconds = this.remainingTime % 60
    this.displayTarget.textContent = `${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`
  }

  setTurnIndicator(isPartner) {
    if (isPartner) {
      this.turnIndicatorTarget.textContent = `Speak in ${this.partnerLanguageValue}`
      this.turnIndicatorTarget.classList.remove('user-turn')
      this.turnIndicatorTarget.classList.add('partner-turn')
    } else {
      this.turnIndicatorTarget.textContent = `Speak in ${this.userLanguageValue}`
      this.turnIndicatorTarget.classList.remove('partner-turn')
      this.turnIndicatorTarget.classList.add('user-turn')
    }
  }

  disconnect() {
    this.stopTimer()
  }
}
