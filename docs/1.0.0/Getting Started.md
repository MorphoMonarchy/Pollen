# Getting Started
This guide will take you through installing and using Pollen for the first time, as well as some helpful optimization tips.

### Installation
1. Download the latest release [here](https://github.com/MorphoMonarchy/Pollen/tree/master).
2. Open GameMaker and find the menu: **Tools > Import Local Package**.
3. Browse for the Pollen.yymps file.
4. Click on the "Pollen" folder under "Package Resources" and then click "Add".
5. Can optionally click "Add All" button if you want the example project too.
6. Click "Import" and you should see the "Pollen" folder in your Asset Browser.

### Setup
1. Navigate to `scr_pollen_config_pfx` script.
2. Copy the following structs and paste them into the `global.pollen_confix_pfx` array

~~~
{type: "myType",},
{
   system: "mySystem",
   emitterList: [
      {type: "myType",}
   ]
}
~~~

3. Copy and paste the following code into a create event of an object or a global script: `Pollen.Stream("mySystem")`
4. Use examples commented in `scr_pollen_config_pfx` or read the "Config JSON" docs for info on how to configure your particle types/systems more.
5. Click "Run" or press f5 to compile and run your project.
6. If live-reload is enabled, you can see changes in real time by simply saving the `scr_pollen_config_pfx` script after making your changes.
7. Check logs often for warnings and/or errors especially if you aren't seeing live updates!
8. Profit.


## Optimization Tips

For the intents and purposes of most projects, you could probably get away with having all of your particle effects defined in the `global.pollen_config_pfx` array. However, if you notice major hitching when you initially run the game, or every time you live-reload `scr_pollen_config_pfx`, or when using Pollen's setter methods during runtime, then you may need to break your effects up into multiple groups and manually import/clean-up your effects as you need them. The following steps explain how you could do this:

1. Optionally set the `POLLEN_AUTO_IMPORT_CONFIG_PFX` & `POLLEN_LIVE_UPDATE` macros found in `scr_pollen_config_macros` to `false` (this disables Pollen from automatically importing `scr_pollen_config_pfx` so you can load your effects according to your needs)

<p class="tip">
    Live-update only works with scr_pollen_config_pfx by default. So disabling these macros means you have to manually import any effects defined in it by using `Pollen.ImportPfx(global.pollen_config_pfx)`.
</p>

2. Create multiple arrays that represent different particle effect "groups" and define the corresponding Pollen JSON in them. The following example demonstrates one way you could do this:

~~~
// Particle FX needed throughout the entire game
pfx_global = [
    {type: "type_global_smoke", /*etc..*/},
    {
        system: "system_global_smoke",
        emitterList: [
            {type: "type_global_smoke", /*etc..*/}
        ],
    },
    /*etc..*/
];
// Particle FX needed for specific levels
pfx_lv1 = [
    {type: "type_lv1_rain", /*etc..*/},
    {type: "type_lv1_cloud", /*etc..*/},
    {
        system: "system_lv1_storm",
        emitterList: [
            {type: "type_lv1_rain", /*etc..*/},
            {type: "type_lv1_cloud", /*etc..*/},
        ],
    },
    /*etc..*/
];
pfx_lv2 = [
   {
        system: "system_lv2_snow",
        emitterList: [
            {
                type: {tag: "type_lv2_snow", /*etc..*/}, 
                /*etc..*/
            },
        ]
   },
    /*etc..*/
];
// And so on...
~~~

3. Import the particle fx groups you need by calling `Pollen.Import()` and pass in the array you want to import like the following example:

~~~
Pollen.ImportPfx(pfx_global);
Pollen.ImportPfx(pfx_lv1);
~~~

4. When you're ready to load the next group of particles, you can optionally call `Pollen.DestroyAll()` to clear previous data and then use `Pollen.Import` on the groups you need like the following example:

~~~
Pollen.DestroyAll() //<--- optional only if you need to save on memory
Pollen.ImportPfx(pfx_global); //<--- Only import this again if you call Pollen.DestroyAll() beforehand
Pollen.ImportPfx(pfx_lv2);
~~~

<p class="warn">
    As stated in the "FAQ" section, Pollen takes a small amount of memory per instance (roughly 0.1 - 0.3 mb per type/emitter/system). So, for most particles, you could probably get away with leaving them in memory (i.e. not destroying them) even when they're not needed anymore.
</p>

5. If you need to micromanage things, you can also manually destroy particle types/emitters/systems by passing their data into the corresponding functions:

~~~
var _typeData = Pollen.TypeTagGetData("type_lv1_rain");
Pollen.TypeDestroy(_typeData);

var _systemData = Pollen.SystemTagGetData("system_lv1_storm");
var _emitterData = _systemData.GetEmitterList()[0];
Pollen.EmitterDestroy(_emitterData);
Pollen.SystemDestroy(_systemData);
~~~

<p class="warn">
    Calling Pollen.SystemDestroy() will automatically destroy all of the system's emitters
    so there's no need to manually destroy all of them beforehand, but the prior example demonstrates
    how to manually destroy one if needed.
</p>

6. Keep in mind that, though GameMaker's particle backend is pretty fast, having a million particles on screen will slow things down regardless of how you optimize everything else. Plus, when it comes to VFX design, less is often more anyway. 


