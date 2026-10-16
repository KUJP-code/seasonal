import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["editor"];

  normalizePaste(event) {
    if (!event.paste?.html) return;
    const document = new DOMParser().parseFromString(event.paste.html, "text/html");

    // Office paragraph margins and hanging indents otherwise turn into extra breaks.
    document.querySelectorAll("style, meta, link, script").forEach((element) => element.remove());
    document.querySelectorAll("[style]").forEach((element) => {
      ["margin", "margin-top", "margin-bottom", "margin-left", "margin-right",
        "padding", "padding-top", "padding-bottom", "padding-left", "padding-right",
        "text-indent", "line-height"].forEach((property) => element.style.removeProperty(property));
    });
    document.querySelectorAll('b[id^="docs-internal-guid"]').forEach((element) => {
      element.replaceWith(...element.childNodes);
    });
    document.querySelectorAll("p").forEach((paragraph) => {
      const block = document.createElement("div");
      block.style.cssText = paragraph.style.cssText;
      if (paragraph.dir) block.dir = paragraph.dir;
      block.append(...paragraph.childNodes);
      if (!block.textContent.trim() && !block.querySelector("img, action-text-attachment")) {
        block.replaceChildren(document.createElement("br"));
      }
      paragraph.replaceWith(block);
    });
    event.paste.html = document.body.innerHTML;
  }

  keydown(event) {
    if (event.isComposing || event.keyCode === 229 || event.ctrlKey || event.metaKey || event.altKey) return;
    const editor = this.editorTarget.editor;
    if (event.key === "Enter") {
      event.preventDefault();
      event.stopImmediatePropagation();
      editor.recordUndoEntry("New line");
      if (event.shiftKey) editor.insertString("\n");
      else editor.insertLineBreak();
      return;
    }
    if (event.key !== "Tab") return;
    // Real list items keep the editor's normal nesting behavior.
    if (editor.attributeIsActive("bullet") || editor.attributeIsActive("number")) return;

    event.preventDefault();
    event.stopImmediatePropagation();
    const text = editor.getDocument().toString();
    let [start, end] = editor.getSelectedRange();
    const last = end > start ? end - 1 : end;
    const positions = [start === 0 ? 0 : text.lastIndexOf("\n", start - 1) + 1];
    for (let position = text.indexOf("\n", positions[0]); position >= 0 && position < last;
      position = text.indexOf("\n", position + 1)) {
      positions.push(position + 1);
    }

    editor.recordUndoEntry(event.shiftKey ? "Outdent" : "Indent");
    positions.reverse().forEach((position) => {
      if (event.shiftKey) {
        const length = text.slice(position).match(/^(?: {1,4}|\t)/)?.[0].length || 0;
        if (!length) return;
        editor.setSelectedRange([position, position + length]);
        editor.deleteInDirection("backward");
        start -= Math.min(length, Math.max(0, start - position));
        end -= Math.min(length, Math.max(0, end - position));
      } else {
        editor.setSelectedRange([position, position]);
        editor.insertString("    ");
        if (position <= start) start += 4;
        if (position <= end) end += 4;
      }
    });
    editor.setSelectedRange([start, end]);
  }
}
