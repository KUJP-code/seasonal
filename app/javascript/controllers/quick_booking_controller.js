import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["container", "hiddenField", "partyPicture"];

  loadTimeslots(event) {
    const schoolId = event.target.value;
    if (!schoolId) {
      this.containerTarget.innerHTML = "";
      this.hiddenFieldTarget.value = "";
      this.partyPictureTarget.innerHTML = "";
      return;
    }
    fetch(`/schools/${schoolId}/quick_booking_timeslots.json`)
      .then((response) => response.json())
      .then((data) => {
        if (data.party_event) {
          this.partyPictureTarget.innerHTML = `
          <img src="${data.party_event.image_url}" alt="${data.party_event.name}" class="img-fluid img-thumbnail">
        `;
        } else {
          this.partyPictureTarget.innerHTML = "";
        }

        let html = "";
        data.timeslots.forEach((timeslot) => {
          html += `
            <div class="col-6 col-lg-3">
              <div class="card timeslot-card mb-3" data-timeslot-id="${timeslot.id}">
                <div class="card-body text-center">
                  <img src="${timeslot.image_url}" alt="${timeslot.name}" class="img-fluid img-thumbnail">
                  <div class="form-check form-switch mt-2">
                    <input class="form-check-input" type="radio" name="selected_timeslot" id="timeslot_${timeslot.id}" value="${timeslot.id}" data-action="change->quick-booking#updateSelection">
                    <label class="form-check-label" for="timeslot_${timeslot.id}">Select</label>
                  </div>
                </div>
              </div>
            </div>
          `;
        });
        this.containerTarget.innerHTML = `<div class="row">${html}</div>`;
      })
      .catch((error) => {
        console.error("Error loading timeslots:", error);
        this.containerTarget.innerHTML =
          "<p>There are no available time slots, we apologise for the inconvenience.</p>";
      });
  }

  updateSelection(event) {
    // Update the hidden field when a radio button is selected
    this.hiddenFieldTarget.value = event.target.value;
  }
}
