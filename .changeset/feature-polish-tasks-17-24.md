---
"share_circle": patch
---

Polish and reliability improvements (tasks 17–24)

- **Feature**: Added service worker (`priv/static/sw.js`) for web push notifications; registered in `app.js` with `navigator.serviceWorker.register`.
- **Fix**: `PushNotifications` JS hook clones the subscribe button before re-attaching the click listener on `updated()`, preventing duplicate event listeners from accumulating across LiveView re-renders.
- **Refactor**: Extracted `ShareCircleWeb.LiveHelpers.build_media_urls/2` to eliminate the identical private function duplicated across `FeedLive` and `ProfileLive`.
- **Feature**: Typing indicator in chat now resolves user IDs to display names (e.g. "Alice is typing…", "Alice and Bob are typing…") instead of the generic "Someone is typing…".
- **Fix**: Added `phx-debounce="300"` to all `phx-keyup` text inputs across feed, chat, and members pages to reduce unnecessary server round-trips.
- **Fix**: `ChatLive.handle_event("load_older", ...)` now guards against a nil cursor with a fast-path clause, preventing a crash if the button is clicked when no older messages exist.
- **Feature**: `FeedLive` and `ProfileLive` schedule a `:refresh_media_urls` message every 240 seconds to regenerate presigned media URLs before the 300-second TTL expires.
- **Fix**: All silent `{:error, _}` branches in `FeedLive`, `ChatLive`, and `NotificationsLive` now call `put_flash(:error, ...)` so users see feedback instead of nothing happening.
