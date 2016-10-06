--[[                          Made by mcNuggets aka deinemudda32                           ]]--
--[[ Please dont re-credit this addon as yours, if you don't have my permissions to do so. ]]--

local MG_FreezePropsOnServerLag = true -- Freeze props on server lag?
local MG_EnableAntiPropminge = true -- Disable prop minging?
local MG_FreezeProps = true -- Freeze all props in a delay?
local MG_FreezePropsTimer = 600 -- How often should props be frozen? (in seconds)
local MG_FreezeMapProps = true -- Automatic freeze all map props?
local MG_BlockBigSizeProps_FPP = true -- (FPP required) Block too big props?
local MG_AllowPhysgunReload = false -- Should Players be allowed to use the Reloadfunction of the Physics Gun?
local MG_FixButtonExploit = true -- I know it is not really a real exploit, but this is one of the things, this addon doesn't fix up. If you find a better way, tell me.
local MG_DisablePropDamage = false -- Should Players receive prop damage?
local MG_DisableVehicleDamage = false -- Should Players receive vehicle damage?
local MG_AllowPhysgunWorld = false -- Should Players be allowed to physgun world entities?
local MG_AllowToolGunWorld = false -- Should Players be allowed to use toolgun on world entities?
local MG_AllowPropertyWorld = false -- Should Players be allowed to use properties on world entities?

local MG_DarkRPNotifications = true -- Display DarkRP-Notifications instead of using meta:ChatPrint("")?

local MG_BlockedPropDamageList = { -- List of entities which should not damage players.
	"prop_physics",
	"prop_physics_multiplayer"
	"gmod_*"
}

local MG_LanguageStrings = { -- Translate the addon.
	"Please don't use button models, rather the standard ones!",
	"There is a player stucking in this prop!",
	"This prop is now blocked. Thank you!",
}

-- Don't edit under this line.

if !MG_PhysgunWorld then
	hook.Add("PhysgunPickup", "AntiCrash_BlockPhysgunOnWorld", function(ply, ent)
		if ent:CreatedByMap() then
			return false
		end
	end)
end

if !MG_ToolGunWorld then
	hook.Add("CanTool", "AntiCrash_BlockToolgunOnWorld", function(ply, tr, tool)
		if IsValid(tr.Entity) and tr.Entity:CreatedByMap() then
			return false
		end
	end)
end

if !MG_PropertyWorld then
	hook.Add("CanProperty", "AntiCrash_BlockPropertyOnWorld", function(ply, property, ent)
		if ent:CreatedByMap() then
			return false
		end
	end)
end

if MG_FixButtonExploit then
	local MG_Disabled_Tools = {
		"models/maxofs2d/button_01.mdl",
		"models/maxofs2d/button_02.mdl",
		"models/maxofs2d/button_03.mdl",
		"models/maxofs2d/button_04.mdl",
		"models/maxofs2d/button_05.mdl",
		"models/maxofs2d/button_06.mdl",
		"models/maxofs2d/button_slider.mdl"
	}

	hook.Add("CanTool", "AntiCrash_BlockButtonModels", function(ply, ent, tool)
		if tool == "button" then
			if !table.HasValue(MG_Disabled_Tools,ply:GetInfo("button_model")) then
				local message = MG_LanguageStrings[1]
				if MG_DarkRPNotifications then
					DarkRP.notify(ply, 1, 5, message)
				else
					ply:ChatPrint(message)
				end
				return false
			end
		end
	end)
end

if !MG_AllowPhysgunReload then
	hook.Add("OnPhysgunReload", "AntiCrash_DisablePhysgunUnfreeze", function(g, ply)
		return false
	end)
end

local function EnableProtectionMode(ent)
	ent:SetRenderMode(RENDERMODE_TRANSALPHA)
	ent.MG_Color = ent:GetColor()
	ent:SetColor(Color(255,255,255,200))
	ent:DrawShadow(false)
	ent:SetCollisionGroup(COLLISION_GROUP_WORLD)
	ent:CollisionRulesChanged()
end

local function DisableProtectionMode(ent)
	ent:SetRenderMode(RENDERMODE_NORMAL)
	ent:SetColor(ent.MG_Color or Color(255,255,255,255))
	ent:DrawShadow(true)
	ent:SetCollisionGroup(COLLISION_GROUP_NONE)
	ent:CollisionRulesChanged()
end

if MG_EnableAntiPropminge then
	hook.Add("PlayerSpawnedProp", "AntiCrash_EnableProtectionMode", function(ply, model, ent)
		timer.Simple(0, function()
			if !IsValid(ent) then return end
			local phys = ent:GetPhysicsObject()
			if IsValid(phys) then
				if phys:IsMotionEnabled() then
					ent.protected = true
					EnableProtectionMode(ent)
				end
			end
		end)
	end)

	hook.Add("PhysgunPickup", "AntiCrash_EnableProtectionMode", function(ply, ent)
		if ent:GetClass() != "prop_physics" or ent.protected then return end
		if ent.CPPIGetOwner and ent:CPPIGetOwner() != ply then return end
		if !MG_PhysgunWorld and ent:CreatedByMap() then return end
		ent.protected = true
		EnableProtectionMode(ent)
	end)

	local function CheckForStuckingPlayers(ent)
		local mins, maxs, check = ent:OBBMins(), ent:OBBMaxs(), false
		local tr = {start = ent:LocalToWorld(mins), endpos = ent:LocalToWorld(maxs), filter = ent}
		local trace = util.TraceLine(tr)
		check = IsValid(trace.Entity) and trace.Entity:IsPlayer() or false
		if check then return check end
		local pos = ent:GetPos()
		tr = {start = pos, endpos = pos, filter = ent, mins = ent:OBBMins(), maxs = ent:OBBMaxs()}
		trace = util.TraceHull(tr)
		check = IsValid(trace.Entity) and trace.Entity:IsPlayer() or false
		if check then return check end
		local cube = ents.FindInBox(ent:LocalToWorld(mins), ent:LocalToWorld(maxs))
		for _,v in pairs(cube) do
			if v:IsPlayer() then
				return true
			end
		end
		return false
	end

	hook.Add("OnPhysgunFreeze", "AntiCrash_DisableProtectionMode", function(weapon, physobj, ent, ply)
		if IsValid(ent) and ent.protected then
			if CheckForStuckingPlayers(ent) == true then
				local message = MG_LanguageStrings[2]
				if MG_DarkRPNotifications then
					DarkRP.notify(ply, 1, 5, message)
				else
					ply:ChatPrint(message)
				end
				return false
			end
			ent.protected = nil
			DisableProtectionMode(ent)
		end
	end)
end

if MG_FreezeProps then
	hook.Add("PhysgunPickup", "AntiCrash_PickUpCheck", function(ply, ent)
		if ent:GetClass() != "prop_physics" then return end
		if ent.CPPIGetOwner and ent:CPPIGetOwner() != ply then return end
		if !MG_PhysgunWorld and ent:CreatedByMap() then return end
		ent.picked = true
	end)

	hook.Add("PhysgunDrop", "AntiCrash_PickUpCheck", function(ply, ent)
		if IsValid(ent) then
			ent.picked = nil
		end
	end)

	hook.Add("OnPhysgunFreeze", "AntiCrash_PickUpCheck", function(weapon, physobj, ent, ply)
		if IsValid(ent) then
			ent.picked = nil
		end
	end)

	hook.Add("GravGunOnPickedUp", "AntiCrash_PickUpCheck", function(ply, ent)
		if ent:IsPlayer() then return end
		ent.picked = true
	end)

	hook.Add("GravGunOnDropped", "AntiCrash_PickUpCheck", function(ply, ent)
		if IsValid(ent) then
			ent.picked = nil
		end
	end)
end

if MG_DisablePropDamage or MG_DisableVehicleDamage then
	hook.Add("EntityTakeDamage", "AntiCrash_DisableKilling", function(target, dmg)
		if dmg:GetDamageType() == DMG_CRUSH then
			local ent = dmg:GetInflictor()
			if !IsValid(ent) then return end
			if (MG_DisableVehicleDamage and ent:IsVehicle()) or (MG_DisablePropDamage and table.HasValue(MG_BlockedPropDamageList, ent:GetClass()) then
				dmg:SetDamage(0)
				dmg:ScaleDamage(0)
				return true
			end
		end
	end)
end

if MG_BlockBigSizeProps_FPP then
	local function AntiCrash_FixModel(model)
		local model = model or ""
		model = tostring(model)
		model = string.lower(model)
		model = string.Replace(model, "\\", "/")
		model = string.Replace(model, " ", "_")
		model = string.Replace(model, ";", "")
		model = string.gsub(model, "[\\/]+", "/")
		return model
	end

	hook.Add("PlayerSpawnedProp", "AntiCrash_BlockBigSizeProps", function(ply, mdl, ent)
		local phys = ent:GetPhysicsObject()
		if IsValid(phys) and phys:GetVolume() then
			if phys:GetVolume() > math.pow(10, 7) then
				mdl = AntiCrash_FixModel(mdl)
				if mdl and type(FPP) == "table" then
					RunConsoleCommand("FPP_AddBlockedModel", mdl)
				end
				SafeRemoveEntity(ent)
				if IsValid(ply) then
					local message = MG_LanguageStrings[3]
					if MG_DarkRPNotifications then
						DarkRP.notify(ply, 0, 8, message)
					else
						ply:ChatPrint(message)
					end
				end
			end
		end
	end)
end

local function AntiCrash_FreezeEntities(name)
	for k,v in pairs(ents.FindByClass(name)) do
		if v.picked then continue end
		if MG_EnableAntiPropminge then
			v.protected = nil
			DisableProtectionMode(v)
		end
		local phys = v:GetPhysicsObject()
		if IsValid(phys) then
			phys:EnableMotion(false)
		end
	end
end

if MG_FreezeMapProps then
	timer.Create("AntiCrash_FreezeMapProps", 1, 1, function()
		AntiCrash_FreezeEntities("prop_physics")
		AntiCrash_FreezeEntities("prop_physics_multiplayer")
	end)
end

if MG_FreezeProps then
	timer.Create("AntiCrash_FreezeProps", MG_FreezePropsTimer, 0, function()
		AntiCrash_FreezeEntities("prop_physics")
	end)
end

if MG_FreezePropsOnServerLag then
	timer.Simple(10, function()
		local maxlongs = 3 -- You may play with these values to find the best matching one!
		local sensitivity = 15
		local tickrate = 1/engine.TickInterval()

		local tick = RealTime() -- Not with these ones!
		local counter = 0

		hook.Add("Think", "AntiCrash_FreezeAll", function()
			local rate = 1 / (RealTime() - tick)
			if rate < tickrate / sensitivity then
				counter = counter + 1
				if counter >= maxlongs then
					for _,p in pairs(ents.FindByClass("prop_physics")) do
						local phys = p:GetPhysicsObject()
						if IsValid(phys) then
							phys:EnableMotion(false)
						end
					end
					MsgN("[MG] Froze all props due to server lag.")
					counter = 0
				end
			end
			tick = RealTime()
		end)
	end)
end

print("MG: AntiCrash initialised")