fx_version 'cerulean'
game 'gta5'
lua54 'yes'

description 'Job Outfit Script for ESX using ox_lib'

shared_script 'config.lua'
client_script {
    '@ox_lib/init.lua', -- Aggiungi questa linea per inizializzare ox_lib nel client
    'client/main.lua'
}
server_script {
    '@oxmysql/lib/MySQL.lua', -- Aggiungi questa linea per usare oxmysql nel server
    'server/main.lua'
}

files {
    'database.sql' -- Aggiungi questa linea per eseguire il file SQL all'avvio
}

dependencies {
    'es_extended',
    'ox_lib',
    'oxmysql', -- Aggiungi questa linea per impostare oxmysql come dipendenza
    'fivem-appearance', -- o 'illenium-appearance' se impostato nel config
}