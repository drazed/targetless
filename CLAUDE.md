# Targetless - Vendetta Online HUD Plugin

## What This Is
A Lua plugin for **Vendetta Online** (space MMO) that provides a real-time target list HUD, ore scanner, and tactical tracking. Runs inside the game's **LME** (Lua Module Environment) using **IUP** for UI and **Neoloader** (v3 API) for plugin registration.

**Author**: Adrian (drazed) Zakrzewski — drazed@gmail.com / http://targetless.com/

## Architecture

**Pattern**: Event-driven, triple-buffered, pre-allocated widget pool.

### Data Flow
1. Game event (TARGET_CHANGED, LEAVING_STATION, etc.) fires a handler in `main.lua`
2. `Controller:update()` → `Buffer:reset()` starts async ship collection
3. `Buffer:step()` processes one ship per tick via `Timer:SetTimeout()` (prevents lag)
4. `Buffer:switchbuffers()` atomically swaps display buffer
5. `Controller:populatecells()` builds unified list (pinned + mode items)
6. `CellList:populate()` mutates pre-allocated cell widgets in-place
7. IUP renders the changes

### Display Modes (cycle order)
PvP → Cap → Bomb → All → Ore → none

### Key Globals
- `targetless.Controller` — main orchestrator (mode, pin table, cell list, buffers)
- `targetless.var` — all config/state (settings, fonts, layouts, colors)
- `targetless.RoidList` — sector-persistent asteroid list
- `targetless.api` — shared API (radarlock mechanism)

## File Structure

```
main.lua              — Entry point, event handlers, game commands, IUP assembly
var.lua               — Config variables (gkini persistence), fonts, layouts, ore colors
api.lua               — Shared API (radarlock for plugin conflict prevention)
touchless.lua         — Android touch/swipe input handling

lists/
  Controller.lua      — Main orchestrator: buffers, modes, cells, sorting, navigation
  Buffer.lua          — Async triple-buffered ship data collector
  Ship.lua            — Player/NPC/capship data object + IUP widget rendering
  CellList.lua        — Pre-allocated cell container (pin + ship containers)
  iupCell.lua         — Individual HUD row widget (mutated in-place, never destroyed)
  List.lua            — Simple sorted generic list
  RoidList.lua        — Sector-persistent asteroid collection (pickled to game notes)
  Roid.lua            — Asteroid data object with ore composition

ui/
  ui.lua              — Main tabbed dialog (Home/Binds/Options/Ore)
  home_ui.lua         — About/help/credits tab
  options_ui.lua      — Settings panel (filters, display, auto-pin)
  controls_ui.lua     — Keybind configuration (presets + custom)
  roid_ui.lua         — Ore scanner/editor UI
  ui_matrix.lua       — Data table widget helper
```

## Coding Conventions

- **Namespace**: Everything under `targetless.*`
- **OOP**: Prototype-based (`Class:new()` returning metatabled tables)
- **Module loading**: `dofile()` (not `require()`)
- **Config storage**: `gkini.ReadString/WriteString` (game INI) + system notes pickle for roids
- **Color codes**: Vendetta format `\127rrggbbaa` (alpha byte, `o` closes)
- **Layout templates**: Tag-based strings like `<health>`, `<name>`, `<distance>`, `<ore>`
- **Async work**: `Timer():SetTimeout()` for deferred/non-blocking operations
- **Widget strategy**: Pre-allocate cells, mutate properties, never destroy — hide with `visible="NO"`

## Key Design Decisions

- **Cell-based rendering**: Fixed widget pool eliminates GC pressure and lag in large fleet combat
- **Triple buffering**: Prevents mid-frame display inconsistency during async data collection
- **Cross-mode pinning**: Pinned items appear across all display modes (pin table uses "roid:" prefix keys for roids to avoid ID collision with ships)
- **One-ship-per-tick scanning**: Spreads CPU cost across frames to maintain smooth gameplay
- **Roid distance updates**: Independent background timer, one roid per tick, locks both `var.lock` and `api.radarlock` to prevent TARGET_CHANGED from triggering expensive rebuilds

## Recent Refactoring History (Claude-assisted)

### Stage 0 — Cleanup & bug fixes
- Fixed operator precedence bug: `if not self.rush == true` → `if not (self.rush == true)`
- Removed duplicate shadowed `targetchild` in Ship.lua
- Extracted `Controller:updatetotalcolors()` helper (replaced ~20 lines of duplication)

### Stage 1 — Cell-based rendering (experimental)
- Added `iupCell.lua` (Cell class) and `CellList.lua` (CellList pool)
- Ships display in compact single-row cells with health bars, standings, target highlighting
- Pinned targets render in separate `hudrightframe` container at top of list
- Added `usecells` toggle for A/B testing against legacy renderer

### Stage 2+3 — Permanent cells, roids, cross-mode pinning
- Removed legacy IUP rendering path entirely (cells-only)
- Removed `usecells` toggle and deleted `CellBuffer.lua`
- Stripped `List.lua` and `RoidList.lua` to data-only (removed `getiup` methods)
- Added roid rendering to `iupCell.lua` (colored ore text, no bars/standings)
- Unified ship+roid display in `populatecells()` with cross-mode pinning
- Decoupled roid distance updates into independent background timer

### Ghost list fix
- `appendiups()` was being called from OnHide without cleaning up old widget trees → duplicate widgets, frozen ghost lists
- Fix: hide all cells/containers, Detach (not Destroy) old trees before creating new ones
- Store `centerHUDinfo` on `targetless.var` for cleanup on subsequent calls
- Null out references in `re_attach()` since VO destroys widgets on HUD_RELOADED

### Cleanup pass
- Removed 7 unused variables from var.lua, dead code from Ship/Roid/Controller/options_ui
- Fixed "Bombships" → "Bomb" typo in `switchback()`
- Fixed cap display order to "PlayerName ShipType"
