import { Controller } from "@hotwired/stimulus";
import Swal from "sweetalert2";

// Connects to data-controller="flash"
export default class extends Controller {
  static values = {
    type: String,
    message: String,
  };

  connect() {
    this.showAlert();
  }

  showAlert() {
    const isSuccess = this.typeValue === "notice";

    Swal.fire({
      title: isSuccess ? "Success!" : "Oops...",
      text: this.messageValue,
      icon: isSuccess ? "success" : "error",
      confirmButtonColor: "#3D88BA",
      background: "#271e35",
      color: "#ffffff",
      timer: 3000,
      timerProgressBar: true,
      showConfirmButton: false,
    });
  }
}
