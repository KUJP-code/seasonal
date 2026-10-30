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

- KeepUP codes **414, 415, 430, 431** use **AV and BH** (schedule slots 1 and 3).
  BB and BN contain evening lessons and are excluded for these codes.
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
deleting the monthly schedule. No empty records are created for students without
a recent schedule. If an omitted external student has a schedule in the preceding
five months, the upload saves an explicit no-days schedule for the upload month
to stop older weekdays from carrying forward. Update student membership
from SS before importing schedules so the external category is current.

Historical imports never automatically clear omitted students based on today's
membership. A student who is external now retains their recorded past weekdays
and still matches those past regular days. Changing membership alone does not
alter any monthly schedule. Regular-day labels use the activity month's
effective schedule, even if the student is external today. The afternoon price
and snack waiver apply only to students who are currently internal.
Schedule edits and automatic clearing are recorded with PaperTrail and the
uploading admin. Uploads without changes do not create repeat schedule versions.

For staff only, booking screens display one set of weekdays for internal students,
such as `月・水・金`, centered in red below the student's name. Other student
categories do not display the weekday summary. Use the effective schedule for the
event's final month, or the latest event's final month on combined booking lists.
Do not show month labels or earlier weekday patterns. Staff student information
shows only the latest uploaded, dated schedule's weekdays, including an upcoming
month before it begins. This display does not change the activity-month lookup
used for pricing and attendance matching.
Each booked afternoon checks its own calendar month's
effective weekdays and displays the red `通学日` label on a match for staff.
Parents do not see monthly weekdays, schedule tables, or regular-day activity
badges on student pages, booking forms, booking lists, invoices, or confirmation
previews. Eligible regular-day prices and snack waivers still apply and are
shown as pricing information.

If a student has no upload for an activity's month, use their most recent
schedule at or before that month, up to **five calendar months earlier**. For
example, January 2027 activities can use an August–December 2026 upload, with
December taking priority. Older schedules, undated legacy records, and schedules
for months after the activity are excluded. A January upload always overrides
December's pattern for January activities. A later upload for an older attendance
month does not override a newer attendance month's record.

An explicit schedule with all weekdays false stops older days from returning;
it is displayed as `—`. The same lookup controls regular-day labels,
the optional afternoon price, and snack fee waivers. Lookups do not copy records
into future months or rewrite saved invoices.

These are live web annotations. Uploading schedules updates the display on
existing and confirmed/locked bookings without saving or recalculating invoices,
changing prices, or sending emails. Previously sent emails and saved invoice
summaries do not change.

## Optional regular-day afternoon pricing

The admin price list editor has an optional **Regular-day afternoon price**.
Leave it blank to retain normal session packages and snack fees. An explicit
zero is a free regular-day afternoon. Only currently internal students are
eligible, using the event's member price list. External, reservation and unknown
students retain normal package pricing and snack fees even if their price list
has a regular-day amount or they have recorded regular weekdays. Their recorded
monthly attendance is preserved, as is the own-snack exemption.

When the member price list has a value, Seasonal School afternoons other than
special or party activities automatically use that amount on an internal student's
regular lesson days. No per-activity switch is needed. Morning activities and
afternoons with no eligible exact-month or recent prior schedule retain normal pricing.

Qualifying afternoons are excluded from the normal session package count and
have no snack fee. Other sessions keep their existing package/batch rules and
snack fees, including the own-snack exemption. Activity surcharges and selected
options still apply separately. The live booking total and saved invoice use
the same rules, and the invoice lists regular-day afternoons separately.

For example, with a 5,500-yen single session, 22,000-yen five-session package,
and 2,700-yen regular-day afternoon, ten sessions with four qualifying afternoons
cost 22,000 + 5,500 + (2,700 × 4) = **38,300 yen** before any chargeable snacks,
options or activity surcharges. Monday/Wednesday afternoons for a Monday/Tuesday
student cost 5,500 + 225 + 2,700 = **8,425 yen**.

Use a price list with this field blank for an event without this offer. Price
lists can be shared by multiple events; editing a shared list changes the
configuration for every event using it. Saving a rate or uploading schedules
does not automatically rewrite invoices or send emails. Existing locked
invoices keep their saved totals; explicit invoice recalculation applies the
current rates and monthly schedules.

Existing undated schedules are preserved by the migration but are excluded from
monthly matching. Re-upload them for their actual attendance month; the
migration does not infer that month from creation or update timestamps.

Development examples can be added with the guarded seed script:

```sh
env -u DATABASE_URL PGHOST=/tmp PGPORT=5432 RAILS_ENV=development bundle exec rails runner script/seed_regular_schedule_demo.rb
```

It adds a December/January afternoon-only event with different weekdays for each
month and a confirmed booking created in October, under `customer@example.com`.
