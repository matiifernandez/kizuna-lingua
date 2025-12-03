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
    console.log("recording");

    // if (!this.mediaDevicesAvailable) return
    navigator.mediaDevices.getUserMedia({ audio: true })
      .then((stream) => {
        this.mediaRecorder = new MediaRecorder(stream);
        this.isRecording = true
        this.mediaRecorder.start();
        console.log(this.mediaRecorder);



        console.log(stream);

        let chunks = [];
        this.mediaRecorder.ondataavailable = (e) => {
          console.log(e.data);
          chunks.push(e.data);


        };

        this.mediaRecorder.onstop = (e) => {
            console.log("recorder stopped");
            const mimeType = this.mediaRecorder.mimeType;

            // Change button to show processing
            this.recordTarget.style.background = "orange";
            this.recordTarget.textContent = "Processing...";

            const blob = new Blob(chunks, { type: mimeType });

            console.log(blob);

            chunks = [];
            const formData = new FormData();
            formData.append('audio', blob, 'recording.webm');
            const formObject = Object.fromEntries(formData.entries());
            console.log(formObject);

            // console.log(blob);
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
    console.log("stopping");

    if (this.mediaRecorder && this.mediaRecorder.state === "recording") {
      this.isRecording = false
      this.mediaRecorder.stop();
      this.mediaRecorder.stream.getTracks().forEach(track => track.stop());
    }
  }
}
