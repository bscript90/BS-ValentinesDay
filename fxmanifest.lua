fx_version "cerulean"
version "1.1"
author "BScript Development"
description "Valentines Day"
game "rdr3"
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
lua54 "yes"

ui_page 'ui/index.html'

files {
  'ui/**'
}

shared_scripts {
  'config.lua',
  'framework.lua'
}

server_scripts {
  'server.lua',
  'versionchecker.lua'
}

client_scripts {
  'client.lua'
}