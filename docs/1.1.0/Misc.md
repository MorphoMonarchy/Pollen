# Misc

Additional util and debug methods.

### `DestroyAll()` → `undefined`
Destroys all Pollen Types, Emitters, & Systems and clears all their data.

| Parameter | Datatype | Purpose |
|------------|-----------|----------|
| None |  |  |

### `DebugViewRefresh()` → `undefined`
Clears and repopulates the dbg view with dbg sections and controls that watch the currently selected system.

| Parameter | Datatype | Purpose |
|------------|-----------|----------|
| None |  |  |

### `DebugFormatGmlData(system_or_tag)` → `string`
Gets the particle info struct for a gml part system and formats the data into a "pretty print" string.

| Parameter | Datatype | Purpose |
|------------|-----------|----------|
| `system_or_tag` | Pollen.System or string or undefined | The pollen system or tag to get particle info data from. Pass 'undefined' to default to the currently selected part system in the Pollen dbg view|

### `DebugDumpGmlData(system_or_tag)` → `undefined`
Shows a debug message (log) of a "pretty print" formatted gml part system. **NOTE: the `POLLEN_LOG_LEVEL` macro must be set to `2` in order to see the log.**

| Parameter | Datatype | Purpose |
|------------|-----------|----------|
| `system` | string or Pollen.System or undefined | The pollen system pr tag to dump particle info data from. Pass 'undefined' to default to the currently selected part system in the Pollen dbg view|

### `DebugCopyGmlData(system_or_tag)` → `undefined`
 Copies "pretty print" formatted gml part system data into clipboard. Defaults to the currently selected part system in the Pollen dbg view.

| Parameter | Datatype | Purpose |
|------------|-----------|----------|
| `system` | string or Pollen.System or undefined | The pollen system or tag to copy particle info data from. Pass 'undefined' to default to the currently selected part system in the Pollen dbg view|