// Feather ignore all
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
    self.__numPollen++;
    if(self.__numPollen > 1){self.Error("Only one instance of Pollen should ever be created which should be created automatically at the end of the Pollen() constructor.\n   There's no need to create more than one instance since Pollen only uses static vars.");}
    
    
//======================================================================================================================
#region ~ UPDATE ~
//======================================================================================================================

    //Set up an update function that executes one every frame forever.
    
    static __bootSetupTimer = 0;
    static __bootSetupPath = (POLLEN_LIVE_EDIT) ? filename_dir(GM_project_filename) + "/scripts/scr_pollen_config_pfx/scr_pollen_config_pfx.gml" : undefined;
    static __bootSetupHash = undefined;
    
    time_source_start(time_source_create(time_source_global, 1, time_source_units_frames, function()
    {
        
        if (POLLEN_LIVE_EDIT && ((os_type == os_windows) || (os_type == os_macosx) || (os_type == os_linux))){
            self.__bootSetupTimer--;
            if (self.__bootSetupTimer <= 0){
                self.__bootSetupTimer = 60;
                // self.Log("TEST");
                
                var _newHash = md5_file(self.__bootSetupPath);
                if (_newHash != self.__bootSetupHash){
                    if (self.__bootSetupHash == undefined){self.__bootSetupHash = _newHash;}
                    else {
                        self.__bootSetupHash = _newHash;
                        
                        var _buffer = buffer_load(__bootSetupPath);
                        
                        var _gml = undefined;
                        try {
                            var _gml = __PollenBufferReadGML(_buffer, 0, buffer_get_size(_buffer));
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
                                self.Warn("Failed to import JSON");
                            }
                        }
                    }
                }
            }
        }
    }, [], -1));
    

//======================================================================================================================
#region ~ Particle Systems ~
//======================================================================================================================

    static PFX = function(_system = undefined, _typeList = undefined, _emitterList = undefined) constructor {
        system = _system ?? part_system_create();
        part_system_depth(system, -100);
        
        typeList = _typeList ?? [
            part_type_create(),
        ];
        
        if(_typeList == undefined){
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
        }
        
        emitterList = _emitterList ?? [
            part_emitter_create(system),
        ];
        
        if(_emitterList == undefined){
            part_emitter_region(system, emitterList[0], 0, 0, 64, 64, ps_shape_rectangle, ps_distr_linear);
        }
        
        //--- TYPE SETTERS ---//
        
        static SetTypeProperty = function(_index_or_tag, _property, _args){
            if(!is_real(_index_or_tag)){return self;}
            var _type = typeList[_index_or_tag];
            Pollen.TypeSetProperty(_type, _property, _args);
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
            if(struct_exists(_struct, "type")){
                var _tag = struct_get(_struct, "type");
                var _tagData = self.TypeTagGetData(_tag);
                if(_tagData == undefined){_tagData = new PFXType(_tag);}
                var _shape = struct_get(_struct, "shape");
                if(_shape != undefined){_tagData.SetShape(_shape);}
                self.Log($"Type: '{_tag}' was reloaded.");
            }
            else if (struct_exists(_struct, "emitter")){self.Log($"Emitter: '{struct_get(_struct, "emitter")}' was reloaded");}
            else if (struct_exists(_struct, "system")){self.Log($"System: '{struct_get(_struct, "system")}' was reloaded.");}
            else {
                static __expectedList = "type', 'emitter', 'system'";
                self.Error($"Struct at global.pollen_config_pfx[{i}] could not be parsed. Struct should contain one of the following properties: {self.__expectedList}");
            }
        }
    }
    
    static CreatePFX = function(){return new PFX();}
    
    
//======================================================================================================================
#region ~ Particle Types ~
//======================================================================================================================
    
    enum pollen_type_property {shape, sprite, size, scale, speed, direction, gravity, orientation, color, blend, life, step, death}
    
    static __typeMap = ds_map_create();
    static TypeTagGetData = function(_tag){return __typeMap[? _tag];}
    
    static PFXType = function(_tag) constructor {
        
        //--- SETUP BACKEND ---//
        if(Pollen.__typeMap[? _tag] != undefined){Pollen.Error($"Attempting to create pollen part type, but type tag: '{_tag}' already exists!");}
        Pollen.__typeMap[? _tag] = self; 
        
        //--- SETUP PROPERTIES ---//
        __gmlType = part_type_create();
        __shape = undefined;
        __sprite = {id: undefined, image: 0}
        
        //--- GML TYPE ---//
        static GetGmlType = function(){return __gmlType;}
        
        //--- SHAPE ---//
        static GetShape = function(){return self.__shape;}
        static SetShape = function(_shape){
            self.__sprite.id = undefined; 
            self.__shape = _shape; 
            part_type_shape(self.__gmlType, _shape); 
            return self;
        }
    }
    
    static TypeSetProperty = function(_part_type_or_tag, _property, _args){
        if(is_string(_part_type_or_tag)){
            var _data = TypeTagGetData(_part_type_or_tag);
            if(_data == undefined){self.Error("TypeSetProperty: type tag not recognized!");}
            switch(_property){
                case pollen_type_property.shape: _data.SetShape(_args[0]); break;
                case pollen_type_property.sprite: break;
                case pollen_type_property.size: break;
                case pollen_type_property.scale: break;
                case pollen_type_property.speed: break;
                case pollen_type_property.direction: break;
                case pollen_type_property.gravity: break;
                case pollen_type_property.orientation: break;
                case pollen_type_property.color: break;
                case pollen_type_property.blend: break;
                case pollen_type_property.life: break;
                case pollen_type_property.step: break;
                case pollen_type_property.death: break;
            }
            return;
        }
        switch(_property){
            case pollen_type_property.shape: part_type_shape(_part_type_or_tag, _args[0]); break;
            case pollen_type_property.sprite: break;
            case pollen_type_property.size: break;
            case pollen_type_property.scale: break;
            case pollen_type_property.speed: break;
            case pollen_type_property.direction: break;
            case pollen_type_property.gravity: break;
            case pollen_type_property.orientation: break;
            case pollen_type_property.color: break;
            case pollen_type_property.blend: break;
            case pollen_type_property.life: break;
            case pollen_type_property.step: break;
            case pollen_type_property.death: break;
        }
    }
    
    // static __TypeSetPropertyTestArgs = function(_part_type_or_tag, _property, _args){
    //     if(is_string(_part_type_or_tag)){return;}
    //     switch(_property){
    //         case pollen_type_property.shape: break;
    //         case pollen_type_property.sprite: break;
    //         case pollen_type_property.size: break;
    //         case pollen_type_property.scale: break;
    //         case pollen_type_property.speed: break;
    //         case pollen_type_property.direction: break;
    //         case pollen_type_property.gravity: break;
    //         case pollen_type_property.orientation: break;
    //         case pollen_type_property.color: break;
    //         case pollen_type_property.blend: break;
    //         case pollen_type_property.life: break;
    //         case pollen_type_property.step: break;
    //         case pollen_type_property.death: break;
    //     }
    // }
    
    
//======================================================================================================================
#region ~ Debug ~
//======================================================================================================================
    
    static Log = function(_message){show_debug_message("Pollen -> " + _message);}
    static Warn = function(_message){show_debug_message("Pollen -> Warning! " + _message);}
    static Error = function(_message){show_error("Pollen -> Error! " + _message, true);}
}

//We only need the static vars in Pollen so we instantiate Pollen to set them up, then delete the actual instance since we don't need it.
var _initPollen = new Pollen(); 
delete _initPollen;
Pollen.ImportPFX(global.pollen_config_pfx);
Pollen.Log("Ready!");