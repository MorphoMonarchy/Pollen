// Feather ignore all
//======================================================================================================================
/*
                     ____       _ _               ____             __ _         ____  _______  __
                    |  _ \ ___ | | | ___ _ __    / ___|___  _ __  / _(_) __ _  |  _ \|  ___\ \/ /
                    | |_) / _ \| | |/ _ \ '_ \  | |   / _ \| '_ \| |_| |/ _` | | |_) | |_   \  /
                    |  __/ (_) | | |  __/ | | | | |__| (_) | | | |  _| | (_| | |  __/|  _|  /  \
                    |_|   \___/|_|_|\___|_| |_|  \____\___/|_| |_|_| |_|\__, | |_|   |_|   /_/\_\
                                                                        |___/
*/
//======================================================================================================================

/*

    NOTES:
        
        ~ DO NOT RENAME THIS FILE!!!
        
        ~ Continuously adding and deleting unique tags will result in a memory leak which will eventually slow things
          down due to the ds_maps that hold these tags growing in size, thus increasing lookup times. However, this
          will be resolved by re-compiling the game, and I do not imagine users doing this to such an excess that it
          will make much of a difference, so I will likely not fix this issue.

*/

global.pollen_config_pfx = [
    
    //--- DEFINE INDEPENDENT TYPES HERE ---//
    
    {
        type : "test",
        shape : pt_shape_pixel,
    },
    
    
    //--- DEFINE SYSTEMS HERE ---//
    
    {
        system : "test",
        emitterList : [
            {
                type: "test",
                width: 64,
                height: 64,
            },
        ],
    },
];