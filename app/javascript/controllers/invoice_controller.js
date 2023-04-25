import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["slotTemplate", "slotTarget", "optTemplate", "optTarget"];

  add(child, cost, id, type, name) {
    const wrapper =
      type === "TimeSlot"
        ? document.getElementById(`slot${id}`.concat(`child${child}`))
        : document.getElementById(`opt${id}`.concat(`child${child}`));

    if (wrapper) {
      // For existing registrations
      const destroy = wrapper.querySelector("input[name*='_destroy']");
      destroy.value = "0";
      wrapper.classList.add(`child${child}`);
      if (type === "Option") {
        const cost = wrapper.querySelector(".opt_cost.hidden");
        cost.classList.add("registered");
      }
    } else {
      // For newly created registrations
      if (type === "TimeSlot") {
        const content = this.slotTemplateTarget.innerHTML
          .replace(/REG_INDEX/g, new Date().getTime().toString())
          .replace(/NEW_ID/g, `slot${id}`.concat(`child${child}`))
          .replace(/NEW_CLASS/, `child${child}`)
          .replace(/NEW_CHILD_ID/g, child)
          .replace(/NEW_REGISTERABLE_ID/g, id);
        this.slotTargetTarget.insertAdjacentHTML("beforebegin", content);
      } else {
        const content = this.optTemplateTarget.innerHTML
          .replace(/REG_INDEX/g, new Date().getTime().toString())
          .replace(/NEW_ID/g, `opt${id}`.concat(`child${child}`))
          .replace(/NEW_CLASS/, `child${child}`)
          .replace(/NEW_CHILD_ID/g, child)
          .replace(/NEW_REGISTERABLE_ID/g, id)
          .replace(/NEW_COST/g, cost);
        this.optTargetTarget.insertAdjacentHTML("beforebegin", content);
      }
    }

    if (name !== null) {
      // Add the name of the registration to the registration list
      const nameContainer = document.getElementById("reg_slots");
      const nameP = document.createElement("p");
      nameP.innerText = name.replaceAll("_", " ");
      nameContainer.appendChild(nameP);

      // Sort the registration list alphabetically
      const names = [];
      nameContainer.childNodes.forEach((node) => {
        names.push(node.innerText);
      });
      names.sort();
      nameContainer.innerHTML = "";
      names.forEach((name) => {
        const nameP = document.createElement("p");
        nameP.innerText = name.replaceAll("_", " ");
        nameContainer.appendChild(nameP);
      });
    }

    this.dispatch("add");
  }

  change(e) {
    const child = e.detail.child;
    const checked = e.detail.checked;
    const cost = e.detail.cost;
    const id = e.detail.id;
    const name = e.detail.name ? e.detail.name : null;
    const siblings = e.detail.siblings;
    const type = e.detail.type;

    if (checked && type === "TimeSlot") {
      this.add(child, cost, id, type, name);
    } else if (checked) {
      this.radio(child, cost, id, siblings, type, name);
    } else {
      this.remove(child, id, type, name);
    }
  }

  radio(child, cost, id, siblings, type, name) {
    this.add(child, cost, id, type, name);

    siblings.forEach((sibling) => {
      const child = sibling.dataset.registerChildValue;
      const id = sibling.dataset.registerIdValue;

      this.remove(child, id, "Option", name);
    });
  }

  remove(child, id, type, name) {
    const wrapper =
      type === "TimeSlot"
        ? document.getElementById(`slot${id}`.concat(`child${child}`))
        : document.getElementById(`opt${id}`.concat(`child${child}`));

    if (wrapper) {
      if (wrapper.dataset.newRecord === "true") {
        // For newly created registrations
        wrapper.remove();
      } else {
        // For existing registrations
        const destroy = wrapper.querySelector("input[name*='_destroy']");
        destroy.value = "1";
        wrapper.classList.remove(`child${child}`);
        if (type === "Option") {
          const cost = wrapper.querySelector(".opt_cost.hidden");
          cost.classList.remove("registered");
        }
      }
    }

    if (name !== null) {
      const nameContainer = document.getElementById("reg_slots");
      nameContainer.childNodes.forEach((node) => {
        if (node.innerText === name.replaceAll("_", " ")) {
          nameContainer.removeChild(node);
        }
      });
    }

    this.dispatch("remove");
  }
}
