---
"share_circle": minor
---

Phase 4: Events — calendar events, RSVPs, Events LiveView

- New tables: calendar_events, rsvps
- ShareCircle.Calendar context with create/update/delete events and upsert RSVP
- Policy extended: members can update/delete their own events; admins can update/delete any
- EventController and RsvpController API endpoints under /families/:id/events and /events/:id
- Events LiveView at /families/:id/events with create form, upcoming event list, and RSVP buttons
- Real-time updates via PubSub: event_created, event_updated, event_deleted, rsvp_updated
