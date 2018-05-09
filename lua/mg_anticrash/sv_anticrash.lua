-- Dont edit this file without knowing what you are doing!

if MG.UseNWBools and (!MG.PhysgunWorld or !MG.ToolgunWorld) then
	hook.Add("OnEntityCreated", "MG_BlockWorldEntities", function(ent)
		if !ent:CreatedByMap() then return end
		timer.Simple(0, function()
			if !IsValid(ent) then return end
			if !MG.PhysgunWorld then ent:SetNW2Bool("MG_P_Blocked", true) end
			if !MG.ToolgunWorld then ent:SetNW2Bool("MG_T_Blocked_P", true) end
		end)
	end)
end

if !MG.PropertyWorld then
	hook.Add("CanProperty", "MG_BlockPropertyOnWorld", function(ent)
		if ent:CreatedByMap() then
			return false
		end
	end)
end

if !MG.AllowPhysgunReload then
	hook.Add("OnPhysgunReload", "MG_DisablePhysgunReload", function()
		return false
	end)
end

function MG.Notify(ply, typ, length, msg)
	if hook.Run("MG_Notify", ply, typ, length, msg, MG.DarkRPNotifications) == false then return end
	if MG.DarkRPNotifications and DarkRP then
		DarkRP.notify(ply, typ or 0, length or 5, msg)
	else
		ply:ChatPrint(msg)
	end
end

function MG.CheckForClass(ent)
	local class = ent:GetClass()
	local override_checking = hook.Run("MG_CheckForClass", ent, class)
	if isbool(override_checking) then return override_checking end
	if MG.GhostAllEntities then
		if class == "prop_physics" or class == "prop_physics_multiplayer" then
			return true
		end
	else
		if (!MG.UseWhitelist and MG.MingeEntities[class] == true) or (MG.UseWhitelist and MG.MingeEntities[class] != true) then
			return true
		end
	end
	return false
end

function MG.CanPhysgun(ply, ent)
	local override_canphysgun = hook.Run("MG_CanPhysgun", ply, ent)
	if isbool(override_canphysgun) then return override_canphysgun end
	if ent.MG_EnableProtection then return true end
	if ent.MG_DisableProtection then return false end
	if MG.CheckForClass(ent) == false then return false end
	local override_entity = ent.PhysgunPickup
	if isfunction(override_entity) then return override_entity(ent, ply, ent) end
	if ent.CPPICanPhysgun and !ent:CPPICanPhysgun(ply) then return false end
	return true
end

function MG.CanFreeze(ply, ent)
	local override_canfreeze = hook.Run("MG_CanFreeze", ply, ent)
	if isbool(override_canfreeze) then return override_canfreeze end
	if ent.MG_EnableProtection then return true end
	if ent.MG_DisableProtection then return false end
	if MG.CheckForClass(ent) == false then return false end
	if !ent.MG_Protected then return false end
	return true
end

function MG.CanUnfreeze(ply, ent)
	local override_canunfreeze = hook.Run("MG_CanUnfreeze", ply, ent)
	if isbool(override_canunfreeze) then return override_canunfreeze end
	if MG.CheckForClass(ent) == false or ent.MG_Protected then return false end
	return true
end

function MG.IsTouchingEntity(ent, ent2, mask)
	local pos = ent2:GetPos()
	local trace = {start = pos, endpos = pos, filter = ent2, mask = mask or MASK_SOLID}
	local tr = util.TraceEntity(trace, ent2)
	local override_touchentity = hook.Run("MG_CanTouchEntity", ent, ent2, pos, tr, trace)
	if isbool(override_touchentity) then return override_touchentity end
	if tr.Entity == ent then
		return true
	end
	return false
end

function MG.CheckForStuckingPlayers(ent)
	local override_stucking = hook.Run("MG_CheckForStuckingPlayers", ent)
	if isbool(override_stucking) then return override_stucking end
	local center, radius, forbidden = ent:LocalToWorld(ent:OBBCenter()), ent:BoundingRadius(), false
	for _,v in ipairs(ents.FindInSphere(center, radius)) do
		if v:IsPlayer() and v:Alive() or (MG.DisableFreezeInsideVehicles and v:IsVehicle()) then
			if MG.IsTouchingEntity(ent, v) then
				forbidden = true
			end
		end
		if forbidden then break end
	end
	return forbidden
end

if MG.CheckForStuckingProps then
	function MG.CheckForProps(ply, ent)
		local cnt = 0
		local center, radius = ent:LocalToWorld(ent:OBBCenter()), ent:BoundingRadius()
		for _,v in ipairs(ents.FindInSphere(center, radius)) do
			if v == ent or MG.CheckForClass(ent) == false or v.MG_Protected or (v.CPPIGetOwner and v:CPPIGetOwner() != ply) then continue end
			if MG.IsTouchingEntity(ent, v) then
				cnt = cnt + 1
			end
		end
		if cnt >= MG.MaxStuckingProps then
			if MG.RemoveStuckingProps then
				ent:Remove()
			else
				local phys = ent:GetPhysicsObject()
				if IsValid(phys) then
					phys:SetMotionEnabled(false)
				end
			end
			if MG.WarnPlayer and ply then
				MG.Notify(ply, 1, 5, MG.LanguageStrings[3])
			end
		end
	end

	hook.Add(!MG.EnableAntiPropMinge and "OnEntityCreated" or "MG_OnEntityCreated", "MG_CheckForStuckingProps", function(ent)
		timer.Simple(0, function()
			if !IsValid(ent) then return end
			MG.CheckForProps(ent.CPPIGetOwner and ent:CPPIGetOwner() or NULL, ent)
		end)
	end)

	hook.Add("PhysgunPickup", "MG_CheckForStuckingProps", function(ply, ent)
		if MG.CanPhysgun(ply, ent) == false then return end
		MG.CheckForProps(ply, ent)
	end)

	hook.Add("PlayerUnfrozeObject", "MG_CheckForStuckingProps", function(ply, ent)
		if !MG.CanUnfreeze(ply, ent) then return end
		MG.CheckForProps(ply, ent)
	end)
end

function MG.EnableProtectionMode(ent)
	if hook.Run("MG_ShouldEnableProtectionMode", ent) == false then return end
	if ent:GetNW2Bool("MG_Disabled") then return end
	if MG.BlockToolsOnGhostEntities then
		ent:SetNW2Bool("MG_T_Blocked", true)
	end
	ent.MG_RenderMode = ent:GetRenderMode()
	ent:SetRenderMode(RENDERMODE_TRANSALPHA)
	local color = ent:GetColor()
	ent.MG_Color = color
	ent:SetColor(Color(color.r, color.g, color.b, 200))
	ent.MG_CollisionGroup = ent:GetCollisionGroup()
	ent:SetCollisionGroup(MG.CollideWithEntities and COLLISION_GROUP_DEBRIS_TRIGGER or COLLISION_GROUP_WORLD)
	ent:DrawShadow(false)
	hook.Run("MG_OnEnableProtectionMode", ent)
end

function MG.DisableProtectionMode(ent)
	if hook.Run("MG_ShouldDisableProtectionMode", ent) == false then return end
	if MG.BlockToolsOnGhostEntities then
		ent:SetNW2Bool("MG_T_Blocked", false)
	end
	ent:SetRenderMode(ent.MG_RenderMode or RENDERMODE_NORMAL)
	ent:SetColor(ent.MG_Color or Color(255, 255, 255, 255))
	ent:SetCollisionGroup(ent.MG_CollisionGroup or COLLISION_GROUP_NONE)
	ent:DrawShadow(true)
	hook.Run("MG_OnDisableProtectionMode", ent)
end

if MG.EnableAntiPropMinge then
	if MG.AllowWeldWorkaround then
		hook.Add("CanTool", "MG_WeldWorkaround", function(ply, tr, tool)
			local ent = tr.Entity
			if IsValid(ent) and (tool == "weld" or tool == "precision") then
				if FPP and FPP.plyCanTouchEnt and !FPP.plyCanTouchEnt(ply, ent, "Toolgun") then return false end
				if MG.CheckForClass(ent) == false then return end
				timer.Simple(0, function()
					if !IsValid(ent) then return end
					if MG.CheckForStuckingPlayers(ent) and !ent.MG_Protected then
						ent.MG_Protected = true
						MG.EnableProtectionMode(ent)
					end
					local phys = ent:GetPhysicsObject()
					if IsValid(phys) then
						phys:EnableMotion(false)
					end
				end)
			end
		end)
	end

	if MG.AllowCollideWorkaround then
		hook.Add("CanTool", "MG_CollideWorkaround", function(ply, tr, tool)
			local ent = tr.Entity
			if IsValid(ent) then
				if ent.MG_Protected and tool == "nocollide" then
					return false
				end
			end
		end)

		hook.Add("CanProperty", "MG_CollideWorkaround", function(ply, prop, ent)
			if ent.MG_Protected and prop == "collision" then
				return false
			end
		end)
	end

	function MG.GhostEntity(ent)
		if hook.Run("MG_GhostEntity", ent) == false then return end
		if FPP and FPP.UnGhost then
			FPP.UnGhost(ply, ent)
		end
		local phys = ent:GetPhysicsObject()
		if IsValid(phys) then
			if (phys:IsMotionEnabled() or MG.CheckForStuckingPlayers(ent)) then
				ent.MG_Protected = true
				MG.EnableProtectionMode(ent)
			end
		end
	end

	local function DoGhostEntity(ent)
		if MG.CheckForClass(ent) == false then return end
		timer.Simple(0, function()
			if !IsValid(ent) then return end
			MG.GhostEntity(ent)
			hook.Run("MG_OnEntityCreated", ent)
		end)
	end

	if MG.OnlyGhostPropsOnSpawn then
		hook.Add("PlayerSpawnedProp", "MG_EnableProtectionMode", function(_, _, ent)
			DoGhostEntity(ent)
		end)
	else
		hook.Add("OnEntityCreated", "MG_EnableProtectionMode", function(ent)
			DoGhostEntity(ent)
		end)
	end

	hook.Add("PhysgunPickup", "MG_EnableProtectionMode", function(ply, ent)
		if MG.CanPhysgun(ply, ent) == false or ent.MG_Protected then return end
		ent.MG_Protected = true
		MG.EnableProtectionMode(ent)
	end)

	hook.Add("OnPhysgunFreeze", "MG_DisableProtectionMode", function(_, _, ent, ply)
		if !MG.CanFreeze(ply, ent) then return end
		if MG.CheckForStuckingPlayers(ent) then MG.Notify(ply, 1, 5, MG.LanguageStrings[1]) return end
		if ent.MG_Protected then
			ent.MG_Protected = nil
			MG.DisableProtectionMode(ent)
		end
	end)

	hook.Add("PlayerUnfrozeObject", "MG_DisableProtectionMode", function(ply, ent)
		if !MG.CanUnfreeze(ply, ent) then return end
		ent.MG_Protected = true
		MG.EnableProtectionMode(ent)
	end)
end

if MG.FreezeSpecificEntities then
	hook.Add("PhysgunPickup", "MG_PickUpCheck", function(ply, ent)
		if MG.CanPhysgun(ply, ent) == false then return end
		ent.MG_PickedUp = (ent.MG_PickedUp and ent.MG_PickedUp + 1) or 1
	end)

	local function ResetPickup(ent)
		if ent.MG_PickedUp then
			ent.MG_PickedUp = ent.MG_PickedUp - 1
			if ent.MG_PickedUp <= 0 then
				ent.MG_PickedUp = nil
			end
		end
	end

	hook.Add("PhysgunDrop", "MG_PickUpCheck", function(ply, ent)
		ResetPickup(ent)
	end)

	hook.Add("OnPhysgunFreeze", "MG_PickUpCheck", function(weapon, phys, ent)
		ResetPickup(ent)
	end)

	hook.Add("GravGunOnPickedUp", "MG_PickUpCheck", function(ply, ent)
		ResetPickup(ent)
	end)

	hook.Add("GravGunOnDropped", "MG_PickUpCheck", function(ply, ent)
		ResetPickup(ent)
	end)
end

if MG.DisableVehicleCollision then
	hook.Add("OnEntityCreated", "MG_SetVehicleCollision", function(ent)
		timer.Simple(0, function()
			if IsValid(ent) and ent:IsVehicle() then
				if hook.Run("MG_ShouldEnableVehicleCollision", ent) == false then return end
				ent:SetCollisionGroup(COLLISION_GROUP_PASSABLE_DOOR)
			end
		end)
	end)
end

if MG.DisableSpecificEntityDamage or MG.DisableVehicleDamage then
	hook.Add("EntityTakeDamage", "MG_DisableEntityDamage", function(target, dmg)
		local ent = dmg:GetInflictor()
		local attacker = dmg:GetAttacker()
		if !IsValid(ent) or !IsValid(attacker) then return end
		if hook.Run("MG_ShouldApplyVehicleDamage", target, dmg, ent, attacker) == false then return end
		if (MG.DisableVehicleDamage and (ent:IsVehicle() or attacker:IsVehicle() or dmg:GetDamageType() == DMG_VEHICLE)) or (MG.DisableSpecificEntityDamage and MG.EntityDamageBlockList[ent:GetClass()] == true) then
			dmg:SetDamage(0)
			dmg:ScaleDamage(0)
			return true
		end
	end)
end

if MG.BlockBigSizeProps_FPP then
	function MG.FixModel(mdl)
		local override_name = hook.Run("MG_FixModelName", mdl)
		if isstring(override_name) then return override_name end
		mdl = tostring(string.lower(mdl))
		mdl = string.Replace(mdl, "\\", "/")
		mdl = string.Replace(mdl, " ", "_")
		mdl = string.Replace(mdl, ";", "")
		mdl = string.gsub(mdl, "[\\/]+", "/")
		return mdl
	end

	function MG.AddToBlacklist(mdl)
		if (FPP and FPP.BlockedModels[mdl] != true) then
			FPP.BlockedModels[mdl] = true
		end
	end

	hook.Add("PlayerSpawnedProp", "MG_BlockBigSizeProps", function(ply, mdl, ent)
		local mdl = MG.FixModel(mdl)
		local phys = ent:GetPhysicsObject()
		if hook.Run("MG_AddToBlacklist", ply, mdl, ent) == false then return end
		if IsValid(phys) and phys:GetVolume() then
			if phys:GetVolume() > math.pow(10, 7) then
				MG.AddToBlacklist(mdl)
				SafeRemoveEntity(ent)
				if IsValid(ply) then
					MG.Notify(ply, 0, 8, MG.LanguageStrings[2])
				end
			end
		end
	end)
end

function MG.FreezeEntities(force)
	if hook.Run("MG_FreezeAllMapEntities", force) == false then return end
	for k, v in ipairs(ents.GetAll()) do
		if !force and v.MG_PickedUp then continue end
		local phys = v:GetPhysicsObject()
		if !IsValid(phys) then continue end
		local phys_penetrating = MG.FreezePenetratingProps and phys:IsPenetrating()
		if (MG.EntityFreezeList[v:GetClass()] != true and !phys_penetrating) then continue end
		if hook.Run("MG_CanFreezeEntity", v, k, force) == false then return end
		if v.MG_Protected then
			if (!force and MG.CheckForStuckingPlayers(v)) then continue end
			v.MG_Protected = nil
			MG.DisableProtectionMode(v)
		end
		if v:GetNW2Bool("MG_Disabled") then continue end
		phys:EnableMotion(false)
	end
end

if MG.EnableFreezeCommand then
	concommand.Add("mg_freeze", function(ply, cmd, args)
		if hook.Run("MG_CanForceFreeze", ply, cmd, args) == false then return end
		if MG.FreezeGroups[ply:GetUserGroup()] == true then
			MG.FreezeEntities(true)
		end
	end)
end

if MG.FreezeAllMapEntities then
	timer.Create("MG_FreezeAllMapEntities", 1, 1, function()
		MG.FreezeEntities(false)
		MsgN("[MG] Froze all map props.")
	end)
end

if MG.FreezeSpecificEntities then
	timer.Create("MG_FreezeProps", MG.FreezeSpecificEntitiesTimer, 0, function()
		MG.FreezeEntities(false)
		MsgN("[MG] Froze specific entities.")
	end)
end

if MG.FreezeAllPropsOnServerLag then
	local tickrate = 1 / engine.TickInterval()
	local tick = RealTime()
	local counter = 0
	local delay = 0

	hook.Add("Tick", "MG_FreezeAll", function()
		local real_time = RealTime()
		local rate = 1 / (real_time - tick)
		if rate < tickrate / MG.Sensitivity then
			counter = counter + 1
			if counter >= MG.MaxLongs and delay < CurTime() then
				delay = CurTime() + MG.FreezeDelay
				counter = 0
				if hook.Run("MG_ShouldFreezeAllEntitiesOnServerLag") == false then return end
				MG.FreezeEntities(true)
				MsgN("[MG] Froze all props due to server lag.")
			end
		end
		tick = real_time
	end)
end

print("MG: AntiCrash serverside initialised")