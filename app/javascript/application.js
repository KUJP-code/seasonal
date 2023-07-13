// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails

//= require popper
//= require bootstrap-sprockets

import "@hotwired/turbo-rails";
import "controllers";
import "chartkick";
import "Chart.bundle";

// Initializers for Bootstrap components that need them

// Form validation

(() => {
  "use strict";

  // Fetch all the forms we want to apply custom Bootstrap validation styles to
  const forms = document.querySelectorAll(".needs-validation");

  // Loop over them and prevent submission
  Array.from(forms).forEach((form) => {
    form.addEventListener(
      "submit",
      (event) => {
        if (!form.checkValidity()) {
          event.preventDefault();
          event.stopPropagation();
        }

        form.classList.add("was-validated");
      },
      false
    );
  });
})();

// Popovers

document.addEventListener("turbo:load", function () {
  const popoverTriggerList = document.querySelectorAll(
    '[data-bs-toggle="popover"]'
  );
  [...popoverTriggerList].map(
    (popoverTriggerEl) => new bootstrap.Popover(popoverTriggerEl)
  );
});

// Toasts

document.addEventListener("turbo:load", function () {
  const toastElList = document.querySelectorAll(".toast");
  [...toastElList].map((toastEl) => new bootstrap.Toast(toastEl).show());
});

// Tracking from Microsoft Clarity

document.addEventListener(
  "turbo:load",
  (function (c, l, a, r, i, t, y) {
    c[a] =
      c[a] ||
      function () {
        (c[a].q = c[a].q || []).push(arguments);
      };
    t = l.createElement(r);
    t.async = 1;
    t.src = "https://www.clarity.ms/tag/" + i;
    y = l.getElementsByTagName(r)[0];
    y.parentNode.insertBefore(t, y);
  })(window, document, "clarity", "script", "hghp07f095")
);
