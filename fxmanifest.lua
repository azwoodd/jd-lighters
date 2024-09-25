name "JD-Tobacco-Lighters"
author "JDSTUDIOS"
version "v1.1"
description "Custom Lighters Script By JD"
fx_version "cerulean"
game "gta5"

dependency 'qb-core'

client_scripts {
    'client.lua',
}

server_scripts {
    'server.lua'
}

shared_scripts {
    'config.lua',
}

ui_page 'html/lighters.html' -- Make sure this matches your HTML file name

files {
    'html/lighters.html', -- Ensure this matches the ui_page
}

lua54 'yes'

escrow_ignore {
    '*.lua',
    'client/*.lua',
    'server/*.lua',
}

dependency '/assetpacks'
