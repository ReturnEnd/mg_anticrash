-- Dont edit this file without knowing what you are doing!

if !MG.PhysgunWorld or !MG.ToolgunWorld then
	hook.Add("OnEntityCreated", "AntiCrash_BlockWorldEntities", function(ent)
		timer.Simple(0, function()
			if !IsValid(ent) then return end
			if ent:CreatedByMap() then
				if !MG.PhysgunWorld then
					ent:SetNWBool("MG_P_Blocked", true)
				end
				if !MG.ToolgunWorld then
					ent:SetNWBool("MG_T_Blocked_S", true)
				end
			end
		end)
	end)
end

if !MG.PropertyWorld then
	hook.Add("CanProperty", "AntiCrash_BlockPropertyOnWorld", function(ply, property, ent)
		if ent:CreatedByMap() then
			return false
		end
	end)
end

if !MG.AllowPhysgunReload then
	hook.Add("OnPhysgunReload", "AntiCrash_DisablePhysgunUnfreeze", function(g, ply)
		return false
	end)
end

local function EnableProtectionMode(ent)
	if MG.BlockToolsOnGhostEntities then
		ent:SetNWBool("MG_T_Blocked", true)
	end
	ent.MG_RenderMode = ent:GetRenderMode()
	ent:SetRenderMode(RENDERMODE_TRANSALPHA)
	local color = ent:GetColor()
	ent.MG_Color = color
	ent:SetColor(Color(color.r,color.g,color.b,200))
	ent.MG_CollisionGroup = ent:GetCollisionGroup()
	ent:SetCollisionGroup(COLLISION_GROUP_WORLD)
	ent:DrawShadow(false)
	ent:CollisionRulesChanged()
end

local function DisableProtectionMode(ent)
	if MG.BlockToolsOnGhostEntities then
		ent:SetNWBool("MG_T_Blocked", false)
	end
	ent:SetRenderMode(ent.MG_RenderMode or RENDERMODE_NORMAL)
	ent:SetColor(ent.MG_Color or Color(255,255,255,255))
	ent:SetCollisionGroup(ent.MG_CollisionGroup or COLLISION_GROUP_NONE)
	ent:DrawShadow(true)
	ent:CollisionRulesChanged()
end

if MG.EnableAntiPropminge then
	hook.Add("CanTool", "AntiCrash_WeldWorkaround", function(ply, tr, tool)
		if IsValid(tr.Entity) and tool == "weld" then
			local ent = tr.Entity
			if FPP.canTouchEnt and !FPP.canTouchEnt(trace.Entity, "Toolgun") then return end
			timer.Simple(0, function()
				if IsValid(ent) then
					local phys = ent:GetPhysicsObject()
					if IsValid(phys) and phys:IsMotionEnabled() then
						phys:EnableMotion(false)
					end
				end
			end)
		end
	end)

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
		if ent.CPPICanPhysgun and !ent:CPPICanPhysgun(ply) then return end
		if !MG.PhysgunWorld and ent:CreatedByMap() then return end
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
		if ent:GetClass() != "prop_physics" or !ent.protected then return end
		if CheckForStuckingPlayers(ent) == true then
			local message = MG.LanguageStrings[2]
			if MG.DarkRPNotifications then
				DarkRP.notify(ply, 1, 5, message)
			else
				ply:ChatPrint(message)
			end
			return false
		end
		ent.protected = nil
		DisableProtectionMode(ent)
	end)

	hook.Add("PlayerUnfrozeObject", "AntiCrash_DisableProtectionMode", function(ply, ent)
		if ent:GetClass() != "prop_physics" or ent.protected then return end
		ent.protected = true
		EnableProtectionMode(ent)
	end)
end

if MG.FreezeSpecificEntities then
	hook.Add("PhysgunPickup", "AntiCrash_PickUpCheck", function(ply, ent)
		if ent.CPPICanPhysgun and !ent:CPPICanPhysgun(ply) then return end
		if !MG.PhysgunWorld and ent:CreatedByMap() then return end
		ent.picked = true
	end)

	hook.Add("PhysgunDrop", "AntiCrash_PickUpCheck", function(ply, ent)
		ent.picked = nil
	end)

	hook.Add("OnPhysgunFreeze", "AntiCrash_PickUpCheck", function(weapon, physobj, ent)
		ent.picked = nil
	end)

	hook.Add("GravGunOnPickedUp", "AntiCrash_PickUpCheck", function(ply, ent)
		ent.picked = true
	end)

	hook.Add("GravGunOnDropped", "AntiCrash_PickUpCheck", function(ply, ent)
		ent.picked = nil
	end)
end

if MG.DisableSpecificEntityDamage or MG.DisableVehicleDamage then
	hook.Add("EntityTakeDamage", "AntiCrash_DisableEntityKilling", function(target, dmg)
		if dmg:GetDamageType() == DMG_CRUSH then
			local ent = dmg:GetInflictor()
			if !IsValid(ent) then return end
			if (MG.DisableVehicleDamage and ent:IsVehicle()) or (MG.DisableSpecificEntityDamage and table.HasValue(MG.EntityDamageBlockList, ent:GetClass())) then
				dmg:SetDamage(0)
				dmg:ScaleDamage(0)
				return true
			end
		end
	end)
end

if MG.BlockBigSizeProps_FPP then
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
					local message = MG.LanguageStrings[3]
					if MG.DarkRPNotifications then
						DarkRP.notify(ply, 0, 8, message)
					else
						ply:ChatPrint(message)
					end
				end
			end
		end
	end)
end

if MG.FreezeSpecificEntitiesAfterSpawn then
	hook.Add("OnEntityCreated", "AntiCrash_FreezeSpecificEntities", function(ent)
		if !table.HasValue(MG.EntitySpawnFreezeList, ent:GetClass()) then return end
		timer.Simple(0, function()
			if !IsValid(ent) then return end
			local phys = ent:GetPhysicsObject()
			if IsValid(phys) then
				phys:EnableMotion(false)
			end
			if MG.DisableUnfreeze then
				ent.MG_DisableUnfreeze = true
				ent:SetNWBool("MG_P_Blocked", true)
			end
		end)
	end)
	
	if MG.DisableUnfreeze then
		hook.Add("CanPlayerUnfreeze", "AntiCrash_DisableUnfreeze", function(ply, ent)
			if ent.MG_DisableUnfreeze then
				return false
			end
		end)
	end
end

local function AntiCrash_FreezeSpecificEntities(force)
	for _,s in pairs(MG.EntityFreezeList) do
		for _,v in pairs(ents.FindByClass(s)) do
			if !force and v.picked then continue end
			if MG.EnableAntiPropminge and v.protected then
				v.protected = nil
				DisableProtectionMode(v)
			end
			local phys = v:GetPhysicsObject()
			if IsValid(phys) then
				phys:EnableMotion(false)
			end
		end
	end
end

if MG.FreezeAllMapEntities then
	timer.Create("AntiCrash_FreezeAllMapEntities", 1, 1, function()
		AntiCrash_FreezeSpecificEntities(false)
		MsgN("[MG] Froze all map props.")
	end)
end

if MG.FreezeSpecificEntities then
	timer.Create("AntiCrash_FreezeProps", MG.FreezeSpecificEntitiesTimer, 0, function()
		AntiCrash_FreezeSpecificEntities(false)
		MsgN("[MG] Froze specific entities.")
	end)
end

if MG.FreezeAllPropsOnServerLag then
	timer.Simple(10, function()
		local tickrate = 1/engine.TickInterval()
		local tick = RealTime()
		local counter = 0

		hook.Add("Think", "AntiCrash_FreezeAll", function()
			local rate = 1 / (RealTime() - tick)
			if rate < tickrate / MG.Sensitivity then
				counter = counter + 1
				if counter >= MG.MaxLongs then
					AntiCrash_FreezeSpecificEntities(true)
					MsgN("[MG] Froze all props due to server lag.")
					counter = 0
				end
			end
			tick = RealTime()
		end)
	end)
end

print("MG: AntiCrash serverside initialised")