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
            ~ Generate particle types from hot-reload script                                                    [X]
            ~ Generate particle systems from hot-reload script                                                  [X]
            ~ Hot-reload particle systems                                                                       [ ]
            ~ Generate particle systems from presets (use GM-editor presets, and add more)                      [ ]
            ~ Generate particle types from presets                                                              [ ]
            ~ Ability for user to config presets (only for types and systems                                    [ ]
            ~ Ensure easy cleanup of data (add .Destroy methods and check for mem-leaks)                        [ ]
        
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
                                self.ImportPfx(_result);
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
#region ~ TYPES ~
//======================================================================================================================
    
    enum pollen_type_property {shape, sprite, size, scale, speed, direction, gravity, orientation, color, blend, life, step, death}
    
    static __typeMap = ds_map_create();
    static TypeTagGetData = function(_tag){return __typeMap[? _tag];}
    
    static PfxType = function(_tag) constructor {
        
        //--- SETUP BACKEND ---//
        if(Pollen.__typeMap[? _tag] != undefined){Pollen.Error($"Attempting to create pollen part type, but type tag: '{_tag}' already exists!");}
        Pollen.__typeMap[? _tag] = self; 
        
        //--- GML TYPE ---//
        __tag = _tag;
        __gmlData = part_type_create();
        static GetGmlData = function(){return __gmlData;}
        
        //--- SHAPE ---//
        __shape = undefined;
        static GetShape = function(){return self.__shape;}
        static SetShape = function(_shape){
            self.__sprite.id = undefined; 
            self.__shape = _shape; 
            part_type_shape(self.__gmlData, _shape); 
            return self;
        }
        
        //--- SPRITE ---//
        __sprite = {id: undefined, subImg: 0, animate: false, stretch: false, randomImg: false}
        static GetSpriteData = function(){return self.__sprite;}
        static SetSprite = function(_sprite, _subImg = 0, _animate = false, _stretch = false, _randomImg = false){
            self.__shape = undefined; 
            self.__sprite = {id: _sprite, subImg: _subImg, animate: _animate, stretch: _stretch, randomImg: _randomImg}; 
            part_type_sprite(self.__gmlData, _sprite, _animate, _stretch, _randomImg); 
            part_type_subimage(self.__gmlData, _subImg);
            return self;
        }
        
        //--- SIZE ---// 
        __size = {min: 0, max: 0, incr: 0, wiggle: 0}
        __sizeX = undefined; //<--- I hate this but oh well...
        __sizeY = undefined;
        static GetSize = function(){return self.__size;}
        static SetSize = function(_min = undefined, _max = undefined, _incr = undefined, _wiggle = undefined){
            if(__size != undefined){_min ??= __size.min; _max ??= __size.max; _incr ??= __size.incr; _wiggle ??= __size.wiggle;}
            else {_min ??= 0; _max ??= 0; _incr ??= 0; _wiggle ??= 0;}
            self.__size = {min: _min, max: _max, incr: _incr, wiggle: _wiggle}
            self.__sizeX = undefined;
            self.__sizeY = undefined;
            part_type_size(self.__gmlData, _min, _max, _incr, _wiggle); 
            return self;
        }
        static GetSizeX = function(){return self.__sizeX;}
        static SetSizeX = function(_min = undefined, _max = undefined, _incr = undefined, _wiggle = undefined){
            if(__sizeX != undefined){_min ??= __sizeX.min; _max ??= __sizeX.max; _incr ??= __sizeX.incr; _wiggle ??= __sizeX.wiggle;}
            else {_min ??= 0; _max ??= 0; _incr ??= 0; _wiggle ??= 0;}
            self.__sizeX = undefined;
            self.__sizeX = {min: _min, max: _max, incr: _incr, wiggle: _wiggle};
            part_type_size_x(self.__gmlData, _min, _max, _incr, _wiggle); 
            return self;
        }
        static GetSizeY = function(){return self.__sizeY;}
        static SetSizeY = function(_min = undefined, _max = undefined, _incr = undefined, _wiggle = undefined){
            if(__sizeY != undefined){_min ??= __sizeY.min; _max ??= __sizeY.max; _incr ??= __sizeY.incr; _wiggle ??= __sizeY.wiggle;}
            else {_min ??= 0; _max ??= 0; _incr ??= 0; _wiggle ??= 0;}
            self.__size = undefined;
            self.__sizeY = {min: _min, max: _max, incr: _incr, wiggle: _wiggle};
            part_type_size_y(self.__gmlData, _min, _max, _incr, _wiggle); 
            return self;
        }
        
        //--- SCALE ---//
        __scale = {x: 1, y: 1};
        static GetScale = function(){return self.__scale;}
        static SetScale = function(_x = __scale.x, _y = __scale.y){
            self.__scale = {x: _x, y: _y};
            part_type_scale(self.__gmlData, _x, _y); 
            return self;
        }
        
        //--- SPEED ---//
        __speed = { min: 1, max: 1, incr: 0, wiggle: 0 };
        static GetSpeed = function(){ return self.__speed; }
        static SetSpeed = function(
            _min    = __speed.min,
            _max    = __speed.max,
            _incr   = __speed.incr,
            _wiggle = __speed.wiggle
        ){
            self.__speed = { min: _min, max: _max, incr: _incr, wiggle: _wiggle };
            part_type_speed(self.__gmlData, _min, _max, _incr, _wiggle);
            return self;
        }
        
        //--- DIRECTION ---//
        __direction = { min: 0, max: 0, incr: 0, wiggle: 0 };
        static GetDirection = function(){ return self.__direction; }
        static SetDirection = function(
            _min    = __direction.min,
            _max    = __direction.max,
            _incr   = __direction.incr,
            _wiggle = __direction.wiggle
        ){
            self.__direction = { min: _min, max: _max, incr: _incr, wiggle: _wiggle };
            part_type_direction(self.__gmlData, _min, _max, _incr, _wiggle);
            return self;
        }
        
        //--- GRAVITY ---//
        __gravity = { amount: 0, direction: 270 };
        static GetGravity = function(){ return self.__gravity; }
        static SetGravity = function(
            _amount    = __gravity.amount,
            _direction = __gravity.direction
        ){
            self.__gravity = { amount: _amount, direction: _direction };
            part_type_gravity(self.__gmlData, _amount, _direction);
            return self;
        }
        
        //--- ORIENTATION ---//
        __orientation = { min: 0, max: 0, incr: 0, wiggle: 0, relative: false };
        static GetOrientation = function(){ return self.__orientation; }
        static SetOrientation = function(
            _min      = __orientation.min,
            _max      = __orientation.max,
            _incr     = __orientation.incr,
            _wiggle   = __orientation.wiggle,
            _relative = __orientation.relative
        ){
            self.__orientation = { min: _min, max: _max, incr: _incr, wiggle: _wiggle, relative: _relative };
            part_type_orientation(self.__gmlData, _min, _max, _incr, _wiggle, _relative);
            return self;
        }
        
        //--- COLOR (STANDARD) ---//
        __color = c_white;
        static GetColor = function(){return self.__color;}
        static SetColor = function(_color_or_array){
            if(!is_array(_color_or_array)){
                self.__color = _color_or_array;
                part_type_color1(self.__gmlData, _color_or_array);
                return self;
            }
            var _numColors = array_length(_color_or_array);
            if(_numColors == 0){
                Pollen.Warn($"Attempting to set color of type: '{self.__tag}' using an empty array! Bailing!");
            }
            else if(_numColors == 1){
                __color = _color_or_array[0];
                part_type_color1(self.__gmlData, _color_or_array[0]);
            }
            else if(_numColors == 2){
                __color = _color_or_array;
                part_type_color2(self.__gmlData, _color_or_array[0], _color_or_array[1]);
            }
            else if(_numColors == 3){
                __color = _color_or_array;
                part_type_color3(self.__gmlData, _color_or_array[0], _color_or_array[1], _color_or_array[2]);
            }
            else {
                Pollen.Warn($"Attempting to set color of type: '{self.__tag}' using an array larger than 3. Defaulting to first 3 values!");
                __color = [_color_or_array[0], _color_or_array[1], _color_or_array[2]];
                part_type_color3(self.__gmlData, _color_or_array[0], _color_or_array[1], _color_or_array[2]);
            }
            return self;
        }
        
        //--- ALPHA ---//
        __alpha = c_white;
        static GetAlpha = function(){return self.__alpha;}
        static SetAlpha = function(_alpha_or_array){
            if(!is_array(_alpha_or_array)){
                self.__alpha = _alpha_or_array;
                part_type_alpha1(self.__gmlData, _alpha_or_array);
                return self;
            }
            var _numalphas = array_length(_alpha_or_array);
            if(_numalphas == 0){
                Pollen.Warn($"Attempting to set alpha of type: '{self.__tag}' using an empty array! Bailing!");
            }
            else if(_numalphas == 1){
                __alpha = _alpha_or_array[0];
                part_type_alpha1(self.__gmlData, _alpha_or_array[0]);
            }
            else if(_numalphas == 2){
                __alpha = _alpha_or_array;
                part_type_alpha2(self.__gmlData, _alpha_or_array[0], _alpha_or_array[1]);
            }
            else if(_numalphas == 3){
                __alpha = _alpha_or_array;
                part_type_alpha3(self.__gmlData, _alpha_or_array[0], _alpha_or_array[1], _alpha_or_array[2]);
            }
            else {
                Pollen.Warn($"Attempting to set alpha of type: '{self.__tag}' using an array larger than 3. Defaulting to first 3 values!");
                __alpha = [_alpha_or_array[0], _alpha_or_array[1], _alpha_or_array[2]];
                part_type_alpha3(self.__gmlData, _alpha_or_array[0], _alpha_or_array[1], _alpha_or_array[2]);
            }
            return self;
        }
    }
    
    // static TypeSetProperty = function(_part_type_or_tag, _property, _args){
    //     if(is_string(_part_type_or_tag)){
    //         var _data = TypeTagGetData(_part_type_or_tag);
    //         if(_data == undefined){self.Error("TypeSetProperty: type tag not recognized!");}
    //         switch(_property){
    //             case pollen_type_property.shape: _data.SetShape(_args[0]); break;
    //             case pollen_type_property.sprite: _data.SetSprite(_args[0], _args[1], _args[2], _args[3], _args[4]);
    //             case pollen_type_property.size: break;
    //             case pollen_type_property.scale: break;
    //             case pollen_type_property.speed: break;
    //             case pollen_type_property.direction: break;
    //             case pollen_type_property.gravity: break;
    //             case pollen_type_property.orientation: break;
    //             case pollen_type_property.color: break;
    //             case pollen_type_property.blend: break;
    //             case pollen_type_property.life: break;
    //             case pollen_type_property.step: break;
    //             case pollen_type_property.death: break;
    //         }
    //         return;
    //     }
    //     switch(_property){
    //         case pollen_type_property.shape: part_type_shape(_part_type_or_tag, _args[0]); break;
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
#region ~ EMITTERS ~
//======================================================================================================================

    // static __emitterMap = ds_map_create();
    // static EmitterTagGetData = function(_tag){return __emitterMap[? _tag];}
    
    //NOTE: Emitters must be tied to systems which is why I'm defining the data inside Pfx instead of Pollen
    static PfxEmitter = function(_type, _system) constructor {
        
        //--- SETUP BACKEND ---//
        // if(Pollen.__emitterMap[? _tag] != undefined){Pollen.Error($"Attempting to create pollen part emitter, but emitter tag: '{_tag}' already exists!");}
        // Pollen.__emitterMap[? _tag] = self; 
        
        //--- SETUP PROPERTIES ---//
        __gmlData = part_emitter_create(_system.GetGmlData());
        __system = _system;
        __type = _type;
        __shape = ps_shape_ellipse;
        __distr = ps_distr_linear;
        __number = 10;
        __offsetX = 0;
        __offsetY = 0;
        __width = 0;
        __height = 0;
        
        //--- SETTERS ---//
        static SetSize = function(_width, _height){
            __width = _width; 
            __height = _height; 
            __system.RefreshStream();
            return self;
        }
        static SetWidth = function(_width){SetSize(_width, __height); return self;}
        static SetHeight = function(_height){SetSize(__width, _height); return self;}
        static SetNumber = function(_number){__number = _number; __system.RefreshStream(); return self;}
        static SetType = function(_type){__type = _type; __system.RefreshStream(); return self;}
        
        //--- GETTERS ---//
        static GetType = function(){return __type;}
        static GetNumber = function(){return __number;}
        static GetShape = function(){return __shape;}
        static GetDistr = function(){return __distr;}
        static GetGmlData = function(){return __gmlData;}
        static GetWidth = function(){return __width;}
        static GetHeight = function(){return __height;}
        static GetSize = function(){return {w: __width, h: __height}}
    }
   
    
//======================================================================================================================
#region ~ SYSTEMS ~
//======================================================================================================================

    static __systemMap = ds_map_create();
    static SystemTagGetData = function(_tag){return __systemMap[? _tag];}

    static Pfx = function(_tag, _system = undefined, _typeList = undefined, _emitterList = undefined) constructor {
        
        //--- SETUP BACKEND ---//
        if(Pollen.__systemMap[? _tag] != undefined){Pollen.Error($"Attempting to create pollen part system, but system tag: '{_tag}' already exists!");}
        Pollen.__systemMap[? _tag] = self; 
        
        
        //--- SETUP PROPERTIES ---//
        __tag = _tag;
        __gmlData = _system ?? part_system_create();
        part_system_depth(__gmlData, -100); //<---will get rid of this eventually
        
        __position = {x: 0, y: 0}
        __typeList = _typeList ?? [];
        __emitterList = _emitterList ?? [];
        __isStreaming = false;
        __streamNumber = undefined;
        
        //--- SETTERS ---//
        static SetPosition = function(_x, _y){__position = {x: _x, y: _y};}
        static SetTypeList = function(_list){__typeList = _list; return self;}
        static SetEmitterList = function(_list){__typeList = _list; return self;}
        static SetTypeProperty = function(_index_or_tag, _property, _args){
            if(!is_real(_index_or_tag)){return self;}
            var _type = __typeList[_index_or_tag];
            Pollen.TypeSetProperty(_type, _property, _args);
            return self;
        }
        
        //--- GETTERS ---//
        static GetTag = function(){return __tag;}
        static GetGmlData = function(){return __gmlData;}
        static GetTypeList = function(){return __typeList;}
        static GetEmitterList = function(){return __emitterList;}
        
        //--- UTIL ---//
        static RefreshStream = function(){
            if(!__isStreaming){return;}
            var _numEmitter = array_length(__emitterList);
            var _i = -1;
            repeat(_numEmitter){
                _i++;
                var _emitter = __emitterList[_i];
                part_emitter_clear(__gmlData, _emitter.GetGmlData());
            }
            Pollen.PfxStream(__tag, __position.x, __position.y, __streamNumber);
        }
    }
    
    static PfxStream = function(_system_or_tag, _x, _y, _amount = undefined){
        if(is_string(_system_or_tag)){
            
            var _data = self.__systemMap[? _system_or_tag];
            var _gmlData = _data.GetGmlData();
            var _emitterList = _data.GetEmitterList();
            var _typeList = _data.GetTypeList();
            
            _data.SetPosition(_x, _y);
            _data.__isStreaming = true;
            _data.__streamNumber = _amount;
            
            var _i = -1;
            var _numEmitters = array_length(_emitterList);
            repeat(_numEmitters){
                _i++;
                var _emitter = _emitterList[_i];
                var _emitterGml = _emitter.GetGmlData();
                
                var _number = _amount ?? _emitter.GetNumber(); //<---will give users the ability to set default values when I add emitter data later
                var _halfW = 0.5*_emitter.GetWidth(), _halfH = 0.5*_emitter.GetHeight();
                var _shape = _emitter.GetShape(), _distr = _emitter.GetDistr();
                
                var _type = _emitter.GetType();
                if(is_string(_type)){_type = self.TypeTagGetData(_type);}
                var _typeGml = _type.GetGmlData();
                
                part_emitter_region(_gmlData, _emitterGml, _x - _halfW, _x + _halfW, _y - _halfH, _y + _halfH, _shape, _distr);
                part_emitter_stream(_gmlData, _emitterGml, _typeGml, _number);
            }
        }
        //I'll add support for calling with gml part systems and possibly gml part assets later
        return;
    }
    
    
//======================================================================================================================
#region ~ Import ~
//======================================================================================================================
    
    static ImportPfx = function(_data){
        if(!is_array(_data)){self.Error("global.pollen_config_vfx must be an array!");}
        var _i = -1;
        var _len = array_length(_data);
        repeat(_len){
            _i++;
            var _struct = _data[_i];
            if(struct_exists(_struct, "type")){
                var _tag = struct_get(_struct, "type");
                var _tagData = self.TypeTagGetData(_tag);
                if(_tagData == undefined){_tagData = new PfxType(_tag);}
                self.ImportPfxType(_struct, _tagData);
                self.Log($"Type: '{_tag}' was reloaded.");
            }
            else if (struct_exists(_struct, "system")){
                var _tag = struct_get(_struct, "system");
                var _tagData = self.SystemTagGetData(_tag);
                if(_tagData == undefined){_tagData = new Pfx(_tag);}
                var _emitterList = struct_get(_struct, "emitterList");
                if(_emitterList != undefined){
                    var _numOldList = array_length(_tagData.GetEmitterList());
                    var _numNewList = array_length(_emitterList);
                    var _i = -1;
                    repeat(_numNewList){
                        _i++;
                        var _props = _emitterList[_i];
                        if(_numOldList >= _i + 1){
                            var _emitter = _tagData.GetEmitterList()[_i];
                            var _type = struct_get(_props, "type") ?? _emitter.GetType();
                            var _width = struct_get(_props, "width") ?? _emitter.GetWidth();
                            var _height = struct_get(_props, "height") ?? _emitter.GetHeight();
                            _emitter.SetType(_type).SetSize(_width, _height);
                            continue;
                        }
                        var _emitter = new PfxEmitter(_props.type, _tagData)
                            .SetSize(_props.width, _props.height);
                        array_push(_tagData.GetEmitterList(), _emitter);
                    }
                    _tagData.RefreshStream();
                }
                self.Log($"System: '{_tag}' was reloaded.");
            }
            else {
                static __expectedList = "type', 'system'";
                self.Error($"Struct at global.pollen_config_pfx[{_i}] could not be parsed. Struct should contain one of the following properties: {self.__expectedList}");
            }
        }
    }
    
    //NOTE: Refactor this to use struct get names instead so we can test for mispellings and what not!!!
    static ImportPfxType = function(_import_data, _type_data){
        
        //--- SHAPE ---//
        var _shape = struct_get(_import_data, "shape");
        if(_shape != undefined){_type_data.SetShape(_shape);}
    
        //--- SPRITE ---//
        var _sprite = struct_get(_import_data, "sprite");
        if(_sprite != undefined){
            var _id = struct_get(_sprite, "id");
            if(_id == undefined){
                Pollen.Error($"Sprite struct defined in '{_import_data.type}' must contain 'id' property!");
            }
            var _default   = _type_data.GetSpriteData();
            var _subImg    = struct_get(_sprite, "subImg")    ?? _default.subImg;
            var _animate   = struct_get(_sprite, "animate")   ?? _default.animate;
            var _stretch   = struct_get(_sprite, "stretch")   ?? _default.stretch;
            var _randomImg = struct_get(_sprite, "randomImg") ?? _default.randomImg;
            _type_data.SetSprite(_id, _subImg, _animate, _stretch, _randomImg);
        }
    
        //--- SIZE (uniform) ---//
        var _size = struct_get(_import_data, "size");
        if(_size != undefined){
            var _def = _type_data.GetSize();
            if (_def == undefined) { _def = { min: 0, max: 0, incr: 0, wiggle: 0 }; }
            var _min    = struct_get(_size, "min")    ?? _def.min;
            var _max    = struct_get(_size, "max")    ?? _def.max;
            var _incr   = struct_get(_size, "incr")   ?? _def.incr;
            var _wiggle = struct_get(_size, "wiggle") ?? _def.wiggle;
            _type_data.SetSize(_min, _max, _incr, _wiggle);
        }
    
        //--- SIZE X (axis override) ---//
        var _sizeX = struct_get(_import_data, "sizeX");
        if(_sizeX != undefined){
            var _defX = _type_data.GetSizeX();
            if (_defX == undefined) { _defX = { min: 0, max: 0, incr: 0, wiggle: 0 }; }
            var _minX    = struct_get(_sizeX, "min")    ?? _defX.min;
            var _maxX    = struct_get(_sizeX, "max")    ?? _defX.max;
            var _incrX   = struct_get(_sizeX, "incr")   ?? _defX.incr;
            var _wiggleX = struct_get(_sizeX, "wiggle") ?? _defX.wiggle;
            _type_data.SetSizeX(_minX, _maxX, _incrX, _wiggleX);
        }
    
        //--- SIZE Y (axis override) ---//
        var _sizeY = struct_get(_import_data, "sizeY");
        if(_sizeY != undefined){
            var _defY = _type_data.GetSizeY();
            if (_defY == undefined) { _defY = { min: 0, max: 0, incr: 0, wiggle: 0 }; }
            var _minY    = struct_get(_sizeY, "min")    ?? _defY.min;
            var _maxY    = struct_get(_sizeY, "max")    ?? _defY.max;
            var _incrY   = struct_get(_sizeY, "incr")   ?? _defY.incr;
            var _wiggleY = struct_get(_sizeY, "wiggle") ?? _defY.wiggle;
            _type_data.SetSizeY(_minY, _maxY, _incrY, _wiggleY);
        }
    
        //--- SCALE ---//
        var _scale = struct_get(_import_data, "scale");
        if(_scale != undefined){
            var _defScale = _type_data.GetScale();
            var _sx = struct_get(_scale, "x") ?? _defScale.x;
            var _sy = struct_get(_scale, "y") ?? _defScale.y;
            _type_data.SetScale(_sx, _sy);
        }
    
        //--- SPEED ---//
        var _speed = struct_get(_import_data, "speed");
        if(_speed != undefined){
            var _defSpeed = _type_data.GetSpeed();
            var _smin    = struct_get(_speed, "min")    ?? _defSpeed.min;
            var _smax    = struct_get(_speed, "max")    ?? _defSpeed.max;
            var _sincr   = struct_get(_speed, "incr")   ?? _defSpeed.incr;
            var _swiggle = struct_get(_speed, "wiggle") ?? _defSpeed.wiggle;
            _type_data.SetSpeed(_smin, _smax, _sincr, _swiggle);
        }
    
        //--- DIRECTION ---//
        var _direction = struct_get(_import_data, "direction");
        if(_direction != undefined){
            var _defDir = _type_data.GetDirection();
            var _dmin    = struct_get(_direction, "min")    ?? _defDir.min;
            var _dmax    = struct_get(_direction, "max")    ?? _defDir.max;
            var _dincr   = struct_get(_direction, "incr")   ?? _defDir.incr;
            var _dwiggle = struct_get(_direction, "wiggle") ?? _defDir.wiggle;
            _type_data.SetDirection(_dmin, _dmax, _dincr, _dwiggle);
        }
        
        //--- ORIENTATION ---//
        var _orientation = struct_get(_import_data, "orientation");
        if(_orientation != undefined){
            var _defOri = _type_data.GetOrientation();
            var _omin  = struct_get(_orientation, "min")      ?? _defOri.min;
            var _omax  = struct_get(_orientation, "max")      ?? _defOri.max;
            var _oinc  = struct_get(_orientation, "incr")     ?? _defOri.incr;
            var _owig  = struct_get(_orientation, "wiggle")   ?? _defOri.wiggle;
            var _orel  = struct_get(_orientation, "relative") ?? _defOri.relative;
            _type_data.SetOrientation(_omin, _omax, _oinc, _owig, _orel);
        }
    
        //--- GRAVITY ---//
        var _gravity = struct_get(_import_data, "gravity");
        if(_gravity != undefined){
            var _defGrav = _type_data.GetGravity();
            var _gamt = struct_get(_gravity, "amount")    ?? _defGrav.amount;
            var _gdir = struct_get(_gravity, "direction") ?? _defGrav.direction;
            _type_data.SetGravity(_gamt, _gdir);
        }
        
        //--- COLOR (STANDARD ---//
        var _color = struct_get(_import_data, "color");
        if(_color != undefined){_type_data.SetColor(_color);}
        
        //--- ALPHA ---//
        var _alpha = struct_get(_import_data, "alpha");
        if(_alpha != undefined){_type_data.SetAlpha(_alpha);}
    }
    
    
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
Pollen.ImportPfx(global.pollen_config_pfx); //<---Do not rename any files or this might not work since it requires the other scripts to be initialized first!!!
Pollen.Log("Ready!");