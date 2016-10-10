-- Dont edit this file without knowing what you are doing!

hook.Add("PhysgunPickup", "AntiCrash_BlockPhysgun", function(ply, ent)
	if ent:GetNWBool("MG_P_Blocked") then
		return false
	end
end)

hook.Add("CanTool", "AntiCrash_BlockToolgun", function(ply, tr, tool)
	if IsValid(tr.Entity) and tr.Entity:GetNWBool("MG_T_Blocked_S") or (tr.Entity:GetNWBool("MG_T_Blocked") and !table.HasValue(MG.AllowedTools, tool)) then
		return false
	end
end)

print("MG: AntiCrash shared initialised")