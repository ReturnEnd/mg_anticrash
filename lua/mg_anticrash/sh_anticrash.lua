-- Dont edit this file without knowing what you are doing!

hook.Add("PhysgunPickup", "MG_BlockPhysgun", function(ply, ent)
	local can_tool = hook.Run("MG_CanPhysgunWorld", ply, ent)
	if isbool(can_tool) then
		return can_tool
	end
	if !MG.AllowPhysgunOnWorld and (ent:GetNW2Bool("MG_P_Blocked") or SERVER and ent:CreatedByMap()) then
		return false
	end
end)

hook.Add("CanTool", "MG_BlockToolgun", function(ply, tr, tool)
	local can_tool = hook.Run("MG_CanTool", ply, tr, tool)
	if isbool(can_tool) then
		return can_tool
	end
	local ent = tr.Entity
	if IsValid(ent) and (MG.AllowedTools[tool] != true and ent:GetNW2Bool("MG_T_Blocked") or (!MG.AllowToolgunOnWorld and (ent:GetNW2Bool("MG_T_Blocked_P") or SERVER and ent:CreatedByMap()))) then
		return false
	end
end)

if MG.EnableAntiPropMinge and MG.EnableGhostingCommands then
	properties.Add("MG_UnghostProp", {
		MenuLabel = MG.LanguageStrings[6],
		Order = 10000,
		MenuIcon = "icon16/shield_delete.png",
		Filter = function(self, ent, ply)
			if !IsValid(ent) or MG.ProtectGroups[ply:GetUserGroup()] != true then return false end
			local class = ent:GetClass()
			if ent:GetNW2Bool("MG_Disabled") then return false end
			if !MG.GhostAllEntities and class != "prop_physics" and class != "prop_physics_multiplayer" then return false end
			if MG.UseWhitelist and MG.MingeEntities[class] == true then return false end
			if !MG.UseWhitelist and MG.MingeEntities[class] != true then return false end
			return true
		end,
		Action = function(self, ent)
			self:MsgStart()
				net.WriteEntity(ent)
			self:MsgEnd()
		end,
		Receive = function(self, length, player)
			local ent = net.ReadEntity()
			if !IsValid(ent) or MG.ProtectGroups[player:GetUserGroup()] != true then return false end
			local class = ent:GetClass()
			if ent:GetNW2Bool("MG_Disabled") then return false end
			if !MG.GhostAllEntities and class != "prop_physics" and class != "prop_physics_multiplayer" then return false end
			if MG.UseWhitelist and MG.MingeEntities[class] == true then return false end
			if !MG.UseWhitelist and MG.MingeEntities[class] != true then return false end
			ent:SetNW2Bool("MG_Disabled", true)
			if ent.MG_Protected then
				ent.MG_Protected = false
				MG.DisableProtectionMode(ent)
			end
			MG.Notify(player, 0, 4, MG.LanguageStrings[4])
		end
	})

	properties.Add("MG_GhostProp", {
		MenuLabel = MG.LanguageStrings[7],
		Order = 10000,
		MenuIcon = "icon16/shield.png",
		Filter = function(self, ent, ply)
			if !IsValid(ent) or MG.ProtectGroups[ply:GetUserGroup()] != true then return false end
			if !ent:GetNW2Bool("MG_Disabled") then return false end
			local class = ent:GetClass()
			if !MG.GhostAllEntities and class != "prop_physics" and class != "prop_physics_multiplayer" then return false end
			if MG.UseWhitelist and MG.MingeEntities[class] == true then return false end
			if !MG.UseWhitelist and MG.MingeEntities[class] != true then return false end
			return true
		end,
		Action = function(self, ent)
			self:MsgStart()
				net.WriteEntity(ent)
			self:MsgEnd()
		end,
		Receive = function(self, length, player)
			local ent = net.ReadEntity()
			if !IsValid(ent) or MG.ProtectGroups[player:GetUserGroup()] != true then return false end
			if !ent:GetNW2Bool("MG_Disabled") then return false end
			local class = ent:GetClass()
			if !MG.GhostAllEntities and class != "prop_physics" and class != "prop_physics_multiplayer" then return false end
			if MG.UseWhitelist and MG.MingeEntities[class] == true then return false end
			if !MG.UseWhitelist and MG.MingeEntities[class] != true then return false end
			ent:SetNW2Bool("MG_Disabled", false)
			if MG.CheckForStuckingPlayers(ent) and !ent.MG_Protected then
				ent.MG_Protected = true
				MG.EnableProtectionMode(ent)
			else
				ent.MG_Protected = false
			end
			local phys = ent:GetPhysicsObject()
			if IsValid(phys) then
				phys:EnableMotion(false)
			end
			MG.Notify(player, 0, 4, MG.LanguageStrings[5])
		end
	})
end

print("MG: AntiCrash shared initialised")
