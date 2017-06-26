--[[                                   Made by mcNuggets                                   ]]--
--[[ Please dont re-credit this addon as yours, if you don't have my permissions to do so. ]]--

MG = MG or {}

MG.FreezeAllPropsOnServerLag = true -- Freeze props on (heavy) server lag.
MG.MaxLongs = 3 -- Minimum lag checks before freezing all props specified in the EntityFreezeList-table. 
MG.Sensitivity = 10 -- Sensitivity of the lag detection.
MG.FreezeDelay = 0.1 -- Minimum delay between two freezes.
MG.EnableAntiPropMinge = true -- Prevents minging around with props. (Ghosts props, when unfrozen)
MG.CollideWithEntities = false -- Enables collision between two props. (Still collision with players is disabled)
MG.GhostAllEntities = false -- Ghosts all entities specified in the MingeEntities-table instead of just props. (If you want to ghost other entities on spawn as well, turn the config-setting "OnlyGhostPropsOnSpawn" to "true")
MG.UseWhitelist = false -- Uses a whitelist for the MingeEntities-table instead of a blacklist.
MG.OnlyGhostPropsOnSpawn = false -- Ghosts all entities instead of just props on spawn. (Enabling this ghosts all entities in the MingeEntities-table on spawn)
MG.BlockToolsOnGhostEntities = true -- Blocks tool usage on ghosted entities. (Excluding tools defined in the AllowedTools-table)
MG.AllowWeldWorkaround = true -- Fixes occuring problems with the weld-tool. (Don't edit this, if you don't know what is meant)
MG.AllowCollideWorkaround = true -- Fixes occuring problems with nocollide-properties. (Don't edit this, if you don't know what is meant)
MG.DisableFreezeInsideVehicles = false -- Disables freezing of entities inside a vehicle.
MG.FreezeSpecificEntities = true -- Automatically freezes all entities in the EntityFreezeList-table in a custom delay.
MG.FreezeSpecificEntitiesTimer = 600 -- Delay for freezing all entities periodically.
MG.FreezeAllMapEntities = true -- Freeze all map entities on serverstartup. (Usually helpful for DarkRP-servers)
MG.EnableFreezeCommand = true -- Allows Admins to be able to FORCE freeze all props via console-command "mg_freeze".
MG.BlockBigSizeProps_FPP = true -- Automatically blocks big size props. (Only works with Falco's Prop Protection "https://github.com/FPtje/Falcos-Prop-protection")
MG.AllowPhysgunReload = true -- Allows players to use the reload function of the Physics Gun to unfreeze props. (Should work well and is a supported feature of this anticrash thingy anyway)
MG.DisableSpecificEntityDamage = false -- Disables damage received by entities specified in the EntityDamageBlockList-table.
MG.DisableVehicleDamage = false -- Disables any damage taken by vehicles.
MG.DisableVehicleCollision = true -- Disables collision of vehicles with players.
MG.CheckForStuckingProps = true -- Freezes or removes props whose owners try to crash the server. (Multiple props in each other stucking unfreezed in each other is causing heavy lag with complex prop-models)
MG.MaxStuckingProps = 4 -- Minimum stucking props to activate the protection.
MG.RemoveStuckingProps = true -- Removes props instead of freezing them.
MG.WarnPlayer = true -- Informs the player about their bad behaviour.
MG.AllowPhysgunOnWorld = false -- Allows physgunning of map created entities. (Usually helpful for DarkRP-servers)
MG.AllowToolgunOnWorld = false -- Allows to use the toolgun on map created entities. (Usually helpful for DarkRP-servers)
MG.AllowPropertyOnWorld = false -- Allows to use properties (via context menu) on map created entities? (Usually helpful for DarkRP-servers)
MG.UseNWBools = false -- Use NWBools for networking map created entities to players. (DON'T USE IT, IF YOU HAVE A HIGH PLAYER COUNT!)

MG.DarkRPNotifications = false -- Use the DarkRP-notifications system instead of chatprints. (DarkRP required)

MG.MingeEntities = { -- Table of entities the ghost protection should deal with.
	["prop_physics"] = true, -- Don't remove this, if "GhostAllEntities" is set to "false".
	["prop_physics_multiplayer"] = true, -- Used on rp_evocity_v33x as map props.
	["prop_ragdoll"] = true
}

MG.AllowedTools = { -- Table of tools allowed to be used on ghosted entities. (Only works if "BlockToolsOnGhostEntities" is set to "true")
	["remover"] = true
}

MG.EntityFreezeList = { -- Table of entities the automatic freezing system should freeze periodically. (Only works if "FreezeSpecificEntities" is set to "true")
	["prop_physics"] = true,
	["prop_physics_multiplayer"] = true
}

MG.EntityDamageBlockList = { -- Table of entities not being able to damage other players. (Only works if "DisableSpecificEntityDamage" is set to "true")
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

MG.LanguageStrings = { -- Translate the addon! (There isn't much to be translated)
	"There is a player stuck in this prop!",
	"This prop is now blocked. Thank you!",
	"The server wants to stay online, buddy."
}