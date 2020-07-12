resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

dependency "vrp"

ui_page "NUI/panel.html"

files {
	"NUI/panel.js",
	"NUI/panel.html",
	"NUI/panel.css",
	"NUI/iphone.png",
	"NUI/robinhood-logo.png",
}

client_scripts {
	"lib/Tunnel.lua",
	"lib/Proxy.lua",
    "config.lua",
    "client.lua"
}

server_scripts {
	"@vrp/lib/utils.lua",
    "@mysql-async/lib/MySQL.lua",
    "config.lua",
    "server.lua"
}