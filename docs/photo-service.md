# Photo service

For Seasonal School events using the 2026 pricing rules, photo service is
available only when the child attends a morning or special activity in that
same event. Regular afternoon-only bookings and children with no activities
are ineligible. An eligible activity already saved on another invoice for the
same child and event also counts, including confirmed bookings. A sibling's
morning booking does not make an afternoon-only child eligible.

The parent banner stays visible with a disabled, greyed-out switch and a clear
explanation for ineligible bookings. Selecting a morning or special activity
enables it. Removing the last eligible activity unchecks it and removes its
fee from the live total. Valid confirmed photo selections stay checked and
locked. The availability explanation is provided in English and Japanese.
The banner has separate before/after-selection wording and a shared sibling-fee
notice. Winter School 2026 uses the supplied December 25–January 7 wording
through January 7, 2027 (Japan time), reverting to the general morning/special
wording from January 8. This is a copy override only: it does not restrict
eligibility dates or remove special activities from eligibility. Other events
always use the general wording. Mobile text wraps without clipping, and the
footer uses compact spacing and a smaller banner.

The server applies the same rule to submitted options and invoice summaries.
Saving or explicitly recalculating an ineligible invoice removes its photo
registration and charge. Sibling synchronization adds photo service only to
eligible children. Editing an afternoon-only child's booking does not opt
eligible siblings out of photo service. If the family has already selected photo
service for this event, it is selected automatically when another child becomes
eligible, including when a morning is added to an existing afternoon booking.
With no existing family selection, becoming eligible only enables the switch.
Switching photo service off prompts for confirmation that saving will also
remove it from eligible siblings' bookings. This explicit opt-out is carried
through the preview and save; removing an activity alone is not a family opt-out.

This rule leaves party events and older pricing rules unchanged. Existing
production invoices are not migrated automatically on deployment; use an
explicit invoice recalculation to remove old afternoon-only photo charges.
Simply viewing a booking does not rewrite its saved invoice. The live booking
form excludes an ineligible old photo selection, while the saved invoice
retains its previous total until a save or recalculation occurs.
