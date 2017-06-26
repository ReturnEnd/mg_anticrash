-- Dont edit this file without knowing what you are doing!

hook.Add("PhysgunPickup", "MG_BlockPhysgun", function(ply, ent)
	if hook.Run("MG_CanPhysGun", ply, ent) == false then return end
	if ent:GetNWBool("MG_P_Blocked") or (SERVER and ent:CreatedByMap()) then
		return false
	end
end)

hook.Add("CanTool", "MG_BlockToolgun", function(ply, tr, tool)
	if hook.Run("MG_CanTool", ply, tr, tool) == false then return end
	if IsValid(tr.Entity) and (MG.AllowedTools[tool] != true and tr.Entity:GetNWBool("MG_T_Blocked") or (tr.Entity:GetNWBool("MG_T_Blocked_P")) or SERVER and tr.Entity:CreatedByMap()) then
		return false
	end
end)

print("MG: AntiCrash shared initialised")

print("MG: AntiCrash shared initialised")