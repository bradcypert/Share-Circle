---
"share_circle": patch
---

Bug fixes and code quality cleanup

- **Fix**: `ChatLive` was calling `PubSub.subscribe` on the old conversation instead of `unsubscribe` when switching conversations — users would accumulate stale subscriptions and receive ghost messages from conversations they had navigated away from. Added `PubSub.unsubscribe/1` and fixed the call in `handle_params`.
- **Fix**: `Posts.create_post` used `Enum.with_index` (return value unused) for side effects — changed to `Enum.with_index |> Enum.each` to correctly express intent and silence the credo warning.
- **Refactor**: `Enum.map |> Enum.join` → `Enum.map_join` in `ChatLive.conversation_display_name` and `MembersLive` error formatting.
- **Refactor**: Extracted `maybe_load_media_url/3` from `FeedLive.handle_info({:media_ready, ...})` to reduce nesting depth.
