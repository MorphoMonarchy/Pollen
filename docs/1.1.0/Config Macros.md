# Config Macros

The following macros can be found in the `scr_pollen_config_macros` script.  
You can adjust these macros to customize how Pollen behaves in your project.  
When updating Pollen, be sure to back up any custom macro settings and restore them after updating the library.

---

## `POLLEN_LIVE_EDIT`
Default: `true`  

Determines whether **live/hot-reloading** is enabled. Set to `false` when ready to ship the game.

## `POLLEN_ENABLE_DEBUG`
Default: `true` 

Whether to enable the debug tools for Pollen such as the dbg_view.

## `POLLEN_AUTO_IMPORT_CONFIG_PFX`
Default: `true`

Whether Pollen should automatically import global.pollen_config_pfx after initialization. If false, you must manually import effects using [`Pollen.ImportPfx()`](https://morphomonarchy.github.io/Pollen/#/1.0.0/Import%20Particles?id=importpfxdata-%e2%86%92-undefined).

## `POLLEN_LOG_LEVEL`
Default: `2`

Sets the log verbosity level to one of three settings: `0 = errors only`, `1 = warnings & errors only`, & `2 = verbose`

## `POLLEN_FALLBACK_TO_PRIOR_VALUES`
Default: `false`  

Controls whether deleted properties in `global.pollen_config_pfx` fall back to a **constant default value** (`true`) or to the **last value previously defined in the type/emitter/system** (`false`).  