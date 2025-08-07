--=========================================================
-- ANIMATION POST FX EFFECTS DATA  
--=========================================================
-- Based on confirmed working AnimPostFX effects
-- All effects in this list have been tested and confirmed working
--=========================================================

AnimPostFXData = {}

-- Popular/Common Effects
AnimPostFXData.popular = {
    name = "Popular Effects",
    icon = "⭐",
    effects = {
        { name = "PauseMenuIn", label = "Pause Menu" },
        { name = "WheelHUDIn", label = "Wheel HUD" },
        { name = "PlayerHealthPoor", label = "Player Health Poor" },
        { name = "MP_SkillGeneric01", label = "Generic Skill" },
        { name = "MP_Region", label = "Region" },
        { name = "PlayerDrunk01", label = "Player Drunk 1" },
        { name = "playerdrugshalluc01", label = "Player Drug 1" },
        { name = "consumegeneric01", label = "Consume 1" },
        { name = "consumefortgeneric01", label = "Consume 2" },
        { name = "MissionFail01", label = "Mission Fail" }
    }
}

-- Death & Combat
AnimPostFXData.combat = {
    name = "Death & Combat",
    icon = "💀",
    effects = {
        { name = "DeathFailMP01", label = "Death Fail" },
        { name = "RespawnPulse01", label = "Respawn Pulse" },
        { name = "RespawnPulseMP01", label = "Respawn Pulse 2" },
        { name = "killCam", label = "Killcam" },
        { name = "MP_PedKill", label = "MP Ped Kill" },
        { name = "PedKill", label = "Ped Kill" },
        { name = "directionalhit01", label = "Directional Hit" },
        { name = "KillCamHonorChange", label = "Kill Cam Honor Change" },
        { name = "MP_Downed", label = "MP Downed" },
        { name = "PlayerOverpower", label = "Player Overpower" }
    }
}

-- Player States
AnimPostFXData.player = {
    name = "Player States",
    icon = "🤠",
    effects = {
        { name = "PlayerWakeUpDrunk", label = "Wake Up Drunk" },
        { name = "PlayerWakeUpInterrogation", label = "Wake Up Interrogation" },
        { name = "PlayerRPGCoreDeadEye", label = "RPG Core Dead Eye" },
        { name = "DEADEYE", label = "Dead Eye" },
        { name = "DeadEyeEmpty", label = "Dead Eye Empty" },
        { name = "PlayerHealthPoorCS", label = "Health Poor CS" },
        { name = "PlayerHealthPoorGuarma", label = "Health Poor Guarma" },
        { name = "PlayerSickDoctorsOpinion", label = "Sick Doctors Opinion" },
        { name = "PlayerRPGCore", label = "Player RPG Core" },
        { name = "PlayerImpactFall", label = "Impact Fall" }
    }
}

-- Photo Mode & Filters  
AnimPostFXData.photo = {
    name = "Photo Mode & Filters",
    icon = "📸",
    effects = {
        { name = "PhotoMode_FilterGame01", label = "Photo Filter Game 01" },
        { name = "PhotoMode_FilterGame02", label = "Photo Filter Game 02" },
        { name = "PhotoMode_FilterGame03", label = "Photo Filter Game 03" },
        { name = "PhotoMode_FilterGame04", label = "Photo Filter Game 04" },
        { name = "PhotoMode_FilterGame05", label = "Photo Filter Game 05" },
        { name = "PhotoMode_FilterModern01", label = "Filter Modern 01" },
        { name = "PhotoMode_FilterModern02", label = "Filter Modern 02" },
        { name = "PhotoMode_FilterVintage01", label = "Filter Vintage 01" },
        { name = "PhotoMode_FilterVintage02", label = "Filter Vintage 02" },
        { name = "PhotoMode_Bounds", label = "Photo Bounds" }
    }
}

-- Camera & Transitions
AnimPostFXData.camera = {
    name = "Camera & Transitions",
    icon = "📷",
    effects = {
        { name = "CamTransition01", label = "Cam Transition 01" },
        { name = "CamTransitionBlink", label = "Cam Transition Blink" },
        { name = "CamTransitionBlinkSlow", label = "Cam Transition Blink Slow" },
        { name = "CameraTransitionBlink", label = "Camera Transition Blink" },
        { name = "CameraTransitionFlash", label = "Camera Transition Flash" },
        { name = "CameraTransitionWipe_R", label = "Camera Wipe Right" },
        { name = "CameraTransitionWipe_L", label = "Camera Wipe Left" },
        { name = "CameraViewfinder", label = "Camera Viewfinder" },
        { name = "CameraTakePicture", label = "Camera Take Picture" },
        { name = "spectatorcam01", label = "Spectator Cam" }
    }
}

-- Chapter Titles
AnimPostFXData.chapters = {
    name = "Chapter Titles",
    icon = "📜",
    effects = {
        { name = "title_ch01_colter", label = "Chapter 1 - Colter" },
        { name = "title_ch02_horseshoeoverlook", label = "Chapter 2 - Horseshoe" },
        { name = "Title_Ch03_ClemensPoint", label = "Chapter 3 - Clemens Point" },
        { name = "title_ch04_saintdenis", label = "Chapter 4 - Saint Denis" },
        { name = "title_ch05_guarma", label = "Chapter 5 - Guarma" },
        { name = "title_ch06_beaverhollow", label = "Chapter 6 - Beaver Hollow" },
        { name = "title_ep01_pronghornranch", label = "Epilogue 1 - Pronghorn" },
        { name = "title_ep02_beechershope", label = "Epilogue 2 - Beechers Hope" },
        { name = "Title_GameIntro", label = "Game Intro" },
        { name = "Title_Gen_FewWeeksLater", label = "Few Weeks Later" }
    }
}

-- Multiplayer
AnimPostFXData.multiplayer = {
    name = "Multiplayer",
    icon = "👥",
    effects = {
        { name = "MP_LobbyBW01_Intro", label = "Blackwater Lobby Intro" },
        { name = "MP_LobbyBW01", label = "Blackwater Lobby" },
        { name = "MP_OutofArea", label = "Out of Area" },
        { name = "mp_outofbounds", label = "Out of Bounds" },
        { name = "MP_RiderFormation", label = "Rider Formation" },
        { name = "MP_ArcheryTarget", label = "Archery Target" },
        { name = "MP_ArrowDisorient", label = "Arrow Disorient" },
        { name = "MP_ArrowDrain", label = "Arrow Drain" },
        { name = "MP_ArrowTracking", label = "Arrow Tracking" },
        { name = "MP_HealthDrop", label = "Health Drop" }
    }
}

-- Sky/Time Effects
AnimPostFXData.sky = {
    name = "Sky & Time Effects", 
    icon = "🌅",
    effects = {
        { name = "skytl_0000_01clear", label = "Sky Midnight Clear" },
        { name = "skytl_0600_01clear", label = "Sky 6AM Clear" },
        { name = "skytl_1200_01clear", label = "Sky Noon Clear" },
        { name = "skytl_1800_01clear", label = "Sky 6PM Clear" },
        { name = "skytl_0000_03clouds", label = "Sky Midnight Clouds" },
        { name = "skytl_0600_03clouds", label = "Sky 6AM Clouds" },
        { name = "skytl_1200_03clouds", label = "Sky Noon Clouds" },
        { name = "skytl_1800_03clouds", label = "Sky 6PM Clouds" },
        { name = "skytl_0000_04storm", label = "Sky Midnight Storm" },
        { name = "skytl_1200_04storm", label = "Sky Noon Storm" }
    }
}

-- Special/Misc Effects
AnimPostFXData.special = {
    name = "Special Effects",
    icon = "✨",
    effects = {
        { name = "KingCastleBlue", label = "King Castle Blue" },
        { name = "KingCastleRed", label = "King Castle Red" },
        { name = "GunslingerFill", label = "Gunslinger Fill" },
        { name = "EagleEye", label = "Eagle Eye" },
        { name = "ScopeSniper", label = "Scope Sniper" },
        { name = "ScopeBinoculars", label = "Scope Binoculars" },
        { name = "1p_glassesdark", label = "Dark Glasses" },
        { name = "1p_maskdark", label = "Dark Mask" },
        { name = "1p_hatdark", label = "Dark Hat" },
        { name = "poisondarthit", label = "Poison Dart Hit" }
    }
}