# Own-snack fees

SS's `スナック持参有無` field maps `Own Snack` to `Child#own_snack = true`.
Blank means false. The allergy memo is not used for this decision.

Own-snack children pay no separate snack fee, including internal/external
students, normal afternoons and special activities. This rule already exists
in `TimeSlot#snack_charge_for` and is used by both the live booking price and
the saved invoice calculation. It does not subtract another snack fee from
the base course price or from the regular-day afternoon price.

Confirmed activity cards now show the own-snack/no-fee explanation as well.
They previously showed a snack checkmark even when no snack fee was charged.
The invoice includes one short `おやつ代なし（おやつ持参）` line when an
own-snack child books an activity that would otherwise carry a snack fee.
It is omitted when all booked activities have no snack or their snack fees
are already waived by regular-day pricing. This adds no discount or extra
deduction; it explains the existing exemption.

After deployment, run:

```sh
bundle exec rails runner script/audit_winter_2026_own_snack.rb
```

This audits saved Winter School 2026 summaries for children currently marked
own-snack. It uses a read-only database transaction, reports invoices with
recorded snack charges, and exits with status 1 if any are found. It does not
prove that every unrelated component of an invoice is correct.

If stale snack charges are found, review and preview a correction to those
specific invoices, preserving registrations, confirmation status and other
adjustments. Do not use a blanket bundle recalculation for this cleanup.

The production check on November 2 found 11 matching invoices and no recorded
snack charges. No production prices were changed by that check.
