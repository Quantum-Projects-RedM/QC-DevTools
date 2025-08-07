--=========================================================
-- TIMECYCLE MODIFIERS DATA
--=========================================================
-- Based on https://github.com/femga/rdr3_discoveries/blob/master/graphics/timecycles/timecycles.lua
-- Organized by categories for easy browsing
--=========================================================

TimecycleData = {}

-- General & Base Effects
TimecycleData.general = {
    name = "General & Base Effects",
    icon = "🌍",
    timecycles = {
        "Base_modifier",
        "noDirectLight", 
        "NOrain",
        "noInteriorArtificialAmbient",
        "Prologue"
    }
}

-- Cave & Underground Effects
TimecycleData.caves = {
    name = "Cave & Underground",
    icon = "🕳️",
    timecycles = {
        "Bea_Cave",
        "bea_cave_entrance", 
        "bea_cave_artificial_ambient",
        "elysian_cave",
        "cave_artificial_ambient",
        "TunnelArtificialAmbient",
        "mp_camp_cave_artificialAmbient"
    }
}

-- Water & Underwater Effects
TimecycleData.water = {
    name = "Water & Underwater",
    icon = "🌊",
    timecycles = {
        "underwater",
        "underwaterDeep",
        "Water",
        "Boiling_water",
        "mp_saintdenismarket_boiling_pot",
        "swampLagras",
        "bayou_nwa_lagras",
        "lannahechee_river"
    }
}


-- Towns & Cities
TimecycleData.towns = {
    name = "Towns & Cities",
    icon = "🏘️",
    timecycles = {
        "townBlackwater",
        "townStrawberry",
        "townValentine", 
        "townSaintDenis",
        "townRhodes",
        "townVanhorn",
        "townArmadillo",
        "townTumbleweed",
        "townAnnesburg",
        "townLonniesShack",
        "townSwamp"
    }
}

-- Camp Locations
TimecycleData.camps = {
    name = "Camp Locations",
    icon = "🏕️",
    timecycles = {
        "campHorseShoe",
        "campLakay",
        "campClemens", 
        "campBeaverHollow",
        "campShadyBelle",
        "mp_camp_nighttime"
    }
}

-- Interior Effects
TimecycleData.interiors = {
    name = "Interior Effects",
    icon = "🏠",
    timecycles = {
        "interior",
        "saloon",
        "saloon_artificialAmbient",
        "GeneralStore",
        "gunsmith",
        "hotel",
        "Church",
        "Bank",
        "Barber",
        "doctor_interior"
    }
}


-- Natural Environments
TimecycleData.nature = {
    name = "Natural Environments",
    icon = "🌲",
    timecycles = {
        "mp_region_grizzlies",
        "mp_region_heartlands",
        "mp_region_bayou", 
        "mp_region_great_plains",
        "mp_region_new_austin",
        "mp_region_roanoke_ridge",
        "mp_region_big_valley",
        "forest_artificialAmbient",
        "plains_artificialAmbient"
    }
}

-- Time of Day Effects
TimecycleData.timeofday = {
    name = "Time of Day",
    icon = "🌅",
    timecycles = {
        "nighttime",
        "sunrise",
        "sunset",
        "midday",
        "dusk",
        "dawn",
        "golden_hour",
        "blue_hour",
        "midnight"
    }
}