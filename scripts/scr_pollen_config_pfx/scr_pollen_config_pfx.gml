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
    
    {type: "type_example_min"}, 
    
    {
        type : "type_example_full",
        // shape: pt_shape_line,
        sprite : {id: spr_pollen_test},
        size: {min: 1, max: 3, wiggle: 0.1, incr: -0.01},
        scale: {x: 0.2, y: 0.2},
        speed: {min: 2, max: 10, incr: -0.05, wiggle: 0.1},
        direction: {min: 0, max: 359, incr: 5, wiggle: 1},
        gravity: {amount: 0.05, direction: 270},
        orientation: {min: 0, max: 359, wiggle: 1, relative: true},
        // color: [ #2beB34, #D422B7, c_orange ],
        // colorMix: [c_red, c_blue],
        // colorRgb: {rmin: 0, rmax: 255, gmin: 0, gmax: 255,  bmin: 0, bmax: 255},
        colorHsv: {hmin: 0, hmax: 255, smin: 0, smax: 255,  vmin: 0, vmax: 255},
        alpha: [0.5, 1, 0.35],
        blend: false,
        life: {min: 0, max: 100},
        // step: {number: 1, type: "type_example_min"}, //<--- Should I parse structs first to add types to typeMap before setting properties so that way users can do this without having to worry about defining particles in order?
        death: {number: 1, type: "type_example_min"},
    },
    
    
    //--- DEFINE SYSTEMS HERE ---//
    
    {
        system : "system_example",
        depth: 100,
        // layer: "Asset",
        // position: {x: 600, y: 300},
        globalSpace: true,
        drawOrder: false,
        // angle: 45,
        // color: c_red,
        // alpha: 1,
        emitterList : [
            {
                type: "type_example_full",
                width: 64,
                height: 64,
                number: 10,
            },
            {
                type: "type_example_min",
                relative: false, //<---NOTE: This must be before .SetNumber or changes won't be reflected properly
                number: 20,
                width: 64,
                height: 64,
                delay: {min: 120, max: 200, unit: time_source_units_frames},
                interval: {min: 0, max: 5, unit: time_source_units_frames},
                shape: ps_shape_diamond,
                distr: ps_distr_gaussian,
                offsetX: 8,
                offsetY: 8,
            },
        ],
    },
];