# Editing Event Fields across schools

Open an event's full edit form and check **Apply Event Fields to all … events**
to update every event with the same saved name. The Bulk Events page also has
an **Edit Event Fields for all … events** link that opens this form with the
batch option selected. Ordinary edits keep the batch option unchecked.

The batch includes the name, description, images, start/end dates, goal, price
lists, early-bird settings, and release status. Each event keeps its school
assignment. Changes to nested event options or activities belong to the source
school and are not copied to other schools.

The group is selected using the source event's name before the update, so a
rename updates the original group. The update is transactional, including
Action Text descriptions: a validation error rolls back changes at every school
and appears on the form.

## Description editing

The editor keeps the existing Action Text/Trix storage format. Its stylesheet
loads from the application manifest header, with a normal block layout and
visible list markers both while editing and when displaying descriptions.

Word/Google Docs paste removes document-specific spacing and hanging indents
while retaining supported rich text such as bold, italics, headings, links,
lists, and intentional empty paragraphs. Exact word-processor page layout,
fonts, and tables are outside the editor's supported format.

Enter goes through Trix's editor API once per key press, preventing duplicate
browser insertion. Shift+Enter inserts a soft break. IME composition and
modifier shortcuts retain their native handling. Tab/Shift+Tab add or remove
indentation on the selected text lines. List items use Trix's normal nesting.

```sh
bundle exec rspec spec/requests/event_batch_fields_spec.rb spec/system/event_description_editor_spec.rb
```

Coverage includes all Event Fields across forty schools, group renaming,
school-specific records, rollback and authorization, pasted Word/Docs HTML,
Enter, Japanese text, selected-line indentation, list nesting, and saved content.
