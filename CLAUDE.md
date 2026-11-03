# Hotel ERP Frontend (Flutter)

**The rules and the build plan do not live in this repository.** They live in `Hotel-ERP-Backend`:

```
https://github.com/ganesh991212/Hotel-ERP-Backend
  CLAUDE.md             project rules, read every session
  docs/BUILD-PLAN.md    the single tracker
  docs/                 architecture, domain model, kitchen routing, API surface
```

Clone it alongside this repo and read it from there. **Do not copy it here**; copies drift.

## Rules most often broken in this repo
- The client never computes money. The server sends `_minor` paise; Flutter only formats it.
- No `Text('literal')` in feature code; strings live in ARB with descriptions.
- Theme tokens only; status is icon + label, never colour alone.
- Serialise concurrent token refreshes (refresh tokens rotate; reuse revokes the family).
- Never send prices from the client. Entitlements come from `GET /me/entitlements`; the server is the authority.
- Layouts must work on phone, tablet and large screens (kitchen TV).
- Repo is public for now: no secrets or real customer data.
