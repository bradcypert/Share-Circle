---
"share_circle": minor
---

Phase 3: Chat — conversations, messages, typing indicators, read receipts

- New tables: conversations, conversation_members, messages
- Family-wide conversation auto-created when a family is created or an invitation is accepted
- Chat context with send/edit/delete messages, mark-read, and conversation management
- ConversationChannel (WebSocket) for real-time delivery, typing indicators (typing.start/stop), and read receipts
- Chat LiveView at /families/:id/chat with sidebar conversation list and real-time message stream
- API endpoints: list/create/show conversations, send/edit/delete messages, mark read
