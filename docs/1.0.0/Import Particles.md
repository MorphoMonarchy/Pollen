# Import particles

Use these methods to import particle data into Pollen.

### `ImportPfx(data)` → `undefined`
Import data from a GML 'JSON' array (see info about setting up 'JSON' in the 'Config JSON' section of the manual)

| Parameter | Datatype  | Purpose |
|-----------|-----------|---------|
|`data` |array |The array to parse and import data from |

### `ImportType(import_data, type_data)` → `undefined`
Copy data from a GML 'JSON' type struct into a Pollen.Type instance (see info about setting up 'JSON' in the 'Config JSON' section of the manual)

| Parameter | Datatype  | Purpose |
|-----------|-----------|---------|
|`import_data` |struct |The struct to parse and import data from |
|`type_data` |Pollen.Type |The Pollen.Type instance to copy the data to |

### `ConvertGmlPartAssetToPollenStruct(asset, pollen_system, [ignore_emitter_list])` → `Pollen.System`
Copy data from a GML part system *asset* (created using GM's particle editor) into a Pollen.System instance

| Parameter | Datatype  | Purpose |
|-----------|-----------|---------|
|`asset` |GM Particle Asset |The GM particle to copy data from |
|`pollen_system` |Pollen.System |The Pollen.System instance to copy the data to |
|`[ignore_emitter_list]` | bool |Whether to skip copying the emitter data (defaults to 'false')|