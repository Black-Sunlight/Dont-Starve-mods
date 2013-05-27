require "uianim"
local easing = require "easing"

local Badge = Class(Widget, function(self, anim, owner)
    
    Widget._ctor(self, "Badge")
	self.owner = owner
    
    --self:SetHAnchor(ANCHOR_RIGHT)
    --self:SetVAnchor(ANCHOR_TOP)
    self.percent = 1
    self:SetScale(.9,.9,.9)
    
    
    self.pulse = self:AddChild(UIAnim())
    self.pulse:GetAnimState():SetBank("pulse")
    self.pulse:GetAnimState():SetBuild("hunger_health_pulse")

    self.warning = self:AddChild(UIAnim())
    self.warning:GetAnimState():SetBank("pulse")
    self.warning:GetAnimState():SetBuild("hunger_health_pulse")
    self.warning:Hide()

    self.anim = self:AddChild(UIAnim())
    self.anim:GetAnimState():SetBank(anim)
    self.anim:GetAnimState():SetBuild(anim)
    self.anim:GetAnimState():PlayAnimation("anim")
    
    self.underNumber = self:AddChild(Widget("undernumber"))

	self.bg = self:AddChild(Image("mods/Always On Status/images/status_bg.tex"))
	self.bg:SetScale(.4,.429,0)
    self.bg:SetPosition(-.5,-25,0)
    
    self.num = self:AddChild(Text(NUMBERFONT, 28))
    self.num:SetHAlign(ANCHOR_MIDDLE)
    self.num:SetPosition(3, -40.5, 0)
	self.num:SetScale(1,.8,1)
    self.num:Show()
    
    --self.anim:SetMouseOver( function()
    --self.num:Show()
    --end)

    --self.anim:SetMouseOut( function()
    --self.num:Hide()
    --end)
    
end)

function Badge:SetPercent(val, max)
    val = val or self.percent
    max = max or 100
	
    self.anim:GetAnimState():SetPercent("anim", 1 - val)
    self.num:SetString(tostring(math.ceil(val*max)))
            
    self.percent = val
end

function Badge:PulseGreen()
    self.pulse:GetAnimState():SetMultColour(0,1,0,1)
	self.pulse:GetAnimState():PlayAnimation("pulse")
end

function Badge:PulseRed()
    self.pulse:GetAnimState():SetMultColour(1,0,0,1)
	self.pulse:GetAnimState():PlayAnimation("pulse")
end

function Badge:StopWarning()
	if self.warning.shown then
		self.warning:Hide()
	end
end

function Badge:StartWarning()
	if not self.warning.shown then
		self.warning:Show()
		self.warning:GetAnimState():SetMultColour(1,0,0,1)
		self.warning:GetAnimState():PlayAnimation("pulse", true)
	end
end


local HealthBadge = Class(Badge, function(self, owner)
	Badge._ctor(self, "health", owner)
	
	self.topperanim = self.underNumber:AddChild(UIAnim())
	self.topperanim:GetAnimState():SetBank("effigy_topper")
	self.topperanim:GetAnimState():SetBuild("effigy_topper")
	self.topperanim:GetAnimState():PlayAnimation("anim")
	self.topperanim:SetClickable(false)
end)


function HealthBadge:SetPercent(val, max, penaltypercent)
	Badge.SetPercent(self, val, max)

	penaltypercent = penaltypercent or 0
	self.topperanim:GetAnimState():SetPercent("anim", penaltypercent)
end	


local HungerBadge = Class(Badge, function(self, owner)
	Badge._ctor(self, "hunger", owner)
end)



local SanityBadge = Class(Badge, function(self, owner)
	Badge._ctor(self, "sanity", owner)
	
	self.sanityarrow = self.underNumber:AddChild(UIAnim())
	self.sanityarrow:GetAnimState():SetBank("sanity_arrow")
	self.sanityarrow:GetAnimState():SetBuild("sanity_arrow")
	self.sanityarrow:GetAnimState():PlayAnimation("neutral")
	self.sanityarrow:SetClickable(false)
end)

function SanityBadge:Update(dt)
	local rate = self.owner.components.sanity:GetRate()
	
	local small_down = .02
	local med_down = .1
	local large_down = .3
	local small_up = .01
	local med_up = .1
	local large_up = .2
	local anim = nil
	anim = "neutral"
	if rate > 0 and self.owner.components.sanity:GetPercent() < 1 then
		if rate > large_up then
			anim = "arrow_loop_increase_most"
		elseif rate > med_up then
			anim = "arrow_loop_increase_more"
		elseif rate > small_up then
			anim = "arrow_loop_increase"
		end
	elseif rate < 0 and self.owner.components.sanity:GetPercent() > 0 then
		if rate < -large_down then
			anim = "arrow_loop_decrease_most"
		elseif rate < -med_down then
			anim = "arrow_loop_decrease_more"
		elseif rate < -small_down then
			anim = "arrow_loop_decrease"
		end
	end
	
	if anim and self.arrowdir ~= anim then
		self.arrowdir = anim
		self.sanityarrow:GetAnimState():PlayAnimation(anim, true)
	end
	
end


Status = Class(Widget, function(self, owner)
    Widget._ctor(self, "Status")
    self.owner = owner
	
    self.brain = self:AddChild(SanityBadge(owner))
    --self.brain:SetPosition(0,35,0)
    self.brain:SetPosition(-20,0,0)
    self.brain:SetPercent(self.owner.components.sanity:GetPercent(), self.owner.components.health.maxhealth, self.owner.components.health:GetPenaltyPercent())

    self.stomach = self:AddChild(HungerBadge(owner))
    --self.stomach:SetPosition(-38,-32,0)
    self.stomach:SetPosition(-80,30,0)
    self.stomach:SetPercent(self.owner.components.hunger:GetPercent(), self.owner.components.hunger.max)

    self.heart = self:AddChild(HealthBadge(owner))
    --self.heart:SetPosition(38,-32,0)
    self.heart:SetPosition(40,30,0)
    
    self.heart:SetPercent(self.owner.components.health:GetPercent(), self.owner.components.health.maxhealth, self.owner.components.health:GetPenaltyPercent())
    
    self.inst:ListenForEvent("healthdelta", function(inst, data)  self:HealthDelta(data) end, self.owner)
    self.inst:ListenForEvent("hungerdelta", function(inst, data) self:HungerDelta(data) end, self.owner)
    self.inst:ListenForEvent("sanitydelta", function(inst, data) self:SanityDelta(data) end, self.owner)
end)

function Status:HealthDelta(data)
	self.heart:SetPercent(data.newpercent, self.owner.components.health.maxhealth,self.owner.components.health:GetPenaltyPercent()) 
	
	if data.oldpercent > .33 and data.newpercent <= .33 then
		self.heart:StartWarning()
	else
		self.heart:StopWarning()
	end
	
	if not data.overtime then
		if data.newpercent > data.oldpercent then
			self.heart:PulseGreen()
			TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/health_up")
		elseif data.newpercent < data.oldpercent then
			TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/health_down")
			self.heart:PulseRed()
		end
	end
end

function Status:HungerDelta(data)
	self.stomach:SetPercent(data.newpercent, self.owner.components.hunger.max)

	if data.newpercent <= 0 then
		self.stomach:StartWarning()
	else
		self.stomach:StopWarning()
	end
	
	if not data.overtime then
		if data.newpercent > data.oldpercent then
			self.stomach:PulseGreen()
			TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/hunger_up")
		elseif data.newpercent < data.oldpercent then
			TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/hunger_down")
			self.stomach:PulseRed()
		end
	end
	
end

function Status:SanityDelta(data)
	self.brain:SetPercent(data.newpercent, self.owner.components.sanity.max)
	
	
	if self.owner.components.sanity:IsCrazy() then
		self.brain:StartWarning()
	else
		self.brain:StopWarning()
	end
	
	if not data.overtime then
		if data.newpercent > data.oldpercent then
			self.brain:PulseGreen()
			TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/sanity_up")
		elseif data.newpercent < data.oldpercent then
			self.brain:PulseRed()
			TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/sanity_down")
		end
	end
	
end

function Status:Update(dt)
	self.brain:Update(dt)
end

-------------------------------------------------------------------------------------------------------

local DAY_COLOUR = Vector3(254/255,212/255,86/255)
local DUSK_COLOUR = Vector3(165/255,91/255,82/255)
local DARKEN_PERCENT = .75



UIClock = Class(Widget, function(self)
    Widget._ctor(self, "Clock")
    --self:SetHAnchor(ANCHOR_RIGHT)
    --self:SetVAnchor(ANCHOR_TOP)

    self.base_scale = 1
    
    self:SetScale(self.base_scale,self.base_scale,self.base_scale)
    self:SetPosition(-20,-5,0)

    self.moonanim = self:AddChild(UIAnim())
    --self.moonanim:SetScale(.4,.4,.4)
    self.moonanim:GetAnimState():SetBank("moon_phases_clock")
    self.moonanim:GetAnimState():SetBuild("moon_phases_clock")
    self.moonanim:GetAnimState():PlayAnimation("hidden")
    
    
    self.anim = self:AddChild(UIAnim())
    local sc = 1
    self.anim:SetScale(sc,sc,sc)
    self.anim:GetAnimState():SetBank("clock01")
    self.anim:GetAnimState():SetBuild("clock_transitions")
    self.anim:GetAnimState():PlayAnimation("idle_day",true)
    
    
    
    self.face = self:AddChild(Image("data/images/clock_NIGHT.tex"))
    self.segs = {}
	local segscale = .4
    local numsegs = 16
    for i = 1, numsegs do
		local seg = self:AddChild(Image("data/images/clock_wedge.tex"))
        seg:SetScale(segscale,segscale,segscale)
        seg:SetHRegPoint(ANCHOR_LEFT)
        seg:SetVRegPoint(ANCHOR_BOTTOM)
        seg:SetRotation((i-1)*(360/numsegs))
        seg:SetClickable(false)
        table.insert(self.segs, seg)
    end
    

    
    self.rim = self:AddChild(Image("data/images/clock_rim.tex"))
    self.hands = self:AddChild(Image("data/images/clock_hand.tex"))
    self.text = self:AddChild(Text(NUMBERFONT, 40/self.base_scale))
    --self.text:SetPosition(0,30/self.base_scale,0)

    self.rim:SetClickable(false)
    self.hands:SetClickable(false)
    self.face:SetClickable(false)
    
    local ground = GetWorld()   
    self.world_num = SaveGameIndex:GetSlotWorld()
    
    self.inst:ListenForEvent( "clocktick", function(inst, data) 
    				self:SetTime(data.normalizedtime, data.phase) 
    			end, GetWorld())

	self.anim:SetMouseOver( function()
		local clock_str = STRINGS.UI.HUD.WORLD.." ".. tostring(self.world_num or 1)
		self.text:SetString(clock_str)
	end)

    local function updatedaysstring()
        local clock_str = STRINGS.UI.HUD.CLOCKDAY.." "..tostring(GetClock().numcycles+1)
        self.text:SetString(clock_str)
    end
    
    self.anim:SetMouseOut(updatedaysstring )

	updatedaysstring()

    self.inst:ListenForEvent( "daycomplete", updatedaysstring, GetWorld())

	self.inst:ListenForEvent( "daytime", function(inst, data) 
        self.text:SetString(STRINGS.UI.HUD.CLOCKDAY.." "..tostring(data.day)+1) 
        self.anim:GetAnimState():PlayAnimation("trans_night_day") 
        self.anim:GetAnimState():PushAnimation("idle_day", true) 
        self.moonanim:GetAnimState():PlayAnimation("trans_in") 
        
    end, GetWorld())
	
	  
	self.inst:ListenForEvent( "nighttime", function(inst, data) 
		
        self.anim:GetAnimState():PlayAnimation("trans_dusk_night") 
        self.anim:GetAnimState():PushAnimation("idle_night", true) 
        self:ShowMoon()

    end, GetWorld())
    
	self.inst:ListenForEvent( "dusktime", function(inst, data) 
        self.anim:GetAnimState():PlayAnimation("trans_day_dusk")
    end, GetWorld())
    
	self.inst:ListenForEvent( "daysegschanged", function(inst, data) 
        self:RecalcSegs()
    end, GetWorld())
    
    
    self.old_t = 0 
    self:RecalcSegs()
    
    if GetClock():IsNight() then
		self:ShowMoon()
    end
    
end)


function UIClock:ShowMoon()
    local mp = GetClock():GetMoonPhase()
    local moon_syms = 
    {
        full="moon_full",
        quarter="moon_quarter",
        new="moon_new",
        threequarter="moon_three_quarter",
        half="moon_half",
    }
    self.moonanim:GetAnimState():OverrideSymbol("swap_moon", "moon_phases", moon_syms[mp] or "moon_full")        
    self.moonanim:GetAnimState():PlayAnimation("trans_out") 
    self.moonanim:GetAnimState():PushAnimation("idle", true) 
end

function UIClock:RecalcSegs()
    
    local dark = true
    for k,seg in pairs(self.segs) do
        
        local color = nil
        
        local daysegs = GetClock():GetDaySegs()
        local dusksegs = GetClock():GetDuskSegs()
        
        if k > daysegs + dusksegs then
			seg:Hide()
		else
	        seg:Show()
			
			if k <= daysegs then
				color = DAY_COLOUR 
			else
				color = DUSK_COLOUR
			end
	        
			if dark then
				color = color * DARKEN_PERCENT
			end
			seg:SetTint(color.x, color.y, color.z, 1)
			dark = not dark
		end
    end
    
end


function UIClock:SetTime(t, phase)

    if phase == "day" then
        local segs = 16
        if math.floor(t * segs) > 0 and math.floor(t * segs) ~= math.floor(self.old_t * segs) then
            self.anim:GetAnimState():PlayAnimation("pulse_day") 
            self.anim:GetAnimState():PushAnimation("idle_day", true)            
        end
    end
    
    self.hands:SetRotation(t*360)
    
    
    self.old_t = t
end

-------------------------------------------------------------------------------------------------------

SavingIndicator = Class(Widget, function(self, owner)
    self.owner = owner

    Widget._ctor(self, "Saving")
    self.anim = self:AddChild(UIAnim())
    self.anim:GetAnimState():SetBank("saving")
    self.anim:GetAnimState():SetBuild("saving")
    self:Hide()
    local scale = .5
    
    self.text = self:AddChild(Text(UIFONT, 50/scale))
    
    self.text:SetString(STRINGS.UI.HUD.SAVING)
    self.text:SetColour(241/255, 199/255, 66/255, 1)
    self.text:SetHAlign(ANCHOR_LEFT)
    self.text:SetPosition(160, -170, 0)
    self.text:Hide()
    self:SetScale(scale,scale,scale)
    self:SetPosition(100, 0,0)
end)

function SavingIndicator:OnSave(for_time)
	self:Show()
	self.anim:GetAnimState():PlayAnimation("save_pre")
	self.inst:DoTaskInTime(.5, function() self.text:Show()end)  
	self.anim:GetAnimState():PushAnimation("save_loop", true)
	self.inst:DoTaskInTime(for_time, function() self.text:Hide() self.anim:GetAnimState():PlayAnimation("save_post") end)  
end

-------------------------------------------------------------------------------------------------------

BloodOver =  Class(Widget, function(self, owner)

	self.owner = owner
	Widget._ctor(self, "BloodOver")
	
	self.anim = self:AddChild(UIAnim())
	self:SetClickable(false)
    self.anim:GetAnimState():SetBank("blood_over")
    self.anim:GetAnimState():SetBuild("blood_over")
    self.anim:GetAnimState():PlayAnimation("anim", true)
    self:SetHAnchor(ANCHOR_LEFT)
    self:SetVAnchor(ANCHOR_TOP)
    self:SetScaleMode(SCALEMODE_FIXEDPROPORTIONAL)
    self:Hide()
end)


function BloodOver:TurnOn()
    self.on = true
    if self.task then
        KillThread(self.task)
    end
    self:Show()
    self.anim:GetAnimState():SetMultColour(1,1,1,.5)
end

function BloodOver:TurnOff()
    self:Hide()
    self.on = false
end

function BloodOver:Flash()
    if self.on then
        return
    end

    if self.task then
        KillThread(self.task)
    end

    self.task = self.inst:StartThread(
    function()

        self:Show()
        local total_time = .75
        local t = total_time
        local dt = GetTickTime()
        while true do
            t = t - dt
            if t <= 0 then
                self:Hide()
                return
            end
            self.anim:GetAnimState():SetMultColour(1,1,1,t/total_time)
            Yield()
        end
    end)

end


-------------------------------------------------------------------------------------------------------


FireOver = Class(Widget, function(self, owner)
    self.owner = owner
    Widget._ctor(self, "FireOver")
	self.anim = self:AddChild(UIAnim())
    self:SetScaleMode(SCALEMODE_FIXEDPROPORTIONAL)
	
	self:SetClickable(false)
    self.anim:GetAnimState():SetBank("fire_over")
    self.anim:GetAnimState():SetBuild("fire_over")
    self.anim:GetAnimState():PlayAnimation("anim", true)
    self:SetHAnchor(ANCHOR_LEFT)
    self:SetVAnchor(ANCHOR_TOP)
    self.targetalpha = 0
    self.startalpha = 0
    self.alpha = 0
    self:Hide()
    self.ease_time = .4
    self.t = 0
	self.anim:GetAnimState():SetMultColour(1,1,1,0)
	
    self.inst:ListenForEvent("startfiredamage", function(inst, data) self:TurnOn() end, self.owner)
    self.inst:ListenForEvent("stopfiredamage", function(inst, data) self:TurnOff() end, self.owner)
	
end)


function FireOver:TurnOn()
	self.targetalpha = 1
	self.ease_time = 2
	self.startalpha = 0
	self.t = 0
	self.alpha = 0
end

function FireOver:TurnOff()
	self.targetalpha = 0
	self.ease_time = 1
	self.startalpha = 1
	self.t = 0
	self.alpha = 1
end

function FireOver:Update(dt)
	self.t = self.t + dt
	self.alpha = easing.outCubic( self.t, self.startalpha, self.targetalpha-self.startalpha, self.ease_time ) 
	self.anim:GetAnimState():SetMultColour(1,1,1,self.alpha)
	if self.alpha <= 0 then
		self:Hide()	
	else
		self:Show()
	end
end

-------------------------------------------------------------------------------------------------------

IceOver = Class(Widget, function(self, owner)
    self.owner = owner
    Widget._ctor(self, "IceOver")
	self.img = self:AddChild(Image("data/images/ice_over.tex"))
    self:SetScaleMode(SCALEMODE_FIXEDPROPORTIONAL)
	self:SetClickable(false)

    self:SetHAnchor(ANCHOR_MIDDLE)
    self:SetVAnchor(ANCHOR_MIDDLE)
    self:Hide()
    self.laststep = 0
    
    self.alpha_min = 1
    self.alpha_min_target = 1
    
    self.alphavalues = {
		day		= 1.0,
		dusk	= 0.6,
		night	= 0.3,
	}
    
    self.inst:ListenForEvent("temperaturedelta", function(inst, data) self:OnIceChange() end, self.owner)
end)


function IceOver:OnIceChange()
	
	local temp = self.owner.components.temperature:GetCurrent()

	local num_steps = 4
	
	
	local all_up_thresh = {5, 0, -5, -10}
	
	local freeze_sounds = 
	{
		"dontstarve/winter/freeze_1st",
		"dontstarve/winter/freeze_2nd",
		"dontstarve/winter/freeze_3rd",
		"dontstarve/winter/freeze_4th",
	}
	--local all_down_thresh = {8, 3, -2, -7}
	
	local up_thresh = all_up_thresh[self.laststep+1]
	local down_thresh = all_up_thresh[self.laststep]

	
	if up_thresh and temp < up_thresh and self.laststep < num_steps and (temp < 0 or GetSeasonManager():IsWinter()) then
		TheFrontEnd:GetSound():PlaySound(freeze_sounds[self.laststep+1])
		self.laststep = self.laststep + 1
	elseif down_thresh and temp > down_thresh and self.laststep > 0 then
		self.laststep = self.laststep - 1
	end
	
	if self.laststep == 0 then
		self.alpha_min_target = 1
	else
		
		local alpha_mins = {
			.7, .5, .3, 0
		}
		self.alpha_min_target = alpha_mins[self.laststep] 
	end
end

function IceOver:Update(dt)
	local clock = GetClock()
	
	if clock ~= nil then
		local lerp_factor = clock:LerpFactor()
		local cur_alpha = self.alphavalues[ clock:GetPrevPhase() ]
		local next_alpha = self.alphavalues[ clock:GetPhase() ]
		
		local new_alpha = ( 1 - lerp_factor ) * cur_alpha + lerp_factor * next_alpha
		self.img:SetTint( 1, 1, 1, new_alpha )
	end

	local lspeed = dt*2
	self.alpha_min = (1 - lspeed) * self.alpha_min + lspeed *self.alpha_min_target
	self.img:SetAlphaRange(self.alpha_min,1)
	
	if self.alpha_min >= .99 then
		self:Hide()
	else
		self:Show()
	end
end

-------------------------------------------------------------------------------------------------------

DemoTimer = Class(Widget, function(self, owner)
    self.owner = owner

    Widget._ctor(self, "DemoTimer")
    
    local font = UIFONT
    self.purchasebutton = self:AddChild(Button())
    self.purchasebutton:SetImage("data/images/button.tex")
    self.purchasebutton:SetMouseOverImage("data/images/button_over.tex")
    self.purchasebutton:SetDisabledImage("data/images/button_disabled.tex")
    self.purchasebutton:SetPosition(-60, 0, 0)
    self.purchasebutton:SetText(STRINGS.UI.HUD.BUYNOW)
    self.purchasebutton:SetOnClick( function() self:Purchase() end)
    self.purchasebutton:SetFont(font)
    
    self.base_scale = .5
    self.purchasebutton:SetTextSize(50) 
    self.purchasebutton:SetScale(self.base_scale,self.base_scale,self.base_scale)
    
    self.text = self:AddChild(Text(NUMBERFONT, 40))
    self.text:SetString("0:00")
    self.text:SetHAlign(ANCHOR_LEFT)
    self.text:SetVAlign(ANCHOR_MIDDLE)
	self.text:SetRegionSize( 150, 50 )
	self.text:SetPosition( 80, 0, 0 )

    self:Update()
end)

function DemoTimer:Purchase()
	ShowUpsellScreen(false)
end

function DemoTimer:Update()
    if self.owner and not IsGamePurchased() then
		local time = GetTimePlaying()
		local time_left = TUNING.DEMO_TIME - time
		
		if time_left > 0 then
			local minutes = math.floor(time_left / 60)
			local seconds = math.floor(time_left - minutes*60)
	        
			if minutes > 0 then
				self.text:SetString(string.format("Demo %d:%02d", minutes, seconds ))
			else
				self.text:SetString(string.format("Demo %02d", seconds ))
			end
		else
			self.text:SetString(string.format("Demo Over!"))
		end
    end
end
