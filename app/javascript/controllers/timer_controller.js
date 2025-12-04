import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["display", "startButton", "turnIndicator", "playIcon", "recordingIndicator"]

  static values = {
    duration: { type: Number, default: 10 },
    userLanguage: { type: String, default: "Your Language" },
    partnerLanguage: { type: String, default: "Partner's Language" }
  }

  connect() {
    console.log(this.startButtonTarget)
    this.remainingTime = this.durationValue
    this.isPartnerTurn = false
    this.isTimerRunning = false
    this.updateDisplay()
  }

  playSound() {
    const audio = new Audio("/timer-sound.mp3")
    audio.play()
  }

  toggleTimer() {
    console.log("timer start")
    if (this.isTimerRunning) {
      this.pauseTimer()
    } else {
      this.startTimer()
    }
  }

  startTimer() {
    console.log("timer starting")
    this.isTimerRunning = true
    this.startButtonTarget.classList.add('disabled')
    this.startButtonTarget.disabled = true;
    // this.pauseIconTarget.classList.remove('d-none')
    this.setTurnIndicator(this.isPartnerTurn)
    this.showRecordingIndicator()

    this.timerInterval = setInterval(() => {
      this.remainingTime -= 1
      this.updateDisplay()

      if (this.remainingTime <= 0) {
        this.playSound()
        this.switchTurn()
      }
    }, 1000)
  }

  // pauseTimer() {
  //   if (this.timerInterval) {
  //     clearInterval(this.timerInterval)
  //   }
  //   this.isTimerRunning = false
  //   this.pauseIconTarget.classList.add('d-none')
  //   this.playIconTarget.classList.remove('d-none')
  // }

  stopTimer() {
    if (this.timerInterval) {
      clearInterval(this.timerInterval)
    }
    this.isTimerRunning = false
    this.startButtonTarget.classList.remove('disabled')
    this.startButtonTarget.disabled = false;
    this.hideRecordingIndicator()
  }

  showRecordingIndicator() {
    if (this.hasRecordingIndicatorTarget) {
      this.recordingIndicatorTarget.style.display = 'flex'
    }
  }

  hideRecordingIndicator() {
    if (this.hasRecordingIndicatorTarget) {
      this.recordingIndicatorTarget.style.display = 'none'
    }
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
      this.turnIndicatorTarget.textContent = `Time to practice in ${this.partnerLanguageValue}`
      this.turnIndicatorTarget.classList.remove('user-turn')
      this.turnIndicatorTarget.classList.add('partner-turn')
    } else {
      this.turnIndicatorTarget.textContent = `Time to practice in ${this.userLanguageValue}`
      this.turnIndicatorTarget.classList.remove('partner-turn')
      this.turnIndicatorTarget.classList.add('user-turn')
    }
  }

  disconnect() {
    this.stopTimer()
  }
}
