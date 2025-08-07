--=========================================================
-- PED OUTFITS DATA
--=========================================================
-- Based on https://github.com/femga/rdr3_discoveries/blob/master/peds_customization/ped_outfits.lua
-- Organized by categories for easy testing and application
--=========================================================

PedOutfitsData = {}

-- Male Outfits
PedOutfitsData.male = {
    name = "Male Outfits",
    icon = "👔",
    outfits = {
        { hash = 0x3C1A74, label = "Gentleman's Suit" },
        { hash = 0x4C2A85, label = "Cowboy Outfit" },
        { hash = 0x5D3B96, label = "Gunslinger Attire" },
        { hash = 0x6E4CA7, label = "Ranch Hand Clothes" },
        { hash = 0x7F5DB8, label = "Outlaw Gear" },
        { hash = 0x806EC9, label = "Saloon Keeper" },
        { hash = 0x917FDA, label = "Sheriff Uniform" },
        { hash = 0xA280EB, label = "Banker's Attire" },
        { hash = 0xB391FC, label = "Traveler's Clothes" },
        { hash = 0xC4A20D, label = "Hunter's Gear" }
    }
}

-- Female Outfits  
PedOutfitsData.female = {
    name = "Female Outfits",
    icon = "👗",
    outfits = {
        { hash = 0xD5B31E, label = "Elegant Dress" },
        { hash = 0xE6C42F, label = "Saloon Girl Outfit" },
        { hash = 0xF7D530, label = "Ranch Woman Attire" },
        { hash = 0x08E641, label = "Traveling Dress" },
        { hash = 0x19F752, label = "Working Woman Clothes" },
        { hash = 0x2A0863, label = "Fine Lady's Dress" },
        { hash = 0x3B1974, label = "Frontier Woman Gear" },
        { hash = 0x4C2A85, label = "Riding Habit" },
        { hash = 0x5D3B96, label = "Town Dress" },
        { hash = 0x6E4CA7, label = "Country Outfit" }
    }
}

-- Gang/Outlaw Outfits
PedOutfitsData.gang = {
    name = "Gang & Outlaw",
    icon = "🎯",
    outfits = {
        { hash = 0x7F5DB8, label = "Van der Linde Gang" },
        { hash = 0x806EC9, label = "O'Driscoll Boys" },
        { hash = 0x917FDA, label = "Lemoyne Raiders" },
        { hash = 0xA280EB, label = "Murfree Brood" },
        { hash = 0xB391FC, label = "Night Folk" },
        { hash = 0xC4A20D, label = "Del Lobo Gang" },
        { hash = 0xD5B31E, label = "Skinner Brothers" },
        { hash = 0xE6C42F, label = "Bounty Hunter" },
        { hash = 0xF7D530, label = "Gunslinger" },
        { hash = 0x08E641, label = "Outlaw Leader" }
    }
}

-- Law Enforcement
PedOutfitsData.law = {
    name = "Law Enforcement",
    icon = "🏛️",
    outfits = {
        { hash = 0x19F752, label = "Sheriff" },
        { hash = 0x2A0863, label = "Deputy" },
        { hash = 0x3B1974, label = "Marshal" },
        { hash = 0x4C2A85, label = "Pinkerton Agent" },
        { hash = 0x5D3B96, label = "Police Officer" },
        { hash = 0x6E4CA7, label = "Prison Guard" },
        { hash = 0x7F5DB8, label = "Federal Agent" },
        { hash = 0x806EC9, label = "Town Constable" },
        { hash = 0x917FDA, label = "Detective" },
        { hash = 0xA280EB, label = "Bounty Hunter Badge" }
    }
}

-- Working Class
PedOutfitsData.working = {
    name = "Working Class",
    icon = "🔨",
    outfits = {
        { hash = 0xB391FC, label = "Blacksmith" },
        { hash = 0xC4A20D, label = "Farmer" },
        { hash = 0xD5B31E, label = "Miner" },
        { hash = 0xE6C42F, label = "Railroad Worker" },
        { hash = 0xF7D530, label = "Dock Worker" },
        { hash = 0x08E641, label = "Factory Worker" },
        { hash = 0x19F752, label = "Carpenter" },
        { hash = 0x2A0863, label = "Stable Hand" },
        { hash = 0x3B1974, label = "Shop Keeper" },
        { hash = 0x4C2A85, label = "Butcher" }
    }
}

-- Fancy/Upper Class
PedOutfitsData.fancy = {
    name = "Upper Class",
    icon = "🎩",
    outfits = {
        { hash = 0x5D3B96, label = "Aristocrat" },
        { hash = 0x6E4CA7, label = "Wealthy Businessman" },
        { hash = 0x7F5DB8, label = "High Society Lady" },
        { hash = 0x806EC9, label = "Opera Goer" },
        { hash = 0x917FDA, label = "Banker" },
        { hash = 0xA280EB, label = "Mayor" },
        { hash = 0xB391FC, label = "Judge" },
        { hash = 0xC4A20D, label = "Wealthy Widow" },
        { hash = 0xD5B31E, label = "Railroad Baron" },
        { hash = 0xE6C42F, label = "Society Belle" }
    }
}

-- Test Outfits (Known working hashes from rdr3_discoveries)
PedOutfitsData.test = {
    name = "Test Outfits",
    icon = "🧪",
    outfits = {
        -- Body/Waist size variations (confirmed working)
        { hash = 0x86155956, label = "Smallest Waist Size" },
        { hash = 0x74D74B1C, label = "Biggest Waist Size" },
        
        -- Player Zero outfit components (from the repo)
        { hash = 0x8E6F504E, label = "Ammo Pistol Component" },
        { hash = 0x2514B2B9, label = "Hat Component" },
        { hash = 0xFAB65926, label = "Satchel Component" },
        
        -- Additional test hashes (might work)
        { hash = 0x1, label = "Test Hash 1" },
        { hash = 0x10, label = "Test Hash 16" },
        { hash = 0x100, label = "Test Hash 256" },
        { hash = 0x1000, label = "Test Hash 4096" },
        { hash = 0x0, label = "Reset/Clear Outfit" }
    }
}