// app/javascript/controllers/timer_controller.js

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["display", "startButton", "turnIndicator"]

  // Define the duration for each partner's turn (30 seconds)
  static values = { duration: { type: Number, default: 30 } }

  connect() {
    this.remainingTime = this.durationValue;
    this.isPartnerTurn = false; // Tracks which partner is speaking
    this.isTimerRunning = false;
    this.updateDisplay();
  }

  // --- Core Timer Logic ---

  startTimer() {
    // Prevent starting if already running
    if (this.isTimerRunning) return;

    this.isTimerRunning = true;
    this.startButtonTarget.disabled = true; // Disable the start button
    this.setTurnIndicator(false); // Start with the user's turn

    this.timerInterval = setInterval(() => {
      this.remainingTime -= 1;
      this.updateDisplay();

      if (this.remainingTime <= 0) {
        this.switchTurn();
      }
    }, 1000); // Update every 1 second
  }

  stopTimer() {
    if (this.timerInterval) {
      clearInterval(this.timerInterval);
      this.isTimerRunning = false;
    }
  }

  // --- Turn Management ---

  switchTurn() {
    this.stopTimer(); // Stop the current timer
    this.isPartnerTurn = !this.isPartnerTurn; // Toggle the turn
    this.remainingTime = this.durationValue; // Reset time to 30 seconds

    if (this.isPartnerTurn) {
      // This is the **second** turn, after which the challenge is considered complete.
      this.setTurnIndicator(true);
      // Restart the timer for the partner
      this.startTimer();
    } else {
      // The conversation is complete after the partner's turn finishes.
      this.setComplete();
    }
  }

  // --- Display Updates ---

  updateDisplay() {
    const minutes = Math.floor(this.remainingTime / 60);
    const seconds = this.remainingTime % 60;
    const formattedTime = `${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;
    this.displayTarget.textContent = formattedTime;
  }

  setTurnIndicator(isPartner) {
    const userLang = "Your Language (30s)"; // Replace with actual language name if available
    const partnerLang = "Partner's Language (30s)"; // Replace with actual language name if available

    if (isPartner) {
      this.turnIndicatorTarget.textContent = partnerLang;
      this.turnIndicatorTarget.classList.remove('text-primary');
      this.turnIndicatorTarget.classList.add('text-danger'); // Use a different color for partner
    } else {
      this.turnIndicatorTarget.textContent = userLang;
      this.turnIndicatorTarget.classList.remove('text-danger');
      this.turnIndicatorTarget.classList.add('text-primary'); // Use a primary color for the user
    }
  }

  setComplete() {
    this.turnIndicatorTarget.textContent = "Time's Up! Conversation Complete.";
    this.turnIndicatorTarget.classList.remove('text-primary', 'text-danger');
    this.turnIndicatorTarget.classList.add('text-success');

    this.displayTarget.textContent = "00:00";

    // You might want to automatically click the "Conversation Completed" button here
    // or unhide a separate completion confirmation.
    console.log("Conversation Challenge Completed!");
    // Example: document.getElementById('completion-form-button').click();
  }

  // Ensure timer is stopped if the user leaves the page
  disconnect() {
    this.stopTimer();
  }
}
