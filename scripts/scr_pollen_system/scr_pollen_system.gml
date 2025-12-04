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

/*                                                                                                          

    READ THE DOCS!!! -> https://morphomonarchy.github.io/Pollen/#/
  
    INDEX (use ctrl+f to jump to section or search for #region):
    
        ~ UPDATE ~
        ~ TYPES ~
        ~ EMITTERS ~
        ~ SYSTEMS ~
        ~ CREATE PARTICLES ~
        ~ IMPORT ~
        ~ UTIL ~
        ~ DEBUG ~
        
*/

function Pollen() constructor {
    
    //There should be no more than one instance of Pollen
    static __numPollen = 0;
    __numPollen++;
    if(__numPollen > 1){Error("Only one instance of Pollen should ever be created which should be created automatically at the end of the Pollen() constructor.\n   There's no need to create more than one instance since Pollen only uses static vars.");}
    

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
            Pollen.__bootSetupTimer--;
            if (Pollen.__bootSetupTimer <= 0){
                Pollen.__bootSetupTimer = 60;
                
                var _newHash = md5_file(Pollen.__bootSetupPath);
                if (_newHash != Pollen.__bootSetupHash){
                    if (Pollen.__bootSetupHash == undefined){Pollen.__bootSetupHash = _newHash;}
                    else {
                        Pollen.__bootSetupHash = _newHash;
                        
                        var _buffer = buffer_load(Pollen.__bootSetupPath);
                        
                        var _gml = undefined;
                        try {
                            var _gml = __PollenBufferReadGML(_buffer, 0, buffer_get_size(_buffer));
                        }
                        catch(_error) {
                            show_debug_message(json_stringify(_error, true));
                            Warn("Failed to read GML");
                        }
                        
                        if (buffer_exists(_buffer)){
                            buffer_delete(_buffer);
                        }
                        
                        if (is_struct(_gml)){
                            try {
                                var _result = _gml[$ "global.pollen_config_pfx"] ?? [];
                                ImportPfx(_result);
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
    
 
#endregion   
//======================================================================================================================
#region ~ TYPES ~
//======================================================================================================================
    
    /// @title      Types
    /// @category   API
    /// @text       A particle type constructor that uses similar properties found in GM's part_type family of functions. 
    
    
    //--- PROPERTIES ---/
    
    enum pollen_type_property {shape, sprite, size, scale, speed, direction, gravity, orientation, color, blend, life, step, death}
    static __typeMap = ds_map_create();
    
    
    //--- CLASS ---/
    
    /// @constructor
    /// @func   Type(tag, [gml_type])
    /// @desc   A Pollen object that represents GM's part types with additional util functions to simplify building types and getting their data
    /// @param  {string} tag A unique tag used to identity the type
    /// @param  {Id.ParticleType|undefined} [gml_type] An optional reference to a GML part type you can pass in to initialize the type with (i.e. with part_type_create(). Defaults to 'undefined') 
    static Type = function(_tag, _gml_type = undefined) constructor {
        
        //--- SETUP BACKEND ---//
        if(!is_string(_tag)){Pollen.Error($"Tag must be a valid string!");}
        if(Pollen.__typeMap[? _tag] != undefined){Pollen.Error($"Attempting to create pollen part type, but type tag: '{_tag}' already exists!");}
        Pollen.__typeMap[? _tag] = self; 
        
        
        //--- TAG & GML-DATA ---//
        __tag = _tag;
        __gmlData = _gml_type ?? part_type_create();
        
        ///@method  GetTag()
        ///@desc    Returns the unique tag used to identify the type
        ///@return  {string}
        static GetTag = function(){return __tag;}
        
        ///@method  GetGmlData()
        ///@desc    Returns the gml part type data that the Pollen type uses in the backend
        ///@return  {Id.ParticleType}
        static GetGmlData = function(){return __gmlData;}
        
        
        //--- SHAPE ---//
        __shape = pt_shape_pixel;
        
        ///@method  GetShape()
        ///@desc    Returns the part type shape that is being used or undefined if in sprite mode
        ///@return  {pt_shape?}
        static GetShape = function(){return __shape;}
        
        ///@method SetShape(shape)
        ///@desc Sets the shape to a GM part type shape (i.e. pt_shape_snow, etc.) instead of a sprite
        ///@param {pt_shape} shape The pt_shape to set the type to
        ///@return {self}
        static SetShape = function(_shape){
            Pollen.__AssertReal(_shape, "SetShape", "_shape");
            __sprite.id = undefined;
            __shape = _shape;
            part_type_shape(__gmlData, _shape);
            return self;
        }
        
        
        //--- SPRITE ---//
        __sprite = {id: undefined, subImg: 0, animate: false, stretch: false, randomImg: false}
        
        ///@method GetSpriteData()
        ///@desc   Returns the current sprite configuration for the type or undefined if using a primitive shape
        ///@return {struct?}
        static GetSpriteData = function(){return __sprite;}
    
        ///@method SetSprite(sprite, [sub_img], [animate], [stretch], [random_img])
        ///@desc   Sets the particle to use a sprite instead of a pt_shape
        ///@param  {sprite} sprite The sprite asset to render for particles
        ///@param  {real} [sub_img] The starting subimage index
        ///@param  {bool} [animate] Whether the sprite should animate
        ///@param  {bool} [stretch] Whether the sprite should stretch its animation across the life of the particle
        ///@param  {bool} [random_img] Whether to use a random subimage
        ///@return {self}
        static SetSprite = function(_sprite, _sub_img = 0, _animate = false, _stretch = false, _random_img = false){
            if(asset_get_type(_sprite) != asset_sprite){Pollen.Error($"Attempting to set sprite of type: {__tag} but '{_sprite}' is not a valid GM sprite!");};
            Pollen.__AssertReal(_sub_img, "SetSprite", "_sub_img");
            Pollen.__AssertBool(_animate, "SetSprite", "_animate");
            Pollen.__AssertBool(_stretch, "SetSprite", "_stretch");
            Pollen.__AssertBool(_random_img, "SetSprite", "_random_img");
            __shape = undefined;
            __sprite = {id: _sprite, subImg: _sub_img, animate: _animate, stretch: _stretch, randomImg: _random_img};
            part_type_sprite(__gmlData, _sprite, _animate, _stretch, _random_img);
            part_type_subimage(__gmlData, _sub_img);
            return self;
        }
        
        
        //--- SIZE ---// 
        __size = {min: 1, max: 1, incr: 0, wiggle: 0}
        __sizeX = undefined; //<--- I hate this but oh well...
        __sizeY = undefined;
    
        ///@method GetSize()
        ///@desc   Returns the uniform size configuration or undefined if using axis-specific sizes
        ///@return {struct?}
        static GetSize = function(){return __size;}
    
        ///@method SetSize([min], [max], [incr], [wiggle])
        ///@desc   Sets uniform particle size parameters for both axes and clears axis-specific settings
        ///@param  {real} [min] The minimum size
        ///@param  {real} [max] The maximum size
        ///@param  {real} [incr] The size increment per step
        ///@param  {real} [wiggle] The random variation applied to size
        ///@return {self}
        static SetSize = function(_min = undefined, _max = undefined, _incr = undefined, _wiggle = undefined){
            if(__size != undefined){_min ??= __size.min; _max ??= __size.max; _incr ??= __size.incr; _wiggle ??= __size.wiggle;}
            else {_min ??= 0; _max ??= 0; _incr ??= 0; _wiggle ??= 0;}
            Pollen.__AssertReal(_min, "SetSize", "_min");
            Pollen.__AssertReal(_max, "SetSize", "_max");
            Pollen.__AssertReal(_incr, "SetSize", "_incr");
            Pollen.__AssertReal(_wiggle, "SetSize", "_wiggle");
            __size = {min: _min, max: _max, incr: _incr, wiggle: _wiggle}
            __sizeX = undefined;
            __sizeY = undefined;
            part_type_size(__gmlData, _min, _max, _incr, _wiggle);
            return self;
        }
    
        ///@method GetSizeX()
        ///@desc   Returns the X-axis size configuration or undefined if using uniform size
        ///@return {struct?}
        static GetSizeX = function(){return __sizeX;}
    
        ///@method SetSizeX(min, max, incr, wiggle)
        ///@desc   Sets size parameters for the X-axis and clears uniform size
        ///@param  {real} [min] The minimum X size
        ///@param  {real} [max] The maximum X size
        ///@param  {real} [incr] The X size increment per step
        ///@param  {real} [wiggle] The random variation applied to X size
        ///@return {self}
        static SetSizeX = function(_min = undefined, _max = undefined, _incr = undefined, _wiggle = undefined){
            if(__sizeX != undefined){_min ??= __sizeX.min; _max ??= __sizeX.max; _incr ??= __sizeX.incr; _wiggle ??= __sizeX.wiggle;}
            else {_min ??= 0; _max ??= 0; _incr ??= 0; _wiggle ??= 0;}
            __size = undefined;
            Pollen.__AssertReal(_min, "SetSizeX", "_min");
            Pollen.__AssertReal(_max, "SetSizeX", "_max");
            Pollen.__AssertReal(_incr, "SetSizeX", "_incr");
            Pollen.__AssertReal(_wiggle, "SetSizeX", "_wiggle");
            __sizeX = {min: _min, max: _max, incr: _incr, wiggle: _wiggle};
            part_type_size_offsetX(__gmlData, _min, _max, _incr, _wiggle);
            return self;
        }
    
        ///@method GetSizeY()
        ///@desc   Returns the Y-axis size configuration or undefined if using uniform size
        ///@return {struct?}
        static GetSizeY = function(){return __sizeY;}
    
        ///@method SetSizeY([min], [max], [incr], [wiggle])
        ///@desc   Sets size parameters for the Y-axis and clears uniform size
        ///@param  {real} [min] The minimum Y size
        ///@param  {real} [max] The maximum Y size
        ///@param  {real} [incr] The Y size increment per step
        ///@param  {real} [wiggle] The random variation applied to Y size
        ///@return {self}
        static SetSizeY = function(_min = undefined, _max = undefined, _incr = undefined, _wiggle = undefined){
            if(__sizeY != undefined){_min ??= __sizeY.min; _max ??= __sizeY.max; _incr ??= __sizeY.incr; _wiggle ??= __sizeY.wiggle;}
            else {_min ??= 0; _max ??= 0; _incr ??= 0; _wiggle ??= 0;}
            __size = undefined;
            Pollen.__AssertReal(_min, "SetSizeY", "_min");
            Pollen.__AssertReal(_max, "SetSizeY", "_max");
            Pollen.__AssertReal(_incr, "SetSizeY", "_incr");
            Pollen.__AssertReal(_wiggle, "SetSizeY", "_wiggle");
            __sizeY = {min: _min, max: _max, incr: _incr, wiggle: _wiggle};
            part_type_size_y(__gmlData, _min, _max, _incr, _wiggle);
            return self;
        }
        
        
        //--- SCALE ---//
        __scale = {x: 1, y: 1};
    
        ///@method GetScale()
        ///@desc   Returns the current particle render scale (x & y)
        ///@return {struct}
        static GetScale = function(){return __scale;}
    
        ///@method SetScale(x, y)
        ///@desc   Sets the particle render scale on each axis
        ///@param  {real} [x] The horizontal scale factor
        ///@param  {real} [y] The vertical scale factor
        ///@return {self}
        static SetScale = function(_x = __scale.x, _y = __scale.y){
            Pollen.__AssertReal(_x, "SetScale", "_x");
            Pollen.__AssertReal(_y, "SetScale", "_y");
            __scale = {x: _x, y: _y};
            part_type_scale(__gmlData, _x, _y);
            return self;
        }
        
        
        //--- SPEED ---//
        __speed = { min: 0, max: 0, incr: 0, wiggle: 0 };
    
        ///@method GetSpeed()
        ///@desc   Returns the speed configuration for particles
        ///@return {struct}
        static GetSpeed = function(){ return __speed; }
    
        ///@method SetSpeed([min], [max], [incr], [wiggle])
        ///@desc   Sets the particle speed range and dynamics
        ///@param  {real} [min] The minimum speed
        ///@param  {real} [max] The maximum speed
        ///@param  {real} [incr] The speed increment per step
        ///@param  {real} [wiggle] The random variation applied to speed
        ///@return {self}
        static SetSpeed = function(
            _min    = __speed.min,
            _max    = __speed.max,
            _incr   = __speed.incr,
            _wiggle = __speed.wiggle
        ){
            Pollen.__AssertReal(_min, "SetSpeed", "_min");
            Pollen.__AssertReal(_max, "SetSpeed", "_max");
            Pollen.__AssertReal(_incr, "SetSpeed", "_incr");
            Pollen.__AssertReal(_wiggle, "SetSpeed", "_wiggle");
            __speed = { min: _min, max: _max, incr: _incr, wiggle: _wiggle };
            part_type_speed(__gmlData, _min, _max, _incr, _wiggle);
            return self;
        }
        
        
        //--- DIRECTION ---//
        __direction = { min: 0, max: 0, incr: 0, wiggle: 0 };
    
        ///@method GetDirection()
        ///@desc   Returns the emission direction parameters
        ///@return {struct}
        static GetDirection = function(){ return __direction; }
    
        ///@method SetDirection([min], [max], [incr], [wiggle])
        ///@desc   Sets the emission direction range and dynamics
        ///@param  {real} [min] The minimum direction (degrees)
        ///@param  {real} [max] The maximum direction (degrees)
        ///@param  {real} [incr] The direction increment per step (degrees)
        ///@param  {real} [wiggle] The random variation applied to direction
        ///@return {self}
        static SetDirection = function(
            _min    = __direction.min,
            _max    = __direction.max,
            _incr   = __direction.incr,
            _wiggle = __direction.wiggle
        ){
            Pollen.__AssertReal(_min, "SetDirection", "_min");
            Pollen.__AssertReal(_max, "SetDirection", "_max");
            Pollen.__AssertReal(_incr, "SetDirection", "_incr");
            Pollen.__AssertReal(_wiggle, "SetDirection", "_wiggle");
            __direction = { min: _min, max: _max, incr: _incr, wiggle: _wiggle };
            part_type_direction(__gmlData, _min, _max, _incr, _wiggle);
            return self;
        }
        
        
        //--- GRAVITY ---//
        __gravity = { amount: 0, direction: 270 };
    
        ///@method GetGravity()
        ///@desc   Returns the gravity settings (amount and direction)
        ///@return {struct}
        static GetGravity = function(){ return __gravity; }
    
        ///@method SetGravity([amount], [direction])
        ///@desc   Sets the gravity amount and direction applied to particles
        ///@param  {real} [amount] The gravity strength
        ///@param  {real} [direction] The gravity direction in degrees
        ///@return {self}
        static SetGravity = function(
            _amount    = __gravity.amount,
            _direction = __gravity.direction
        ){
            Pollen.__AssertReal(_amount, "SetGravity", "_amount");
            Pollen.__AssertReal(_direction, "SetGravity", "_direction");
            __gravity = { amount: _amount, direction: _direction };
            part_type_gravity(__gmlData, _amount, _direction);
            return self;
        }
        
        
        //--- ORIENTATION ---//
        __orientation = { min: 0, max: 0, incr: 0, wiggle: 0, relative: false };
    
        ///@method GetOrientation()
        ///@desc   Returns the image orientation parameters
        ///@return {struct}
        static GetOrientation = function(){ return __orientation; }
    
        ///@method SetOrientation([min], [max], [incr], [wiggle], [relative])
        ///@desc   Sets the image orientation range and whether it tracks particle direction
        ///@param  {real} [min] The minimum image angle
        ///@param  {real} [max] The maximum image angle
        ///@param  {real} [incr] The angle increment per step
        ///@param  {real} [wiggle] The random variation applied to angle
        ///@param  {bool} [relative] Whether to orient relative to motion
        ///@return {self}
        static SetOrientation = function(
            _min      = __orientation.min,
            _max      = __orientation.max,
            _incr     = __orientation.incr,
            _wiggle   = __orientation.wiggle,
            _relative = __orientation.relative
        ){
            Pollen.__AssertReal(_min, "SetOrientation", "_min");
            Pollen.__AssertReal(_max, "SetOrientation", "_max");
            Pollen.__AssertReal(_incr, "SetOrientation", "_incr");
            Pollen.__AssertReal(_wiggle, "SetOrientation", "_wiggle");
            Pollen.__AssertBool(_relative, "SetOrientation", "_relative");
            __orientation = { min: _min, max: _max, incr: _incr, wiggle: _wiggle, relative: _relative };
            part_type_orientation(__gmlData, _min, _max, _incr, _wiggle, _relative);
            return self;
        }
        
        
        //--- COLOR MIX ---//
        __colorMix = undefined;
    
        ///@method GetColorMix()
        ///@desc   Returns the two-color mix array if set, otherwise undefined
        ///@return {array<color>?}
        static GetColorMix = function(){return __colorMix;}
    
        ///@method SetColorMix(colors_or_array)
        ///@desc   Sets a two-color gradient mix for particles (accepts two arguments or an array of colors)
        ///@param  {array<color>|color} colors_or_array Two colors as an array, or pass as two separate arguments
        ///@return {self}
        static SetColorMix = function(_colors_or_array){
            var _array = _colors_or_array;
            if(argument_count > 1){
                Pollen.__AssertReal(argument0, "SetColorMix", "argument0");
                Pollen.__AssertReal(argument1, "SetColorMix", "argument1");
                _array = [argument0, argument1];
            }
            else {
                Pollen.__AssertArray(_array, "SetColorMix", "_colors_or_array");
            }
            var _length = array_length(_array);
            if(_length < 2){
                Pollen.Error($"PfxType.SetColorMix() expects at least 2 colors but received {_length}!");
            }
            Pollen.__AssertReal(_array[0], "SetColorMix", "_colors_or_array[0]");
            Pollen.__AssertReal(_array[1], "SetColorMix", "_colors_or_array[1]");
            __colorMix = _array;
            __colorRgb = undefined;
            __colorHsv = undefined;
            __color = undefined;
            part_type_color_mix(__gmlData, _array[0], _array[1]);
            return self;
        }
        
        
        //--- COLOR RGB ---//
        __colorRgb = undefined;
    
        ///@method GetColorRgb()
        ///@desc   Returns the RGB range configuration or undefined if not set
        ///@return {struct?}
        static GetColorRgb = function(){return __colorRgb;}
    
        ///@method SetColorRgb(rmin, rmax, gmin, gmax, bmin, bmax)
        ///@desc   Sets randomized RGB color channel ranges for particles
        ///@param  {real} rmin Minimum red channel (0–255)
        ///@param  {real} rmax Maximum red channel (0–255)
        ///@param  {real} gmin Minimum green channel (0–255)
        ///@param  {real} gmax Maximum green channel (0–255)
        ///@param  {real} bmin Minimum blue channel (0–255)
        ///@param  {real} bmax Maximum blue channel (0–255)
        ///@return {self}
        static SetColorRgb = function(_rmin, _rmax, _gmin, _gmax, _bmin, _bmax){
            Pollen.__AssertReal(_rmin, "SetColorRgb", "_rmin");
            Pollen.__AssertReal(_rmax, "SetColorRgb", "_rmax");
            Pollen.__AssertReal(_gmin, "SetColorRgb", "_gmin");
            Pollen.__AssertReal(_gmax, "SetColorRgb", "_gmax");
            Pollen.__AssertReal(_bmin, "SetColorRgb", "_bmin");
            Pollen.__AssertReal(_bmax, "SetColorRgb", "_bmax");
            __colorMix = undefined;
            __colorRgb = {rmin: _rmin, rmax: _rmax, gmin: _gmin, gmax: _gmax, bmin: _bmin, bmax: _bmax};
            __colorHsv = undefined;
            __color = undefined;
            part_type_color_rgb(__gmlData, _rmin, _rmax, _gmin, _gmax, _bmin, _bmax);
            return self;
        }
    
    
        //--- COLOR HSV ---//
        __colorHsv = undefined;
    
        ///@method GetColorHsv()
        ///@desc   Returns the HSV range configuration or undefined if not set
        ///@return {struct?}
        static GetColorHsv = function(){return __colorHsv;}
    
        ///@method SetColorHsv(hmin, hmax, smin, smax, vmin, vmax)
        ///@desc   Sets randomized HSV color ranges for particles
        ///@param  {real} hmin Minimum hue (0–255)
        ///@param  {real} hmax Maximum hue (0–255)
        ///@param  {real} smin Minimum saturation (0–255)
        ///@param  {real} smax Maximum saturation (0–255)
        ///@param  {real} vmin Minimum value/brightness (0–255)
        ///@param  {real} vmax Maximum value/brightness (0–255)
        ///@return {self}
        static SetColorHsv = function(_hmin, _hmax, _smin, _smax, _vmin, _vmax){
            Pollen.__AssertReal(_hmin, "SetColorHsv", "_hmin");
            Pollen.__AssertReal(_hmax, "SetColorHsv", "_hmax");
            Pollen.__AssertReal(_smin, "SetColorHsv", "_smin");
            Pollen.__AssertReal(_smax, "SetColorHsv", "_smax");
            Pollen.__AssertReal(_vmin, "SetColorHsv", "_vmin");
            Pollen.__AssertReal(_vmax, "SetColorHsv", "_vmax");
            __colorMix = undefined;
            __colorRgb = undefined;
            __colorHsv = {hmin: _hmin, hmax: _hmax, smin: _smin, smax: _smax, vmin: _vmin, vmax: _vmax};
            __color = undefined;
            part_type_color_hsv(__gmlData, _hmin, _hmax, _smin, _smax, _vmin, _vmax);
            return self;
        }
        
        
        //--- COLOR (STANDARD) ---//
        __color = c_white;
    
        ///@method GetColor()
        ///@desc   Returns the standard color configuration (single, two, or three colors) if set
        ///@return {color|array<color>}
        static GetColor = function(){return __color;}
    
        ///@method SetColor(color_or_array)
        ///@desc   Sets standard color using one, two, or three colors; accepts a single color or an array of up to three colors
        ///@param  {color|array<color>} color_or_array A single color or an array of colors (1–3 entries)
        ///@return {self}
        static SetColor = function(_color_or_array){
            if(!is_array(_color_or_array)){
                Pollen.__AssertReal(_color_or_array, "SetColor", "_color_or_array");
                __color = _color_or_array;
                part_type_color1(__gmlData, _color_or_array);
                __colorMix = undefined;
                __colorRgb = undefined;
                __colorHsv = undefined;
                return self;
            }
            Pollen.__AssertArrayOfReals(_color_or_array, "SetColor", "_color_or_array");
            var _numColors = array_length(_color_or_array);
            if(_numColors == 0){
                Pollen.Warn($"Attempting to set color of type: '{__tag}' using an empty array! Bailing!");
                return self;
            }
            else if(_numColors == 1){
                __color = _color_or_array[0];
                part_type_color1(__gmlData, _color_or_array[0]);
            }
            else if(_numColors == 2){
                __color = _color_or_array;
                part_type_color2(__gmlData, _color_or_array[0], _color_or_array[1]);
            }
            else if(_numColors == 3){
                __color = _color_or_array;
                part_type_color3(__gmlData, _color_or_array[0], _color_or_array[1], _color_or_array[2]);
            }
            else {
                Pollen.Warn($"Attempting to set color of type: '{__tag}' using an array larger than 3. Defaulting to first 3 values!");
                __color = [_color_or_array[0], _color_or_array[1], _color_or_array[2]];
                part_type_color3(__gmlData, _color_or_array[0], _color_or_array[1], _color_or_array[2]);
            }
            __colorMix = undefined;
            __colorRgb = undefined;
            __colorHsv = undefined;
            return self;
        }
        
        
        //--- ALPHA ---//
        __alpha = 1;
    
        ///@method GetAlpha()
        ///@desc   Returns the alpha (opacity) configuration (single, two, or three values)
        ///@return {real|array<real>}
        static GetAlpha = function(){return __alpha;}
    
        ///@method SetAlpha(alpha_or_array)
        ///@desc   Sets alpha (opacity) using one, two, or three values; accepts a single number or an array
        ///@param  {real|array<real>} alpha_or_array A single alpha value or an array (1–3 entries)
        ///@return {self}
        static SetAlpha = function(_alpha_or_array){
            if(!is_array(_alpha_or_array)){
                Pollen.__AssertReal(_alpha_or_array, "SetAlpha", "_alpha_or_array");
                __alpha = _alpha_or_array;
                part_type_alpha1(__gmlData, _alpha_or_array);
                return self;
            }
            Pollen.__AssertArrayOfReals(_alpha_or_array, "SetAlpha", "_alpha_or_array");
            var _numalphas = array_length(_alpha_or_array);
            if(_numalphas == 0){
                Pollen.Warn($"Attempting to set alpha of type: '{__tag}' using an empty array! Bailing!");
                return self;
            }
            else if(_numalphas == 1){
                __alpha = _alpha_or_array[0];
                part_type_alpha1(__gmlData, _alpha_or_array[0]);
            }
            else if(_numalphas == 2){
                __alpha = _alpha_or_array;
                part_type_alpha2(__gmlData, _alpha_or_array[0], _alpha_or_array[1]);
            }
            else if(_numalphas == 3){
                __alpha = _alpha_or_array;
                part_type_alpha3(__gmlData, _alpha_or_array[0], _alpha_or_array[1], _alpha_or_array[2]);
            }
            else {
                Pollen.Warn($"Attempting to set alpha of type: '{__tag}' using an array larger than 3. Defaulting to first 3 values!");
                __alpha = [_alpha_or_array[0], _alpha_or_array[1], _alpha_or_array[2]];
                part_type_alpha3(__gmlData, _alpha_or_array[0], _alpha_or_array[1], _alpha_or_array[2]);
            }
            return self;
        }
        
        
        //--- BLEND ---//
        __blend = false;
    
        ///@method GetBlend()
        ///@desc   Returns whether additive blending is enabled for this particle type
        ///@return {bool}
        static GetBlend = function(){return __blend;}
    
        ///@method SetBlend(enable)
        ///@desc   Enables or disables additive blending for particles
        ///@param  {bool} enable True to enable additive blending, false for normal blending
        ///@return {self}
        static SetBlend = function(_enable){
            Pollen.__AssertBool(_enable, "SetBlend", "_enable");
            __blend = _enable;
            part_type_blend(__gmlData, _enable);
            return self;
        }
    
    
        //--- LIFE ---//
        __life = { min: 100, max: 100};
    
        ///@method GetLife()
        ///@desc   Returns the particle lifetime range in steps
        ///@return {struct}
        static GetLife = function(){ return __life; }
    
        ///@method SetLife([min], [max])
        ///@desc   Sets the particle lifetime range in steps
        ///@param  {real} [min] The minimum lifetime (steps)
        ///@param  {real} [max] The maximum lifetime (steps)
        ///@return {self}
        static SetLife = function(_min = __life.min, _max = __life.max){
            Pollen.__AssertReal(_min, "SetLife", "_min");
            Pollen.__AssertReal(_max, "SetLife", "_max");
            __life = { min: _min, max: _max };
            part_type_life(__gmlData, _min, _max);
            return self;
        }
    
    
        //--- SUB-PARTICLE STEP ---//
        __step = { number: 0, type: undefined};
    
        ///@method GetStep()
        ///@desc   Returns the sub-particle step emission settings
        ///@return {struct}
        static GetStep = function(){ return __step; }
    
        ///@method SetStep([number], [type])
        ///@desc   Emits sub-particles every given number of steps using the specified type
        ///@param  {real} [number] The step interval between emissions
        ///@param  {struct|string|undefined} [type] The sub-particle type (Pollen.Type instance, tag, or undefined)
        ///@return {self}
        static SetStep = function(_number = __step.number, _type = __step.type){
            Pollen.__AssertReal(_number, "SetStep", "_number");
            if((_type != undefined) && !is_struct(_type) && !is_string(_type)){
                Pollen.Error($"PfxType.SetStep() expects argument '_type' to be a struct, string, or undefined but received {typeof(_type)}!");
            }
            __step = { number: _number, type: _type };
            if(is_string(_type)){
                var _mapData = Pollen.__typeMap[? _type];
                if(_mapData == undefined){Pollen.Error($"Particle type '{_type}' is not defined in particle map!");}
                _type = _mapData.GetGmlData();
            }
            part_type_step(__gmlData, _number, _type);
            return self;
        }
    
    
        //--- SUB-PARTICLE DEATH ---//
        __death = { number: 0, type: undefined};
    
        ///@method GetDeath()
        ///@desc   Returns the sub-particle death emission settings
        ///@return {struct}
        static GetDeath = function(){ return __death; }
    
        ///@method SetDeath([number], [type])
        ///@desc   Emits sub-particles upon death using the specified type and particle count
        ///@param  {real} [number] The number of sub-particles to create on death
        ///@param  {struct|string|undefined} [type] The sub-particle type (Pollen.Type instance, tag, or undefined)
        ///@return {self}
        static SetDeath = function(_number = __death.number, _type = __death.type){
            Pollen.__AssertReal(_number, "SetDeath", "_number");
            if((_type != undefined) && !is_struct(_type) && !is_string(_type)){
                Pollen.Error($"PfxType.SetDeath() expects argument '_type' to be a struct, string, or undefined but received {typeof(_type)}!");
            }
            __death = { number: _number, type: _type };
            if(is_string(_type)){
                var _mapData = Pollen.__typeMap[? _type];
                if(_mapData == undefined){Pollen.Error($"Particle type '{_type}' is not defined in particle map!");}
                _type = _mapData.GetGmlData();
            }
            part_type_death(__gmlData, _number, _type);
            return self;
        }
    
    
        //--- UTIL ---//
        
        ///@method Copy()
        ///@desc   Copies all configurable properties from another Pollen.Type into this type
        ///@param  {Pollen.Type} target The source type to copy from
        ///@return {undefined}
        static Copy = function(_target) {
            if (_target == undefined || _target == self) { return; }
            if (!is_instanceof(_target, Pollen.Type)){Pollen.Error($"Attempting to have type: '{__tag}'' copy data from target, but the target is not a valid Pollen.Type!");}
        
            var _sprite = _target.GetSpriteData();
            var _shape = _target.GetShape();
            if (_sprite != undefined && _sprite.id != undefined) {
                SetSprite(
                    _sprite.id,
                    _sprite.subImg,
                    _sprite.animate,
                    _sprite.stretch,
                    _sprite.randomImg
                );
            }
            else if (_shape != undefined) {
                SetShape(_shape);
            }
        
            var _size = _target.GetSize();
            if (_size != undefined) {
                SetSize(_size.min, _size.max, _size.incr, _size.wiggle);
            }
        
            var _sizeX = _target.GetSizeX();
            if (_sizeX != undefined) {
                SetSizeX(_sizeX.min, _sizeX.max, _sizeX.incr, _sizeX.wiggle);
            }
        
            var _sizeY = _target.GetSizeY();
            if (_sizeY != undefined) {
                SetSizeY(_sizeY.min, _sizeY.max, _sizeY.incr, _sizeY.wiggle);
            }
        
            var _scale = _target.GetScale();
            if (_scale != undefined) {
                SetScale(_scale.x, _scale.y);
            }
        
            var _speed = _target.GetSpeed();
            if (_speed != undefined) {
                SetSpeed(_speed.min, _speed.max, _speed.incr, _speed.wiggle);
            }
        
            var _direction = _target.GetDirection();
            if (_direction != undefined) {
                SetDirection(_direction.min, _direction.max, _direction.incr, _direction.wiggle);
            }
        
            var _gravity = _target.GetGravity();
            if (_gravity != undefined) {
                SetGravity(_gravity.amount, _gravity.direction);
            }
        
            var _orientation = _target.GetOrientation();
            if (_orientation != undefined) {
                SetOrientation(
                    _orientation.min,
                    _orientation.max,
                    _orientation.incr,
                    _orientation.wiggle,
                    _orientation.relative
                );
            }
        
            var _colorMix = _target.GetColorMix();
            if (_colorMix != undefined) {
                SetColorMix(_colorMix);
            }
            else {
                var _colorRgb = _target.GetColorRgb();
                if (_colorRgb != undefined) {
                    SetColorRgb(
                        _colorRgb.rmin,
                        _colorRgb.rmax,
                        _colorRgb.gmin,
                        _colorRgb.gmax,
                        _colorRgb.bmin,
                        _colorRgb.bmax
                    );
                }
                else {
                    var _colorHsv = _target.GetColorHsv();
                    if (_colorHsv != undefined) {
                        SetColorHsv(
                            _colorHsv.hmin,
                            _colorHsv.hmax,
                            _colorHsv.smin,
                            _colorHsv.smax,
                            _colorHsv.vmin,
                            _colorHsv.vmax
                        );
                    }
                    else {
                        var _color = _target.GetColor();
                        if (_color != undefined) {
                            SetColor(_color);
                        }
                    }
                }
            }
        
            var _alpha = _target.GetAlpha();
            if (_alpha != undefined) {
                SetAlpha(_alpha);
            }
        
            var _blend = _target.GetBlend();
            if (_blend != undefined) {
                SetBlend(_blend);
            }
        
            var _life = _target.GetLife();
            if (_life != undefined) {
                SetLife(_life.min, _life.max);
            }
        
            var _step = _target.GetStep();
            if (_step.type != undefined) {
                SetStep(_step.number, _step.type);
            }
        
            var _death = _target.GetDeath();
            if (_death.type != undefined) {
                SetDeath(_death.number, _death.type);
            }
        }
        
    }
    
    //--- TYPE CONTROL ---/
    
    ///@func    TypeTagGetData(tag)
    ///@desc    Get the data associated with a Pollen.Type tag (or undefined if data does not exist for the tag)
    ///@param   {string} tag The tag of the Pollen.Type that you want to get the data for
    ///@return {Pollen.Type|undefined}
    static TypeTagGetData = function(_tag){return __typeMap[? _tag];}
    
    ///@func    TypeDestroy(type)
    ///@desc    Destroys a Pollen.Type and clears all of its data (including the GM part_type it holds)
    ///@param   {Pollen.Type} type The Pollen.Type data that you want to destroy
    ///@return  {undefined}
    static TypeDestroy = function(_type){
        if(!is_instanceof(_type, Type)){Error("Cannot destroy type that is not a valid Pollen.Type struct!");}
        part_type_destroy(_type.GetGmlData());
        var _tag = _type.GetTag();
        ds_map_delete(__typeMap, _tag);
        delete _type;
        Log($"Successfully destroyed Pollen type: {_tag}");
    }
    
    ///@func    TypeDestroyAll()
    ///@desc    Destroys all Pollen.Types that exist and clears all their data
    ///@return  {undefined}
    static TypeDestroyAll = function(){
        var _mapArray = ds_map_values_to_array(__typeMap);
        var _numTypes = array_length(_mapArray);
        var _i = -1;
        repeat(_numTypes){
            _i++;
            var _type = _mapArray[_i];
            TypeDestroy(_type);
        }
        ds_map_destroy(__typeMap); //<---Gamemaker does not automatically reallocate an empty map, therefore it's best to destroy the map and make a new one so there isn't a bunch of empty data floating around
        __typeMap = ds_map_create();
        __defaultType = new Pollen.Type("__pollen_type_default");
    }

    ///@func    TypeReset(type)
    ///@desc    Resets all the underlying data of a part type to default settings similar to GM's 'part_type_clear' function. Does not clear the visual representation of particles!
    ///@param   {Pollen.Type} type The Pollen.Type data that you want to reset
    ///@return  {undefined}
    static TypeReset = function(_type){
        part_type_clear(_type.GetGmlData());
        _type.Copy(__defaultType);
    }

#endregion 
//======================================================================================================================
#region ~ EMITTERS ~
//======================================================================================================================
    
    /// @title      Emitters
    /// @category   API
    /// @text       A particle emitter constructor that uses similar properties found in GM's part_emitter family of functions.
    
    /// @constructor
    /// @func   Emitter(system, [gml_emitter])
    /// @desc   A Pollen object that represents GM's part emitters with additional util functions to simplify building emitters and getting their data
    /// @param  {Pollen.System} system The Pollen.System the emitter is tied to
    /// @param  {Id.ParticleEmitter|undefined} [gml_emitter] An optional reference to a GML part emitter you can pass in to initialize the emitter with (i.e. with part_emitter_create(). Defaults to 'undefined') 
    //NOTE: Emitters must be tied to systems which is why there are no maps/tags associated with it
    static Emitter = function(_system, _gml_emitter = undefined) constructor {
            
        if(!is_instanceof(_system, Pollen.System)){Pollen.Error("Trying to create an emitter using a system that is not a valid Pollen.System struct!");}
        
        //--- SETUP PROPERTIES ---//
        __gmlData = _gml_emitter ?? part_emitter_create(_system.GetGmlData());
        __system = _system;
        __enabled = true;
        __type = undefined;
        __number = 1;
        __shape = ps_shape_ellipse;
        __distr = ps_distr_linear;
        __relative = false;
        __delay = {min: 0, max: 0, unit: time_source_units_frames};
        __interval = {min: 0, max: 0, unit: time_source_units_frames};
        __width = 32;
        __height = 32;
        __offsetX = 0;
        __offsetY = 0;
        

        //--- SETTERS ---//

        ///@method SetEnabled(enabled)
        ///@desc   Whether to enable the emitter to emit particles or not
        ///@param  {bool} enabled True to enable, false to disable
        ///@return {self}
        static SetEnabled = function(_enabled){
            Pollen.__AssertBool(_enabled, "SetEnabled", "_enabled");
            __enabled = _enabled;
            part_emitter_enable(__system.GetGmlData(), __gmlData, _enabled);
            return self;
        }

        ///@method SetType(type)
        ///@desc   Sets the particle type emitted (Pollen.Type instance or tag)
        ///@param  {struct|string|undefined} type The type struct or tag, or undefined to clear
        ///@return {self}
        static SetType = function(_type){
            if((_type != undefined) && !is_struct(_type) && !is_string(_type)){
                Pollen.Error($"PfxEmitter.SetType() expects argument '_type' to be a struct, string, or undefined but received {typeof(_type)}!");
            }
            __type = _type;
            __system.RefreshStream();
            return self;
        }

        ///@method SetNumber(number)
        ///@desc   Sets how many particles this emitter creates per burst/tick
        ///@param  {real} number The number of particles
        ///@return {self}
        static SetNumber = function(_number){
            Pollen.__AssertReal(_number, "SetNumber", "_number");
            __number = _number;
            __system.RefreshStream();
            return self;
        }

        ///@method SetShape(shape)
        ///@desc   Sets the emitter region shape (e.g., ps_shape_rectangle, ps_shape_ellipse)
        ///@param  {ps_shape} shape The emitter shape constant
        ///@return {self}
        static SetShape = function(_shape){
            Pollen.__AssertReal(_shape, "SetShape", "_shape");
            __shape = _shape;
            __system.RefreshStream();
            return self;
        }

        ///@method SetDistr(distr)
        ///@desc   Sets the particle distribution shape within the emitter region (e.g., ps_distr_linear)
        ///@param  {ps_distr} distr The distribution constant
        ///@return {self}
        static SetDistr = function(_distr){
            Pollen.__AssertReal(_distr, "SetDistr", "_distr");
            __distr = _distr;
            __system.RefreshStream();
            return self;
        }

        ///@method SetRelative(enabled)
        ///@desc   Toggles whether the number of particles (changed via .SetNumber) is an exact number or a relative percentage of emitter area filled
        /// (see "part_emitter_relative" in GM manual for more info)
        ///@param  {bool} enabled True for relative, false for absolute
        ///@return {self}
        static SetRelative = function(_enabled){
            Pollen.__AssertBool(_enabled, "SetRelative", "_enabled");
            __relative = _enabled;
            part_emitter_relative(__system.GetGmlData(), __gmlData, _enabled);
            __system.RefreshStream();
            return self;
        }

        ///@method SetDelay(delay)
        ///@desc   Sets the initial delay before emission begins when streaming a particle
        ///@param  {struct} delay A struct containing the following properties {min, max, unit}
        ///@return {self}
        static SetDelay = function(_delay){
            Pollen.__AssertRangeStruct(_delay, "SetDelay", "_delay");
            __delay = _delay;
            part_emitter_delay(__system.GetGmlData(), __gmlData, _delay.min, _delay.max, _delay.unit);
            __system.RefreshStream();
            return self;
        }

        ///@method SetInterval(interval)
        ///@desc   Sets the interval between emissions when streaming a particle
        ///@param  {struct} interval A struct containing the following properties {min, max, unit}
        ///@return {self}
        static SetInterval = function(_interval){
            Pollen.__AssertRangeStruct(_interval, "SetInterval", "_interval");
            __interval = _interval;
            part_emitter_interval(__system.GetGmlData(), __gmlData, _interval.min, _interval.max, _interval.unit);
            __system.RefreshStream();
            return self;
        }

        ///@method SetSize(width, height)
        ///@desc   Sets the emitter region size
        ///@param  {real} width The emitter width
        ///@param  {real} height The emitter height
        ///@return {self}
        static SetSize = function(_width, _height){
            Pollen.__AssertReal(_width, "SetSize", "_width");
            Pollen.__AssertReal(_height, "SetSize", "_height");
            __width = _width;
            __height = _height;
            __system.RefreshStream();
            return self;
        }

        ///@method SetWidth(width)
        ///@desc   Sets the emitter region width
        ///@param  {real} width The emitter width
        ///@return {self}
        static SetWidth = function(_width){
            Pollen.__AssertReal(_width, "SetWidth", "_width");
            SetSize(_width, __height);
            return self;
        }

        ///@method SetHeight(height)
        ///@desc   Sets the emitter region height
        ///@param  {real} height The emitter height
        ///@return {self}
        static SetHeight = function(_height){
            Pollen.__AssertReal(_height, "SetHeight", "_height");
            SetSize(__width, _height);
            return self;
        }

        ///@method SetOffset(offsetX, offsetY)
        ///@desc   Sets the emitter offset from its origin
        ///@param  {real} offsetX Horizontal offset
        ///@param  {real} offsetY Vertical offset
        ///@return {self}
        static SetOffset = function(_offsetX, _offsetY){
            Pollen.__AssertReal(_offsetX, "SetOffset", "_offsetX");
            Pollen.__AssertReal(_offsetY, "SetOffset", "_offsetY");
            __offsetX = _offsetX;
            __offsetY = _offsetY;
            __system.RefreshStream();
            return self;
        }

        ///@method SetOffsetX(offsetX)
        ///@desc   Sets only the horizontal emitter offset
        ///@param  {real} offsetX Horizontal offset
        ///@return {self}
        static SetOffsetX = function(_offsetX){
            Pollen.__AssertReal(_offsetX, "SetOffsetX", "_offsetX");
            SetOffset(_offsetX, __offsetY);
            return self;
        }

        ///@method SetOffsetY(offsetY)
        ///@desc   Sets only the vertical emitter offset
        ///@param  {real} offsetY Vertical offset
        ///@return {self}
        static SetOffsetY = function(_offsetY){
            Pollen.__AssertReal(_offsetY, "SetOffsetY", "_offsetY");
            SetOffset(__offsetX, _offsetY);
            return self;
        }
        
        
        //--- GETTERS ---//

        ///@method GetGmlData()
        ///@desc   Returns the underlying GM emitter handle used by the system
        ///@return {Id.Emitter}
        static GetGmlData = function(){return __gmlData;}

        ///@method GetSystem()
        ///@desc   Returns the parent Pollen.System that owns this emitter
        ///@return {Pollen.System}
        static GetSystem = function(){return __system;}

        ///@method IsEnabled()
        ///@desc   Returns whether the emitter is enabled
        ///@return {bool}
        static IsEnabled = function(){return __enabled;}

        ///@method GetEnabled()
        ///@desc   Alias for IsEnabled(); returns whether the emitter is enabled
        ///@return {bool}
        static GetEnabled = function(){return __enabled;}

        ///@method GetType()
        ///@desc   Returns the particle type set on this emitter (struct or tag), or undefined
        ///@return {struct|string|undefined}
        static GetType = function(){return __type;}

        ///@method GetNumber()
        ///@desc   Returns the number of particles emitted per burst/tick
        ///@return {real}
        static GetNumber = function(){return __number;}

        ///@method GetShape()
        ///@desc   Returns the emitter region shape constant
        ///@return {ps_shape|undefined}
        static GetShape = function(){return __shape;}

        ///@method GetDistr()
        ///@desc   Returns the emitter distribution
        ///@return {bool}
        static GetDistr = function(){return __distr;}

        ///@method GetRelative()
        ///@desc   Returns whether the emitter is emitting exact number of particles (true) or a relative percentage (false)
        ///@return {bool}
        static GetRelative = function(){return __relative;}

        ///@method GetDelay()
        ///@desc   Returns the initial delay settings for streaming {min, max, unit}
        ///@return {struct}
        static GetDelay = function(){return __delay;}

        ///@method GetInterval()
        ///@desc   Returns the interval settings for streaming {min, max, unit}
        ///@return {struct}
        static GetInterval = function(){return __interval;}

        ///@method GetSize()
        ///@desc   Returns the emitter region size as a struct {w, h}
        ///@return {struct}
        static GetSize = function(){return {w: __width, h: __height}}

        ///@method GetWidth()
        ///@desc   Returns the emitter region width
        ///@return {real}
        static GetWidth = function(){return __width;}

        ///@method GetHeight()
        ///@desc   Returns the emitter region height
        ///@return {real}
        static GetHeight = function(){return __height;}

        ///@method GetOffset()
        ///@desc   Returns the emitter offset as a struct {x, y}
        ///@return {struct}
        static GetOffset = function(){return {x: __offsetX, y: __offsetY}}

        ///@method GetOffsetX()
        ///@desc   Returns the horizontal emitter offset
        ///@return {real}
        static GetOffsetX = function(){return __offsetX;}

        ///@method GetOffsetY()
        ///@desc   Returns the vertical emitter offset
        ///@return {real}
        static GetOffsetY = function(){return __offsetY;}
        
        //--- UTIL ---//
        ///@method Copy(target)
        ///@desc   Copies configuration from another Pollen.Emitter into this emitter
        ///@param  {Pollen.Emitter} target The source emitter to copy from
        ///@return {undefined}
        static Copy = function(_target){
            SetEnabled(_target.GetEnabled());
            SetType(_target.GetType());
            SetNumber(_target.GetNumber());
            SetShape(_target.GetShape());
            SetDistr(_target.GetDistr());
            SetRelative(_target.GetRelative());
            SetDelay(_target.GetDelay());
            SetInterval(_target.GetInterval());
            SetSize(_target.GetWidth(), _target.GetHeight());
            SetOffset(_target.GetOffsetX(), _target.GetOffsetY());
        }
    }
    
    ///@func    EmitterDestroy(emitter)
    ///@desc    Destroys a single Pollen.Emitter and clears all of its data (including its underlying GM part_emitter data)
    ///@param   {Pollen.Emitter} emitter The Pollen.Emitter data to destroy
    ///@returns {undefined}
    static EmitterDestroy = function(_emitter){
        if(!is_instanceof(_emitter, Emitter)){Error("Cannot destroy emitter that is not a valid Pollen.Emitter struct!");}
        var _system = _emitter.GetSystem();
        part_emitter_destroy(_system.GetGmlData(), _emitter.GetGmlData());
        delete _emitter;
        Log($"Destroyed emitter from {_system.GetTag()}");
    }
    
    ///@func    EmitterReset(emitter)
    ///@desc    Resets the underlying data of a particle emitter similar to GM's 'part_emitter_clear' function. NOTE: if an emitter is streaming particles, it will stop and have to be restarted using Pollen.Stream
    ///@param   {Pollen.Emitter} system The Pollen.System data that you want to reset
    ///@return  {undefined}
    static EmitterReset = function(_emitter){
        part_emitter_clear(_emitter.__system.GetGmlData(), _emitter.GetGmlData());
        _emitter.Copy(__defaultEmitter);
    }
   
#endregion 
//======================================================================================================================
#region ~ SYSTEMS ~
//======================================================================================================================

    /// @title      System
    /// @category   API
    /// @text       A particle system constructor that uses similar properties found in GM's part_system family of functions. 


    //--- PROPERTIES ---//
    
    static __systemMap = ds_map_create();


    //--- CLASS ---//
    
    /// @constructor
    /// @func   System(tag, [gml_system])
    /// @desc   A Pollen object that represents GM's part systems with additional util functions to simplify building systems and getting their data
    /// @param  {string} tag A unique tag used to identity the system
    /// @param  {Id.ParticleType|undefined} [gml_system] An optional reference to a GML part system you can pass in to initialize the type with (i.e. with part_system_create(). Defaults to 'undefined') 
    static System = function(_tag, _gml_system = undefined) constructor {
        
        //--- SETUP BACKEND ---//
        if(!is_string(_tag)){Pollen.Error($"Tag must be a valid string!");}
        if(Pollen.__systemMap[? _tag] != undefined){Pollen.Error($"Attempting to create pollen part system, but system tag: '{_tag}' already exists!");}
        Pollen.__systemMap[? _tag] = self; 
        
        
        //--- SETUP PROPERTIES ---//
        __tag = _tag;
        __gmlData = _gml_system ?? part_system_create();
        __enabled = true;
        __template = undefined;
        __position = {x: 0, y: 0}
        __globalSpace = false;
        __drawOrder = true;
        __angle = 0;
        __depth = 0;
        __layer = undefined;
        __color = c_white;
        __alpha = 1;
        __emitterList = [];
        __isStreaming = false;
        __streamNumber = undefined;
        
        
        //--- SETTERS ---//
        ///@method SetEnabled(enabled)
        ///@desc   Enables/disables all the system's emitters
        ///@param  {bool} enabled True to enable, false to disable
        ///@return {self}
        static SetEnabled = function(_enabled){
            Pollen.__AssertBool(_enabled, "SetEnabled", "_enabled");
            __enabled = _enabled;
            var _numEmitters = array_length(__emitterList);
            var _i = -1;
            repeat(_numEmitters){
                _i++;
                var _emitter = __emitterList[_i];
                _emitter.SetEnabled(_enabled);
            }
            return self;
        }
        
        
        ///@method  SetTemplate(template, [copy_on_set])
        ///@desc    Sets the template that the system will default to
        ///@param   {string|Pollen.System|undefined} template The tag or Pollen.Instance to set the template as, or set as 'undefined' clear the template
        ///@return  {self}
        static SetTemplate = function(_template, _copy_on_set = false){
            __template = _template;
            if(_copy_on_set && _template != undefined){Copy(_template);}
            return self;
        }

        ///@method SetEmitterList(list)
        ///@desc   Replaces the system's emitter list with the provided array; destroys existing emitters first
        ///@param  {array} list The new list of Pollen.Emitter instances
        ///@return {self}
        static SetEmitterList = function(_list){
            if(!is_array(_list)){Pollen.Error($"Attempting to set emitterList of system: {__tag} but {_list} is not a valid array!");}
            Pollen.EmitterListDestroyAll(self);
            __emitterList = _list; 
            return self;
        }

        ///@method SetColor(color)
        ///@desc   Sets a color multiplier applied to all particles rendered by this system
        ///@param  {color} color The color (e.g., c_white)
        ///@return {self}
        static SetColor = function(_color){
            if(!is_real(_color) && !is_int64(_color)){Pollen.Error($"Attempting to set color of system: {__tag} but {_color} is not a valid color!");}
            __color = _color; 
            part_system_color(__gmlData, _color, __alpha); 
            RefreshStream();
            return self;
        }

        ///@method SetAlpha(alpha)
        ///@desc   Sets the alpha multiplier applied to all particles rendered by this system
        ///@param  {real} alpha The alpha value (0..1)
        ///@return {self}
        static SetAlpha = function(_alpha){
            if(!is_real(_alpha)){Pollen.Error($"Attempting to set alpha of system: {__tag} but {_alpha} is not a valid color!");}
            __alpha = _alpha; 
            part_system_color(__gmlData, __color, _alpha); 
            RefreshStream();
            return self;
        }

        ///@method SetPosition([x], [y])
        ///@desc   Sets the system's origin position
        ///@param  {real|undefined} [x] X position (or undefined to keep current)
        ///@param  {real|undefined} [y] Y position (or undefined to keep current)
        ///@return {self}
        static SetPosition = function(_x = undefined, _y = undefined){
            __position.x = _x ?? __position.x;
            __position.y = _y ?? __position.y;
            if(!is_real(__position.x)){Pollen.Error($"Attempting to set position of system: {__tag} but {__position.x} is not a valid number!");}
            if(!is_real(__position.y)){Pollen.Error($"Attempting to set position of system: {__tag} but {__position.y} is not a valid number!");}
            part_system_position(__gmlData, __position.x, __position.y);
            // RefreshStream(); //<---NOTE: This will cause a freeze since there is a recursive loop since Stream also calls the SetPosition() method
            return self;
        }

        ///@method SetGlobalSpace(enabled)
        ///@desc   Toggles whether particle positions maintain their global/room position or are set local/relative to the system's position
        ///@param  {bool} enabled True for global space, false for local
        ///@return {self}
        static SetGlobalSpace = function(_enabled){
            if(!is_bool(_enabled)){Pollen.Error($"Attempting to set globalSpace of system: {__tag} but {_enabled} is not a valid bool!");}
            __globalSpace = _enabled;
            part_system_global_space(__gmlData, _enabled);
            return self;
        }

        ///@method SetDrawOrder(enabled)
        ///@desc   Sets draw order to old-to-new (true) or new-to-old (false)
        ///@param  {bool} enabled Draw oldest first when true
        ///@return {self}
        static SetDrawOrder = function(_enabled){
            if(!is_bool(_enabled)){Pollen.Error($"Attempting to set drawOrder of system: {__tag} but {_enabled} is not a valid bool!");}
            __drawOrder = _enabled;
            part_system_draw_order(__gmlData, _enabled);
            return self;
        }

        ///@method SetAngle(angle)
        ///@desc   Sets a rotation applied to all particles during rendering
        ///@param  {real} angle Angle in degrees
        ///@return {self}
        static SetAngle = function(_angle){
            if(!is_real(_angle)){Pollen.Error($"Attempting to set angle of system: {__tag} but {_angle} is not a valid number!");}
            __angle = _angle;
            part_system_angle(__gmlData, _angle);
            // RefreshStream(); //<---NOTE: This is not needed for part_system_angle
            return self;
        }

        ///@method SetDepth(depth)
        ///@desc   Sets the draw depth for the system and clears any layer binding
        ///@param  {real|undefined} depth The new depth (smaller = in front)
        ///@return {self}
        static SetDepth = function(_depth){
            if(_depth == undefined){return;}
            if(!is_real(_depth)){Pollen.Error($"Attempting to set depth of system: {__tag} but {_depth} is not a valid number!");}
            __depth = _depth; 
            __layer = undefined;
            part_system_depth(__gmlData, _depth); 
            RefreshStream(); 
            return self;
        }

        ///@method SetLayer(layer)
        ///@desc   Binds the system to a room layer (overrides depth)
        ///@param  {string|real|undefined} layer The room layer name or ID
        ///@return {self}
        static SetLayer = function(_layer){
            if(_layer == undefined){__layer = _layer; return;}
            var _id = _layer;
            if(is_string(_layer)){_id = layer_get_id(_layer);}
            if(_id == -1){Pollen.Error($"Attempting to set layer of system: {__tag} but layer: '{_layer}' does not exist in current room!");}
            __layer = _layer;
            __depth = layer_get_depth(_id);
            part_system_layer(__gmlData, _id);
            return self;
        }
        
        //--- GETTERS ---//

        ///@method GetTag()
        ///@desc   Returns the unique system tag
        ///@return {string}
        static GetTag = function(){return __tag;}

        ///@method GetGmlData()
        ///@desc   Returns the underlying GM particle system handle
        ///@return {Id.ParticleSystem}
        static GetGmlData = function(){return __gmlData;}
        
        ///@method GetGmlData()
        ///@desc   Returns the part system template the Pollen.System copies from
        ///@return {string|Id.ParticleSystem|undefined}
        static GetTemplate = function(){return __template;}

        ///@method GetDepth()
        ///@desc   Returns the system's draw depth (ignored when layer is set)
        ///@return {real}
        static GetDepth = function(){return __depth;}

        ///@method GetLayer()
        ///@desc   Returns the bound room layer name/ID, or undefined if unbound
        ///@return {string|real|undefined}
        static GetLayer = function(){return __layer;}

        ///@method GetPosition()
        ///@desc   Returns the system position as a struct {x, y}
        ///@return {struct}
        static GetPosition = function(){return __position;}

        ///@method GetGlobalSpace()
        ///@desc   Returns whether the system uses global space
        ///@return {bool}
        static GetGlobalSpace = function(){return __globalSpace;}

        ///@method GetDrawOrder()
        ///@desc   Returns whether oldest particles are drawn first
        ///@return {bool}
        static GetDrawOrder = function(){return __drawOrder;}

        ///@method GetAngle()
        ///@desc   Returns the render rotation angle in degrees
        ///@return {real}
        static GetAngle = function(){return __angle;}

        ///@method GetColor()
        ///@desc   Returns the color multiplier applied to particles
        ///@return {color}
        static GetColor = function(){return __color;}

        ///@method GetAlpha()
        ///@desc   Returns the alpha multiplier applied to particles
        ///@return {real}
        static GetAlpha = function(){return __alpha;}

        ///@method GetEmitterList()
        ///@desc   Returns the array of emitters owned by this system
        ///@return {array}
        static GetEmitterList = function(){return __emitterList;}
        
        //--- UTIL ---//

        ///@method RefreshStream()
        ///@desc   Rebuilds and restarts the system's streaming emitters if streaming is active
        ///@return {undefined}
        static RefreshStream = function(){
            if(!__isStreaming){return;}
            var _numEmitter = array_length(__emitterList);
            var _i = -1;
            repeat(_numEmitter){
                _i++;
                var _emitter = __emitterList[_i];
                var _emitterGml = _emitter.GetGmlData();
                part_emitter_clear(__gmlData, _emitterGml);
                
                //These have to be reset every refresh as well
                var _emitterDelay = _emitter.GetDelay();
                var _emitterInterval = _emitter.GetInterval();
                var _emitterRelative = _emitter.GetRelative();
                part_emitter_delay(__gmlData, _emitterGml, _emitterDelay.min, _emitterDelay.max, _emitterDelay.unit);
                part_emitter_interval(__gmlData, _emitterGml, _emitterInterval.min, _emitterInterval.max, _emitterInterval.unit);
                part_emitter_relative(__gmlData, _emitterGml, _emitterRelative);
            }
            Pollen.Stream(__tag);
        }

        ///@method Copy(pfx, [ignore_emitter_list])
        ///@desc   Copies configuration from another Pollen.System into this system
        ///@param  {Pollen.System} pfx The source system to copy from
        ///@param  {bool} [ignore_emitter_list] If true, skips copying the emitter list
        ///@return {undefined}
        static Copy = function(_pfx, _ignore_emitter_list = false) {
            SetPosition(_pfx.__position.x, _pfx.__position.y);
            SetGlobalSpace(_pfx.__globalSpace);
            SetDrawOrder(_pfx.__drawOrder);
            SetAngle(_pfx.__angle);
            SetDepth(_pfx.__depth);
            SetLayer(_pfx.__layer);
            SetColor(_pfx.__color);
            SetAlpha(_pfx.__alpha);
            
            if(!_ignore_emitter_list){
                var _emitterList = _pfx.__emitterList;
                var _numEmitters = array_length(_emitterList);
                var _copyList = [];
                var _iEm = -1;
                repeat(_numEmitters){
                    _iEm++;
                    var _emitter = _emitterList[_iEm];
                    var _newEm = new Pollen.Emitter(self)
                        .SetEnabled(_emitter.IsEnabled())
                        .SetWidth(_emitter.GetWidth())
                        .SetHeight(_emitter.GetHeight())
                        .SetNumber(_emitter.GetNumber())
                        .SetType(_emitter.GetType())
                        .SetShape(_emitter.GetShape())
                        .SetDistr(_emitter.GetDistr())
                        .SetRelative(_emitter.GetRelative())
                        .SetDelay(_emitter.GetDelay())
                        .SetInterval(_emitter.GetInterval())
                        .SetOffsetX(_emitter.GetOffsetX())
                        .SetOffsetY(_emitter.GetOffsetY());
                    array_push(_copyList, _newEm);
                }
                SetEmitterList(_copyList);
            }
        }
    }
    
    
    ///--- SYSTEM CONTROL ---//
    
    ///@func    SystemTagGetData(tag)
    ///@desc    Get the data associated with a Pollen.System tag (or undefined if data does not exist for the tag)
    ///@param   {string} tag The tag of the Pollen.System that you want to get the data for
    ///@return  {Pollen.System|undefined}
    static SystemTagGetData = function(_tag){return __systemMap[? _tag];}
    
    ///@func    EmitterListDestroyAll(system)
    ///@desc    Destroys all the emitters tied to a Pollen.System
    ///@param   {Pollen.System} system The system to clear the emitters from
    ///@returns {undefined}
    static EmitterListDestroyAll = function(_system){
        if(!is_instanceof(_system, System)){Error("Cannot destroy system that is not a valid Pollen.System struct!");}
        var _numEmitters = array_length(_system.__emitterList);
        var _i = -1;
        repeat(_numEmitters){
            _i++;
            var _emitter = _system.__emitterList[_i];
            Pollen.EmitterDestroy(_emitter);
        }
        delete _system.__emitterList;
        _system.__emitterList = [];
    }
    
    ///@func    SystemDestroy(system)
    ///@desc    Destroys a single Pollen.System instance and clears all of its data (including its underlying GM part_system data)
    ///@param   {Pollen.System} system The Pollen.System instance to destroy
    ///@returns {undefined}
    static SystemDestroy = function(_system){
        if(!is_instanceof(_system, System)){Error("Cannot destroy system that is not a valid Pollen.System struct!");}
        EmitterListDestroyAll(_system);
        part_system_destroy(_system.GetGmlData());
        var _tag = _system.GetTag();
        ds_map_delete(__systemMap, _tag);
        delete _system;
        Log($"Successfully destroyed Pollen system: {_tag}");
    }
    
    ///@func    SystemDestroyAll()
    ///@desc    Destroys all instances of Pollen.System and clears all of their data
    ///@returns {undefined}
    static SystemDestroyAll = function(){
        var _mapArray = ds_map_values_to_array(__systemMap);
        var _numSystems = array_length(_mapArray);
        var _i = -1;
        repeat(_numSystems){
            _i++;
            var _system = _mapArray[_i];
            SystemDestroy(_system);
        }
        ds_map_destroy(__systemMap); //<---Gamemaker does not automatically reallocate an empty map, therefore it's best to destroy the map and make a new one so there isn't a bunch of empty data floating around
        __systemMap = ds_map_create();
        __defaultSystem = new Pollen.System("__pollen_system_default");
    }
    
    ///@func    SystemClear(system)
    ///@desc    Clears the visual representation of a particle system without resetting it's underlying data similar to GM's 'part_particle_clear' function. NOTE: streaming particles will only be cleared for 1 frame and will resume streaming afterwards!
    ///@param   {Pollen.System} system The Pollen.System data that you want to reset
    ///@return  {undefined}
    static SystemClear = function(_system){
        if(!is_instanceof(_system, System)){Error("Cannot destroy system that is not a valid Pollen.System struct!");}
        part_particles_clear(_system.GetGmlData());
    }
    
    ///@func    SystemReset(system)
    ///@desc    Clears the visual representation of a particle system AND resets it's underlying data similar to GM's 'part_system_clear' function. NOTE: this will destroy all the system's emitters as well so any references to them will result in a crash!
    ///@param   {Pollen.System} system The Pollen.System data that you want to reset
    ///@return  {undefined}
    static SystemReset = function(_system){
        if(!is_instanceof(_system, System)){Error("Cannot destroy system that is not a valid Pollen.System struct!");}
        EmitterListDestroyAll(_system); //<---preemptively destroy emitters so Pollen data is set properly before calling part_system_clear
        part_system_clear(_system.GetGmlData());
        _system.Copy(__defaultSystem); //<---Set pollen data back to default to reflect gml data
    }
    

#endregion   
//======================================================================================================================
#region ~ CREATE PARTICLES ~
//======================================================================================================================
    
    /// @title      Create Particles
    /// @category   API
    /// @text       Use these methods to create particles in game.
    
    ///@func   Stream(system_or_tag, [x_offset], [y_offset], [amount])
    ///@desc   Starts continuous streaming from all enabled emitters in a system. If `amount` is provided, it overrides each emitter's particle count.
    ///@param  {Pollen.System|string} system_or_tag The Pollen system instance or its string tag
    ///@param  {real} [x_offset] An optional horizontal offset to apply to emission position (i.e. relative to particle system position)
    ///@param  {real} [y_offset] An optional vertical offset to apply to emission position (i.e. relative to particle system position)
    ///@param  {real|undefined} [amount] Optional particles-per-step override for all emitters
    ///@return {undefined}
    static Stream = function(_system_or_tag, _x_offset = 0, _y_offset = 0, _amount = undefined){
        
        var _isTag = is_string(_system_or_tag), _isSystem = is_struct(_system_or_tag) && is_instanceof(_system_or_tag, Pollen.System);
        if(!_isTag && !_isSystem){Error($"Could not recognize '{_system_or_tag}' as a valid Pollen system (Pollen.Pfx) or a string tag!"); return;}
            
        var _data = (_isTag) ? __systemMap[? _system_or_tag] : _system_or_tag;
        if(_data == undefined){Error($"Unable to find data for {_system_or_tag}. Check for spelling errors and make sure data has been imported properly!"); return;}
        var _gmlData = _data.GetGmlData();
        var _emitterList = _data.GetEmitterList();
        
        _data.__isStreaming = true;
        _data.__streamNumber = _amount;
        
        var _i = -1;
        var _numEmitters = array_length(_emitterList);
        repeat(_numEmitters){
            _i++;
            var _emitter = _emitterList[_i];
            if(!_emitter.IsEnabled()){continue;}
            var _emitterGml = _emitter.GetGmlData();
            
            var _number = _amount ?? _emitter.GetNumber();
            var _halfW = 0.5*_emitter.GetWidth(), _halfH = 0.5*_emitter.GetHeight();
            var _offsetX = _x_offset + _emitter.GetOffsetX(), _offsetY = _y_offset + _emitter.GetOffsetY();
            var _left = _offsetX - _halfW, _right = _offsetX + _halfW;
            var _top = _offsetY - _halfH, _bottom = _offsetY + _halfH;
            var _shape = _emitter.GetShape(), _distr = _emitter.GetDistr();
            
            var _type = _emitter.GetType();
            // Log($"{_type}");
            if(is_string(_type)){_type = TypeTagGetData(_type); _emitter.SetType(_type);}
            if(_type == undefined){continue;}
            var _typeGml = _type.GetGmlData();
            
            part_emitter_region(_gmlData, _emitterGml, _left, _right, _top, _bottom, _shape, _distr);
            part_emitter_stream(_gmlData, _emitterGml, _typeGml, _number);
        }
        
        return;
    }
    
    ///@func   Burst(system_or_tag, [x_offset], [y_offset], [amount])
    ///@desc   Emits a single burst from all enabled emitters in a system. If `amount` is provided, it overrides each emitter's particle count.
    ///@param  {Pollen.System|string} system_or_tag The Pollen system instance or its string tag
    ///@param  {real} [x_offset] An optional horizontal offset to apply to emission position (i.e. relative to particle system position. Defaults to 0)
    ///@param  {real} [y_offset] An optional vertical offset to apply to emission position (i.e. relative to particle system position. Defaults to 0)
    ///@param  {real|undefined} [amount] Optional particles-per-step override for all emitters (Defaults to undefined)
    ///@return {undefined}
    static Burst = function(_system_or_tag, _x_offset = 0, _y_offset = 0, _amount = undefined){
        
        var _isTag = is_string(_system_or_tag), _isSystem = is_struct(_system_or_tag);
        if(!_isTag && !_isSystem){Error($"Could not recognize '{_system_or_tag}' as a valid Pollen system (Pollen.Pfx) or a string tag!"); return;}
        
        var _data = (_isTag) ? __systemMap[? _system_or_tag] : _system_or_tag;
        if(_data == undefined){Error($"Unable to find data for {_system_or_tag}. Check for spelling errors and make sure data has been imported properly!"); return;}
        var _gmlData = _data.GetGmlData();
        var _emitterList = _data.GetEmitterList();
        
        var _i = -1;
        var _numEmitters = array_length(_emitterList);
        repeat(_numEmitters){
            _i++;
            var _emitter = _emitterList[_i];
            if(!_emitter.IsEnabled()){continue;}
            var _emitterGml = _emitter.GetGmlData();
            
            var _number = _amount ?? _emitter.GetNumber();
            var _halfW = 0.5*_emitter.GetWidth(), _halfH = 0.5*_emitter.GetHeight();
            var _offsetX = _x_offset + _emitter.GetOffsetX(), _offsetY = _y_offset + _emitter.GetOffsetY();
            var _left = _offsetX - _halfW, _right = _offsetX + _halfW;
            var _top = _offsetY - _halfH, _bottom = _offsetY + _halfH;
            var _shape = _emitter.GetShape(), _distr = _emitter.GetDistr();
            
            var _type = _emitter.GetType();
            if(is_string(_type)){_type = TypeTagGetData(_type); _emitter.SetType(_type);}
            if(_type == undefined){continue;}
            var _typeGml = _type.GetGmlData();
            
            part_emitter_region(_gmlData, _emitterGml, _left, _right, _top, _bottom, _shape, _distr);
            part_emitter_burst(_gmlData, _emitterGml, _typeGml, abs(_number)); //<---Take abs since in stream mode a number can be set to negative so always default to the positive of that value when bursting
        }
    }


#endregion   
//======================================================================================================================
#region ~ IMPORT ~
//======================================================================================================================
    
    /// @title      Import particles
    /// @category   API
    /// @text       Use these methods to import particle data into Pollen.
    
    ///@func    ImportPfx(data)
    ///@desc    Import data from a GML 'JSON' array (see info about setting up 'JSON' in the 'Config JSON' section of the manual)
    ///@param   {array} data The array to parse and import data from
    ///@return  {undefined}
    static ImportPfx = function(_data){
        if(!is_array(_data)){Error("Data must be an array of structs!");}
        var _i = -1;
        var _len = array_length(_data);
        repeat(_len){
            _i++;
            var _struct = _data[_i];
            if(!is_struct(_struct)){Error($"Import data at index {_i} is not a struct! Data must be an array of structs!");}
            if(struct_exists(_struct, "type")){
                var _tag = struct_get(_struct, "type");
                var _tagData = TypeTagGetData(_tag) ?? new Type(_tag);
                ImportType(_struct, _tagData);
                Log($"Type: '{_tag}' was reloaded.");
            }
            else if (struct_exists(_struct, "system")){
                var _tag = struct_get(_struct, "system");
                var _tagData = SystemTagGetData(_tag) ?? new System(_tag);
                if(!POLLEN_FALLBACK_TO_PRIOR_VALUES){
                    if(_tagData.GetTemplate() != undefined){_tagData.Copy(SystemTagGetData(_tagData.GetTemplate()));}
                    else {_tagData.Copy(__defaultSystem, true);}
                }
                var _template = struct_get(_struct, "template");
                var _oldTemplate = _tagData.GetTemplate()
                if(_template != undefined && _oldTemplate != _template){
                    var _ignoreEmitterList = struct_exists(_struct, "emitterList");
                    if(is_string(_template)){
                        var _templateID = SystemTagGetData(_template);
                        if(_templateID == undefined){Error($"Unable to find system: '{_template}' make sure system is defined before using it as a template!");}
                        _tagData.SetTemplate(_template);
                        _tagData.Copy(_templateID, _ignoreEmitterList);
                    }
                    else if(asset_get_type(_template) == asset_particlesystem){
                        var _templateData = ConvertGmlPartAssetToPollenStruct(_template, _tagData, _ignoreEmitterList);
                        _tagData.SetTemplate($"{_templateData.GetTag()}");
                        _tagData.Copy(_templateData);
                    }
                    else {Warn($"Could not recognize template: {_template} as either a valid GM part asset or a string tag. Bailing!");}
                } 
                
                var _sysNames = struct_get_names(_struct);
                var _numSysNames = array_length(_sysNames);
                var _iSys = -1;
                repeat(_numSysNames){
                    _iSys++;
                    var _name = _sysNames[_iSys];
                    switch(_name){
                        case "system": break; //<---Not needed since it's handled above
                        case "template": break; //<---Not needed since it's handled above
                        case "depth": var _depth = _struct.depth; _tagData.SetDepth(_depth); break;
                        case "layer": var _layer = _struct.layer; _tagData.SetLayer(_layer); break;
                        case "angle": var _angle = _struct.angle; _tagData.SetAngle(_angle); break;
                        case "position": var _position = _struct.position; _tagData.SetPosition(_position); break;
                        case "globalSpace": var _globalSpace = _struct.globalSpace; _tagData.SetGlobalSpace(_globalSpace); break;
                        case "drawOrder": var _drawOrder = _struct.drawOrder; _tagData.SetDrawOrder(_drawOrder); break;
                        case "color": var _color = _struct.color; _tagData.SetColor(_color); break;
                        case "alpha": var _alpha = _struct.alpha; _tagData.SetDepth(_alpha); break;
                        case "emitterList":
                            var _emitterList = _struct.emitterList;
                            var _numOldList = array_length(_tagData.GetEmitterList());
                            var _numNewList = array_length(_emitterList);
                            var _numDiff = _numNewList - _numOldList;
                            
                            //Get rid of dead emitters
                            if(POLLEN_FALLBACK_TO_PRIOR_VALUES){
                                if(_numDiff < 0){
                                    var _iOld = 0;
                                    repeat(abs(_numDiff)){
                                        _iOld++;
                                        var _deadEmit = _tagData.GetEmitterList()[_numOldList - _iOld];
                                        EmitterDestroy(_deadEmit);
                                        array_pop(_tagData.GetEmitterList());
                                    }
                                }
                            }
                            else {Pollen.EmitterListDestroyAll(_tagData);}
                            
                            var _iEmList = -1;
                            repeat(_numNewList){
                                _iEmList++;
                                var _props = _emitterList[_iEmList];
                                var _emitter;
                                
                                if(POLLEN_FALLBACK_TO_PRIOR_VALUES){
                                    if(_numOldList >= _iEmList + 1){_emitter = _tagData.GetEmitterList()[_iEmList];}
                                    else {_emitter = new Emitter(_tagData); array_push(_tagData.GetEmitterList(), _emitter);}
                                }
                                else {_emitter = new Emitter(_tagData); array_push(_tagData.GetEmitterList(), _emitter);}
                                
                                var _iEm = -1;
                                var _emNameList = struct_get_names(_props);
                                var _numEmNames = array_length(_emNameList);
                                repeat(_numEmNames){
                                    _iEm++;
                                    var _emName = _emNameList[_iEm];
                                    switch(_emName){
                                        case "type": 
                                        case "tag":
                                            var _type = _props.type; 
                                            if(is_struct(_type) && ! is_instanceof(_type, Pollen.Type)){
                                                var _tag = struct_get(_props.type, "tag") 
                                                var _type = struct_get(_props.type, "type"); 
                                                if(_tag != undefined && _type != undefined){Error("Can define 'tag' OR 'type' properties but not both when defining types inside of emitters!");}
                                                _tag ??= _type;
                                                if(_tag == undefined){Error("Type structs defined in emitterLists must have a 'type' or 'tag' property defined with a valid string!");}
                                                _type = TypeTagGetData(_tag) ?? new Type(_tag); 
                                                if(_type == undefined){Error($"Unable to get type data or create a new type for tag: '{_tag}'.");}
                                                ImportType(_props.type, _type);
                                            }
                                            if(_type == undefined){Error($"Unable to load data from 'type' property of emitter: {_iEm} in '{_emitter.GetSystem()}'.");}
                                            _emitter.SetType(_type); 
                                            break;
                                        case "enabled": var _enabled = _props.enabled; _emitter.SetEnabled(_enabled); break;
                                        case "width": var _width = _props.width; _emitter.SetWidth(_width); break;
                                        case "height": var _height = _props.height; _emitter.SetHeight(_height); break;
                                        case "relative": var _relative = _props.relative; _emitter.SetRelative(_relative); break; 
                                        case "number": var _number = _props.number; _emitter.SetNumber(_number); break;
                                        case "shape": var _shape = _props.shape; _emitter.SetShape(_shape); break;
                                        case "distr": var _distr = _props.distr; _emitter.SetDistr(_distr); break;
                                        case "delay": var _delay = _props.delay; _emitter.SetDelay(_delay); break;
                                        case "interval": var _interval = _props.interval; _emitter.SetInterval(_interval); break;
                                        case "offsetX": var _offsetX = _props.offsetX; _emitter.SetOffsetX(_offsetX); break;
                                        case "offsetY": var _offsetY = _props.offsetY; _emitter.SetOffsetY(_offsetY); break;
                                        default: Log($"Emitter property {_emName} is not supported!");
                                    }
                                }
                            }
                            _tagData.RefreshStream();
                            break;
                        
                        default: Log($"System property: {_name} is not supported!");
                    }
                }
                Log($"System: '{_tag}' was reloaded.");
            }
            else {
                static __expectedList = "type', 'system'";
                Error($"Struct at global.pollen_config_pfx[{_i}] could not be parsed. Struct should contain one of the following properties: {__expectedList}");
            }
        }
    }
    
    ///@func    ImportType(import_data, type_data)
    ///@desc    Copy data from a GML 'JSON' type struct into a Pollen.Type instance (see info about setting up 'JSON' in the 'Config JSON' section of the manual)
    ///@param   {struct} import_data The struct to parse and import data from
    ///@param   {Pollen.Type} type_data The Pollen.Type instance to copy the data to
    ///@return  {undefined}
    static ImportType = function(_import_data, _type_data){
        var _template = struct_get(_import_data, "template");
        if(_template != undefined){
            if(!is_string(_template)){
                Error($"Template defined for type '{_import_data.type}' must be a string!");
            }
            else {
                var _templateData = TypeTagGetData(_template);
                if(_templateData == undefined){
                    Error($"Unable to find template type '{_template}' while loading '{_import_data.type}'!");
                }
                else if(_templateData != _type_data){
                    _type_data.Copy(_templateData);
                }
            }
        }
        else if (_template == undefined && !POLLEN_FALLBACK_TO_PRIOR_VALUES){_type_data.Copy(__defaultType);}

        var _i = -1;
        var _nameList = struct_get_names(_import_data);
        var _numNames = array_length(_nameList);
        repeat(_numNames){
            _i++;
            var _name = _nameList[_i];
            switch(_name){

                case "type": break; //<---'type' is checked before ImportType function is called.

                case "template": break;
                
                case "shape": var _shape = _import_data.shape; _type_data.SetShape(_shape); break;
                
                case "sprite":
                    var _sprite = _import_data.sprite;
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
                    break;
                    
                case "size":
                    var _size = _import_data.size;
                    var _def = _type_data.GetSize();
                    if (_def == undefined) { _def = { min: 0, max: 0, incr: 0, wiggle: 0 }; }
                    var _min    = struct_get(_size, "min")    ?? _def.min;
                    var _max    = struct_get(_size, "max")    ?? _def.max;
                    var _incr   = struct_get(_size, "incr")   ?? _def.incr;
                    var _wiggle = struct_get(_size, "wiggle") ?? _def.wiggle;
                    _type_data.SetSize(_min, _max, _incr, _wiggle);
                    break;
                    
                case "sizeX":
                    var _sizeX = _import_data.sizeX;
                    var _defX = _type_data.GetSizeX();
                    if (_defX == undefined) { _defX = { min: 0, max: 0, incr: 0, wiggle: 0 }; }
                    var _minX    = struct_get(_sizeX, "min")    ?? _defX.min;
                    var _maxX    = struct_get(_sizeX, "max")    ?? _defX.max;
                    var _incrX   = struct_get(_sizeX, "incr")   ?? _defX.incr;
                    var _wiggleX = struct_get(_sizeX, "wiggle") ?? _defX.wiggle;
                    _type_data.SetSizeX(_minX, _maxX, _incrX, _wiggleX);
                    break;
                    
                case "sizeY":
                    var _sizeY = _import_data.sizeY;
                    var _defY = _type_data.GetSizeY();
                    if (_defY == undefined) { _defY = { min: 0, max: 0, incr: 0, wiggle: 0 }; }
                    var _minY    = struct_get(_sizeY, "min")    ?? _defY.min;
                    var _maxY    = struct_get(_sizeY, "max")    ?? _defY.max;
                    var _incrY   = struct_get(_sizeY, "incr")   ?? _defY.incr;
                    var _wiggleY = struct_get(_sizeY, "wiggle") ?? _defY.wiggle;
                    _type_data.SetSizeY(_minY, _maxY, _incrY, _wiggleY);
                    break;
                    
                case "scale":
                    var _scale = _import_data.scale;
                    var _defScale = _type_data.GetScale();
                    var _sx = struct_get(_scale, "x") ?? _defScale.x;
                    var _sy = struct_get(_scale, "y") ?? _defScale.y;
                    _type_data.SetScale(_sx, _sy);
                    break;
                    
                case "speed":
                    var _speed = _import_data.speed;
                    var _defSpeed = _type_data.GetSpeed();
                    var _smin    = struct_get(_speed, "min")    ?? _defSpeed.min;
                    var _smax    = struct_get(_speed, "max")    ?? _defSpeed.max;
                    var _sincr   = struct_get(_speed, "incr")   ?? _defSpeed.incr;
                    var _swiggle = struct_get(_speed, "wiggle") ?? _defSpeed.wiggle;
                    _type_data.SetSpeed(_smin, _smax, _sincr, _swiggle);
                    break;
                    
                case "direction":
                    var _direction = _import_data.direction;
                    var _defDir = _type_data.GetDirection();
                    var _dmin    = struct_get(_direction, "min")    ?? _defDir.min;
                    var _dmax    = struct_get(_direction, "max")    ?? _defDir.max;
                    var _dincr   = struct_get(_direction, "incr")   ?? _defDir.incr;
                    var _dwiggle = struct_get(_direction, "wiggle") ?? _defDir.wiggle;
                    _type_data.SetDirection(_dmin, _dmax, _dincr, _dwiggle);
                    break;
                    
                case "orientation":
                    var _orientation = _import_data.orientation;
                    var _defOri = _type_data.GetOrientation();
                    var _omin  = struct_get(_orientation, "min")      ?? _defOri.min;
                    var _omax  = struct_get(_orientation, "max")      ?? _defOri.max;
                    var _oinc  = struct_get(_orientation, "incr")     ?? _defOri.incr;
                    var _owig  = struct_get(_orientation, "wiggle")   ?? _defOri.wiggle;
                    var _orel  = struct_get(_orientation, "relative") ?? _defOri.relative;
                    _type_data.SetOrientation(_omin, _omax, _oinc, _owig, _orel);
                    break;
                    
                case "gravity":
                    var _gravity = _import_data.gravity;
                    var _defGrav = _type_data.GetGravity();
                    var _gamt = struct_get(_gravity, "amount")    ?? _defGrav.amount;
                    var _gdir = struct_get(_gravity, "direction") ?? _defGrav.direction;
                    _type_data.SetGravity(_gamt, _gdir);
                    break;
                    
                case "colorMix": var _colorMix = _import_data.colorMix; _type_data.SetColorMix(_colorMix); break;
                    
                case "colorRgb":
                    var _colorRgb = _import_data.colorRgb;
                    var _rmin = struct_get(_colorRgb, "rmin");
                    var _rmax = struct_get(_colorRgb, "rmax");
                    _rmin ??= _rmax; _rmax ??= _rmin; //<---if only one of the values exist, the other value defaults to that
                    if(_rmin == undefined && _rmax == undefined){Error("colorRgb needs at least one of the two values 'rmin' or 'rmax' defined.");}
                    
                    var _gmin = struct_get(_colorRgb, "gmin");
                    var _gmax = struct_get(_colorRgb, "gmax");
                    _gmin ??= _gmax; _gmax ??= _gmin;
                    if(_gmin == undefined && _gmax == undefined){Error("colorRgb needs at least one of the two values 'gmin' or 'gmax' defined.");}
                    
                    var _bmin = struct_get(_colorRgb, "bmin");
                    var _bmax = struct_get(_colorRgb, "bmax");
                    _bmin ??= _bmax; _bmax ??= _bmin;
                    if(_bmin == undefined && _bmax == undefined){Error("colorRgb needs at least one of the two values 'bmin' or 'bmax' defined.");}
                    
                    _type_data.SetColorRgb(_rmin, _rmax, _gmin, _gmax, _bmin, _bmax);
                    break;
                    
                case "colorHsv":
                    var _colorHsv = _import_data.colorHsv;
                    var _hmin = struct_get(_colorHsv, "hmin");
                    var _hmax = struct_get(_colorHsv, "hmax");
                    _hmin ??= _hmax; _hmax ??= _hmin; //<---if only one of the values exist, the other value defaults to that
                    if(_hmin == undefined && _hmax == undefined){Error("colorHsv needs at least one of the two values 'hmin' or 'hmax' defined.");}
                    
                    var _smin = struct_get(_colorHsv, "smin");
                    var _smax = struct_get(_colorHsv, "smax");
                    _smin ??= _smax; _smax ??= _smin;
                    if(_smin == undefined && _smax == undefined){Error("colorHsv needs at least one of the two values 'smin' or 'smax' defined.");}
                    
                    var _vmin = struct_get(_colorHsv, "vmin");
                    var _vmax = struct_get(_colorHsv, "vmax");
                    _vmin ??= _vmax; _vmax ??= _vmin;
                    if(_vmin == undefined && _vmax == undefined){Error("colorHsv needs at least one of the two values 'vmin' or 'vmax' defined.");}
                    
                    _type_data.SetColorHsv(_hmin, _hmax, _smin, _smax, _vmin, _vmax);
                    break;
                    
                case "color": var _color = _import_data.color; _type_data.SetColor(_color); break;
                    
                case "alpha": var _alpha = _import_data.alpha; _type_data.SetAlpha(_alpha); break;
                    
                case "blend": var _blend = _import_data.blend; _type_data.SetBlend(_blend); break;
                    
                case "life":
                    var _life = _import_data.life;
                    var _defLife = _type_data.GetLife();
                    var _min = struct_get(_life, "min") ?? _defLife.min;
                    var _max = struct_get(_life, "max") ?? _defLife.max;
                    _type_data.SetLife(_min, _max);
                    break;
                    
                case "step":
                    var _step = _import_data.step;
                    var _defStep = _type_data.GetStep();
                    var _number = struct_get(_step, "number") ?? _defStep.number;
                    var _type = struct_get(_step, "type") ?? _defStep.type;
                    _type_data.SetStep(_number, _type);
                    break;
                    
                case "death":
                    var _death = _import_data.death;
                    var _defDeath = _type_data.GetDeath();
                    var _number = struct_get(_death, "number") ?? _defDeath.number;
                    var _type = struct_get(_death, "type") ?? _defDeath.type;
                    _type_data.SetDeath(_number, _type);
                    break;
                    
                default: Log($"Part type property: {_name} is not supported!");
            }
        }
        
        //Initialize or init debug after import so Pollen data is up to date
        if(POLLEN_ENABLE_DEBUG){Pollen.DebugInit();}
    }
    
    ///@func    ConvertGmlPartAssetToPollenStruct(asset, pollen_system, [ignore_emitter_list])
    ///@desc    Copy data from a GML part system *asset* (created using GM's particle editor) into a Pollen.System instance
    ///@return  {Pollen.System}
    static ConvertGmlPartAssetToPollenStruct = function(_asset){
        
        if(asset_get_type(_asset) != asset_particlesystem){Error("Failed to convert asset to pollen struct due to asset not being a valid GM particle system asset!");}
        if(Pollen.SystemTagGetData($"{_asset}") != undefined){return SystemTagGetData($"{_asset}");}
        
        //--- SYSTEM ---//
        var _data = particle_get_info(_asset);
        var _originX = struct_get(_data, "xorigin") ?? 0;
        var _originY = struct_get(_data, "yorigin") ?? 0;
        var _globalSpace = struct_get(_data, "global_space") ?? false;
        var _drawOrder = struct_get(_data, "oldtonew") ?? false;
        var _gmEmitters = struct_get(_data, "emitters") ?? [];
        
        var _pollenSystem = new Pollen.System($"{_asset}");
        
        _pollenSystem
            .SetPosition(_originX, _originY)
            .SetGlobalSpace(_globalSpace)
            .SetDrawOrder(_drawOrder);
        if(POLLEN_ENABLE_DEBUG){Pollen.DebugInit();}
        //--- EMITTERS ---//
        var _typeList = [];
        var _emitterList = [];
        var _numEmitters = array_length(_gmEmitters);
        var _iEmitter = -1;
        repeat(_numEmitters){
            _iEmitter++;
            var _emitter = _gmEmitters[_iEmitter];
            var _partType = struct_get(_emitter, "parttype");
            if(_partType != undefined){array_push(_typeList, _partType);}
            
            var _enabled = struct_get(_emitter, "enabled") ?? true;
            var _shape = struct_get(_emitter, "shape") ?? ps_shape_ellipse;
            var _distr = struct_get(_emitter, "distribution") ?? ps_distr_linear;
            var _relative = struct_get(_emitter, "relative") ?? false;
            var _number = struct_get(_emitter, "number") ?? 1;
            
            var _xMin = struct_get(_emitter, "xmin") ?? 0, _xMax = struct_get(_emitter, "xmax") ?? 0;
            var _yMin = struct_get(_emitter, "ymin") ?? 0, _yMax = struct_get(_emitter, "ymax") ?? 0;
            var _width = _xMax - _xMin;
            var _height = _yMax - _yMin;
            var _offsetX = _xMin + 0.5*_width;
            var _offsetY = _yMin + 0.5*_height;
            
            var _delayMin = struct_get(_emitter, "delay_min") ?? 0;
            var _delayMax = struct_get(_emitter, "delay_max") ?? 0;
            var _delayUnit = struct_get(_emitter, "delay_unit") ?? time_source_units_frames;
            var _intervalMin = struct_get(_emitter, "interval_min") ?? 0;
            var _intervalMax = struct_get(_emitter, "interval_max") ?? 0;
            var _intervalUnit = struct_get(_emitter, "interval_unit") ?? time_source_units_frames;
    
            var _pEmitter = new Emitter(_pollenSystem);
            _pEmitter
                .SetEnabled(_enabled)
                .SetShape(_shape)
                .SetDistr(_distr)
                .SetRelative(_relative)
                .SetNumber(_number)
                .SetSize(_width, _height)
                .SetOffset(_offsetX, _offsetY)
                .SetDelay({min: _delayMin, max: _delayMax, unit: _delayUnit})
                .SetInterval({min: _intervalMin, max: _intervalMax, unit: _intervalUnit});
                
            array_push(_emitterList, _pEmitter);
        }
        
        _pollenSystem.SetEmitterList(_emitterList);
        
        //--- TYPES ---//
        var _numTypes = array_length(_typeList);
        var _iType = -1;
        repeat(_numTypes){
            _iType++;
            var _type = _typeList[_iType];
            var _tag = $"{_pollenSystem.GetTag()}_type_{_iType}";
            
            var _shape = struct_get(_type, "shape");
            var _sprite = struct_get(_type, "sprite");
            var _frame = struct_get(_type, "frame") ?? 0;
            var _animate = struct_get(_type, "animate") ?? false;
            var _stretch = struct_get(_type, "stretch") ?? false;
            var _randomImg = struct_get(_type, "random") ?? false;
        
            // Size
            var _sizeXMin = struct_get(_type, "size_xmin") ?? 0
            var _sizeXMax = struct_get(_type, "size_xmax") ?? 0
            var _sizeXIncr = struct_get(_type, "size_xincr") ?? 0
            var _sizeXWiggle = struct_get(_type, "size_xwiggle") ?? 0 
        
            var _sizeYMin = struct_get(_type, "size_ymin") ?? 0
            var _sizeYMax = struct_get(_type, "size_ymax") ?? 0
            var _sizeYIncr = struct_get(_type, "size_yincr") ?? 0
            var _sizeYWiggle = struct_get(_type, "size_ywiggle") ?? 0 
        
            // Scale
            var _scaleX = struct_get(_type, "xscale") ?? 1;
            var _scaleY = struct_get(_type, "yscale") ?? 1;
        
            // Speed
            var _spdMin = struct_get(_type, "speed_min") ?? 1;
            var _spdMax = struct_get(_type, "speed_max") ?? 1;
            var _spdIncr = struct_get(_type, "speed_incr") ?? 0;
            var _spdWiggle = struct_get(_type, "speed_wiggle") ?? 0;
        
            // Direction
            var _dirMin = struct_get(_type, "dir_min") ?? 0;
            var _dirMax = struct_get(_type, "dir_max") ?? 0;
            var _dirIncr = struct_get(_type, "dir_incr") ?? 0;
            var _dirWiggle = struct_get(_type, "dir_wiggle") ?? 0;
        
            // Gravity
            var _gravAmt = struct_get(_type, "grav_amount") ?? 0;
            var _gravDir = struct_get(_type, "grav_dir") ?? 270;
        
            // Orientation
            var _angMin = struct_get(_type, "ang_min") ?? 0;
            var _angMax = struct_get(_type, "ang_max") ?? 0;
            var _angIncr = struct_get(_type, "ang_incr") ?? 0;
            var _angWiggle = struct_get(_type, "ang_wiggle") ?? 0;
            var _angRel = struct_get(_type, "ang_relative") ?? false;
        
            // Color (standard 1/2/3), Mix, RGB, HSV
            var _color1 = struct_get(_type, "color1") ?? c_white;
            var _color2 = struct_get(_type, "color2");
            var _color3 = struct_get(_type, "color3");
            var _colArr = [_color1];
            
            if(_color2 != undefined){array_push(_colArr, _color2);}
            if(_color3 != undefined){array_push(_colArr, _color3);}
        
            // Alpha (1/2/3)
            var _alpha1   = struct_get(_type, "alpha1") ?? 1;
            var _alpha2   = struct_get(_type, "alpha2");
            var _alpha3   = struct_get(_type, "alpha3");
            var _alphaArr = [_alpha1];
            
            if(_alpha2 != undefined){array_push(_alphaArr, _alpha2);}
            if(_alpha3 != undefined){array_push(_alphaArr, _alpha3);}
        
            // Blend
            var _additive = struct_get(_type, "additive") ?? false;
        
            // Life
            var _lifeMin = struct_get(_type, "life_min") ?? 100;
            var _lifeMax = struct_get(_type, "life_max") ?? 100;
        
            // Sub-particle Step/Death
            var _stepNum = struct_get(_type, "step_number") ?? 0;
            var _stepType = struct_get(_type, "step_type");
            var _deathNum = struct_get(_type, "death_number") ?? 0;
            var _deathType = struct_get(_type, "death_type");
        
            // Create Pollen type and apply all properties
            var _pType = new Type(_tag);
        
            // Shape / Sprite
            if (_shape != undefined && _shape != -1){_pType.SetShape(_shape);}
            if (_sprite != -1){_pType.SetSprite(_sprite, _frame, _animate, _stretch, _randomImg);}
        
            // Size (uniform), SizeX, SizeY (apply specific axes only if any field exists)
            if(_sizeXMin == _sizeYMin && _sizeXMax == _sizeYMax && _sizeXIncr == _sizeYIncr && _sizeXWiggle == _sizeYWiggle){
                _pType.SetSize(_sizeXMin, _sizeXMax, _sizeXIncr, _sizeXWiggle);   
            }
            else {
                _pType.SetSizeX(_sizeXMin, _sizeXMax, _sizeXIncr, _sizeXWiggle); 
                _pType.SetSizeY(_sizeYMin, _sizeYMax, _sizeYIncr, _sizeYWiggle); 
            }
        
            // Scale
            _pType.SetScale(_scaleX, _scaleY);
        
            // Kinematics
            _pType
                .SetSpeed(_spdMin, _spdMax, _spdIncr, _spdWiggle)
                .SetDirection(_dirMin, _dirMax, _dirIncr, _dirWiggle)
                .SetGravity(_gravAmt, _gravDir)
                .SetOrientation(_angMin, _angMax, _angIncr, _angWiggle, _angRel);
        
            // Color
            _pType
                .SetColor(_colArr)
                .SetAlpha(_alphaArr)
                .SetBlend(_additive);
        
            // Life
            _pType.SetLife(_lifeMin, _lifeMax);
        
            // Sub-particle generation
            if (_stepType != -1 && _stepNum != 0){_pType.SetStep(_stepNum, _stepType);}
            if (_deathType != -1 && _deathNum != 0){_pType.SetDeath(_deathNum, _deathType);}
            
            _emitterList[_iType].SetType(_pType);
        }
        
        Log($"Successfully converted Gml part asset: {_pollenSystem.GetTag()}!");
        return _pollenSystem;
    }
    

#endregion    
//======================================================================================================================
#region ~ UTIL ~
//======================================================================================================================
    
    /// @title      Util
    /// @category   API
    /// @text       Additional util methods.
    
    ///@func    DestroyAll()
    ///@desc    Destroys all Pollen Types, Emitters, & Systems and clears all their data.
    ///@return  {undefined}
    static DestroyAll = function(){
        TypeDestroyAll(); 
        SystemDestroyAll();
        __defaultType = new Pollen.Type("__pollen_type_default");
        __defaultSystem = new Pollen.System("__pollen_system_default");
    }
    
    //No need for JSDOC functions since these are generallty not meant to be called by users
    
    static Log = function(_message){if(POLLEN_LOG_LEVEL < 2){return;} show_debug_message("Pollen -> " + _message);}
    static Warn = function(_message){if(POLLEN_LOG_LEVEL < 1){return;} show_debug_message("Pollen -> Warning! " + _message);}
    static Error = function(_message){show_error("Pollen -> Error! " + _message, true);}

    static __AssertBool = function(_value, _method, _arg){
        if(!is_bool(_value)){
            Pollen.Error($"PfxType.{_method}() expects argument '{_arg}' to be a bool but received {typeof(_value)}!");
        }
    };
    static __AssertReal = function(_value, _method, _arg){
        if(!is_real(_value) && !is_int64(_value)){
            Pollen.Error($"PfxType.{_method}() expects argument '{_arg}' to be a real number but received {typeof(_value)}!");
        }
    };
    static __AssertArray = function(_value, _method, _arg){
        if(!is_array(_value)){
            Pollen.Error($"PfxType.{_method}() expects argument '{_arg}' to be an array but received {typeof(_value)}!");
        }
    };
    static __AssertArrayOfReals = function(_value, _method, _arg){
        __AssertArray(_value, _method, _arg);
        var _length = array_length(_value);
        var _i = -1;
        repeat(_length){
            _i++;
            if(!is_real(_value[_i]) && !is_int64(_value[_i])){
                Pollen.Error($"PfxType.{_method}() expects all entries of '{_arg}' to be real numbers but received {typeof(_value[_i])} at index {_i}!");
            }
        }
    };
    static __AssertRangeStruct = function(_value, _method, _arg){
        if(!is_struct(_value)){
            Pollen.Error($"PfxEmitter.{_method}() expects argument '{_arg}' to be a struct but received {typeof(_value)}!");
        }
        if(!struct_exists(_value, "min") || !is_real(_value.min)){
            Pollen.Error($"PfxEmitter.{_method}() expects '{_arg}.min' to be a real number!");
        }
        if(!struct_exists(_value, "max") || !is_real(_value.max)){
            Pollen.Error($"PfxEmitter.{_method}() expects '{_arg}.max' to be a real number!");
        }
        if(!struct_exists(_value, "unit") || !is_real(_value.unit)){
            Pollen.Error($"PfxEmitter.{_method}() expects '{_arg}.unit' to be a real number!");
        }
    }
    
 
#endregion    
//======================================================================================================================
#region ~ DEBUG ~
//======================================================================================================================
  
    /// @title      Debug
    /// @category   API
    /// @text       Setup debug tools.
    
    static __dbgData = {
        view: undefined,
        selectedSystem: undefined,
        showGmlData: false,
        systemDataString: "",
    }
    
    static DebugInit = function(){
        
        //View
        dbg_view_delete(__dbgData.view);
        __dbgData.view = dbg_view("Pollen", true);
        
        dbg_section("Options");
        
        //System selector
        __dbgData.selectedSystem ??= "__pollen_system_default";
        var _systemTagList = ds_map_keys_to_array(__systemMap);
        array_sort(_systemTagList, true);
        var _selectorRef = ref_create(__dbgData, "selectedSystem");
        dbg_drop_down(_selectorRef, _systemTagList, "System:");
        
        //Show Gml Toggle
        var _toggleRef = ref_create(__dbgData, "showGmlData");
        dbg_checkbox(_toggleRef, "Show Gml Data:");
        
        dbg_section("Data");
        
        //Show data (can expand this later to allow more useful debug tools)
        DebugUpdateDisplayData();
        var _dataRef = ref_create(__dbgData, "systemDataString");
        dbg_text(_dataRef);
    }
  
    static DebugUpdateDisplayData = function(){
        var _data = SystemTagGetData(__dbgData.selectedSystem);
        var _names = struct_get_names(_data);
        var _numNames = array_length(_names);
        var _iName = -1;
        repeat(_numNames){
            _iName++;
            var _name = _names[_iName];
            var _value = struct_get(_data, _name);
            _name = string_delete(_name, 1, 2); //<---Remove '__' prefix from struct members
            var _string = $"{_name}: {_value}\n";
            __dbgData.systemDataString += _string;
        }
    }
    
#endregion    
//======================================================================================================================
#region ~ SETUP ~
//======================================================================================================================

    static __defaultType = new Type("__pollen_type_default");
    static __defaultSystem = new System("__pollen_system_default");
    static __defaultEmitter = new Emitter(__defaultSystem);

} //<---DON'T DELETE THIS!!!

//We only need the static vars in Pollen so we instantiate Pollen to set them up, then delete the actual instance since we don't need it.
var _initPollen = new Pollen(); 
delete _initPollen;
if(POLLEN_AUTO_IMPORT_CONFIG_PFX){Pollen.ImportPfx(global.pollen_config_pfx);} //<---Do not rename any files or this might not work since it requires the other scripts to be initialized first!!!
Pollen.Log("Ready!");


//======================================================================================================================