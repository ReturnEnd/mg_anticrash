-- Dont edit this file without knowing what you are doing!

if MG.UseNWBools and (!MG.PhysgunWorld or !MG.ToolgunWorld) then
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

function MG.EnableProtectionMode(ent)
	if hook.Run("AntiCrash_ShouldEnableProtectionMode", ent) == false then return end
	if MG.BlockToolsOnGhostEntities then
		ent:SetNWBool("MG_T_Blocked", true)
	end
	ent.MG_RenderMode = ent:GetRenderMode()
	ent:SetRenderMode(RENDERMODE_TRANSALPHA)
	local color = ent:GetColor()
	ent.MG_Color = color
	ent:SetColor(Color(color.r,color.g,color.b,200))
	ent.MG_CollisionGroup = ent:GetCollisionGroup()
	if MG.EnablePropCollide then
		ent:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	else
		ent:SetCollisionGroup(COLLISION_GROUP_WORLD)
	end
	ent:DrawShadow(false)
	ent:CollisionRulesChanged()
end

function MG.DisableProtectionMode(ent)
	if hook.Run("AntiCrash_ShouldDisableProtectionMode", ent) == false then return end
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
	if MG.AllowWeldWorkaround then
		hook.Add("CanTool", "AntiCrash_WeldWorkaround", function(ply, tr, tool)
			if IsValid(tr.Entity) and (tool == "weld" or tool == "precision") then
				local ent = tr.Entity
				if FPP and FPP.canTouchEnt and !FPP.canTouchEnt(trace.Entity, "Toolgun") then return end
				timer.Simple(0, function()
					if !IsValid(ent) then return end
					local phys = ent:GetPhysicsObject()
					if IsValid(phys) and phys:IsMotionEnabled() then
						phys:EnableMotion(false)
					end
				end)
			end
		end)
	end

	if MG.AllowCollideWorkaround then
		hook.Add("CanProperty", "AntiCrash_CollideWorkaround", function(ply, prop, ent)
			if ent.MG_Protected and prop == "collision" then
				return false
			end
		end)
	end

	function MG.CheckForStuckingPlayers(ent)
		if hook.Run("AntiCrash_ShouldCheckForStuckingPlayers", ent) == false then return false end
		local mins, maxs, check = ent:OBBMins(), ent:OBBMaxs()
		local tr = {start = ent:LocalToWorld(mins), endpos = ent:LocalToWorld(maxs), filter = ent}
		local trace1 = util.TraceLine(tr)
		check = IsValid(trace1.Entity) and (trace1.Entity:IsPlayer() and trace1.Entity:Alive() or (MG.DisableFreezeInVehicles and trace1.Entity:IsVehicle())) or false
		if check then return check end
		tr = {start = ent:GetPos(), endpos = ent:GetPos(), filter = ent, mins = ent:OBBMins(), maxs = ent:OBBMaxs()}
		trace2 = util.TraceHull(tr)
		check = IsValid(trace2.Entity) and (trace2.Entity:IsPlayer() and trace2.Entity:Alive() or (MG.DisableFreezeInVehicles and trace2.Entity:IsVehicle())) or false
		if check then return check end
		return false
	end

	function MG.GhostEntity(ent)
		if hook.Run("AntiCrash_ShouldGhostEntity", ent) == false then return end
		if FPP and FPP.UnGhost then
			FPP.UnGhost(ply, ent)
		end
		local phys = ent:GetPhysicsObject()
		if IsValid(phys) then
			if (phys:IsMotionEnabled() or MG.CheckForStuckingPlayers(ent) == true) then
				ent.MG_Protected = true
				MG.EnableProtectionMode(ent)
			end
		end
	end

	function MG.CheckForClass(ent)
		if !MG.GhostAllEntities then
			if (ent:GetClass() == "prop_physics" or ent:GetClass() == "prop_physics_multiplayer") then
				return true
			else
				return false
			end
		end
		if (!MG.UseWhitelist and MG.MingeEntities[string.lower(ent:GetClass())] == true) then
			return true
		elseif (MG.UseWhitelist and MG.MingeEntities[string.lower(ent:GetClass())] != true) then
			return true
		end
		return false
	end

	hook.Add("OnEntityCreated", "AntiCrash_EnableProtectionMode", function(ent)
		if (MG.CheckForClass(ent) == false) then return end
		timer.Simple(0, function()
			if !IsValid(ent) then return end
			MG.GhostEntity(ent)
		end)
	end)

	hook.Add("PhysgunPickup", "AntiCrash_EnableProtectionMode", function(ply, ent)
		if (MG.CheckForClass(ent) == false) or ent.MG_Protected then return end
		if ent.CPPICanPhysgun and !ent:CPPICanPhysgun(ply) then return end
		if !MG.PhysgunWorld and ent:CreatedByMap() then return end
		ent.MG_Protected = true
		MG.EnableProtectionMode(ent)
	end)

	hook.Add("OnPhysgunFreeze", "AntiCrash_DisableProtectionMode", function(weapon, phys, ent, ply)
		if (MG.CheckForClass(ent) == false) or !ent.MG_Protected then return end
		if (MG.CheckForStuckingPlayers(ent) == true) then
			local message = MG.LanguageStrings[2]
			if MG.DarkRPNotifications then
				DarkRP.notify(ply, 1, 5, message)
			else
				ply:ChatPrint(message)
			end
			return false
		end
		ent.MG_Protected = nil
		MG.DisableProtectionMode(ent)
	end)

	hook.Add("PlayerUnfrozeObject", "AntiCrash_DisableProtectionMode", function(ply, ent)
		if (MG.CheckForClass(ent) == false) or ent.MG_Protected then return end
		ent.MG_Protected = true
		MG.EnableProtectionMode(ent)
	end)
end

if MG.FreezeSpecificEntities then
	hook.Add("PhysgunPickup", "AntiCrash_PickUpCheck", function(ply, ent)
		if ent.CPPICanPhysgun and !ent:CPPICanPhysgun(ply) then return end
		if !MG.PhysgunWorld and ent:CreatedByMap() then return end
		ent.MG_PickedUp = (ent.MG_PickedUp and ent.MG_PickedUp + 1) or 1
	end)

	local function ResetPickupStatus(ent)
		if ent.MG_PickedUp then
			ent.MG_PickedUp = ent.MG_PickedUp - 1
			if ent.MG_PickedUp <= 0 then
				ent.MG_PickedUp = nil
			end
		end
	end

	hook.Add("PhysgunDrop", "AntiCrash_PickUpCheck", function(ply, ent)
		ResetPickupStatus(ent)
	end)

	hook.Add("OnPhysgunFreeze", "AntiCrash_PickUpCheck", function(weapon, phys, ent)
		ResetPickupStatus(ent)
	end)

	hook.Add("GravGunOnPickedUp", "AntiCrash_PickUpCheck", function(ply, ent)
		ResetPickupStatus(ent)
	end)

	hook.Add("GravGunOnDropped", "AntiCrash_PickUpCheck", function(ply, ent)
		ResetPickupStatus(ent)
	end)
end

if MG.DisableVehicleCollision then
	hook.Add("OnEntityCreated", "AntiCrash_SetVehicleCollision", function(ent)
		if hook.Run("AntiCrash_ShouldEnableVehicleCollision", ent) == false then return end
		timer.Simple(0, function()
			if !IsValid(ent) then return end
			if ent:IsVehicle() then
				ent:SetCollisionGroup(COLLISION_GROUP_WEAPON)
			end
		end)
	end)
end

if MG.DisableSpecificEntityDamage or MG.DisableVehicleDamage then
	hook.Add("EntityTakeDamage", "AntiCrash_DisableEntityDamage", function(target, dmg)
		local ent = dmg:GetInflictor()
		local attacker = dmg:GetAttacker()
		if !IsValid(ent) or !IsValid(attacker) then return end
		if hook.Run("AntiCrash_ShouldApplyVehicleDamage", target, dmg, ent, attacker) == false then return end
		if (MG.DisableVehicleDamage and ent:IsVehicle() or attacker:IsVehicle()) or (MG.DisableSpecificEntityDamage and MG.EntityDamageBlockList[string.lower(ent:GetClass())] == true) then
			dmg:SetDamage(0)
			dmg:ScaleDamage(0)
			return true
		end
	end)
end

if MG.BlockBigSizeProps_FPP then
	function MG.AntiCrash_FixModel(model)
		local model = model or ""
		model = tostring(string.lower(model))
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
				if hook.Run("AntiCrash_ShouldAddToBlacklist", ply, mdl, ent) == false then return end
				mdl = MG.AntiCrash_FixModel(mdl)
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

function MG.FreezeEntities(force)
	for _,v in pairs(ents.GetAll()) do
		if (MG.EntityFreezeList[string.lower(v:GetClass())] != true) then continue end
		if !force and v.MG_PickedUp then continue end
		if MG.EnableAntiPropminge and v.MG_Protected then
			v.MG_Protected = nil
			MG.DisableProtectionMode(v)
		end
		local phys = v:GetPhysicsObject()
		if IsValid(phys) then
			phys:EnableMotion(false)
		end
	end
	hook.Run("AntiCrash_FreezeAllMapEntities")
end

if MG.EnableFreezeCommand then
	concommand.Add("ac_freeze", function(ply, cmd, args)
		if ply:IsAdmin() then
			MG.FreezeEntities(true)
		end
	end)
end

if MG.FreezeAllMapEntities then
	timer.Create("AntiCrash_FreezeAllMapEntities", 1, 1, function()
		MG.FreezeEntities(false)
		MsgN("[MG] Froze all map props.")
	end)
end

if MG.FreezeSpecificEntities then
	timer.Create("AntiCrash_FreezeProps", MG.FreezeSpecificEntitiesTimer, 0, function()
		MG.FreezeEntities(false)
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
					MG.FreezeEntities(true)
					MsgN("[MG] Froze all props due to server lag.")
					counter = 0
				end
			end
			tick = RealTime()
		end)
	end)
end

print("MG: AntiCrash serverside initialised")