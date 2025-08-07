fx_version 'cerulean'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
game 'rdr3'

name 'QC-DevTools'
description 'Development Tools for RedM Server - Decals, Testing, and More'
version '1.0.0'

shared_scripts {
    'shared/config.lua'
}

client_scripts {
    'client/nui.lua',
    'client/main.lua',
    'client/peddecals/decals_data.lua',
    'client/peddecals/main.lua',
    'client/animpostfx/effects_data.lua',
    'client/animpostfx/main.lua',
    'client/timecycles/timecycles_data.lua',
    'client/timecycles/main.lua',
    'client/explosions/explosions_data.lua',
    'client/explosions/main.lua',
    'client/audio/dataview.lua',
    'client/audio/createstream.lua',
    'client/audio/musicevents.lua',
    'client/audio/frontendsoundsets.lua',
    'client/audio/audiobanks.lua',
    'client/audio/audioflags.lua',
    'client/audio/main.lua',
    'client/ipls/ipls_data.lua',
    'client/ipls/main.lua',
    'client/entityinfo/main.lua'
}

server_scripts {
    'server/main.lua'
}

files {
    'html/dist/index.html',
    'html/dist/**/*'
}

ui_page 'html/dist/index.html'

lua54 'yes'