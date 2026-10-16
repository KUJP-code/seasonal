import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["files", "folder", "subfolder", "control", "summary", "progress", "results", "retry"];
  static values = { maxSize: Number };

  connect() {
    this.disconnected = false;
    this.busy = false;
    this.select();
  }

  disconnect() {
    this.disconnected = true;
    this.request?.abort();
  }

  select() {
    if (this.busy) return;
    this.resultsTarget.replaceChildren();
    this.entries = Array.from(this.filesTarget.files, (file) => {
      const row = document.createElement("li");
      row.className = "py-1";
      this.resultsTarget.append(row);
      const entry = { file, row, id: crypto.randomUUID(), state: "queued" };
      this.showEntry(entry, "Waiting");
      return entry;
    });
    this.progressTarget.hidden = true;
    this.retryTarget.hidden = true;
    this.summaryTarget.textContent = this.entries.length ? `${this.entries.length} images selected.` : "";
    this.setBusy(false);
  }

  async upload(event) {
    event.preventDefault();
    if (this.busy || !this.element.reportValidity()) return;
    if (!this.entries.length) this.select();
    await this.run(this.entries.filter((entry) => entry.state === "queued"));
  }

  async retry() {
    if (this.busy) return;
    await this.run(this.entries.filter((entry) => entry.state === "failed"));
  }

  async run(entries) {
    if (!entries.length) return;
    this.setBusy(true);
    this.retryTarget.hidden = true;
    this.progressTarget.hidden = false;
    this.progressTarget.max = this.entries.length;
    const folder = this.folderTarget.value;
    const subfolder = this.subfolderTarget.value;

    try {
      for (const entry of entries) {
        if (this.disconnected) break;
        if (entry.file.size > this.maxSizeValue || entry.file.size === 0) {
          entry.state = "rejected";
          this.showEntry(entry, entry.file.size === 0
            ? "This image is empty. Select another image."
            : "Exceeds 9 MB. Export a smaller image and select it again.");
        } else {
          entry.state = "uploading";
          this.showEntry(entry, "Uploading…");
          const result = await this.send(entry, folder, subfolder);
          entry.state = result.ok ? "uploaded" : result.retryable === false ? "rejected" : "failed";
          this.showEntry(entry, result.message);
        }
        this.updateSummary();
      }
    } finally {
      if (!this.disconnected) {
        this.setBusy(false);
        this.retryTarget.hidden = !this.entries.some((entry) => entry.state === "failed");
      }
    }
  }

  send(entry, folder, subfolder) {
    return new Promise((resolve) => {
      const xhr = new XMLHttpRequest();
      this.request = xhr;
      xhr.open("POST", this.element.action);
      xhr.timeout = 120000;
      xhr.setRequestHeader("Accept", "application/json");
      xhr.setRequestHeader("X-Requested-With", "XMLHttpRequest");
      const token = document.querySelector('meta[name="csrf-token"]')?.content;
      if (token) xhr.setRequestHeader("X-CSRF-Token", token);
      xhr.upload.onprogress = (event) => {
        if (event.lengthComputable) {
          this.showEntry(entry, `Sending ${Math.round(event.loaded / event.total * 100)}%…`);
        }
      };
      xhr.upload.onload = () => this.showEntry(entry, "Saving image…");
      xhr.onload = () => resolve(this.responseFor(xhr));
      xhr.onerror = () => resolve({ ok: false, message: "Connection failed. Retry this image." });
      xhr.ontimeout = () => resolve({ ok: false, message: "Upload timed out. Retry this image." });
      xhr.onabort = () => resolve({ ok: false, message: "Upload interrupted. Retry this image." });

      const body = new FormData();
      body.append("uploads[]", entry.file);
      body.append("folder", folder);
      body.append("subfolder", subfolder);
      body.append("upload_id", entry.id);
      xhr.send(body);
    });
  }

  responseFor(xhr) {
    if (xhr.status === 413) {
      return { ok: false, retryable: false, message: "Server rejected the image size. Export a smaller image and select it again." };
    }
    if ([401, 403, 422].includes(xhr.status) && !xhr.getResponseHeader("Content-Type")?.includes("application/json")) {
      return { ok: false, message: "Your session may have expired. Sign in again and retry." };
    }
    try {
      const result = JSON.parse(xhr.responseText);
      if (xhr.status >= 200 && xhr.status < 300 && result.uploaded?.length === 1 && !result.errors?.length) {
        return { ok: true, message: "Uploaded" };
      }
      if (result.errors?.length) return { ok: false, ...result.errors[0] };
    } catch {
      // Proxies and sign-in redirects may return HTML rather than JSON.
    }
    return { ok: false, message: `Upload was not confirmed (HTTP ${xhr.status}). Check your connection and sign-in, then retry.` };
  }

  showEntry(entry, message) {
    entry.row.textContent = `${entry.file.name} — ${message}`;
    entry.row.classList.toggle("text-success", entry.state === "uploaded");
    entry.row.classList.toggle("text-danger", ["failed", "rejected"].includes(entry.state));
  }

  updateSummary() {
    const uploaded = this.entries.filter((entry) => entry.state === "uploaded").length;
    const failed = this.entries.filter((entry) => ["failed", "rejected"].includes(entry.state)).length;
    this.progressTarget.value = uploaded + failed;
    this.summaryTarget.textContent = `${uploaded} of ${this.entries.length} images uploaded.${failed ? ` ${failed} failed; see details below.` : ""}`;
  }

  setBusy(busy) {
    this.busy = busy;
    this.controlTargets.forEach((control) => { control.disabled = busy; });
    this.retryTarget.disabled = busy;
  }
}
