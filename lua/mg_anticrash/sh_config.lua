--[[                                   Made by mcNuggets                                   ]]--
--[[ Please dont re-credit this addon as yours, if you don't have my permissions to do so. ]]--

MG = MG or {}

-- Propfreeze settings

MG.FreezeAllPropsOnServerLag = true -- Freeze props on (heavy) server lag.
MG.MaxLongs = 3 -- Minimum lag checks before freezing all props specified in the MG.EntityFreezeList-table. 
MG.Sensitivity = 10 -- Sensitivity of the lag detection.
MG.FreezeDelay = 0.1 -- Minimum delay between two freezes.

-- Anti prop minge settings

MG.EnableAntiPropMinge = true -- Prevents minging around with props. (Ghosts props, when unfrozen)

-- Config options below here only work with MG.EnableAntiPropMinge set to true, some may still work, but most of them won't!
MG.CollideWithEntities = false -- Enables collision between two props. (Still collisions with players is disabled)
MG.GhostAllEntities = false -- Ghosts all entities specified in the MG.MingeEntities-table instead of just props. (If you want to ghost other entities on spawn as well, turn the config-setting MG.OnlyGhostPropsOnSpawn to true)
MG.UseWhitelist = false -- Uses a whitelist for the MG.MingeEntities-table instead of a blacklist.
MG.OnlyGhostPropsOnSpawn = false -- Ghosts all entities instead of just props on spawn. (Enabling this ghosts all entities in the MG.MingeEntities-table on spawn)
MG.BlockToolsOnGhostEntities = true -- Blocks tool usage on ghosted entities. (Excluding tools defined in the MG.AllowedTools-table)
MG.AllowWeldWorkaround = true -- Fixes occuring problems with the weld-tool. (Don't edit this, if you don't know what is meant)
MG.AllowCollideWorkaround = true -- Fixes occuring problems with nocollide-properties. (Don't edit this, if you don't know what is meant)
MG.DisableFreezeInsideVehicles = false -- Disables freezing of entities inside of a vehicle.

-- Config options below here should now work without MG.EnableAntiPropMinge set to true, again. Some still may not work however, read the descriptions of it.

-- Misc settings
MG.FreezeSpecificEntities = true -- Automatically freezes all entities in the MG.EntityFreezeList-table in a custom delay.
MG.FreezeSpecificEntitiesTimer = 600 -- Delay for freezing all entities periodically.
MG.FreezeAllMapEntities = true -- Freeze all map entities on serverstartup.
MG.EnableGhostingCommands = true -- Allows players in the usergroup specified in the MG.ProtectGroups-table to be able to disable the protection mode for some props. (Only works with MG.EnableAntiPropMinge set to true)
MG.EnableFreezeCommand = true -- Allows players in the usergroup specified in the MG.FreezeGroups-table to be able to FORCE freeze all props via the console-command "mg_freeze".
MG.BlockBigSizeProps_FPP = true -- Automatically blocks big size props. (Only works with Falco's Prop Protection "https://github.com/FPtje/Falcos-Prop-protection")
MG.AllowPhysgunReload = true -- Allows players to use the reload function of the Physics Gun to unfreeze props.
MG.DisableSpecificEntityDamage = false -- Disables damage received by entities specified in the EntityDamageBlockList-table.
MG.DisableVehicleDamage = false -- Disables any damage taken by vehicles.
MG.DisableVehicleCollision = true -- Disables collision of vehicles with players.
MG.CheckForStuckingProps = true -- Freezes or removes props whose owners try to crash the server. (Multiple props in each other stucking unfreezed in each other is causing heavy lag with complex prop-models)
MG.MaxStuckingProps = 4 -- Minimum stucking props to activate the protection.
MG.RemoveStuckingProps = true -- Removes props instead of freezing them.
MG.WarnPlayer = true -- Informs the player about their bad behaviour.
MG.AllowPhysgunOnWorld = false -- Allows physgunning of map created entities. (Disabled by default, useful for DarkRP-servers)
MG.AllowToolgunOnWorld = false -- Allows to use the toolgun on map created entities. (Disabled by default, useful for DarkRP-servers)
MG.AllowPropertyOnWorld = false -- Allows to use properties (context menu-related actions) on map created entities? (Disabled by default, useful for DarkRP-servers)
MG.UseNWBools = false -- Use NW2Bools for networking map created entities to players. (If you have some sort of problems with lag, leave it as false)
MG.DarkRPNotifications = true -- Use the DarkRP-notifications system instead of chatprints. (DarkRP required. If DarkRP isn't found, it uses ChatPrints)

MG.MingeEntities = { -- Table of entities the ghost protection should deal with.(Only works with MG.GhostAllEntities set to true)
	["prop_physics"] = true, -- Removing this with MG.GhostAllEntities set to true, returns in props not being ghosted properly anymore.
	["prop_physics_multiplayer"] = true, -- Used on rp_evocity_v33x as map props.
	["prop_ragdoll"] = true,
}

MG.AllowedTools = { -- Table of tools allowed to be used on ghosted entities. (Only works with MG.BlockToolsOnGhostEntities is set to true)
	["remover"] = true,
}

MG.EntityFreezeList = { -- Table of entities the automatic freezing system should freeze periodically. (Only works with MG.FreezeSpecificEntities is set to true)
	["prop_physics"] = true,
	["prop_physics_multiplayer"] = true,
}

MG.EntityDamageBlockList = { -- Table of entities not being able to damage other players. (Only works with MG.DisableSpecificEntityDamage is set to true)
	["prop_physics"] = true,
	["prop_physics_multiplayer"] = true,
	["gmod_balloon"] = true,
	["gmod_button"] = true,
	["gmod_thruster"] = true,
	["gmod_light"] = true,
	["gmod_lamp"] = true,
	["gmod_wheel"] = true,
	["gmod_hoverball"] = true,
}

MG.ProtectGroups = { -- Table of usergroups being able to enable/disable the protection mode of props. (Only works with MG.EnableGhostingCommands is set to true)
	["superadmin"] = true,
}

MG.FreezeGroups = { -- Table of usergroups being able to freeze all props on the server. (Only works with MG.EnableFreezeCommand is set to true)
	["owner"] = true,
	["co-owner"] = true,
	["superadmin_don"] = true,
	["superadmin"] = true
}

MG.LanguageStrings = { -- Translate the addon! (There isn't much to be translated)
	"There is a player stuck in this prop!",
	"This prop is now blocked. Thank you!",
	"The server wants to stay online, buddy.",
	"This prop is no longer protected.",
	"This prop is protected again.",
	"Disable protection for this prop",
	"Enable protection for this prop",
}