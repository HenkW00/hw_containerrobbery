fx_version 'cerulean'
games { 'gta5' }
lua54 'yes'

author 'HenkW'
description 'Container Robbery Script using lib libary'
version '1.2.0'

files {
    'locales/*.json'
}

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
    '@es_extended/imports.lua',
    '@ox_lib/init.lua'
}

dependencies {
    'es_extended',
    'hw_utils',
    'ox_lib',
}