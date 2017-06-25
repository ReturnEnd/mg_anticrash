--[[                                   Made by mcNuggets                                   ]]--
--[[ Please dont re-credit this addon as yours, if you don't have my permissions to do so. ]]--

MG = MG or {}

MG.FreezeAllPropsOnServerLag = true -- Freeze props on heavily server lag?
MG.MaxLongs = 3 -- Adjust.
MG.Sensitivity = 10 -- Adjust.
MG.FreezeDelay = 0.1 -- Adjust.
MG.EnableAntiPropMinge = true -- Prevent minging around with props? (Disables collision, when props are unfrozen)
MG.CollideWithEntities = false -- Enable collision between two props?
MG.UseWhitelist = false -- Should we use a white list for minging entities instead of a blacklist?
MG.GhostAllEntities = false -- Should we ghost all entities specified in the table?
MG.OnlyGhostPropsOnSpawn = false -- Should we only ghost props on spawn?
MG.BlockToolsOnGhostEntities = true -- Block tool usage on ghosted entities?
MG.AllowWeldWorkaround = true -- Fix occuring problems with the weld-tool?
MG.AllowCollideWorkaround = true -- Fix occuring problems with nocollide-properties?
MG.DisableFreezeInsideVehicles = false -- Disable freezing of entities inside a vehicle?
MG.FreezeSpecificEntities = true -- Freeze specified entities in a delay?
MG.FreezeSpecificEntitiesTimer = 600 -- In which delay the entities should be frozen?
MG.FreezeAllMapEntities = true -- Freeze all map props on startup of the map?
MG.EnableFreezeCommand = true -- Should admins be able to force freeze all props via command "mg_freeze"?
MG.BlockBigSizeProps_FPP = true -- Automatically block big size props? (FPP required)
MG.AllowPhysgunReload = true -- Should players be allowed to use the reload function of the Physics Gun?
MG.DisableSpecificEntityDamage = false -- Should players receive damage from specified entities?
MG.DisableVehicleDamage = false -- Disable damage taken by vehicle?
MG.DisableVehicleCollision = true -- Disable collision of vehicles with players?
MG.CheckForStuckingProps = true -- Freeze or remove multiple players trying to make props stucking in each other to create physics lags? (Usually used to crash servers)
MG.MaxStuckingProps = 6 -- On which amount should props not be allowed to be unfreezed?
MG.RemoveStuckingProps = true -- Remove props instead of freezing them?
MG.WarnPlayer = true -- Inform the player about too many props stucking in each other?
MG.AllowPhysgunOnWorld = false -- Should it be allowed to physgun map created entities?
MG.AllowToolgunOnWorld = false -- Should it be allowed to use the toolgun on map created entities?
MG.AllowPropertyOnWorld = false -- Should it be allowed to use the property system on map created entities?
MG.UseNWBools = false -- Should NWBools be used for Networking map created entities? (Turn this off, if you encounter some sort of lag.)

MG.DarkRPNotifications = false -- Display DarkRP-notifications instead of using the ChatPrint function? (DarkRP required)

MG.MingeEntities = { -- Which entities should be ghosted on pickup (eventually spawn) and unghosted on drop?
	["prop_physics"] = true, -- Don't remove this, if MG.GhostAllEntities is set to false.
	["prop_physics_multiplayer"] = true
}

MG.AllowedTools = { -- Which tools should be allowed to be used on ghosted entities?
	["remover"] = true
}

MG.EntityFreezeList = { -- Which entities should freeze periodically?
	["prop_physics"] = true,
	["prop_physics_multiplayer"] = true
}

MG.EntityDamageBlockList = { -- Which entities should not deal damage to players?
	["prop_physics"] = true,
	["prop_physics_multiplayer"] = true,
	["gmod_balloon"] = true,
	["gmod_button"] = true,
	["gmod_thruster"] = true,
	["gmod_light"] = true,
	["gmod_lamp"] = true,
	["gmod_wheel"] = true,
	["gmod_hoverball"] = true
}

MG.LanguageStrings = { -- Translate the addon
	"There is a player stuck in this prop!",
	"This prop is now blocked. Thank you!",
	"The server wants to stay online, buddy."
}