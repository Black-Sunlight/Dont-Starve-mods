require "class"
require "widgets/inventoryslot"
require "tilebg"
require "widgets/common"

local DOUBLECLICKTIME = .33

Inv = Class(Widget, function(self, owner)
    Widget._ctor(self, "Inventory")
    self.owner = owner

    local scale = .6
    self:SetScale(scale,scale,scale)
    self:SetPosition(0,-18,0)
	local lp = self:GetLocalPosition()
	local wp = self:GetWorldPosition()

    local num_slots = self.owner.components.inventory:GetNumSlots()
    local num_equip = self.owner.components.inventory:GetNumEquipSlots()

    local equip_slots = {EQUIPSLOTS.HANDS, EQUIPSLOTS.HEAD, EQUIPSLOTS.NECK, EQUIPSLOTS.BODY, EQUIPSLOTS.PACK,}
    local bgs = {"mods/RPG HUD/images/hand.tex", "mods/RPG HUD/images/head.tex", "mods/RPG HUD/images/neck.tex", "mods/RPG HUD/images/body.tex", "mods/RPG HUD/images/pack.tex"}

    self.inv = {}
    self.equip = {}
    
    self.bg = self:AddChild(Image("mods/RPG HUD/images/inventory_bg.tex"))
    self.bg:SetVRegPoint(ANCHOR_BOTTOM)
    self.bg:SetScale(1.378,1,0)
	self.bg:SetPosition(-2,-2,0)
    
    local W = 64
    local SEP = 7
    local INTERSEP = 11
    local y = 132/2
    
    local num_intersep = math.floor(num_slots / 5) - 1
    
    local total_w = num_slots*W + (num_slots - num_intersep - 1)*SEP + INTERSEP*num_intersep
    for k = 1, #equip_slots do
        local slot = EquipSlot(equip_slots[k], bgs[k], self.owner)
        self.equip[equip_slots[k]] = self:AddChild(slot)
        
		local equip_slots_w = num_equip*W + (num_equip - 1)*SEP
        local x = -equip_slots_w/2 + W/2 + (k-1)*W +(k-1)*SEP
        slot:SetPosition(x,y + W + SEP + 1,0)
		
        slot:SetLeftMouseDown(function() self:ClickEquipSlot(slot) end)
        slot:SetRightMouseDown(function() self:RightEquipSlot(slot) end)
    end    

    for k = 1,num_slots do
        local slot = InvSlot(k,"data/images/inv_slot.tex", self.owner, self.owner.components.inventory)
        self.inv[k] = self:AddChild(slot)
        
        local interseps = math.floor((k-1) / 5)
        local x = -total_w/2 + W/2 + interseps*(INTERSEP - SEP) + (k-1)*W + (k-1)*SEP
        slot:SetPosition(x,y,0)
        
        slot:SetLeftMouseDown(function() self:ClickInvSlot(slot) end)
        slot:SetRightMouseDown(function() self:RightClickInvSlot(slot) end)
    end


    self.hovertile = nil

    self.inst:ListenForEvent("builditem", function(inst, data) self:OnBuild() end, self.owner)
    self.inst:ListenForEvent("itemget", function(inst, data) self:OnItemGet(data.item, data.slot, data.src_pos) end, self.owner)
    self.inst:ListenForEvent("equip", function(inst, data) self:OnItemEquip(data.item, data.eslot) end, self.owner)
    self.inst:ListenForEvent("unequip", function(inst, data) self:OnItemUnequip(data.item, data.eslot) end, self.owner)
    self.inst:ListenForEvent("newactiveitem", function(inst, data) self:OnNewActiveItem(data.item) end, self.owner)
    self.inst:ListenForEvent("itemlose", function(inst, data) self:OnItemLose(data.slot) end, self.owner)
    self.inst:ListenForEvent("rightmousedown", function(inst, data) self:Cancel() end, self.owner)
    self.inst:ListenForEvent("keydown", function(inst, data) self:OnKeyPress(data.key) end, self.owner)

	self:Refresh()

end)

function Inv:Refresh()
	
	for k,v in pairs(self.inv) do
		v:SetTile(nil)
	end

	for k,v in pairs(self.equip) do
		v:SetTile(nil)
	end

	for k,v in pairs(self.owner.components.inventory.itemslots) do
		if v then
			local tile = ItemTile(v, self)
			self.inv[k]:SetTile(tile)
		end
	end

	for k,v in pairs(self.owner.components.inventory.equipslots) do
		if v then
			local tile = ItemTile(v, self)
			self.equip[k]:SetTile(tile)
		end
	end
	
	self:OnNewActiveItem(self.owner.components.inventory.activeitem)

end


function Inv:Cancel()
    local active_item = self.owner.components.inventory:GetActiveItem()
    if active_item then
        self.owner.components.inventory:ReturnActiveItem()
    end
end

function Inv:OnItemLose(slot)
	if slot then
		self.inv[slot]:SetTile(nil)
	end
end

function Inv:OnBuild()
    if self.hovertile then
        self.hovertile:ScaleTo(3, 1, .5)
    end
end

function Inv:OnNewActiveItem(item)
    if self.hovertile then
        self.hovertile:Kill()
    end

    if item and self.owner.HUD.controls then
        
        self.hovertile = self.owner.HUD.controls.mousefollow:AddChild(ItemTile(item, self))
        --self.owner.Controller:DoDragAndDrop(true)
        self.hovertile:StartDrag()
    else
        --self.owner.Controller:DoDragAndDrop(false)
    end

end

function Inv:RightClickInvSlot(slot)
    self:UseSlot(slot.num)
end

function Inv:UseSlot(slot)
    local item = self.owner.components.inventory:GetItemInSlot(slot)
    if item then
    
		if self.owner.components.inventory:GetActiveItem() then
			local actions = self.owner.components.playeractionpicker:GetUseItemActions(item, self.owner.components.inventory:GetActiveItem(), true)
			if actions then
				self.owner.components.locomotor:PushAction(actions[1], true)
			end
		else
    
			if item.components.equippable then
				self.owner.components.inventory:Equip(item)
				--self.owner.components.inventory:ReturnActiveItem(slot.num)
			else
				local actions = self.owner.components.playeractionpicker:GetInventoryActions(item)
				if actions then
					self.owner.components.locomotor:PushAction(actions[1], true)
					--self.owner.components.inventory:ReturnActiveItem(slot.num)
				end
			end
		end
    end
end


function Inv:ClickInvSlot(slot)
	HandleContainerUIClick(self.owner, self.owner.components.inventory, self.owner.components.inventory, slot.num)
end


function Inv:RightEquipSlot(slot)
    if slot.tile and slot.tile.item then
        if self.owner.components.inventory:GetActiveItem() then
            local actions = self.owner.components.playeractionpicker:GetUseItemActions(slot.tile.item, self.owner.components.inventory:GetActiveItem(), true)
            if actions then
                self.owner.components.locomotor:PushAction(actions[1], true)
            end
        else
            local actions = self.owner.components.playeractionpicker:GetInventoryActions(slot.tile.item)
        	if actions then
        		self.owner.components.locomotor:PushAction(actions[1], true)
        	end
        end
	end
end

function Inv:ClickEquipSlot(slot)
    local active_item = self.owner.components.inventory:GetActiveItem()
    if active_item and active_item.components.equippable and active_item.components.equippable.equipslot == slot.equipslot then
        self.owner.components.inventory:Equip(active_item, true)
    elseif slot.tile and not active_item then
        self.owner.components.inventory:SelectActiveItemFromEquipSlot(slot.equipslot)
    end
end


function Inv:OnItemGet(item, slot, source_pos)
    if slot and self.inv[slot] then
		local tile = ItemTile(item, self)
        self.inv[slot]:SetTile(tile)
        tile:Hide()

        if source_pos then
			local dest_pos = self.inv[slot]:GetWorldPosition()
			local im = Image(item.components.inventoryitem:GetImage())
			im:MoveTo(source_pos, dest_pos, .3, function() tile:Show() tile:ScaleTo(2, 1, .25) im:Kill() end)
        else
			tile:Show() 
			tile:ScaleTo(2, 1, .25)
        end
        
	end
end

function Inv:OnItemEquip(item, slot)
    self.equip[slot]:SetTile(ItemTile(item, self))
end

function Inv:OnItemUnequip(item, slot)
    if slot and self.equip[slot] then
		self.equip[slot]:SetTile(nil)
	end
end
