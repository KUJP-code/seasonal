// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails

//= require popper
//= require bootstrap-sprockets

import "@hotwired/turbo-rails";
import "@popperjs/core";
import "bootstrap";
import "controllers";

// Initializers for Bootstrap components that need them
document.addEventListener("turbo:load", function () {
  const popoverTriggerList = document.querySelectorAll(
    '[data-bs-toggle="popover"]'
  );
  [...popoverTriggerList].map(
    (popoverTriggerEl) => new bootstrap.Popover(popoverTriggerEl)
  );
});
