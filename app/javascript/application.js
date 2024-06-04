// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails

//= require popper
//= require bootstrap-sprockets

import "@hotwired/turbo-rails";
import "controllers";
import "chartkick";
import "Chart.bundle";

// Initializers for Bootstrap components that need them

// Form validation

document.addEventListener("turbo:load", () => {
	// Fetch all the forms we want to apply custom Bootstrap validation styles to
	const forms = document.querySelectorAll(".needs-validation");

	// Loop over them and prevent submission
	for (const form of forms) {
		form.addEventListener(
			"submit",
			(event) => {
				if (!form.checkValidity()) {
					event.preventDefault();
					event.stopPropagation();
				}

				form.classList.add("was-validated");
			},
			false,
		);
	}
});

// Popovers

document.addEventListener("turbo:load", () => {
	const popoverTriggerList = document.querySelectorAll(
		'[data-bs-toggle="popover"]',
	);
	[...popoverTriggerList].map(
		(popoverTriggerEl) => new bootstrap.Popover(popoverTriggerEl),
	);
});

// Toasts

document.addEventListener("turbo:load", () => {
	const toastElList = document.querySelectorAll(".toast");
	[...toastElList].map((toastEl) => new bootstrap.Toast(toastEl).show());
});
