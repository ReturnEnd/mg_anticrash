--[[                          Made by mcNuggets aka deinemudda32                           ]]--
--[[ Please dont re-credit this addon as yours, if you don't have my permissions to do so. ]]--

MG = MG or {}

MG.FreezeAllPropsOnServerLag = true -- Freeze props on heavily server lag?
MG.MaxLongs = 3 -- Adjust.
MG.Sensitivity = 15 -- Adjust.
MG.EnableAntiPropminge = true -- Disable minging around with props? (Disables collision, when props are unfrozen)
MG.EnablePropCollide = false -- Enable collision between two props.
MG.BlockToolsOnGhostEntities = true -- Block tool usage on ghosted entities?
MG.FreezeSpecificEntities = true -- Freeze specified entities in a delay?
MG.FreezeSpecificEntitiesTimer = 600 -- In what delay the entities should be frozen?
MG.FreezeAllMapEntities = true -- Freeze all map props on startup of the map?
MG.FreezeSpecificEntitiesAfterSpawn = true -- Freeze specified entities after spawning them?
MG.DisableUnfreeze = true -- Disable unfreeze of these entities?
MG.BlockBigSizeProps_FPP = true -- Automatically block big size props? (FPP required)
MG.AllowPhysgunReload = false -- Should players be allowed to use the reload function of the Physics Gun?
MG.DisableSpecificEntityDamage = false -- Should players receive damage from specified entities?
MG.DisableVehicleDamage = false -- Should players receive damage from vehicles?
MG.AllowPhysgunOnWorld = false -- Should it be allowed to physgun world entities?
MG.AllowToolgunOnWorld = false -- Should it be allowed to use the toolgun on world entities?
MG.AllowPropertyOnWorld = false -- Should it be allowed to use the property system on world entities?

MG.DarkRPNotifications = false -- Display DarkRP-notifications instead of using the ChatPrint function? (DarkRP required)

MG.AllowedTools = { -- Which tools should be allowed to be used on ghosted entities?
	"remover"
}

MG.EntityFreezeList = { -- Which entities should freeze periodically?
	"prop_physics",
	"prop_physics_multiplayer"
}

MG.EntitySpawnFreezeList = { -- Which entities should be completly frozen on spawn?
	"gmod_button"
}

MG.EntityDamageBlockList = { -- Which entities should not deal damage to players?
	"prop_physics",
	"prop_physics_multiplayer",
	"gmod_balloon",
	"gmod_button",
	"gmod_thruster",
	"gmod_light",
	"gmod_lamp",
	"gmod_wheel",
	"gmod_hoverball"
}

MG.LanguageStrings = { -- Translate the addon
	"Please use the standard button models!",
	"There is a player stuck in this prop!",
	"This prop is now blocked. Thank you!",
}