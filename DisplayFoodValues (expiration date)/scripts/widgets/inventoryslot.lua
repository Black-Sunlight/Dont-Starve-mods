InvSlot = Class(Widget, function(self, num, bgim, owner, container)
    Widget._ctor(self, "InventorySlot"..tostring(num))
    self.owner = owner

    self.bgimage = self:AddChild(Image(bgim))

    self.num = num
    self.tile = nil

    self.bgimage:SetMouseOver(function()
		local active_item = self.owner.components.inventory:GetActiveItem()
		if active_item then
			if container and not container:CanTakeItemInSlot(active_item, self.num) then
				return
			end
		elseif self.tile == nil then
			return
		end

        self.owner.SoundEmitter:PlaySound("dontstarve/HUD/click_mouseover")
        if self.tile then
            self.tile:OnMouseOver()
        end
        self:ScaleTo(1, 1.3, .125)
        self.big = true
    end)

    self.bgimage:SetMouseOut(function()
		if self.big then    
			if self.tile then
				self.tile:OnMouseOut()
			end
			self:ScaleTo(1.3, 1, .25)
		self.big = nil
		end
		
    end)
end)


function InvSlot:SetTile(tile)
    if self.tile and tile ~= self.tile then
        self.tile = self.tile:Kill()
    end

    if tile then
        self.tile = self:AddChild(tile)
    end
end

EquipSlot = Class(Widget, function(self, equipslot, bgim, owner)
    Widget._ctor(self, "EquipSlot"..tostring(equipslot))
    self.owner = owner

    self.equipslot = equipslot
    self.item = nil

    self.bgimage = self:AddChild(Image(bgim))
    self.highlight = false

    self.inst:ListenForEvent("newactiveitem", function(inst, data)
        if data.item and data.item.components.equippable and data.item.components.equippable.equipslot == self.equipslot then
            self:ScaleTo(1, 1.5, .125)
            self.highlight = true
        elseif self.highlight then
            self.highlight = false
            self:ScaleTo(1.5, 1, .125)
        end
    end, self.owner)


    self.bgimage:SetMouseOver(function()
		self.owner.SoundEmitter:PlaySound("dontstarve/HUD/click_mouseover")
        if self.tile then
            self.tile:OnMouseOver()
        end
        
        if not self.highlight then
            self:ScaleTo(1, 1.2, .125)
        end
    end)

    self.bgimage:SetMouseOut(function()
        if self.tile then
            self.tile:OnMouseOut()
        end
        if not self.highlight then
            self:ScaleTo(1.2, 1, .25)
        end
    end)

end)



function EquipSlot:SetTile(tile)
    if self.tile and tile ~= self.tile then
        self.tile = self.tile:Kill()
    end

    if tile then
        self.tile = self:AddChild(tile)
    end

end


ItemTile = Class(Widget, function(self, invitem, owner)
    Widget._ctor(self, "ItemTile"..tostring(invitem.prefab))
    self.owner = owner
    self.item = invitem

	-- NOT SURE WAHT YOU WANT HERE
	if invitem.components.inventoryitem == nil then
		print("NO INVENTORY ITEM COMPONENT"..tostring(invitem.prefab), invitem, owner)
		return
	end

	self.bg = self:AddChild(Image())
	self.bg:SetTexture("data/images/inv_slot_spoiled.tex")
	self.bg:Hide()
	self.bg:SetClickable(false)
	
	self.spoilage = self:AddChild(UIAnim())
	
    self.spoilage:GetAnimState():SetBank("spoiled_meter")
    self.spoilage:GetAnimState():SetBuild("spoiled_meter")
    self.spoilage:Hide()
    self.spoilage:SetClickable(false)
	
	
    self.image = self:AddChild(Image(invitem.components.inventoryitem:GetImage()))
    self.image:SetClickable(false)

    local owner = self.item.components.inventoryitem.owner
    
    if self.item.prefab == "spoiled_food" or (self.item.components.edible and self.item.components.perishable) then
		self.bg:Show( )
	end
	
	if self.item.components.perishable and self.item.components.edible then
		self.spoilage:Show()
	end

    self.inst:ListenForEvent("imagechange", function() 
        self.image:SetTexture(invitem.components.inventoryitem:GetImage())
    end, invitem)
    
    self.inst:ListenForEvent("stacksizechange",
            function(inst, data)
                if invitem.components.stackable then
                
					if data.src_pos then
						local dest_pos = self:GetWorldPosition()
						local im = Image(invitem.components.inventoryitem:GetImage())
						im:MoveTo(data.src_pos, dest_pos, .3, function() 
							self:SetQuantity(invitem.components.stackable:StackSize())
							self:ScaleTo(2, 1, .25)
							im:Kill() end)
					else
	                    self:SetQuantity(invitem.components.stackable:StackSize())
						self:ScaleTo(2, 1, .25)
					end
                end
            end, invitem)


    if invitem.components.stackable then
        self:SetQuantity(invitem.components.stackable:StackSize())
    end

    self.inst:ListenForEvent("percentusedchange",
            function(inst, data)
                self:SetPercent(data.percent)
            end, invitem)
    self.inst:ListenForEvent("perishchange",
            function(inst, data)
                self:SetPerishPercent(data.percent)
            end, invitem)

    if invitem.components.fueled then
        self:SetPercent(invitem.components.fueled:GetPercent())
    end

    if invitem.components.finiteuses then
        self:SetPercent(invitem.components.finiteuses:GetPercent())
    end

    if invitem.components.perishable then
        self:SetPerishPercent(invitem.components.perishable:GetPercent())
    end
    
    
    if invitem.components.armor then
        self:SetPercent(invitem.components.armor:GetPercent())
    end
    

end)

function ItemTile:OnMouseOver()
    if self.item.components.inventoryitem then
    	--MOD -->
        --self.namedisp= self:AddChild(Text(UIFONT, 40))
        self.namedisp = Text(UIFONT, 40)
	    if not self.children then
			self.children = {}
	    end
	self.children[self.namedisp] = true
	self.namedisp.parent = self
	local realfood = nil
	--MOD <--
		local adjective = self.item:GetAdjective()
		local str = nil
		if adjective then
			str = adjective .. " " .. self.item.name
		else
			str = self.item.name
		end
        
		self.namedisp:SetHAlign(ANCHOR_LEFT)
        local owner = self.item.components.inventoryitem and self.item.components.inventoryitem.owner
		local actionpicker = owner and owner.components.playeractionpicker or GetPlayer().components.playeractionpicker
		local inventory = owner and owner.components.inventory or GetPlayer().components.inventory
        if owner and inventory and actionpicker then
        
			local actions = nil
			if inventory:GetActiveItem() then
				actions = actionpicker:GetUseItemActions(self.item, inventory:GetActiveItem(), true)
			end
            if not actions then
				actions = actionpicker:GetInventoryActions(self.item)
			end
			
            if actions then
                str = str.."\n" .. STRINGS.RMB .. ": " .. actions[1]:GetActionString()
		--MOD
		for k,v in pairs(actions) do
		    if v.action == ACTIONS.EAT or v.action == ACTIONS.HEAL then
			realfood = true
		    end
		end
		--MOD
            end
        end
        
        --MOD -->
        local av = 80
	local positionshift = 0
	local hs = Profile:GetHUDSize()
	if self.item.components.edible and realfood then
	    local hungervalue = math.floor(self.item.components.edible:GetHunger(self.item) * 10 + 0.5) / 10
	    local healthvalue = math.floor(self.item.components.edible:GetHealth(self.item) * 10 + 0.5) / 10
	    local sanityhvalue = math.floor(self.item.components.edible:GetSanity(self.item) * 10 + 0.5) / 10
			
	    if hungervalue ~= 0 then
		str = str.."\n" .. "Голод: " .. hungervalue
		positionshift = positionshift + 10
	    end
	    if healthvalue ~= 0 then
		str = str.."\n" .. "Здоровье: " .. healthvalue
		positionshift = positionshift + 10
	    end
	    if sanityhvalue ~= 0 then
		str = str.."\n" .. "Психика: " .. sanityhvalue
		positionshift = positionshift + 10
	    end
	elseif self.item.components.healer and realfood then
	    str = str.."\n" .. "Здоровье: " .. self.item.components.healer.health
	    positionshift = positionshift + 10
	end
	if self.item.components.perishable and realfood then
	    local modifier = 1
	    if owner then
		if owner:HasTag("fridge") then
		    modifier = TUNING.PERISH_FRIDGE_MULT 
		end
	    end
		
	    if GetSeasonManager():GetCurrentTemperature() < 0 then
		modifier = modifier * TUNING.PERISH_WINTER_MULT
	    end
		
	    modifier = modifier * TUNING.PERISH_GLOBAL_MULT

	    local perishremainingtime = math.floor((self.item.components.perishable.perishremainingtime / TUNING.TOTAL_DAY_TIME / modifier) * 10 + 0.5) / 10
	    if perishremainingtime < .1 then
		str = str.."\n" .. "Испортиться очень скоро"
	    else
		str = str.."\n" .. "Испортиться через " .. perishremainingtime .. " д"
	    end   
	    if perishremainingtime%10==0 or perishremainingtime%10>4 or perishremainingtime%100>10 and perishremainingtime%100<15 then
		str = str .. "ней"
 	    elseif perishremainingtime%10==1 then
		str = str .. "ень"
	    else
	    	str = str .. "ня"
	    end
	    positionshift = positionshift + 10
	end
	if positionshift > 0 then
	    if owner.components.inventory then
		av = 50 + hs*1.8
	    else
		av = av + positionshift + hs*1.5
	    end
	end
        --MOD <--

        self.namedisp:SetString(str)
        
        local scr_w, scr_h = TheSim:GetScreenSize()

        local w, h = self.namedisp:GetRegionSize()
        local pos = self:GetWorldPosition()
        pos.y = pos.y + av --MOD 80 to av
        local x = math.min(math.max(pos.x, w/2), scr_w - w/2)
        local y = math.min(math.max(pos.y, h/2 + av), scr_h - h/2) --MOD 80 to av

	--MOD -->
	--if self.parent then
	--    local parentpos = self.parent:GetWorldPosition()
	--    x = x - parentpos.x
	--    y = y - parentpos.y
	--end
	--MOD <--
        self.namedisp:SetPosition(x,y,0)
    end
    
    if self.namedisp then
        self.namedisp:Show()
    end
end

function ItemTile:SetQuantity(quantity)
    if not self.quantity then
        self.quantity = self:AddChild(Text(NUMBERFONT, 42))
        self.quantity:SetPosition(2,16,0)
    end
    self.quantity:SetString(tostring(quantity))
end

function ItemTile:SetPerishPercent(percent)
	if self.item.components.perishable and self.item.components.edible then
		self.spoilage:GetAnimState():SetPercent("anim", 1-self.item.components.perishable:GetPercent())
	end
end

function ItemTile:SetPercent(percent)
    --if not self.item.components.stackable then
        
	if not self.percent then
		self.percent = self:AddChild(Text(NUMBERFONT, 42))
		self.percent:SetPosition(5,-32+15,0)
	end
    local val_to_show = percent*100
    if val_to_show > 0 and val_to_show < 1 then
        val_to_show = 1
    end
	self.percent:SetString(string.format("%2.0f%%", val_to_show))
        
    --end
end

function ItemTile:OnMouseOut()
    if self.namedisp then
        self.namedisp:Hide()
    end
end

function ItemTile:CancelDrag()
    self:StopFollowMouse()
    
    if self.item.prefab == "spoiled_food" or (self.item.components.edible and self.item.components.perishable) then
		self.bg:Show( )
	end
	
	if self.item.components.perishable and self.item.components.edible then
		self.spoilage:Show()
	end
    
end

function ItemTile:StartDrag()
    self:SetScale(1,1,1)
    --self:FollowMouse(true)
    self.spoilage:Hide()
    self.bg:Hide( )
end
