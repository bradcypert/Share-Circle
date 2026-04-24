---
"share_circle": minor
---

Media uploads in feed posts

- Added `PresignedPut` JavaScript uploader to `app.js` — sends files directly to presigned PUT URLs (local storage or S3) with XHR progress tracking
- Updated `FeedLive` to accept up to 4 photo/video attachments per post via Phoenix LiveView external uploads
- File picker in post composer with drag-and-drop support on the composer card
- Upload preview grid with per-file progress bars and cancel buttons
- Posts with media display thumbnail images in feed (single image or 2-column grid for albums); videos show a play button overlay
- Media variant URLs are pre-generated on mount and updated in real-time when the background processing worker marks media as ready (via `media_ready` PubSub event)
- Gracefully handles pending/processing state — shows "Processing…" until variants are ready
