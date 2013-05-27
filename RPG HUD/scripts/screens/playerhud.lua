require "screen"
require "button"
require "animbutton"
require "image"
require "uianim"

local MAX_HUD_SCALE = 1.25

require "screens/consolescreen"

require("widgets/statusdisplays")
require("widgets/inventorybar")
require("widgets/hoverer")
require("widgets/crafting")
require("widgets/mapwidget")
require("widgets/containerwidget")

local easing = require("easing")

local Sim = TheSim
local gettime = GetTime

local debugstr = {}
local MAX_CONSOLE_LINES = 15
local consolelog = function(...)

    local str = ""
    for i,v in ipairs({...}) do
        str = str..tostring(v)
    end

    table.insert(debugstr, str)

    while #debugstr > MAX_CONSOLE_LINES do
        table.remove(debugstr,1)
    end
end

addprintlogger(consolelog)

local Controls = Class(Widget, function(self, owner)
    Widget._ctor(self, "Controls")
    self.owner = owner
    
    --overlays
    self.clouds = self:AddChild(UIAnim())
    self.clouds:SetClickable(false)
    self.clouds:SetHAnchor(ANCHOR_MIDDLE)
    self.clouds:SetVAnchor(ANCHOR_MIDDLE)
    self.clouds:GetAnimState():SetBank("clouds_ol")
    self.clouds:GetAnimState():SetBuild("clouds_ol")
    self.clouds:GetAnimState():PlayAnimation("idle", true)
    self.clouds:GetAnimState():SetMultColour(1,1,1,0)
    self.clouds:Hide()

    self.iceover = self:AddChild(IceOver(owner))
    self.iceover:Hide()
    self.fireover = self:AddChild(FireOver(owner))
    self.fireover:Hide()


	self:MakeScalingNodes()

	self.minimap = self:AddChild(MapWidget(self.owner))
	self.minimap:Hide()

	--these are visible above the map
    self.bottomright_root = self:AddChild(Widget(""))
    self.bottomright_root:SetScaleMode(SCALEMODE_PROPORTIONAL)
    self.bottomright_root:SetHAnchor(ANCHOR_RIGHT)
    self.bottomright_root:SetVAnchor(ANCHOR_BOTTOM)
    self.bottomright_root:SetMaxPropUpscale(MAX_HUD_SCALE)
	self.bottomright_root = self.bottomright_root:AddChild(Widget(""))



	------ CONSOLE -----------	
	
	self.consoletext = self.bottom_root:AddChild(Text(BODYTEXTFONT, 20, "CONSOLE TEXT"))
	self.consoletext:SetVAlign(ANCHOR_BOTTOM)
	self.consoletext:SetHAlign(ANCHOR_LEFT)
	self.consoletext:SetRegionSize(850, 700)
	self.consoletext:SetPosition(0,500,0)
	self.consoletext:Hide()
    -----------------


    
    self.saving = self:AddChild(SavingIndicator(self.owner))
    self.saving:SetHAnchor(ANCHOR_MIDDLE)
    self.saving:SetVAnchor(ANCHOR_TOP)
    self.saving:SetPosition(Vector3(200,0,0))
    
    self.inv = self.bottom_root:AddChild(Inv(self.owner))
    
    self.crafttabs = self.left_root:AddChild(CraftTabs(self.owner))
    local scale = .75
    self.crafttabs:SetScale(scale,scale,scale)
    


	self.sidepanel = self.topright_root:AddChild(Widget("sidepanel"))
	self.sidepanel:SetScale(1,1,1)
	self.sidepanel:SetPosition(-80, -60, 0)
    self.status = self.sidepanel:AddChild(Status(self.owner))
    self.status:SetPosition(0,-110,0)
    self.status:SetScale(1,1,1)
    self.clock = self.sidepanel:AddChild(UIClock(self.owner))
    

    if GetWorld() and GetWorld():IsCave() then
    	self.clock:Hide()
    	self.status:SetPosition(-10,-20,0)
    end
    

	self.containers = {}

    local MAPSCALE = 0	-- .5
	
	self.maproot = self.bottomright_root:AddChild(Widget("mapstuff"))
	self.maproot:SetPosition(-60,70,0)
	self.minimapBtn = self.maproot:AddChild(Button())

	local btn = self.minimapBtn
    btn:SetScale(MAPSCALE,MAPSCALE,MAPSCALE)
	btn:SetOnClick( function() self:ToggleMap() end )
	btn:SetMouseOver( function()  btn:ScaleTo(MAPSCALE*1.1,MAPSCALE*1.1,MAPSCALE*1.1) end )
	btn:SetMouseOut( function() btn:ScaleTo(MAPSCALE,MAPSCALE,MAPSCALE) end )
	
	btn:SetTooltip(STRINGS.UI.HUD.MAP)
	btn:SetImage( "data/images/map_button.tex" )


	self.pauseBtn = self.maproot:AddChild(Button())
	
    self.pauseBtn:SetOnClick(
		function()
			if not IsHUDPaused() then
				TheFrontEnd:PushScreen(PauseScreen())
			end
		end )
	
	self.pauseBtn:SetMouseOver(
		function()
			self.pauseBtn:ScaleTo( .4, .4, .4 )
		end )
		
	self.pauseBtn:SetMouseOut(
		function()
			self.pauseBtn:ScaleTo( .33, .33, .33 )
		end )
		
	self.pauseBtn:SetTooltip(STRINGS.UI.HUD.PAUSE)
		
	self.pauseBtn:SetImage( "data/images/pause.tex" )	
	self.pauseBtn:SetScale(0,0,0)	-- (.33,.33,.33)
	self.pauseBtn:SetPosition( Point( 0,-50,0 ) )
        
    if true or not IsGamePurchased() then
		self.demotimer = self.top_root:AddChild(DemoTimer(self.owner))
		self.demotimer:SetPosition(320, -25, 0)
	end
	

	--self.alphawarning = self.top_root:AddChild(Text(TITLEFONT, 40))
	--self.alphawarning:SetRegionSize(300, 50)
	--self.alphawarning:SetPosition(0, -28, 0) 
	--self.alphawarning:SetString(STRINGS.UI.HUD.CAVEWARNING)
	--self.alphawarning:Hide()
	--if GetWorld():IsCave() then
	--	self.alphawarning:Show()
	--end


	self.rotleft = self.maproot:AddChild(Button())
	self.rotleft:SetImage( "data/images/turnarrow_icon.tex" )
	--self.rotleft:SetMouseOverImage( "data/images/turnarrow_icon_over.tex" )
	
	self.rotleft:SetMouseOver( function() self.rotleft:SetScale( -.8, .8, .8 ) end )
	self.rotleft:SetMouseOut( function() self.rotleft:SetScale( -.7, .7, .7 ) end )	
	
    self.rotleft:SetPosition(-40,-40,0)
    self.rotleft:SetOnClick(function() GetPlayer().components.playercontroller:RotLeft() end)
    self.rotleft:SetScale(0,0,0)	-- (-.7,.7,.7)
    self.rotleft:SetTooltip(STRINGS.UI.HUD.ROTLEFT)

	self.rotright = self.maproot:AddChild(Button())
	self.rotright:SetImage( "data/images/turnarrow_icon.tex" )
	--self.rotright:SetMouseOverImage( "data/images/turnarrow_icon_over.tex" )
	
	self.rotright:SetMouseOver( function() self.rotright:SetScale( .8, .8, .8 ) end )
	self.rotright:SetMouseOut( function() self.rotright:SetScale( .7, .7, .7 ) end )	
	
    self.rotright:SetPosition(40,-40,0)
    self.rotright:SetOnClick(function() GetPlayer().components.playercontroller:RotRight() end)
    self.rotright:SetScale(0,0,0)	-- (.7,.7,.7)
	self.rotright:SetTooltip(STRINGS.UI.HUD.ROTRIGHT)

    
    
	
	self.containerroot = self:AddChild(Widget(""))
    self.containerroot:SetHAnchor(ANCHOR_MIDDLE)
    self.containerroot:SetVAnchor(ANCHOR_MIDDLE)
	self.containerroot:SetScaleMode(SCALEMODE_PROPORTIONAL)
	self.containerroot:SetMaxPropUpscale(MAX_HUD_SCALE)
	self.containerroot = self.containerroot:AddChild(Widget(""))
	
	self.containerroot_side = self:AddChild(Widget(""))
    self.containerroot_side:SetHAnchor(ANCHOR_RIGHT)
    self.containerroot_side:SetVAnchor(ANCHOR_MIDDLE)
	self.containerroot_side:SetScaleMode(SCALEMODE_PROPORTIONAL)
	self.containerroot_side:SetMaxPropUpscale(MAX_HUD_SCALE)
	self.containerroot_side = self.containerroot_side:AddChild(Widget(""))
	
    self.hover = self:AddChild(HoverText(self.owner))
    
    self.mousefollow = self:AddChild(Widget("follower"))
    self.mousefollow:FollowMouse(true)
    self.mousefollow:SetScaleMode(SCALEMODE_PROPORTIONAL)
    self.hover:SetScaleMode(SCALEMODE_PROPORTIONAL)

    self:SetHUDSize(Profile:GetHUDSize())
end)


function Controls:MakeScalingNodes()

	--these are auto-scaling root nodes
	self.top_root = self:AddChild(Widget("top"))
    self.top_root:SetScaleMode(SCALEMODE_PROPORTIONAL)
    self.top_root:SetHAnchor(ANCHOR_MIDDLE)
    self.top_root:SetVAnchor(ANCHOR_TOP)
    self.top_root:SetMaxPropUpscale(MAX_HUD_SCALE)

    self.bottom_root = self:AddChild(Widget("bottom"))
    self.bottom_root:SetScaleMode(SCALEMODE_PROPORTIONAL)
    self.bottom_root:SetHAnchor(ANCHOR_MIDDLE)
    self.bottom_root:SetVAnchor(ANCHOR_BOTTOM)
    self.bottom_root:SetMaxPropUpscale(MAX_HUD_SCALE)

    self.topright_root = self:AddChild(Widget("side"))
    self.topright_root:SetScaleMode(SCALEMODE_PROPORTIONAL)
    self.topright_root:SetHAnchor(ANCHOR_RIGHT)
    self.topright_root:SetVAnchor(ANCHOR_TOP)
    self.topright_root:SetMaxPropUpscale(MAX_HUD_SCALE)

    
	self.left_root = self:AddChild(Widget("side"))
    self.left_root:SetScaleMode(SCALEMODE_PROPORTIONAL)
    self.left_root:SetHAnchor(ANCHOR_LEFT)
    self.left_root:SetVAnchor(ANCHOR_MIDDLE)
    self.left_root:SetMaxPropUpscale(MAX_HUD_SCALE)
	
	--these are for introducing user-configurable hud scale
	self.topright_root = self.topright_root:AddChild(Widget(""))
	self.bottom_root = self.bottom_root:AddChild(Widget(""))
	self.top_root = self.top_root:AddChild(Widget(""))
	self.left_root = self.left_root:AddChild(Widget(""))
	--

end

function Controls:SetHUDSize( size )
	local min_scale = .75
	local max_scale = 1.1
	
	--testing high res displays
	local w,h = TheSim:GetScreenSize()
	
	local res_scale_x = math.max(1, w / 1920)
	local res_scale_y = math.max(1, h / 1200)
	local res_scale = math.min(res_scale_x, res_scale_y)	
	
	local scale = easing.linear(size, min_scale, max_scale-min_scale, 10) * res_scale
	self.topright_root:SetScale(scale,scale,scale)
	self.bottom_root:SetScale(scale,scale,scale)
	self.top_root:SetScale(scale,scale,scale)
	self.bottomright_root:SetScale(scale,scale,scale)
	self.left_root:SetScale(scale,scale,scale)
	self.containerroot:SetScale(scale,scale,scale)
	self.containerroot_side:SetScale(scale,scale,scale)
	self.hover:SetScale(scale,scale,scale)
	
	self.mousefollow:SetScale(scale,scale,scale)
end

function Controls:OnKeyDown( key )
	if self.owner and self.owner.components.playercontroller and self.owner.components.playercontroller.enabled then
		if key >= KEY_0 and key <= KEY_9 then
			local num = 1
			if key == KEY_0 then
				num = 10
			else
				num = key - KEY_1 + 1
			end
			self.inv:UseSlot(num)
		elseif key == KEY_MINUS then
			self.inv:UseSlot(11)
		elseif key == KEY_EQUALS then
			self.inv:UseSlot(12)
	    elseif key == KEY_TAB then
		    self:ToggleMap()
	    elseif key == KEY_TILDE and PLATFORM ~= "NACL" and TheSim:GetSetting("MISC", "ENABLECONSOLE") == "true" then
	    	TheFrontEnd:PushScreen(ConsoleScreen())
	    	self.consoletext:Show()
	    elseif key == KEY_L and TheInput:IsKeyDown(KEY_CTRL) then
	    	if self.consoletext.shown then
		    	self.consoletext:Hide()
		    else
		    	self.consoletext:Show()
		    end
		elseif key == KEY_B and not TheInput:IsKeyDown(KEY_CTRL) and not TheInput:IsKeyDown(KEY_SHIFT) then
			if self.left_root.shown then
				self.left_root:Hide()
			else
				self.left_root:Show()
			end	
	    elseif key == KEY_R and not TheInput:IsKeyDown(KEY_CTRL) and not TheInput:IsKeyDown(KEY_SHIFT) then
			local bp = self.owner.components.inventory:GetEquippedItem(EQUIPSLOTS.PACK)
				if bp then
					if bp.components.container.open then
						bp.components.container:Close()
					else
					bp.components.container:Open(self.owner)
				end
		end
		
		end
	end
end

function Controls:Update(dt)
    
    local consolestr = ""
    for i,v in ipairs(debugstr) do
    	consolestr = consolestr..v.."\n"
    end
    consolestr = consolestr.."(Press CTRL+L to close this log)"

   	self.consoletext:SetString(consolestr)

    self.status:Update(dt)
    self.hover:Update(dt)
    self.fireover:Update(dt)
    self.crafttabs:Update(dt)
    self.iceover:Update(dt)
    
    for k,v in pairs(self.containers) do
		if not v:Update(dt) then
			self.containers[k] = nil
			v:Kill()
		end
	end
    
    
    if not GetWorld():IsCave() then
	    --this is kind of a weird place to do all of this, but the anim *is* a hud asset...
	    if TheCamera and TheCamera.distance and not TheCamera.dollyzoom then
	        local dist_percent = (TheCamera.distance - TheCamera.mindist) / (TheCamera.maxdist - TheCamera.mindist)
	        local cutoff = .6
	        if dist_percent > cutoff then
	            if not self.clouds_on then
					TheCamera.should_push_down = false
	                self.clouds_on = true
	                self.clouds:Show()
	                --self.owner.SoundEmitter:PlaySound("dontstarve/common/clouds", "windsound")
	                TheMixer:PushMix("high")
	            end
	            
	            local p = easing.outCubic( dist_percent-cutoff , 0, 1, 1 - cutoff) 
	            --self.clouds:GetAnimState():SetMultColour(1,1,1, p )
	            --self.owner.SoundEmitter:SetVolume("windsound",p)
	        else
	            if self.clouds_on then
					TheCamera.should_push_down = false
	                self.clouds_on = false
	                self.clouds:Hide()
	                --self.owner.SoundEmitter:KillSound("windsound")
	                TheMixer:PopMix("high")
	            end
	        end
	    end
	end
	
    if self.demotimer then
		if IsGamePurchased() then
			self.demotimer:Kill()
			self.demotimer = nil
		else
			self.demotimer:Update(dt)
		end
	end
end

function Controls:ToggleMap()
    local minimap = self.owner.HUD.minimap
    if minimap then
        minimap.MiniMap:ToggleVisibility()
        if minimap.MiniMap:IsVisible() then
            self.containerroot:Hide()
            self.containerroot_side:Hide()
            self.owner.SoundEmitter:PlaySound("dontstarve/HUD/map_open")
            SetHUDPause(true)
			self.minimap:Show()
			self.minimap:Update()
            self.minimapBtn:Show()
            self.pauseBtn:Hide()
            self.hover:Hide()
            self.rotleft:Hide()
            self.rotright:Hide()
            
            if self.inv.hovertile then
				self.inv.hovertile:Hide()
			end
        else
			self.containerroot:Show()
			self.containerroot_side:Show()
            self.owner.SoundEmitter:PlaySound("dontstarve/HUD/map_close")
            SetHUDPause(false)
			self.minimap:Hide()
			self.pauseBtn:Show()
			self.hover:Show()
            if self.inv.hovertile then
				self.inv.hovertile:Show()
			end
            self.rotleft:Show()
            self.rotright:Show()

			
        end
    end
end

PlayerHud = Class(Screen, function(self)
	Screen._ctor(self, "HUD")
    
    self.vig = self:AddChild(UIAnim())
    self.vig:GetAnimState():SetBuild("vig")
    self.vig:GetAnimState():SetBank("vig")
    self.vig:GetAnimState():PlayAnimation("basic", true)
    self.vig:SetHAnchor(ANCHOR_LEFT)
    self.vig:SetVAnchor(ANCHOR_TOP)
    self.vig:SetScaleMode(SCALEMODE_FIXEDPROPORTIONAL)
    self.vig:SetClickable(false)
    
    self.bloodover = BloodOver()
    
    self.minimap = SpawnPrefab( "minimap" )
    self.root = self:AddChild(Widget("root"))
end)

function PlayerHud:OnGainFocus()
	Screen.OnGainFocus(self)
	if self.controls then
		self.controls:SetHUDSize(Profile:GetHUDSize())
	end
end

function PlayerHud:OnDestroy()
	self.minimap:Remove()
	Screen.OnDestroy(self)
end

function PlayerHud:Hide()
	self.shown = false
	self.root:Hide()
end

function PlayerHud:Show()
	self.shown = true
	self.root:Show()
end


function PlayerHud:CloseContainer(container)
    for k,v in pairs(self.controls.containers) do
		if v.container == container then
			v:Close()
		end
    end
end

function PlayerHud:OpenContainer(container, side)

	if container then
		local containerwidget = nil
		if side then
			containerwidget = self.controls.containerroot_side:AddChild(ContainerWidget(self.owner))
		else
			containerwidget = self.controls.containerroot:AddChild(ContainerWidget(self.owner))
		end
		containerwidget:Open(container, self.owner)
	    
		for k,v in pairs(self.controls.containers) do
			if v.container then
				if v.container.prefab == container.prefab then
					v:Close()
				end
			else
				self.controls.containers[k] = nil
			end
		end
	    
		self.controls.containers[container] = containerwidget
	end
	    
end

function PlayerHud:GoSane()
    self.vig:GetAnimState():PlayAnimation("basic", true)
end

function PlayerHud:GoInsane()
    self.vig:GetAnimState():PlayAnimation("insane", true)
end

function PlayerHud:SetMainCharacter(maincharacter)
    if maincharacter then
		maincharacter.HUD = self
		self.owner = maincharacter
		
		
		--FIXME: THIS IS A HACK TO GET AROUND AN ISSUE WHEN SHADER CONSTANTS AREN'T BEING SET PROPERLY WHEN YOU HAVE TEXT ON DIFFERENT RENDER LAYERS
		self.garbagetext = self.root:AddChild(Text(TITLEFONT, 40))
		self.garbagetext:SetString(" ")


		self.controls = self.root:AddChild(Controls(self.owner))
		self.controls.inv:Refresh()
		--self.inst.entity:SetParent(self.inst.entity)

		self.inst:ListenForEvent("badaura", function(inst, data) return self.bloodover:Flash() end, self.owner)
		self.inst:ListenForEvent("attacked", function(inst, data) return self.bloodover:Flash() end, self.owner)
		self.inst:ListenForEvent("startstarving", function(inst, data) self.bloodover:TurnOn() end, self.owner)
		self.inst:ListenForEvent("stopstarving", function(inst, data) self.bloodover:TurnOff() end, self.owner)
		self.inst:ListenForEvent("ontriggersave", function(inst, data) self.controls.saving:OnSave(2) end, self.owner)
		self.inst:ListenForEvent("gosane", function(inst, data) self:GoSane() end, self.owner)
		self.inst:ListenForEvent("goinsane", function(inst, data) self:GoInsane() end, self.owner)
		
		if not self.owner.components.sanity:IsSane() then
			self:GoInsane()
		end
		self.controls.crafttabs:UpdateRecipes()
		
		local bp = maincharacter.components.inventory:GetEquippedItem(EQUIPSLOTS.PACK)
		if bp then
			bp.components.container:Close()
			bp.components.container:Open(maincharacter)
		end
	end
end

function PlayerHud:OnUpdate(dt)
    if self.owner then
		if self.controls then
			self.controls:Update(dt)
		end
		
		if Profile and self.vig then
			if RENDER_QUALITY.LOW == Profile:GetRenderQuality() then
				self.vig:Hide()
			else
				self.vig:Show()
			end
		end
	end
end


function PlayerHud:OnKeyUp( key )
	if key == KEY_ESCAPE then
		if not IsHUDPaused() then
			TheFrontEnd:PushScreen(PauseScreen())
		end
	end
end

function PlayerHud:OnKeyDown( key )
	local focused = self:GetActiveFocusWidget()
	if self.controls then
		self.controls:OnKeyDown( key )
	end
end

return PlayerHud

