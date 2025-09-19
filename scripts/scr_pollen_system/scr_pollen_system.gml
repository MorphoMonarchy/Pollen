// Feather ignore all
//======================================================================================================================
#region ~ INDEX ~
//======================================================================================================================
/*
                             ____       _ _              ____            _
                            |  _ \ ___ | | | ___ _ __   / ___| _   _ ___| |_ ___ _ __ ___
                            | |_) / _ \| | |/ _ \ '_ \  \___ \| | | / __| __/ _ \ '_ ` _ \
                            |  __/ (_) | | |  __/ | | |  ___) | |_| \__ \ ||  __/ | | | | |
                            |_|   \___/|_|_|\___|_| |_| |____/ \__, |___/\__\___|_| |_| |_|
                                                               |___/
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
            ~ Ability to adjust any part type property from hot-reload script                                   [X]
            ~ Generate particle systems from hot-reload script                                                  [X]
            ~ Ability to adjust any part system/emitter property from hot-reload script                         [ ]
            ~ Generate particle types from presets                                                              [ ]
            ~ Generate particle systems from presets (use GM-editor presets, and add more)                      [ ]
            ~ Ability for user to config presets                                                                [ ]
            ~ Ensure easy cleanup of data (add .Destroy methods and check for mem-leaks)                        [ ]
            ~ Add error checks and basic debug tools                                                            [ ]
            ~ Add additional util functions                                                                     [ ]
            
        ~ Testing & polish:                                                                                     [ ]
            ~ Check builder functions to make sure all of them return self                                      [ ]
            ~ Add tests to ensure JSON data is valid                                                            [ ]
            ~ Add options to use structs or split-up variables for position, offset, size, etc                  [ ]
                -> e.g. can do "size: {w: 64, h: 64}" OR "width: 64, height: 64"
            ~ Make functional on Gamemaker LTS version                                                          [ ]
            ~ Code cleanup and documentation                                                                    [ ]
        
        
    POTENTIAL FUTURE FEATURES:    
    
        ~ A particle editor tool that copies data as either gml or pollen-struct                            
        ~ Ability to use paths/curves to modify properties                                                  
        ~ Custom emitters:                                                                             
            ~ Utilize GPU for optimization and so shaders can be applied                
            ~ Customize shape of emitter using stencils
            ~ Emit particles along a path or using animation curves
            ~ Displacement maps to effect particle properties
            ~ Ability to cache emitter states for improved performance
            ~ Apply collision & forces to particles for more in-game interactions
            ~ Custom blendmodes for particles (metaball rendering for splatter fx)                                                          
            ~ Custom particle properties (blend shapes so a star can morph into a square for example?)                                  
            
            
*/

function Pollen() constructor {
    
    //There should be no more than one instance of Pollen
    static __numPollen = 0;
    self.__numPollen++;
    if(self.__numPollen > 1){self.Error("Only one instance of Pollen should ever be created which should be created automatically at the end of the Pollen() constructor.\n   There's no need to create more than one instance since Pollen only uses static vars.");}
    

#endregion    
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
    
 
#endregion   
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
            part_type_size_offsetX(self.__gmlData, _min, _max, _incr, _wiggle); 
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
        
        //--- COLOR MIX ---//
        __colorMix = undefined;
        static GetColorMix = function(){return self.__colorMix;}
        static SetColorMix = function(_colors_or_array){
            var _array = _colors_or_array;
            if(argument_count > 1){_array = [argument0, argument1];}
            self.__colorMix = _array;
            self.__colorRgb = undefined;
            self.__colorHsv = undefined;
            self.__color = undefined;
            part_type_color_mix(self.__gmlData, _array[0], _array[1]);
            return self;
        }
        
        //--- COLOR RGB ---//
        __colorRgb = undefined;
        static GetColorRgb = function(){return self.__colorRgb;}
        static SetColorRgb = function(_rmin, _rmax, _gmin, _gmax, _bmin, _bmax){
            self.__colorMix = undefined;
            self.__colorRgb = {rmin: _rmin, rmax: _rmax, gmin: _gmin, gmax: _gmax, bmin: _bmin, bmax: _bmax};
            self.__colorHsv = undefined;
            self.__color = undefined;
            part_type_color_rgb(self.__gmlData, _rmin, _rmax, _gmin, _gmax, _bmin, _bmax);
            return self;
        }
        
        //--- COLOR HSV ---//
        __colorHsv = undefined;
        static GetColorHsv = function(){return self.__colorHsv;}
        static SetColorHsv = function(_hmin, _hmax, _smin, _smax, _vmin, _vmax){
            self.__colorMix = undefined;
            self.__colorRgb = undefined;
            self.__colorHsv = {hmin: _hmin, hmax: _hmax, smin: _smin, smax: _smax, vmin: _vmin, vmax: _vmax};
            self.__color = undefined;
            part_type_color_hsv(self.__gmlData, _hmin, _hmax, _smin, _smax, _vmin, _vmax);
            return self;
        }
        
        //--- COLOR (STANDARD) ---//
        __color = c_white;
        static GetColor = function(){return self.__color;}
        static SetColor = function(_color_or_array){
            if(!is_array(_color_or_array)){
                self.__color = _color_or_array;
                part_type_color1(self.__gmlData, _color_or_array);
                self.__colorMix = undefined;
                self.__colorRgb = undefined;
                self.__colorHsv = undefined;
                return self;
            }
            var _numColors = array_length(_color_or_array);
            if(_numColors == 0){
                Pollen.Warn($"Attempting to set color of type: '{self.__tag}' using an empty array! Bailing!");
                return self;
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
            __colorMix = undefined;
            __colorRgb = undefined;
            __colorHsv = undefined;
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
        
        //--- BLEND ---//
        __blend = undefined;
        static GetBlend = function(){return self.__blend;}
        static SetBlend = function(_blend){
            self.__blend = _blend; 
            part_type_blend(self.__gmlData, _blend); 
            return self;
        }
        
        //--- LIFE ---//
        __life = { min: 100, max: 100};
        static GetLife = function(){ return self.__life; }
        static SetLife = function(_min = __life.min, _max = __life.max){
            self.__life = { min: _min, max: _max };
            part_type_life(self.__gmlData, _min, _max);
            return self;
        }
        
        //--- SUB-PARTICLE STEP ---//
        __step = { number: 100, type: 100};
        static GetStep = function(){ return self.__step; }
        static SetStep = function(_number = __step.number, _type = __step.type){
            self.__step = { number: _number, type: _type };
            if(is_string(_type)){
                var _mapData = Pollen.__typeMap[? _type];
                if(_mapData == undefined){Pollen.Error($"Particle type '{_type}' is not defined in particle map!");}
                _type = _mapData.GetGmlData();
            }
            part_type_step(self.__gmlData, _number, _type);
            return self;
        }
        
        //--- SUB-PARTICLE DEATH ---//
        __death = { number: 100, type: 100};
        static GetDeath = function(){ return self.__death; }
        static SetDeath = function(_number = __death.number, _type = __death.type){
            self.__death = { number: _number, type: _type };
            if(is_string(_type)){
                var _mapData = Pollen.__typeMap[? _type];
                if(_mapData == undefined){Pollen.Error($"Particle type '{_type}' is not defined in particle map!");}
                _type = _mapData.GetGmlData();
            }
            part_type_death(self.__gmlData, _number, _type);
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


#endregion
//======================================================================================================================
#region ~ EMITTERS ~
//======================================================================================================================

    // static __emitterMap = ds_map_create();
    // static EmitterTagGetData = function(_tag){return __emitterMap[? _tag];}
    
    //NOTE: Emitters must be tied to systems which is why I'm defining the data inside Pfx instead of Pollen
    static PfxEmitter = function(_system) constructor {
        
        //--- SETUP BACKEND ---//
        // if(Pollen.__emitterMap[? _tag] != undefined){Pollen.Error($"Attempting to create pollen part emitter, but emitter tag: '{_tag}' already exists!");}
        // Pollen.__emitterMap[? _tag] = self; 
        
        //--- SETUP PROPERTIES ---//
        __gmlData = part_emitter_create(_system.GetGmlData());
        __system = _system;
        __type = undefined;
        __shape = ps_shape_ellipse;
        __distr = ps_distr_linear;
        __delay = {min: 0, max: 0, unit: time_source_units_frames};
        __interval = {min: 0, max: 0, unit: time_source_units_frames};
        __relative = false;
        __number = 1;
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
        static SetShape = function(_shape){__shape = _shape; __system.RefreshStream(); return self;}
        static SetDistr = function(_distr){__distr = _distr; __system.RefreshStream(); return self;}
        
        static SetRelative = function(_enabled){
            __relative = _enabled; 
            part_emitter_relative(__system.GetGmlData(), __gmlData, _enabled);
            __system.RefreshStream(); 
            return self;
        }
        
        static SetDelay = function(_delay){
            __delay = _delay; 
            part_emitter_delay(__system.GetGmlData(), __gmlData, _delay.min, _delay.max, _delay.unit);
            __system.RefreshStream(); 
            return self;
        }
        static SetInterval = function(_interval){
            __interval = _interval; 
            part_emitter_interval(__system.GetGmlData(), __gmlData, _interval.min, _interval.max, _interval.unit);
            __system.RefreshStream(); 
            return self;
        }
        
        static SetOffset = function(_offsetX, _offsetY){
            __offsetX = _offsetX;
            __offsetY = _offsetY;
            __system.RefreshStream();
            return self;
        }
        static SetOffsetX = function(_offsetX){SetSize(_offsetX, __offsetY); return self;}
        static SetOffsetY = function(_offsetY){SetSize(__offsetX, _offsetY); return self;}
        
        //--- GETTERS ---//
        static GetGmlData = function(){return __gmlData;}
        static GetType = function(){return __type;}
        static GetRelative = function(){return __relative;}
        static GetNumber = function(){return __number;}
        static GetShape = function(){return __shape;}
        static GetDistr = function(){return __distr;}
        static GetDelay = function(){return __delay;}
        static GetInterval = function(){return __interval;}
        static GetWidth = function(){return __width;}
        static GetHeight = function(){return __height;}
        static GetSize = function(){return {w: __width, h: __height}}
        static GetOffsetX = function(){return __offsetX;}
        static GetOffsetY = function(){return __offsetY;}
        static GetOffset = function(){return {x: __offsetX, y: __offsetY}}
    }
   
  
#endregion 
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
        __position = {x: 0, y: 0}
        __globalSpace = false;
        __drawOrder = true;
        __angle = 0;
        __depth = 0;
        __layer = undefined;
        __color = c_white;
        __alpha = 1;
        __typeList = _typeList ?? [];
        __emitterList = _emitterList ?? [];
        __isStreaming = false;
        __streamNumber = undefined;
        
        
        //--- SETTERS ---//
        // static SetPosition = function(_x, _y){__position = {x: _x, y: _y}; return self;}
        static SetTypeList = function(_list){__typeList = _list; return self;}
        static SetEmitterList = function(_list){__typeList = _list; return self;}
        static SetColor = function(_color){
            __color = _color; 
            part_system_color(__gmlData, _color, __alpha); 
            self.RefreshStream();
            return self;
        }
        static SetAlpha = function(_alpha){
            __alpha = _alpha; 
            part_system_color(__gmlData, __color, _alpha); 
            self.RefreshStream();
            return self;
        }
        static SetPosition = function(_x = undefined, _y = undefined){
            __position.x = _x ?? __position.x;
            __position.y = _y ?? __position.y;
            part_system_position(__gmlData, __position.x, __position.y); //<---NOTE: I am opting to use a custom position instead since it's less confusing and there are issues with live-updating using part_system_position
            // self.RefreshStream(); //<---NOTE: This will cause a freeze since there is a recursive loop since PfxStream also calls the SetPosition() method
            return self;
        }
        static SetGlobalSpace = function(_enabled){
            __globalSpace = _enabled;
            part_system_global_space(__gmlData, _enabled);
            return self;
        }
        static SetDrawOrder = function(_enabled){
            __drawOrder = _enabled;
            part_system_draw_order(__gmlData, _enabled);
            return self;
        }
        static SetAngle = function(_angle){
            __angle = _angle;
            part_system_angle(__gmlData, _angle);
            // self.RefreshStream(); //<---NOTE: This is not needed for part_system_angle
            return self;
        }
        static SetDepth = function(_depth){
            __depth = _depth; 
            __layer = undefined;
            part_system_depth(__gmlData, _depth); 
            self.RefreshStream(); 
            return self;
        }
        static SetLayer = function(_layer){
            var _id = layer_get_id(_layer);
            if(_id == -1){Pollen.Error("layer: '{_layer}' does not exist in current room!");}
            __layer = _layer;
            __depth = layer_get_depth(_id);
            part_system_layer(__gmlData, _id);
            return self;
        }
        
        static SetTypeProperty = function(_index_or_tag, _property, _args){
            if(!is_real(_index_or_tag)){return self;}
            var _type = __typeList[_index_or_tag];
            Pollen.TypeSetProperty(_type, _property, _args);
            return self;
        }
        
        //--- GETTERS ---//
        static GetTag = function(){return __tag;}
        static GetGmlData = function(){return __gmlData;}
        static GetDepth = function(){return __depth;}
        static GetLayer = function(){return __layer;}
        static GetPosition = function(){return __position;}
        static GetGlobalSpace = function(){return __globalSpace;}
        static GetDrawOrder = function(){return __drawOrder;}
        static GetAngle = function(){return __angle;}
        static GetColor = function(){return __color;}
        static GetAlpha = function(){return __alpha;}
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
            Pollen.PfxStream(__tag);
        }
    }
    
    static PfxStream = function(_system_or_tag, _x = 0, _y = 0, _amount = undefined){
        if(is_string(_system_or_tag)){
            
            var _data = self.__systemMap[? _system_or_tag];
            var _gmlData = _data.GetGmlData();
            var _emitterList = _data.GetEmitterList();
            var _typeList = _data.GetTypeList();
            
            // var _oldPos = _data.GetPosition();
            // _x ??= _oldPos.x; _y ??= _oldPos.y;
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
                var _offsetX = _x + _emitter.GetOffsetX(), _offsetY = _y + _emitter.GetOffsetY();
                var _left = _offsetX - _halfW, _right = _offsetX + _halfW;
                var _top = _offsetY - _halfH, _bottom = _offsetY + _halfH;
                var _shape = _emitter.GetShape(), _distr = _emitter.GetDistr();
                
                var _type = _emitter.GetType();
                if(is_string(_type)){_type = self.TypeTagGetData(_type);}
                var _typeGml = _type.GetGmlData();
                
                part_emitter_region(_gmlData, _emitterGml, _left, _right, _top, _bottom, _shape, _distr);
                part_emitter_stream(_gmlData, _emitterGml, _typeGml, _number);
            }
        }
        //I'll add support for calling with raw Pollen.Pfx data, gml part systems & possibly gml part assets later
        return;
    }
    

#endregion   
//======================================================================================================================
#region ~ IMPORT ~
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
                var _depth = struct_get(_struct, "depth");
                if(_depth != undefined){_tagData.SetDepth(_depth);}
                var _layer = struct_get(_struct, "layer");
                if(_layer != undefined){_tagData.SetLayer(_layer);}
                var _angle = struct_get(_struct, "angle");
                if(_angle != undefined){_tagData.SetAngle(_angle);}
                var _position = struct_get(_struct, "position");
                if(_position != undefined){_tagData.SetPosition(_position.x, _position.y);}
                var _globalSpace = struct_get(_struct, "globalSpace");
                if(_globalSpace != undefined){_tagData.SetGlobalSpace(_globalSpace);}
                var _drawOrder = struct_get(_struct, "drawOrder");
                if(_drawOrder != undefined){_tagData.SetDrawOrder(_drawOrder);}
                var _color = struct_get(_struct, "color");
                if(_color != undefined){_tagData.SetColor(_color);}
                var _alpha = struct_get(_struct, "alpha");
                if(_alpha != undefined){_tagData.SetAlpha(_alpha);}
                var _emitterList = struct_get(_struct, "emitterList");
                if(_emitterList != undefined){
                    var _numOldList = array_length(_tagData.GetEmitterList());
                    var _numNewList = array_length(_emitterList);
                    var _i = -1;
                    repeat(_numNewList){
                        _i++;
                        var _props = _emitterList[_i];
                        var _emitter;
                        if(_numOldList >= _i + 1){_emitter = _tagData.GetEmitterList()[_i];}
                        else {_emitter = new PfxEmitter(_tagData); array_push(_tagData.GetEmitterList(), _emitter);}
                        var _type = struct_get(_props, "type") ?? _emitter.GetType();
                        var _width = struct_get(_props, "width") ?? _emitter.GetWidth();
                        var _height = struct_get(_props, "height") ?? _emitter.GetHeight();
                        var _relative = struct_get(_props, "relative") ?? _emitter.GetRelative();
                        var _number = struct_get(_props, "number") ?? _emitter.GetNumber();
                        var _shape = struct_get(_props, "shape") ?? _emitter.GetShape();
                        var _distr = struct_get(_props, "distr") ?? _emitter.GetDistr();
                        var _delay = struct_get(_props, "delay") ?? _emitter.GetDelay();
                        var _interval = struct_get(_props, "interval") ?? _emitter.GetInterval();
                        var _offsetX = struct_get(_props, "offsetX") ?? _emitter.GetOffsetX();
                        var _offsetY = struct_get(_props, "offsetY") ?? _emitter.GetOffsetY();
                        _emitter
                            .SetType(_type)
                            .SetRelative(_relative) //<---NOTE: This must be before .SetNumber or changes won't be reflected properly
                            .SetNumber(_number)
                            .SetShape(_shape)
                            .SetDistr(_distr)
                            .SetDelay(_delay)
                            .SetInterval(_interval)
                            .SetSize(_width, _height)
                            .SetOffset(_offsetX, _offsetY);
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
        
        //--- COLOR MIX ---//
        var _colorMix = struct_get(_import_data, "colorMix");
        if(_colorMix != undefined){_type_data.SetColorMix(_colorMix);}
        
        //--- COLOR RGB ---//
        var _colorRgb = struct_get(_import_data, "colorRgb");
        if(_colorRgb != undefined){
            
            var _rmin = struct_get(_colorRgb, "rmin");
            var _rmax = struct_get(_colorRgb, "rmax");
            _rmin ??= _rmax; _rmax ??= _rmin; //<---if only one of the values exist, the other value defaults to that
            if(_rmin == undefined && _rmax == undefined){self.Error("colorRgb needs at least one of the two values 'rmin' or 'rmax' defined.");}
            
            var _gmin = struct_get(_colorRgb, "gmin");
            var _gmax = struct_get(_colorRgb, "gmax");
            _gmin ??= _gmax; _gmax ??= _gmin;
            if(_gmin == undefined && _gmax == undefined){self.Error("colorRgb needs at least one of the two values 'gmin' or 'gmax' defined.");}
            
            var _bmin = struct_get(_colorRgb, "bmin");
            var _bmax = struct_get(_colorRgb, "bmax");
            _bmin ??= _bmax; _bmax ??= _bmin;
            if(_bmin == undefined && _bmax == undefined){self.Error("colorRgb needs at least one of the two values 'bmin' or 'bmax' defined.");}
            
            _type_data.SetColorRgb(_rmin, _rmax, _gmin, _gmax, _bmin, _bmax);
        }
        
        //--- COLOR HSV ---//
        var _colorHsv = struct_get(_import_data, "colorHsv");
        if(_colorHsv != undefined){
            
            var _hmin = struct_get(_colorHsv, "hmin");
            var _hmax = struct_get(_colorHsv, "hmax");
            _hmin ??= _hmax; _hmax ??= _hmin; //<---if only one of the values exist, the other value defaults to that
            if(_hmin == undefined && _hmax == undefined){self.Error("colorHsv needs at least one of the two values 'hmin' or 'hmax' defined.");}
            
            var _smin = struct_get(_colorHsv, "smin");
            var _smax = struct_get(_colorHsv, "smax");
            _smin ??= _smax; _smax ??= _smin;
            if(_smin == undefined && _smax == undefined){self.Error("colorHsv needs at least one of the two values 'smin' or 'smax' defined.");}
            
            var _vmin = struct_get(_colorHsv, "vmin");
            var _vmax = struct_get(_colorHsv, "vmax");
            _vmin ??= _vmax; _vmax ??= _vmin;
            if(_vmin == undefined && _vmax == undefined){self.Error("colorHsv needs at least one of the two values 'vmin' or 'vmax' defined.");}
            
            _type_data.SetColorHsv(_hmin, _hmax, _smin, _smax, _vmin, _vmax);
        }
        
        //--- COLOR (STANDARD) ---//
        var _color = struct_get(_import_data, "color");
        if(_color != undefined){_type_data.SetColor(_color);}
        
        //--- ALPHA ---//
        var _alpha = struct_get(_import_data, "alpha");
        if(_alpha != undefined){_type_data.SetAlpha(_alpha);}
        
        //--- BLEND ---//
        var _blend = struct_get(_import_data, "blend");
        if(_blend != undefined){_type_data.SetBlend(_blend);}
        
        //--- LIFE ---//
        var _life = struct_get(_import_data, "life");
        if(_life != undefined){
            var _defLife = _type_data.GetLife();
            var _min = struct_get(_life, "min") ?? _defLife.min;
            var _max = struct_get(_life, "max") ?? _defLife.max;
            _type_data.SetLife(_min, _max);
        }
        
        //--- SUB-PARTICLE STEP ---//
        var _step = struct_get(_import_data, "step");
        if(_step != undefined){
            var _defStep = _type_data.GetLife();
            var _number = struct_get(_step, "number") ?? _defStep.number;
            var _type = struct_get(_step, "type") ?? _defStep.type;
            _type_data.SetStep(_number, _type);
        }
        
        //--- SUB-PARTICLE DEATH ---//
        var _death = struct_get(_import_data, "death");
        if(_death != undefined){
            var _defDeath = _type_data.GetLife();
            var _number = struct_get(_death, "number") ?? _defDeath.number;
            var _type = struct_get(_death, "type") ?? _defDeath.type;
            _type_data.SetDeath(_number, _type);
        }
    }
    

#endregion    
//======================================================================================================================
#region ~ DEBUG ~
//======================================================================================================================
    
    static Log = function(_message){show_debug_message("Pollen -> " + _message);}
    static Warn = function(_message){show_debug_message("Pollen -> Warning! " + _message);}
    static Error = function(_message){show_error("Pollen -> Error! " + _message, true);}


#endregion    
//======================================================================================================================
#region ~ SETUP ~
//======================================================================================================================

} //<---DON'T DELETE THIS!!!

//We only need the static vars in Pollen so we instantiate Pollen to set them up, then delete the actual instance since we don't need it.
var _initPollen = new Pollen(); 
delete _initPollen;
Pollen.ImportPfx(global.pollen_config_pfx); //<---Do not rename any files or this might not work since it requires the other scripts to be initialized first!!!
Pollen.Log("Ready!");


//======================================================================================================================