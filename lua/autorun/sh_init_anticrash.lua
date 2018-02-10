if SERVER then
	include("mg_anticrash/sh_config.lua")
	AddCSLuaFile("mg_anticrash/sh_config.lua")
	include("mg_anticrash/sh_anticrash.lua")
	AddCSLuaFile("mg_anticrash/sh_anticrash.lua")
	include("mg_anticrash/sv_anticrash.lua")
end

if CLIENT then
	include("mg_anticrash/sh_config.lua")
	include("mg_anticrash/sh_anticrash.lua")
end