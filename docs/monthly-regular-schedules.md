# Monthly regular schedules

Admins upload weekday schedules at **Import/Export Files → Monthly Regular
Schedules**. Select the attendance month, not the date of the upload. The default
is the current month before the 21st and the next month from the 21st onward.
It can be overridden for late files and corrections.

For example, a file uploaded November 21–25 can be assigned to December 2026.
A January 2027 file uploaded December 21–25 is stored separately. A December
file uploaded late on December 2 still applies to December.

Upload the original SS contract CSV directly, without spreadsheet formatting.
UTF-8 (including a BOM) and Shift_JIS/CP932 are decoded automatically. The export's
`対象年月` must match the selected attendance month on every row; a mismatch or a
mixed-month file rejects the whole upload. The student identifier is
`生徒情報：生徒コード`, not `生徒情報：管理ＩＤ`.

The raw SS export is curated automatically using the approved course codes in
`config/regular_schedule_courses.yml`: **111–122, 205–208, 301–310, 414, 415, 430,
431**. This is the complete 30-code selection supplied for SS's **test for jayson②**
filter, including codes absent from the example CSV. The CSV contains unwanted
courses, so its full list of codes must not be used as the allowlist. If the
configured list is ever empty, raw SS uploads are rejected without changing
schedules; formatted weekday CSVs remain available.

Only allowed `コースコード` values (column AG) contribute weekdays:

- Codes **414, 415, 430, 431** use **BB and BN** (schedule slots 2 and 4).
- Other allowed codes use **AV, BB, BH, BN, BT** (schedule slots 1–5).
- Other course rows and unused schedule slots do not contribute weekdays.

Columns are identified by their Japanese headers so reordered exports are safe.
No additional time-of-day heuristic overrides these course/slot rules. Repeated
rows and multiple lessons on the same weekday count as one attendance day per
student. A file containing no eligible course rows is rejected without changing
schedules. Fee rows with no schedule contribute no days. An included student
with no weekly weekdays in their eligible slots is rejected rather than silently
cleared. Unknown weekdays, non-weekly intervals and invalid or out-of-month date
ranges on eligible courses also reject the upload. Every row's `対象年月`, including
excluded course rows, must match the selected month to catch mixed-month exports.
This stores the month's weekday
pattern, not individual dated lessons: mid-month start/end dates do not restrict
the display to part of the month. Cancellations and holiday exceptions are not
represented by this monthly pattern; export the relevant attendance contracts.

The existing formatted CSV is also supported with these headers and explicit weekday values:

```csv
ssid,monday,tuesday,wednesday,thursday,friday
123456,false,true,true,false,false
```

Student IDs must already exist. The importer accepts UTF-8 (including a BOM) or
CP932 files, and true/false, t/f, 1/0, or yes/no values. Blank or unrecognised
weekday values, duplicate students in a formatted CSV, missing headers, and unknown student IDs
reject the entire upload. A correction updates students included in the file
for the selected month, regardless of their current membership category.
Other months remain intact. Use five explicit false values to record no regular
weekdays for a student.

For the current or a future attendance month, a successful upload also clears
existing weekdays for omitted students who are currently external, limited to
schools represented by students in the file. Omitted internal, reservation and
unknown students keep their days, as do students at other schools. Clearing is
part of the same transaction and records five false weekday values rather than
deleting the monthly schedule. Students with no saved schedule already have no
regular days; no empty records are created for them. Update student membership
from SS before importing schedules so the external category is current.

Historical imports never automatically clear omitted students based on today's
membership. A student who is external now retains their recorded past weekdays
and still matches those past regular days. Changing membership alone does not
alter any monthly schedule. Future regular-attendance bonuses must use the
schedule for the activity's month, rather than reject a past regular day because
the student is external today; bonus pricing has not been implemented here.
Schedule edits and automatic clearing are recorded with PaperTrail and the
uploading admin. Uploads without changes do not create repeat schedule versions.

The booking screen displays known schedules for the event's months, centered in
red below the student's name, such as `12月：火・水　1月：水・木`. Student information
shows the current and future known schedules. Each booked afternoon checks its
own calendar month's weekdays and displays only the red `通学日` label on a
match. Missing months never inherit another month's weekdays. A known schedule
with no weekdays is displayed as `12月：—`.

These are live web annotations. Uploading schedules updates the display on
existing and confirmed/locked bookings without saving or recalculating invoices,
changing prices, or sending emails. Previously sent emails and saved invoice
summaries do not change.

Existing undated schedules are preserved by the migration but are excluded from
monthly matching. Re-upload them for their actual attendance month; the
migration does not infer that month from creation or update timestamps.

Development examples can be added with the guarded seed script:

```sh
env -u DATABASE_URL PGHOST=/tmp PGPORT=5432 RAILS_ENV=development bundle exec rails runner script/seed_regular_schedule_demo.rb
```

It adds a December/January afternoon-only event with different weekdays for each
month and a confirmed booking created in October, under `customer@example.com`.
