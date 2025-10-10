// Feather ignore all
//======================================================================================================================
/*
             ____       _ _               ____             __ _         __  __
            |  _ \ ___ | | | ___ _ __    / ___|___  _ __  / _(_) __ _  |  \/  | __ _  ___ _ __ ___  ___
            | |_) / _ \| | |/ _ \ '_ \  | |   / _ \| '_ \| |_| |/ _` | | |\/| |/ _` |/ __| '__/ _ \/ __|
            |  __/ (_) | | |  __/ | | | | |__| (_) | | | |  _| | (_| | | |  | | (_| | (__| | | (_) \__ \
            |_|   \___/|_|_|\___|_| |_|  \____\___/|_| |_|_| |_|\__, | |_|  |_|\__,_|\___|_|  \___/|___/
                                                                |___/
*/
//======================================================================================================================


// Whether live/hot-reloading is enabled. Set this to 'false' when making a ship build of your project.
#macro POLLEN_LIVE_EDIT true


// Whether Pollen should automatically import global.pollen_config_pfx after initialization
#macro POLLEN_AUTO_IMPORT_CONFIG_PFX true


// Set Pollen's logging verbosity (0 = errors only, 1 = warnings & errors, 2 = verbose)
#macro POLLEN_LOG_LEVEL 2


// If you delete a property in global.pollen_config_pfx, you can choose whether the type/emitter/system
// should default to a constant default value or to the last value it was defined as.

// WARNING: Setting this to "true" may cause particles to not appear as they would when initially 
// compiling the game. Furthermore, you may experience issues with emitterLists that may result in a crash.
#macro POLLEN_FALLBACK_TO_PRIOR_VALUES false