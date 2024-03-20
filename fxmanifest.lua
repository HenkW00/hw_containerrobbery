fx_version 'cerulean'
games { 'gta5' }

author 'HenkW'
description 'Container Robbery Script'
version '1.0.5'

dependency 'es_extended'

client_scripts {
    'client/main.lua',
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'server/main.lua',
    'server/version.lua'
}

shared_scripts {
    'config/config.lua',
    '@es_extended/imports.lua'
}
