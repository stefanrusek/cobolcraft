---
spile: ticket
id: CC-0030
type: feature
status: draft
owner: stefanrusek
resolution:
blocked_by: []
created: 2026-11-23
relations:
  depends_on: []
  relates_to: [CC-0001, CC-0038]
  supersedes: []
implementation: []
---

# CC-0030: A lectern opens a window and holds a book with pages

## Summary

Using a lectern with a book opens its window, the page buttons turn the page and pulse the comparator, and a written
book has its pages from written_book_content.

## User Stories

### As a Player, I want to read a book on a lectern

- Given a lectern holding a book, when I use it, then the lectern window opens (docs/protocol 40-5 section 4) and the
  page buttons change the page and give the comparator pulse (31-4 section 3.7).
- Given a written book, when its pages are counted, then the count comes from written_book_content.

## Functional Requirements

- FR-001: The core has a lectern window code path (Use Item On opens it; Container Button Click reaches
  BE4-LECTERN-BUTTON).
- FR-002: The data component patch of written_book_content decodes with the wire layout of Filterable<T>.

## Open Questions

- 25-6 open question 5: the wire layout of Filterable<T>. Needed for the page count of a written_book_content patch; a
  clean-room reader round comes first (see CC-0038).

## State at the end of the polish run (2026-11-23)

- Not built. Task line T29570 (lanes/p46h.md): the core has no lectern window (Use Item On on a lectern opens nothing,
  STATION-BUTTON serves only the station kinds of MENU-STATION-KIND), BE4-LECTERN-BUTTON has no caller, and the core
  has no Edit Book handler, so no book has pages today. The window itself is documented well enough (40-5 section 4);
  only the book content needs the reader round.
