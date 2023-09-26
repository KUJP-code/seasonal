import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "slotTemplate",
    "slotTarget",
    "optTemplate",
    "optTarget",
    "snackCount",
  ];

  add(child, cost, id, snack, type, modifier, name) {
    console.log(name);

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

    if (name) {
      // Add the name of the registration to the registration list
      const nameContainer = document.getElementById("reg_slots");
      const nameP = document.createElement("p");
      nameP.dataset.modifier = modifier;
      nameP.innerText = name.replaceAll("_", " ");
      nameContainer.appendChild(nameP);

      // Sort the registration list alphabetically
      const sortedActivities = [...nameContainer.children].sort((a, b) => {
        return a.innerText > b.innerText;
      });
      nameContainer.innerHTML = "";
      nameContainer.append(...sortedActivities);
    }

    if (snack === "true") {
      const snackCount = parseInt(this.snackCountTarget.innerText);
      this.snackCountTarget.innerText = (snackCount + 1).toString();
    }

    this.dispatch("add");
  }

  change(e) {
    const child = e.detail.child;
    const checked = e.detail.checked;
    const cost = e.detail.cost;
    const id = e.detail.id;
    const modifier = e.detail.modifier;
    const name = e.detail.name ? e.detail.name : null;
    const siblings = e.detail.siblings;
    const snack = e.detail.snack;
    const type = e.detail.type;

    console.log(name);

    if (checked && (type === "TimeSlot" || type === "Option")) {
      return this.add(child, cost, id, snack, type, modifier, name);
    } else if (checked && type === "Radio") {
      return this.radio(child, cost, id, siblings, name);
    } else {
      return this.remove(child, id, snack, type, name);
    }
  }

  radio(child, cost, id, siblings, name) {
    this.add(child, cost, id, "Option", name);

    siblings.forEach((sibling) => {
      const child = sibling.dataset.registerChildValue;
      const id = sibling.dataset.registerIdValue;

      this.remove(child, id, "Option", name);
    });
  }

  remove(child, id, snack, type, name) {
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

    if (name) {
      const nameContainer = document.getElementById("reg_slots");
      nameContainer.childNodes.forEach((node) => {
        if (node.innerText === name.replaceAll("_", " ")) {
          nameContainer.removeChild(node);
        }
      });
    }

    if (snack === "true") {
      const snackCount = parseInt(this.snackCountTarget.innerText);
      this.snackCountTarget.innerText = (snackCount - 1).toString();
    }

    this.dispatch("remove");
  }
}
