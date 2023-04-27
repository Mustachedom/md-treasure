name "mustache-treasure"
author "mustache_dom"
description "treasure by mustache dom"
fx_version "cerulean"
game "gta5"

shared_script {
    'config.lua'
}
server_script 'server/main.lua'
client_scripts {
    '@PolyZone/client.lua',
    '@PolyZone/BoxZone.lua',
    '@PolyZone/CircleZone.lua',
    'client/main.lua'
}

lua54 'yes'
