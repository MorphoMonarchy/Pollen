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

    This is an optional configuration script that you can edit. On boot, Pollen will import the JSON defined 
    in this script by passing it into Pollen.ImportPfx() if POLLEN_AUTO_IMPORT_CONFIG_PFX is set to <true>. 
    You can configure the entirety of your game particle effects from this one script in most cases.
    
    If POLLEN_LIVE_EDIT is set to <true> then editing this file will quickly be reflected in
    particle effects currently playing in your game. The live update feature does have limitations, however.
    This feature is only available when running on Windows, Mac, or Linux. Furthermore, the GML
    parser used to power live updating is very simple. You should treat the JSON written in this
    file as "pure JSON" and you should not use conditionals or if-statements or any logic at all.

    NOTES:
        
        ~ DO NOT RENAME THIS FILE!!!
        
        ~ READ THE DOCS!!! -> https://morphomonarchy.github.io/Pollen/#/1.0.0/Config%20PFX
        
        ~ The particle effects defined below are examples of how you can configure particle FX using this script
          feel free to change, delete, or add to them as you need!
        
        ~ Continuously adding and deleting unique tags will result in a memory leak which will eventually slow things
          down due to part types/system not being properly destroyed and the ds_maps that hold these tags growing in 
          size as well, thus increasing lookup times. However, this will be resolved by re-compiling the game, and I do 
          not imagine users doing this to such an excess that it will make much of a difference, so I will likely not 
          fix this issue, especially because it's a complex problem to solve which will very likely impact performance.

*/


global.pollen_config_pfx = [
    
    //--- DEFINE INDEPENDENT TYPES HERE ---//
    
    {type: "type_example_min"}, 
    
    {
        type : "type_example_full",
        // shape: pt_shape_snow, //<--- Uncomment this and comment out "sprite" below for basic shapes
        sprite : {id: spr_pollen_test, subImg: 0, animate: false, stretch: false, randomImg: false}, //<--- 'id' is required!!!
        size: {min: 0.5, max: 2, wiggle: 0.1, incr: -0.01},
        scale: {x: 0.1, y: 0.1},
        speed: {min: 2, max: 10, incr: -0.05, wiggle: 0.1},
        direction: {min: 0, max: 359, incr: 5, wiggle: 1},
        gravity: {amount: 0.05, direction: 270},
        orientation: {min: 0, max: 359, wiggle: 1, relative: true},
        // color: [ #2beB34, #D422B7, c_orange ], //<--- Uncomment this and comment out other color options below for standard color blending
        // colorMix: [c_red, c_blue], //<--- Uncomment this and comment out other color options for random two-color mixes
        // colorRgb: {rmin: 0, rmax: 255, gmin: 0, gmax: 255,  bmin: 0, bmax: 255}, //<--- Uncomment this and comment out other color options for random RGB
        colorHsv: {hmin: 0, hmax: 255, smin: 0, smax: 255,  vmin: 0, vmax: 255}, //<--- Comment this out and uncomment the color lines above for different color modes
        alpha: [0.5, 1, 0.35],
        blend: false,
        life: {min: 0, max: 100},
        // step: {number: 1, type: "type_example_min"}, //<--- Uncomment this to add sub-particles each step
        death: {number: 1, type: "type_example_min"},
    },
    
    {
        type: "type_example_template", 
        template: "type_example_full", //<--- Make sure you define the template before using it on another type 
        speed: {min: 0, max: 0},
        color: [ #2beB34, #D422B7, c_orange ],
    }, 
    
    
    //--- DEFINE SYSTEMS HERE ---//
    
    {
        system : "system_template_example",
        template : ps_example, //<--- This is a GM Particle Asset made using GM's particle editor
        globalSpace: true,
        depth: 0,
    },

    {
        system : "system_example",
        depth: 100,
        // layer: "Asset", //<--- Uncomment this to set the system to a specific room layer instead
        // position: {x: 600, y: 300}, //<--- Uncomment this to initialize the system at a specific position
        globalSpace: true,
        drawOrder: false,
        // angle: 45, //<--- Uncomment this to rotate the particle system
        // color: c_purple, //<--- Uncomment this to adjust global color blend for the particle system
        // alpha: 0.5, //<--- Uncomment this to adjust global alpha for the particle system
        emitterList : [
            {
                type: "type_example_full", //<---set this to 'type_example_template' to see how templates work with part types
                width: 64,
                height: 64,
                number: 10,
            },
            {
                type: "type_example_min",
                relative: true, //<---NOTE: This must be before 'number' or changes won't be reflected properly!
                number: 100,
                width: 64,
                height: 64,
                delay: {min: 120, max: 200, unit: time_source_units_frames},
                interval: {min: 0, max: 5, unit: time_source_units_frames},
                shape: ps_shape_diamond,
                distr: ps_distr_gaussian,
                offsetX: 8,
                offsetY: 8,
            },
            { //--- Example of how to define a type inside an emitter struct ---
                type: {
                    tag: "type_in_emitter", 
                    // type: "type_in_emitter", //<--- You can also use 'type' instead of 'tag' but I figured 'tag' is less confusing when nested inside another 'type' struct
                    scale: {x: 1, y: 1},
                    shape: pt_shape_line,
                    size: {min: 0.3, max: 0.5}, 
                    orientation: {relative: true},
                    direction: {incr: 10},
                    colorMix: [c_orange, c_aqua],
                    alpha: [1, 0],
                },
                number: -5,
                width: 64,
                height: 64,
            }
        ],
    },
    
//     // Another example of using a different system as a template but overriding the properties
    
//     // {
//     //     system : "system_template_example_2",
//     //     template : "system_example",
//     //     color: c_red,
//     //     globalSpace: false,
//     //     depth: -10,
//     //     emitterList : [
//     //         // {
//     //         //     type: "type_example_full",
//     //         //     width: 500,
//     //         //     height: 500,
//     //         //     number: 10,
//     //         // },
//     //         {
//     //             type: "type_example_min",
//     //             relative: false, //<---NOTE: This must be before .SetNumber or changes won't be reflected properly
//     //             number: 20,
//     //             width: 500,
//     //             height: 500,
//     //             delay: {min: 120, max: 200, unit: time_source_units_frames},
//     //             interval: {min: 0, max: 5, unit: time_source_units_frames},
//     //             shape: ps_shape_diamond,
//     //             distr: ps_distr_gaussian,
//     //             offsetX: 8,
//     //             offsetY: 8,
//     //         },
//     //     ],
//     // },

];