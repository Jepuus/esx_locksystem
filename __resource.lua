resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

description 'ESX Lock System'

version '0.1'

server_script {
	'@mysql-async/lib/MySQL.lua',
	'@es_extended/locale.lua',
	'config.lua',
	'server/main.lua'
}

client_scripts {
	'@es_extended/locale.lua',
	'config.lua',
	'client/main.lua'
}

dependencies {
	'es_extended',
	'esx_vehicleshop'
}
