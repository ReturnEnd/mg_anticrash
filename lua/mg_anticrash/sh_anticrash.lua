-- Dont edit this file without knowing what you are doing!

hook.Add("PhysgunPickup", "AntiCrash_BlockPhysgun", function(ply, ent)
	if (MG.UseNWBools and ent:GetNWBool("MG_P_Blocked")) or (SERVER and ent:CreatedByMap()) then
		return false
	end
end)

hook.Add("CanTool", "AntiCrash_BlockToolgun", function(ply, tr, tool)
	if IsValid(tr.Entity) and (tr.Entity:GetNWBool("MG_T_Blocked_S") or ((MG.UseNWBools and tr.Entity:GetNWBool("MG_T_Blocked") and !table.HasValue(MG.AllowedTools, tool)) or SERVER and tr.Entity:CreatedByMap())) then
		return false
	end
end)

print("MG: AntiCrash shared initialised")