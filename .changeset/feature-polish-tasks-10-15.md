---
"share_circle": minor
---

Polish and completeness tasks 10–15

- **Typing indicator**: Added `Chat.broadcast_typing/2` and `broadcast_typing_stopped/2`; message input fires `typing` event with 500ms LiveView debounce and a 3-second server-side timer to auto-stop
- **Feed pagination**: "Load more" button appears when `pagination.has_more` is true; appends posts and merges comment/reaction/media data
- **Chat message history**: "Load older messages" button at top of message list; prepends older messages using cursor pagination
- **Profile wall media**: Photo/video thumbnails now render on the profile wall, matching feed behaviour; includes "Load more" pagination
- **Chat auto-scroll**: `ScrollBottom` JS hook scrolls to bottom on mount and on each update when already near the bottom (within 200px), preserving manual scroll position when reading history
- **Push notification opt-in**: `PushNotifications` JS hook wires browser `PushManager.subscribe` to the LiveView; "Enable push" button on notifications page when `VAPID_PUBLIC_KEY` env var is set; subscription stored via `Notifications.register_push_subscription`
