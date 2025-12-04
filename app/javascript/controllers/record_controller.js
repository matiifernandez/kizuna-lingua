import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="record"
export default class extends Controller {
  static targets = ["record"]
  static values = {
    journal: String
  }
  connect() {

  }

  startRecording(e) {
    navigator.mediaDevices.getUserMedia({ audio: true })
      .then((stream) => {
        this.mediaRecorder = new MediaRecorder(stream);
        this.isRecording = true
        this.mediaRecorder.start();

        let chunks = [];
        this.mediaRecorder.ondataavailable = (e) => {
          chunks.push(e.data);
        };

        this.mediaRecorder.onstop = (e) => {
            const mimeType = this.mediaRecorder.mimeType;
            const blob = new Blob(chunks, { type: mimeType });
            chunks = [];
            const formData = new FormData();
            formData.append('audio', blob, 'recording.wav');
            const response = fetch(`/journals/${this.journalValue}/add_audio`, {
                method: 'PATCH',
                body: formData,
                headers: {
                  'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content,
                  'Accept': 'audio/*'
                }
              });
        }
      })

  }

  stopRecording() {
    if (this.mediaRecorder && this.mediaRecorder.state === "recording") {
      this.isRecording = false
      this.mediaRecorder.stop();
      this.mediaRecorder.stream.getTracks().forEach(track => track.stop());
    }
  }

  disconnect() {
    if (this.mediaRecorder && this.mediaRecorder.state === "recording") {
      this.isRecording = false
      this.mediaRecorder.stop();
      this.mediaRecorder.stream.getTracks().forEach(track => track.stop());
    }
  }
}
