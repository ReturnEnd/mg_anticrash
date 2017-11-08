-- Dont edit this file without knowing what you are doing!

hook.Add("PhysgunPickup", "MG_BlockPhysgun", function(ply, ent)
	if hook.Run("MG_CanPhysGun", ply, ent) == false then return end
	if ent:GetNW2Bool("MG_P_Blocked") or (SERVER and ent:CreatedByMap()) then
		return false
	end
end)

hook.Add("CanTool", "MG_BlockToolgun", function(ply, tr, tool)
	if hook.Run("MG_CanTool", ply, tr, tool) == false then return end
	local ent = tr.Entity
	if IsValid(ent) and (MG.AllowedTools[tool] != true and ent:GetNW2Bool("MG_T_Blocked") or (ent:GetNW2Bool("MG_T_Blocked_P")) or SERVER and ent:CreatedByMap()) then
		return false
	end
end)

print("MG: AntiCrash shared initialised")