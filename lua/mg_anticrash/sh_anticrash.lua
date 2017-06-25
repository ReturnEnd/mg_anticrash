-- Dont edit this file without knowing what you are doing!

hook.Add("PhysgunPickup", "MG_BlockPhysgun", function(ply, ent)
	local override_canphys = hook.Run("MG_CanPhysGun", ply, ent)
	if isbool(override_canphys) then return override_canphys end
	if ent:GetNWBool("MG_P_Blocked") or (SERVER and ent:CreatedByMap()) then
		return false
	end
end)

hook.Add("CanTool", "MG_BlockToolgun", function(ply, tr, tool)
	local override_cantool = hook.Run("MG_CanTool", ply, tr, tool)
	if isbool(override_cantool) then return override_cantool end
	if IsValid(tr.Entity) and (MG.AllowedTools[tool] != true and tr.Entity:GetNWBool("MG_T_Blocked") or (tr.Entity:GetNWBool("MG_T_Blocked_P")) or SERVER and tr.Entity:CreatedByMap()) then
		return false
	end
end)

print("MG: AntiCrash shared initialised")