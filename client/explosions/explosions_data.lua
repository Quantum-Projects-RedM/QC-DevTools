--=========================================================
-- EXPLOSIONS DATA
--=========================================================
-- Based on https://github.com/femga/rdr3_discoveries/tree/master/graphics/explosions
-- Organized by categories for testing different explosion types
--=========================================================

ExplosionData = {}

-- Basic Explosions
ExplosionData.basic = {
    name = "Basic Explosions",
    icon = "💥",
    explosions = {
        { id = 0, tag = "EXP_TAG_GRENADE", name = "Grenade", description = "Standard grenade explosion" },
        { id = 12, tag = "EXP_TAG_BULLET", name = "Bullet Impact", description = "Bullet impact explosion" },
        { id = 25, tag = "EXP_TAG_DYNAMITE", name = "Dynamite", description = "Single dynamite stick explosion" },
        { id = 26, tag = "EXP_TAG_DYNAMITESTACK", name = "Dynamite Stack", description = "Multiple dynamite explosion" },
        { id = 29, tag = "EXP_TAG_PLACED_DYNAMITE", name = "Placed Dynamite", description = "Placed dynamite explosion" }
    }
}

-- Fire & Molotov
ExplosionData.fire = {
    name = "Fire & Incendiary",
    icon = "🔥",
    explosions = {
        { id = 2, tag = "EXP_TAG_MOLOTOV", name = "Molotov Cocktail", description = "Fire bottle explosion" },
        { id = 3, tag = "EXP_TAG_MOLOTOV_VOLATILE", name = "Volatile Molotov", description = "Enhanced fire bottle" },
        { id = 9, tag = "EXP_TAG_DIR_FLAME", name = "Directional Flame", description = "Directed flame explosion" },
        { id = 18, tag = "EXP_TAG_DIR_FLAME_EXPLODE", name = "Flame Explode", description = "Flame burst explosion" },
        { id = 30, tag = "EXP_TAG_FIRE_ARROW", name = "Fire Arrow", description = "Fire arrow explosion" },
        { id = 32, tag = "EXP_TAG_PHOSPHOROUS_BULLET", name = "Phosphorous Bullet", description = "Incendiary bullet impact" }
    }
}

-- Vehicle Explosions
ExplosionData.vehicles = {
    name = "Vehicle Explosions",
    icon = "🚗",
    explosions = {
        { id = 5, tag = "EXP_TAG_CAR", name = "Car Explosion", description = "Vehicle explosion" },
        { id = 6, tag = "EXP_TAG_PLANE", name = "Plane Explosion", description = "Aircraft explosion" },
        { id = 11, tag = "EXP_TAG_BOAT", name = "Boat Explosion", description = "Watercraft explosion" },
        { id = 17, tag = "EXP_TAG_TRAIN", name = "Train Explosion", description = "Railway explosion" },
        { id = 19, tag = "EXP_TAG_VEHICLE_BULLET", name = "Vehicle Bullet", description = "Vehicle-mounted weapon impact" }
    }
}

-- Arrow & Projectile
ExplosionData.projectiles = {
    name = "Arrow & Projectiles",
    icon = "🏹",
    explosions = {
        { id = 31, tag = "EXP_TAG_DYNAMITE_ARROW", name = "Dynamite Arrow", description = "Explosive arrow" },
        { id = 34, tag = "EXP_TAG_TRACKING_ARROW", name = "Tracking Arrow", description = "Tracking arrow explosion" },
        { id = 21, tag = "EXP_TAG_FIREWORK", name = "Firework", description = "Firework explosion" },
        { id = 22, tag = "EXP_TAG_TORPEDO", name = "Torpedo", description = "Underwater torpedo" },
        { id = 23, tag = "EXP_TAG_TORPEDO_UNDERWATER", name = "Underwater Torpedo", description = "Deep water torpedo" }
    }
}

-- Environmental
ExplosionData.environmental = {
    name = "Environmental",
    icon = "🌍",
    explosions = {
        { id = 7, tag = "EXP_TAG_PETROL_PUMP", name = "Petrol Pump", description = "Gas station explosion" },
        { id = 8, tag = "EXP_TAG_DIR_STEAM", name = "Steam Burst", description = "Directional steam explosion" },
        { id = 10, tag = "EXP_TAG_DIR_WATER_HYDRANT", name = "Water Hydrant", description = "Fire hydrant burst" },
        { id = 15, tag = "EXP_TAG_GAS_CANISTER", name = "Gas Canister", description = "Gas canister explosion" },
        { id = 24, tag = "EXP_TAG_LANTERN", name = "Lantern", description = "Lantern explosion" },
        { id = 28, tag = "EXP_TAG_RIVER_BLAST", name = "River Blast", description = "Underwater river explosion" }
    }
}

-- Special Effects
ExplosionData.special = {
    name = "Special Effects",
    icon = "⚡",
    explosions = {
        { id = 33, tag = "EXP_TAG_LIGHTNING_STRIKE", name = "Lightning Strike", description = "Electric lightning explosion" },
        { id = 20, tag = "EXP_TAG_BIRD_CRAP", name = "Bird Impact", description = "Bird collision explosion" },
        { id = 13, tag = "EXP_TAG_SMOKEGRENADE", name = "Smoke Grenade", description = "Smoke explosion" },
        { id = 14, tag = "EXP_TAG_BZGAS", name = "Gas Grenade", description = "Gas cloud explosion" },
        { id = 16, tag = "EXP_TAG_EXTINGUISHER", name = "Fire Extinguisher", description = "Extinguisher burst" }
    }
}

-- Test Explosions (Safe)
ExplosionData.test = {
    name = "Test Explosions (Safe)",
    icon = "🧪",
    explosions = {
        { id = 12, tag = "EXP_TAG_BULLET", name = "Bullet Impact (Safe)", description = "Small bullet impact" },
        { id = 21, tag = "EXP_TAG_FIREWORK", name = "Firework (Safe)", description = "Colorful firework" },
        { id = 13, tag = "EXP_TAG_SMOKEGRENADE", name = "Smoke (Safe)", description = "Smoke cloud only" },
        { id = 16, tag = "EXP_TAG_EXTINGUISHER", name = "Extinguisher (Safe)", description = "Fire extinguisher spray" },
        { id = 10, tag = "EXP_TAG_DIR_WATER_HYDRANT", name = "Water Burst (Safe)", description = "Water spray" }
    }
}