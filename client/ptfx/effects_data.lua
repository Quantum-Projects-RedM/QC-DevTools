--=========================================================
-- PARTICLE EFFECTS (PTFX) DATA
--=========================================================
-- Based on https://github.com/femga/rdr3_discoveries/blob/master/graphics/ptfx/
-- Organized by categories - both looped and non-looped effects
--=========================================================

PTFXData = {}

-- Fire Effects (Looped) - Core Dictionary Only
PTFXData.fire_looped = {
    name = "Fire Effects (Looped)",
    icon = "🔥",
    type = "looped",
    effects = {
        { dict = "core", name = "ent_amb_campfire", label = "Campfire" },
        { dict = "core", name = "ent_amb_fire_flicker", label = "Fire Flicker" },
        { dict = "core", name = "ent_amb_lantern_flame", label = "Lantern Flame" },
        { dict = "core", name = "ent_amb_torch_flame", label = "Torch Flame" },
        { dict = "core", name = "ent_amb_candle_flame", label = "Candle Flame" },
        { dict = "core", name = "ent_amb_fire_small", label = "Small Fire" },
        { dict = "core", name = "ent_amb_fire_large", label = "Large Fire" }
    }
}

-- Smoke Effects (Looped) - Core Dictionary Only
PTFXData.smoke_looped = {
    name = "Smoke Effects (Looped)",
    icon = "💨",
    type = "looped", 
    effects = {
        { dict = "core", name = "ent_amb_smoke_chimney", label = "Chimney Smoke" },
        { dict = "core", name = "ent_amb_smoke_train", label = "Train Smoke" },
        { dict = "core", name = "ent_amb_smoke_cigarette", label = "Cigarette Smoke" },
        { dict = "core", name = "ent_amb_smoke_pipe", label = "Pipe Smoke" },
        { dict = "core", name = "ent_amb_steam", label = "Steam" },
        { dict = "core", name = "ent_amb_smoke_factory", label = "Factory Smoke" },
        { dict = "core", name = "ent_amb_smoke_campfire", label = "Campfire Smoke" },
        { dict = "core", name = "ent_amb_insect_fly_swarm", label = "Fly Swarm" },
        { dict = "core", name = "ent_amb_drips", label = "Water Drips" }
    }
}

-- Weather Effects (Looped) - Core Dictionary Only
PTFXData.weather_looped = {
    name = "Weather Effects (Looped)", 
    icon = "🌧️",
    type = "looped",
    effects = {
        { dict = "core", name = "ent_amb_snow_light", label = "Light Snow" },
        { dict = "core", name = "ent_amb_snow_heavy", label = "Heavy Snow" },
        { dict = "core", name = "ent_amb_rain_light", label = "Light Rain" },
        { dict = "core", name = "ent_amb_rain_heavy", label = "Heavy Rain" },
        { dict = "core", name = "ent_amb_fog", label = "Fog" },
        { dict = "core", name = "ent_amb_dust_devil", label = "Dust Devil" },
        { dict = "core", name = "ent_amb_wind_leaves", label = "Wind Leaves" },
        { dict = "core", name = "ent_amb_wind_dust", label = "Wind Dust" },
        { dict = "core", name = "ent_amb_waterfall_mist", label = "Waterfall Mist" }
    }
}

-- Blood Effects (Looped) - Core Dictionary Only
PTFXData.blood_looped = {
    name = "Blood Effects (Looped)",
    icon = "🩸", 
    type = "looped",
    effects = {
        { dict = "core", name = "ent_amb_blood_drip", label = "Blood Drip" },
        { dict = "core", name = "ent_amb_blood_pool", label = "Blood Pool" },
        { dict = "core", name = "ent_amb_blood_splat", label = "Blood Splat" },
        { dict = "core", name = "ent_amb_flies_blood", label = "Blood Flies" },
        { dict = "core", name = "ent_amb_blood_trail", label = "Blood Trail" },
        { dict = "core", name = "ent_amb_blood_mist", label = "Blood Mist" },
        { dict = "core", name = "ent_amb_blood_thick", label = "Thick Blood" }
    }
}

-- Explosions (Non-Looped) - Core Dictionary Only
PTFXData.explosions = {
    name = "Explosions (Non-Looped)",
    icon = "💥",
    type = "non_looped",
    effects = {
        { dict = "core", name = "ent_dst_dust_impact", label = "Dust Impact" },
        { dict = "core", name = "ent_anim_bullet_impact", label = "Bullet Impact" },
        { dict = "core", name = "ent_amb_sparks", label = "Sparks" }
    }
}

-- Dust & Debris (Non-Looped) - Core Dictionary Only
PTFXData.dust = {
    name = "Dust & Debris (Non-Looped)",
    icon = "🌪️", 
    type = "non_looped",
    effects = {
        { dict = "core", name = "ent_dst_dust", label = "Dust Cloud" },
        { dict = "core", name = "ent_dst_dirt_impact", label = "Dirt Impact" },
        { dict = "core", name = "ent_dst_rocks", label = "Rock Debris" },
        { dict = "core", name = "ent_dst_sand", label = "Sand Cloud" },
        { dict = "core", name = "ent_amb_dust_kick", label = "Dust Kick" },
        { dict = "core", name = "ent_amb_dirt_throw", label = "Dirt Throw" },
        { dict = "core", name = "ent_dst_wood_splinter", label = "Wood Splinters" }
    }
}

-- Water Effects (Non-Looped) - Core Dictionary Only
PTFXData.water = {
    name = "Water Effects (Non-Looped)",
    icon = "💧",
    type = "non_looped",
    effects = {
        { dict = "core", name = "ent_amb_water_splash", label = "Water Splash" },
        { dict = "core", name = "ent_amb_water_spray", label = "Water Spray" },
        { dict = "core", name = "ent_amb_fountain", label = "Fountain Spray" },
        { dict = "core", name = "ent_amb_water_drip", label = "Water Drip" },
        { dict = "core", name = "ent_amb_waterfall", label = "Waterfall" },
        { dict = "core", name = "ent_amb_river_foam", label = "River Foam" }
    }
}

-- Blood Splatter (Non-Looped) - Core Dictionary Only
PTFXData.blood_splatter = {
    name = "Blood Splatter (Non-Looped)", 
    icon = "🔴",
    type = "non_looped",
    effects = {
        { dict = "core", name = "ent_sht_blood", label = "Shot Blood" },
        { dict = "core", name = "ent_amb_blood_splat_large", label = "Large Blood Splat" },
        { dict = "core", name = "ent_amb_blood_hit", label = "Blood Hit" },
        { dict = "core", name = "ent_amb_blood_gush", label = "Blood Gush" },
        { dict = "core", name = "ent_amb_blood_spurt", label = "Blood Spurt" },
        { dict = "core", name = "ent_amb_blood_burst", label = "Blood Burst" }
    }
}

-- Test Effects (Mixed - Core Dictionary Only)
PTFXData.test = {
    name = "Test Effects (Safe)",
    icon = "🧪",
    type = "mixed",
    effects = {
        -- Safe looped effects
        { dict = "core", name = "ent_amb_campfire", label = "Campfire (Looped)", type = "looped" },
        { dict = "core", name = "ent_amb_smoke_cigarette", label = "Cigarette Smoke (Looped)", type = "looped" },
        { dict = "core", name = "ent_amb_steam", label = "Steam (Looped)", type = "looped" },
        { dict = "core", name = "ent_amb_drips", label = "Water Drips (Looped)", type = "looped" },
        -- Safe non-looped effects  
        { dict = "core", name = "ent_amb_sparks", label = "Sparks (Non-Looped)", type = "non_looped" },
        { dict = "core", name = "ent_amb_water_splash", label = "Water Splash (Non-Looped)", type = "non_looped" },
        { dict = "core", name = "ent_dst_dust", label = "Dust Cloud (Non-Looped)", type = "non_looped" },
        { dict = "core", name = "ent_dst_dirt_impact", label = "Dirt Impact (Non-Looped)", type = "non_looped" }
    }
}