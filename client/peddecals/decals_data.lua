--=========================================================
-- PED DECALS DATA
--=========================================================
-- Based on https://github.com/femga/rdr3_discoveries/blob/master/peds_customization/ped_decals.lua
-- Organized by categories for easy testing and application
--=========================================================

PedDecalsData = {}

-- Damage and Injury Decals
PedDecalsData.damage = {
    name = "Damage & Injuries",
    icon = "fa-solid fa-droplet",
    decals = {
        -- Known working test decal from GitHub example
        { name = "PD_Vomit", label = "Vomit (Test)" },
        
        -- Common damage decals (these names are more likely to exist)
        { name = "PD_Blood", label = "Blood" },
        { name = "PD_Bruise", label = "Bruise" },
        { name = "PD_Cut", label = "Cut" },
        { name = "PD_Dirt", label = "Dirt" },
        { name = "PD_Mud", label = "Mud" },
        { name = "PD_Sweat", label = "Sweat" },
        { name = "PD_Burn", label = "Burn" },
        { name = "PD_Scar", label = "Scar" },
        { name = "PD_Scratch", label = "Scratch" },
        { name = "PD_Wound", label = "Wound" },
        
        -- Try some variations
        { name = "PD_Blood_Face", label = "Blood Face" },
        { name = "PD_Blood_Body", label = "Blood Body" },
        { name = "PD_Damage_Light", label = "Light Damage" },
        { name = "PD_Damage_Heavy", label = "Heavy Damage" },
    }
}

-- Test Decals (Simple names to test functionality)
PedDecalsData.test = {
    name = "Test Decals",
    icon = "fa-solid fa-flask",
    decals = {
        -- Start with simple, common decal names
        { name = "PD_Vomit", label = "Vomit (Known Working)" },
        { name = "blood", label = "Blood (Simple)" },
        { name = "dirt", label = "Dirt (Simple)" },
        { name = "mud", label = "Mud (Simple)" },
        { name = "bruise", label = "Bruise (Simple)" },
        { name = "cut", label = "Cut (Simple)" },
        { name = "scar", label = "Scar (Simple)" },
        { name = "wound", label = "Wound (Simple)" },
    }
}

-- Scars and Healing
PedDecalsData.scars = {
    name = "Scars & Healing",
    icon = "fa-solid fa-band-aid",
    decals = {
        { name = "pd_scar_01", label = "Scar 1", bodyPart = "face" },
        { name = "pd_scar_02", label = "Scar 2", bodyPart = "torso" },
        { name = "pd_scar_03", label = "Scar 3", bodyPart = "arms" },
        { name = "pd_old_scar_01", label = "Old Scar 1", bodyPart = "face" },
        { name = "pd_old_scar_02", label = "Old Scar 2", bodyPart = "torso" },
        { name = "pd_healed_wound_01", label = "Healed Wound 1", bodyPart = "arms" },
        { name = "pd_healed_wound_02", label = "Healed Wound 2", bodyPart = "legs" },
        { name = "pd_surgical_scar_01", label = "Surgical Scar 1", bodyPart = "torso" },
        { name = "pd_surgical_scar_02", label = "Surgical Scar 2", bodyPart = "arms" },
        { name = "pd_burn_scar_01", label = "Burn Scar 1", bodyPart = "face" },
        { name = "pd_burn_scar_02", label = "Burn Scar 2", bodyPart = "arms" },
        { name = "pd_burn_scar_03", label = "Burn Scar 3", bodyPart = "torso" },
    }
}

-- Environmental Effects
PedDecalsData.environmental = {
    name = "Environmental Effects",
    icon = "fa-solid fa-mountain",
    decals = {
        { name = "pd_mud_01", label = "Mud Stain 1", bodyPart = "legs" },
        { name = "pd_mud_02", label = "Mud Stain 2", bodyPart = "torso" },
        { name = "pd_mud_03", label = "Mud Stain 3", bodyPart = "arms" },
        { name = "pd_dirt_01", label = "Dirt 1", bodyPart = "face" },
        { name = "pd_dirt_02", label = "Dirt 2", bodyPart = "hands" },
        { name = "pd_dirt_03", label = "Dirt 3", bodyPart = "torso" },
        { name = "pd_dust_01", label = "Dust 1", bodyPart = "face" },
        { name = "pd_dust_02", label = "Dust 2", bodyPart = "torso" },
        { name = "pd_water_stain_01", label = "Water Stain 1", bodyPart = "torso" },
        { name = "pd_water_stain_02", label = "Water Stain 2", bodyPart = "legs" },
        { name = "pd_sweat_01", label = "Sweat 1", bodyPart = "face" },
        { name = "pd_sweat_02", label = "Sweat 2", bodyPart = "torso" },
    }
}

-- Body Part Zones for targeting
PedDecalsData.bodyParts = {
    face = { label = "Face/Head", bone = "SKEL_Head" },
    torso = { label = "Torso/Chest", bone = "SKEL_Spine_Root" },
    arms = { label = "Arms", bone = "SKEL_L_UpperArm" },
    hands = { label = "Hands", bone = "SKEL_L_Hand" },
    legs = { label = "Legs", bone = "SKEL_L_Thigh" },
    back = { label = "Back", bone = "SKEL_Spine1" }
}