# Rashimba inquiries

The sponsor form at `rashimba.com/contact/` and parent release-notification form at
`rashimba.com/parents/` submit to the Rails application on `kids-up.app`.
Records live in `rashimba_inquiries`, separately from school inquiries. Only the
`admin` role can list, view, review, or delete them. The admin navbar has a
**Rashimba Inquiries** tab, with type/status filters, search, pagination, private
notes, and per-recipient email delivery timestamps. Review statuses are Pending,
Reviewed, and Resolved. Deletion is permanent and cancels delivery that has not
started; it cannot recall sent mail.

## API

Send flat JSON or form-encoded fields with an approved `Origin` header:

| Endpoint (POST) | Form fields |
| --- | --- |
| `/api/rashimba/sponsor_inquiries` | `company`, `email`, `name`, optional `phone` and `message`, `privacyConsent: "accepted"` |
| `/api/rashimba/release_notifications` | `email`, optional `child_age`, `privacy_consent: "agreed"` |

Both forms also send `submission_key` (a UUID), an optional `recaptcha_token`, and an empty
`website` honeypot. Email and consent are required for both; company and name are
required for sponsors. Allowed ages are `0-2`, `3-5`, `6-8`, `9-12`, and `13+`.
Names/company are limited to 200 characters, emails to 254, phone to 40,
message/notes to 5,000, and requests to 32 KiB. Metadata and internal workflow
fields cannot be supplied by public clients.

Success is HTTP **202**, meaning the inquiry and delivery job were saved, with
`{"status":"accepted","message":"…"}`. It does not mean SMTP delivery has completed.
Errors use `{"errors":["…"]}`: 400 malformed field types, 403 unapproved origin,
409 submission-key conflict, 413 oversized body, 422 validation/CAPTCHA failure,
429 rate limit (`Retry-After: 3600`), or 503 CAPTCHA/queue unavailable.
There is no public read API.

Retry an unchanged payload with the same UUID after a lost response. Duplicate
requests create neither another record nor another delivery job. Use a new UUID
if the form contents change. Limits are ten accepted inquiries per IP and three
per email in a rolling hour, shared by both forms. PostgreSQL advisory locks
serialize concurrent submissions for an IP, email, or submission key. Validation,
rate limits, duplicate prevention, and the honeypot remain active without CAPTCHA.
Origin restrictions do not authenticate clients.

## Deployment

1. Run `bin/rails db:migrate` and deploy the Rails changes. Keep the existing
   Solid Queue worker running. Inquiry creation and job enqueue use the same
   PostgreSQL database in this application's current Solid Queue configuration;
   keep that shared-database arrangement for atomic acceptance.
2. Set `RASHIMBA_ALLOWED_ORIGINS` if needed. Defaults are
   `https://rashimba.com,https://www.rashimba.com,https://rashimba-staging.pages.dev`.
   If this variable is already set on Rails, add `https://rashimba-staging.pages.dev`
   to its value to test from that site; the variable replaces the defaults.
   Staging submissions use the same delivery flow and recipients as production:
   enter a mailbox you control to receive the confirmation, and expect an internal
   notification to `p-jayson@kids-up.jp` too.
   Use exact origins without paths or trailing slashes. For local development,
   include the Vite origin explicitly,
   e.g. `http://127.0.0.1:5173`. Restart Rails after changing this setting.
3. CAPTCHA is optional for now, including in production. Leave
   `RASHIMBA_RECAPTCHA_SECRET_KEY` and `VITE_RASHIMBA_RECAPTCHA_SITE_KEY` unset
   to accept submissions without it. To enable it later, register a Google
   reCAPTCHA **v3** key for the frontend hostname(s). Set
   `RASHIMBA_RECAPTCHA_SECRET_KEY` on Rails and
   `VITE_RASHIMBA_RECAPTCHA_SITE_KEY` in the frontend build environment.
   The secret belongs only on Rails. Verification checks the hostname, expected
   action (`rashimba_sponsor` or `rashimba_release_notification`), and score >= 0.5.
   Once the Rails secret is configured, all environments require a valid token
   and reject submissions when verification fails or is unavailable. See
   [Google's reCAPTCHA v3 setup](https://developers.google.com/recaptcha/docs/v3).
4. Build/deploy `../rashimba-site` with `npm run build`.
   `VITE_RASHIMBA_API_BASE_URL` defaults to `https://kids-up.app`.
5. Complete the SES sender setup below, then test both forms with a mailbox you
   control. Check the admin record and both delivery timestamps. A frontend success
   message confirms acceptance; check actual inbox delivery separately.

## Sender and DNS

The two transactional emails use `らしんば運営事務局 <notifications@rashimba.com>`. One goes
to the submitter; another goes to `p-jayson@kids-up.jp`, with the submitter as
Reply-To. Sponsor confirmations use `info@rashimba.com` as Reply-To; parent
confirmations use `support@rashimba.com`. Only the internal notification includes
the submitted message and admin link.

Sponsor confirmations include the submitted company/name, the service guide,
and the supplied sponsor message. Parent confirmations use the supplied release
registration message, including the December 2026 planned launch and social links,
without an attachment. The templates are
`app/views/rashimba_inquiry_mailer/sponsor_confirmation.text.erb` and
`app/views/rashimba_inquiry_mailer/parent_confirmation.text.erb`.

The sponsor PDF is bundled at
`app/mailers/attachments/rashimba-service-guide.pdf` and sent as
`らしんば_サービス案内資料.pdf` (`application/pdf`). This is the original 12-page,
6,046,043-byte PDF supplied in the project root, moved without changing its contents.
It is included by the existing Docker build and does not need a public URL or S3
configuration. To update the brochure, replace that file and redeploy the web and
queue worker together. If the file is missing or unreadable, delivery fails and
retries rather than sending an email claiming to include an absent attachment.

Use the existing SES SMTP credentials (`SES_USERNAME`/`SES_PASSWORD`) and Tokyo
endpoint (`ap-northeast-1`). In that AWS account and region, create/verify the
`rashimba.com` domain identity using Easy DKIM. SES supplies the CNAME names and
values to add at the DNS provider hosting **rashimba.com**. These are generated
for the identity and cannot be inferred from the website or invented here. Once
verified, the domain authorizes this sender address. Ensure the SMTP principal
can send from this identity and the SES account has production sending access.
See [SES identity verification](https://docs.aws.amazon.com/ses/latest/dg/creating-identities.html).

Optional: configure a custom MAIL FROM subdomain such as `mail.rashimba.com` in
SES. Its DNS records for the current region are:

| Type | Name | Value |
| --- | --- | --- |
| MX | `mail.rashimba.com` | `10 feedback-smtp.ap-northeast-1.amazonses.com` |
| TXT | `mail.rashimba.com` | `v=spf1 include:amazonses.com ~all` |

Publish the actual values shown by SES for the chosen subdomain. Keep existing
mailbox MX records on the root domain. DKIM and any DMARC policy belong to the
sender domain; hosting the Rails app on `kids-up.app` does not require moving
the frontend or its mailbox hosting. See [SES custom MAIL FROM](https://docs.aws.amazon.com/ses/latest/dg/mail-from.html).

SMTP failures raise for these emails and retry up to five job executions.
Completed recipient deliveries are tracked individually, so retrying a failed
internal notification does not normally repeat an already sent confirmation.
Failed jobs are visible to admins at `/jobs` and can be retried there after fixing
sender configuration. Timestamps record SMTP acceptance, not final inbox delivery.
As with SMTP generally, a process failure after sending but before recording the
timestamp can result in a duplicate on retry. No live emails or DNS changes are
made by the implementation tests.
