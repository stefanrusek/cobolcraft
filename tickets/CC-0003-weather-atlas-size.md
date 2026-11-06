---
spile: ticket
id: CC-0003
type: bug
status: draft
owner: stefanrusek
resolution:
blocked_by: []
created: 2026-11-06
relations:
  depends_on: []
  relates_to: []
  supersedes: []
implementation: []
---

# CC-0003: Weather atlas stays small with any pack image sizes

## Summary

T1080 placed the two environment images (rain and snow) side by side in a repeat-wrapped atlas. The atlas height is
the least common multiple of the two image heights. With the built-in 16-pixel images that is 32 × 16, but a resource
pack with unusual heights (for example 17 and 19 pixels) makes the atlas very tall. The atlas must stay bounded for
any valid pack.

## User Stories

### As a Pack creator, I want any valid weather image sizes to work

- Given a pack whose rain and snow images have different, co-prime heights, when it is enabled, then weather draws
  correctly and the environment atlas is no larger than the two images need.
- Given images whose combined size cannot be supported, when the pack is enabled, then one console line names the pack
  and the images (FR-012 non-fatal), and the built-in weather images are used.

## Notes

> [!NOTE]
> The current code is `client/src/weather-render.cob` and `client/src/submit.cob` (T1080). Only two 16-pixel images
> are tested. A separate texture per image avoids the least common multiple altogether.
