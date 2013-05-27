
local Resurrectable = Class(function(self, inst)
    self.inst = inst
end)

function Resurrectable:FindClosestResurrector()
	local res = nil
	local closest_dist = 0
	for k,v in pairs(Ents) do
		if v.components.resurrector and v.components.resurrector:CanBeUsed() then
			local dist = v:GetDistanceSqToInst(self.inst)
			if not res or dist < closest_dist then
				res = v
				closest_dist = dist
			end
		end
	end

	return res
end

function Resurrectable:CanResurrect()
	if self.inst.components.inventory then
		local item = self.inst.components.inventory:GetEquippedItem(EQUIPSLOTS.NECK)
		if item and item.prefab == "amulet" then
			return true
		end
	end

	local res = self:FindClosestResurrector()

	if res then
		return true
	end
end

function Resurrectable:DoResurrect()
    self.inst:PushEvent("resurrect")
	if self.inst.components.inventory then
		local item = self.inst.components.inventory:GetEquippedItem(EQUIPSLOTS.NECK)
		if item and item.prefab == "amulet" then
			self.inst.sg:GoToState("amulet_rebirth")
			return true
		end
	end
	
	local res = self:FindClosestResurrector()
	if res and res.components.resurrector then
		res.components.resurrector:Resurrect(self.inst)
		return true
	end
end

return Resurrectable
