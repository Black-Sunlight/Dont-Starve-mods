
local function PercentChanged(inst, data)
    if inst.components.weapon
       and not inst.components.tool
       and data.percent and data.percent <= 0
       and inst.components.inventoryitem and inst.components.inventoryitem.owner then
        inst.components.inventoryitem.owner:PushEvent("toolbroke", {tool = inst})
    end
end

AddComponentPostInit("weapon", function (inst)
	inst.inst:ListenForEvent("percentusedchange", PercentChanged)
end)

local function torchInit(inst)
	inst.components.fueled:SetSectionCallback( 
	function (section)
		if section == 0 then
            --when we burn out
            if inst.components.burnable then 
				inst.components.burnable:Extinguish() 
			end
				
            if inst.components.inventoryitem and inst.components.inventoryitem:IsHeld() then
                local owner = inst.components.inventoryitem.owner
                inst:Remove()
                    
                if owner then
                    owner:PushEvent("torchranout", {torch = inst})
-----------------------MOD
					owner:PushEvent("toolbroke", {tool = inst})
-----------------------MOD	
				end
            end
                
        end
	end )
end

AddPrefabPostInit("torch", torchInit)

local function newEquip(self, item, old_to_active, slot, con)
    --print("Inventory:Equip", item)
    if not item or not item.components.equippable or not item:IsValid() then
        return
    end
--------------------------------------------
  -----------------used for equip swap
	if slot == nil then
		 
			slot = self:GetItemSlot(item)
	end
----------------------------------------------------
    if item.components.inventoryitem then
        item = item.components.inventoryitem:RemoveFromOwner(item.components.equippable.equipstack) or item
    else
        item = self:RemoveItem(item, item.components.equippable.equipstack) or item
    end

    local leftovers = nil
    if item == self.activeitem then
        leftovers = self.activeitem
        self:SetActiveItem(nil)
    end
    
    local eslot = item.components.equippable.equipslot
    if self.equipslots[eslot] ~= item then
        local olditem = self.equipslots[eslot]
        if leftovers then
            if old_to_active then
                self:GiveActiveItem(leftovers)
            else
                self:GiveItem(leftovers)
            end
        end
        if olditem then
            self:Unequip(eslot)
            olditem.components.equippable:ToPocket()
            
            if olditem.components.inventoryitem and not olditem.components.inventoryitem.cangoincontainer and not self.ignorescangoincontainer then
				olditem.components.inventoryitem:OnRemoved()
				self:DropItem(olditem)
            else
				if old_to_active then
-------------------- --------------------- ------------------------add slot here
	-----------------used for equip swap
					if con then
						if con.container then
							con.container.components.container:GiveActiveItem(olditem, slot)
						else
							olditem.parent.components.inventory:GiveActiveItem(olditem)
						end
							
					else
						olditem.parent.components.inventory:GiveActiveItem(olditem, slot)
					end
------------------------------------------------------------------------					
				else
					
--------------------------------------------------------------------------------------
	-----------------used for equip swap
					if con then
						if con.container then
							con.container.components.container:GiveItem(olditem, slot)
						else
							olditem.parent.components.inventory:GiveItem(olditem)
						end
					else
						olditem.parent.components.inventory:GiveItem(olditem, slot)
					end
--------------------------------------------------------------------------------

				end
            end
          
        end
        
        item.components.inventoryitem:OnPutInInventory(self.inst)
        item.components.equippable:Equip(self.inst)
        self.equipslots[eslot] = item
        self.inst:PushEvent("equip", {item=item, eslot=eslot})
        return true
    end

end

AddComponentPostInit("inventory", function (inst)
	inst.Equip = newEquip
end)
local function gamePostInit()
	GLOBAL.ContainerWidget.RightClickInvSlot = function (self, slot)
		if self.owner and self.owner.components.inventory then
		
			local item = self.container.components.container:GetItemInSlot(slot.num)
			if item then
		
				if self.owner.components.inventory:GetActiveItem() then
					local actions = self.owner.components.playeractionpicker:GetUseItemActions(item, self.owner.components.inventory:GetActiveItem(), true)
					if actions then
						self.owner.components.locomotor:PushAction(actions[1], true)
					end
				else
					if item.components.equippable then
------------------------------------------------add nil,slot.num,,self here
	------------------------------used for equip swap
						self.owner.components.inventory:Equip(item, nil, slot.num, self)
	--------------------------------------------------------------------------------

					else
						local actions = self.owner.components.playeractionpicker:GetInventoryActions(item, true)
						if actions then
							self.owner.components.locomotor:PushAction(actions[1], true)
						end
					end
				end
			end
		end
	end
end
AddGamePostInit( gamePostInit )