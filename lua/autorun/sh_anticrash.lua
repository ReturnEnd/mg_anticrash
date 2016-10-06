hook.Add("CanTool", "AntiCrash_BlockToolgunOnGhostEntities", function(ply, tr, tool)
	if IsValid(tr.Entity) and !tr.Entity:GetNWBool("MG_Touchable") then
		return false
	end
end)