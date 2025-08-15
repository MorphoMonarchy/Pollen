//======================================================================================================================
/*
                                 ____       _ _                 _    ____ ___
                                |  _ \ ___ | | | ___ _ __      / \  |  _ \_ _|
                                | |_) / _ \| | |/ _ \ '_ \    / _ \ | |_) | |
                                |  __/ (_) | | |  __/ | | |  / ___ \|  __/| |
                                |_|   \___/|_|_|\___|_| |_| /_/   \_\_|  |___|
                                
*/
//======================================================================================================================

/*                                                                                                          Completed?

    USEFUL TOOLS:
        ~ Tome (Auto generate doc site via docsify): https://github.com/CataclysmicStudios/Tome

    TODO:                                                                                                       [ ]                                                                                                            
        
        ~ Feature list (v1.0):                                                                                  [ ]
            ~ Setup hot-reload script                                                                           [X]
            ~ Create default GM-editor particle system                                                          [X]
            ~ Particle builder API                                                                              [ ]
            ~ Util functions for bursting and streaming particles                                               [ ]
            ~ Generate particle systems from hot-reload script                                                  [ ]
            ~ Hot-reload particle systems                                                                       [ ]
            ~ Generate particle systems from presets (use GM-editor presets, and add more)                      [ ]
            ~ Generate particle types/emitters from presets                                                     [ ]
            ~ Ability for user to config presets                                                                [ ]
        
        ~ Potential future features:                                                                            [ ]       
            ~ A particle editor tool that copies data as either gml or pollen-struct                            [ ]
            ~ Ability to use paths/curves to modify properties                                                  [ ]
            ~ Custom emitter shapes/stencils                                                                    [ ]
            ~ Custom blendmodes for particles                                                                   [ ]
            ~ Custom particle properties (randomize shape or image index?)                                      [ ]
            
            
*/

function Pollen() constructor {
    
    //There should be no more than one instance of Pollen
    static __numPollen = 0;
    __numPollen++;
    if(__numPollen > 1){Error("Only one instance of Pollen should ever be created which should be created automatically at the end of the Pollen() constructor.\n   There's no need to create more than one instance since Pollen only uses static vars.");}
    
    
//======================================================================================================================
#region ~ UPDATE ~
//======================================================================================================================

    //Set up an update function that executes one every frame forever.
    time_source_start(time_source_create(time_source_global, 1, time_source_units_frames, function()
    {
        static __bootSetupTimer   = 0;
        // static __bootSetupPath    = VINYL_LIVE_EDIT? filename_dir(GM_project_filename) + "/scripts/__VinylConfigJSON/__VinylConfigJSON.gml" : undefined;
        // static __bootSetupHash    = undefined;
        
        if (POLLEN_LIVE_EDIT && ((os_type == os_windows) || (os_type == os_macosx) || (os_type == os_linux))){
            --__bootSetupTimer;
            if (__bootSetupTimer <= 0){
                __bootSetupTimer = 60;
                self.Log("TEST");
                static __bootSetupTimer   = 0;
                static __bootSetupPath    = VINYL_LIVE_EDIT? filename_dir(GM_project_filename) + "/scripts/scr_pollen_config_pfx/scr_pollen_config_pfx.gml" : undefined;
                static __bootSetupHash    = undefined;
                
                var _newHash = md5_file(__bootSetupPath);
                if (_newHash != __bootSetupHash){
                    if (__bootSetupHash == undefined){__bootSetupHash = _newHash;}
                    else {
                        __bootSetupHash = _newHash;
                        
                        var _buffer = buffer_load(__bootSetupPath);
                        
                        var _gml = undefined;
                        try {
                            var _gml = __VinylBufferReadGML(_buffer, 0, buffer_get_size(_buffer));
                        }
                        catch(_error) {
                            show_debug_message(json_stringify(_error, true));
                            self.Warn("Failed to read GML");
                        }
                        
                        if (buffer_exists(_buffer)){
                            buffer_delete(_buffer);
                        }
                        
                        if (is_struct(_gml)){
                            try {
                                var _result = _gml[$ "global.pollen_config_pfx"] ?? [];
                                self.ImportPFX(_result);
                                global.pollen_config_pfx = _result;
                                // Log($"Success! Result = {_result[0]}");
                                // VinylSetupImportJSON(_gml[$ "global.VinylConfigSON"] ?? []);
                                // __VinylTrace("Successfully loaded config JSON from disk (", date_datetime_string(date_current_datetime()), ")");
                            }
                            catch(_error){
                                show_debug_message(json_stringify(_error, true));
                                Warn("Failed to import JSON");
                            }
                        }
                    }
                }
            }
        }
    }, [], -1));
    

//======================================================================================================================
#region ~ API ~
//======================================================================================================================

    static PFX = function() constructor {
        system = part_system_create();
        part_system_depth(system, -100);
        
        typeList = [
            part_type_create(),
        ];
        
        part_type_shape(typeList[0], pt_shape_sphere);
        part_type_color1(typeList[0], c_white);
        part_type_blend(typeList[0], false);
        part_type_life(typeList[0], 80, 80);
        part_type_scale(typeList[0], 1, 1);
        part_type_size(typeList[0], 1, 1, 0, 0);
        part_type_speed(typeList[0], 5, 5, 0, 0);
        part_type_gravity(typeList[0], 0, 270);
        part_type_direction(typeList[0], 80, 100, 0, 0);
        part_type_orientation(typeList[0], 0, 0, 0, 0, false);
        
        emitterList = [
            part_emitter_create(system),
        ];
        
        part_emitter_region(system, emitterList[0], 0, 0, 64, 64, ps_shape_rectangle, ps_distr_linear);
        
        //--- TYPE SETTERS ---//
        
        static SetTypeShape = function(_index_or_tag, _shape){
            if(!is_real(_index_or_tag)){return self;}
            part_type_shape(typeList[_index_or_tag], _shape);
            return self;
        }
        
        
        //--- TYPE GETTERS ---//
        
        // static GetTypeID = function(_)
    }
    
    static ImportPFX = function(_data){
        if(!is_array(_data)){self.Error("global.pollen_config_vfx must be an array!");}
        var _i = -1;
        var _len = array_length(_data);
        repeat(_len){
            _i++;
            var _struct = _data[_i];
            if(struct_exists(_struct, "test")){
                self.Log($"Success! Result = {_struct.test}");
            }
            else if(struct_exists(_struct, "shape")){
                with(obj_example.pfx){
                    var _tag = struct_get(_struct, "shape");
                    var _shape;
                    switch(_tag){
                        case "pixel": _shape = pt_shape_pixel; break;
                        case "disk": //<--- accept both spellings
                        case "disc": _shape = pt_shape_disk; break; 
                        case "square": _shape = pt_shape_square; break;
                        case "line": _shape = pt_shape_line; break;
                        case "star": _shape = pt_shape_star; break;
                        case "circle": _shape = pt_shape_circle; break;
                        case "ring": _shape = pt_shape_ring; break;
                        case "sphere": _shape = pt_shape_sphere; break;
                        case "flare": _shape = pt_shape_flare; break;
                        case "spark": _shape = pt_shape_spark; break;
                        case "explosion": _shape = pt_shape_explosion; break;
                        case "cloud": _shape = pt_shape_cloud; break;
                        case "smoke": _shape = pt_shape_smoke; break;
                        case "snow": _shape = pt_shape_snow; break;
                        default: other.Error("Particle shape not recognized! Check spelling!"); break; 
                    }
                    self.SetTypeShape(0, _shape);
                }
                self.Log($"Success! Result = {_struct.shape}");
            }
            else {
                static __expectedList = "'test',";
                self.Error($"Struct could not be parsed. Struct should contain one of the following properties: {__expectedList}");
            }
        }
    }
    
    static CreatePFX = function(){return new PFX();}
    
    static Log = function(_message){show_debug_message("Pollen -> " + _message);}
    static Warn = function(_message){show_debug_message("Pollen -> Warning! " + _message);}
    static Error = function(_message){show_error("Pollen -> Error! " + _message, true);}
}

//We only need the static vars in Pollen so we instantiate Pollen to set them up, then delete the actual instance since we don't need it.
var _initPollen = new Pollen(); 
delete _initPollen;