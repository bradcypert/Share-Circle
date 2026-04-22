---
"share_circle": minor
---

Phase 2: Media uploads and processing

- Storage adapter pattern with local filesystem and S3 stub implementations
- Two-phase upload flow: initiate (presigned PUT URL) → complete (create media item + enqueue processing)
- Background processing via Oban: image thumbnail generation (thumb_256, thumb_1024) using Vix/libvips; video transcoding (thumb_256 frame, video_720p H.264) via ffmpeg
- Posts now support media: photo, video, and album kinds with post_media join table
- New tables: media_items, media_variants, upload_sessions, post_media
- API endpoints: POST /api/v1/families/:id/uploads/init, POST /api/v1/uploads/:id/complete, GET /api/v1/media/:id/download
