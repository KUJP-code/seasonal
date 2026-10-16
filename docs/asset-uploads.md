# Asset uploads

The Upload Assets page sends one image per request, in sequence. A batch may
contain any number of images. Each image must be at most 9 MiB, leaving room for
multipart fields under the 10 MiB request limit configured in `Dockerfile`.
The previous form sent the whole batch in one request, so its combined size
could trigger an HTTP 413 response before Rails received it.

The page shows sending progress, waits for storage confirmation, and reports
success or failure for each image. A failed image does not stop the remaining
files. Retry failed uploads resends only retryable failures. Invalid types,
empty images, and oversized images need a new file selection.

Each selected image has a stable upload identifier. Repeating a successful
request returns its existing asset, which prevents duplicates after a lost
response. The blob record and storage upload share a transaction, so storage
exceptions do not leave asset records pointing to missing files. Errors are
logged with the Rails request ID, and the response contains a user-facing error.
Files retain the existing environment/folder/subfolder key structure used by
the activity and event image selectors.

For files larger than this per-image limit, a future option is browser-to-S3
direct uploads. That requires configuring bucket CORS and an authenticated
upload/finalization flow. The current queue uses the existing storage setup.

Verification:

```sh
bundle exec rspec spec/requests/uploads_spec.rb spec/system/asset_uploads_spec.rb spec/concerns/blob_findable_spec.rb
```

The browser coverage includes twelve PNGs whose combined size exceeds 10 MiB,
partial storage failure and retry, client-side size rejection, and HTML proxy
responses for HTTP 413 and 502.
