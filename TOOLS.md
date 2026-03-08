# TOOLS.md - Local Notes

Skills define _how_ tools work. This file is for _your_ specifics — the stuff that's unique to your setup.

## What Goes Here

Things like:

- Camera names and locations
- SSH hosts and aliases
- Preferred voices for TTS
- Speaker/room names
- Device nicknames
- Anything environment-specific

## Examples

```markdown
### Cameras

- living-room → Main area, 180° wide angle
- front-door → Entrance, motion-triggered

### SSH

- home-server → 192.168.1.100, user: admin

### TTS

- Preferred voice: "Nova" (warm, slightly British)
- Default speaker: Kitchen HomePod
```

## Why Separate?

Skills are shared. Your setup is yours. Keeping them apart means you can update skills without losing your notes, and share skills without leaking your infrastructure.

---

Add whatever helps you do your job. This is your cheat sheet.

## OpenClaw Local Commands

### POI Search

- AMap Web key is already configured locally for OpenClaw POI lookups.
- Use the bundled local CLI first, not external web search.

```bash
python3 ~/.openclaw/skills/poi-discovery-guide/amap_poi.py geo "上海静安寺"
python3 ~/.openclaw/skills/poi-discovery-guide/amap_poi.py around --location 121.4454,31.2297 --keywords 咖啡 --radius 1000 --limit 5 --output markdown
python3 ~/.openclaw/skills/poi-discovery-guide/amap_poi.py text "联合办公" --city 上海 --limit 5 --output markdown
```

### Flight Search

- Use the local `flight-search` tool before any web-search fallback.

```bash
uvx flight-search SHA TYO --date 2026-03-09 --limit 3 --output json
```
