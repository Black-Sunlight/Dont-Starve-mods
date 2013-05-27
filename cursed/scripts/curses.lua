Curse = Class(function(self, name, desc)
	self.name = name
	self.desc = desc
	self.isrunning = false
	self.owner = nil
end)

function Curse:SetOwner(inst)
	self.owner = inst
end

function Curse:GetName()
	return self.name
end

function Curse:BeginCurse()
	TheFrontEnd:PushScreen(
		GLOBAL.PopupDialogScreen(
			"A new curse has befallen you!", 
			self.desc,
			{
				{text="I ACCEPT!", cb = function() self:Run() end},
				{text="No! Too hard!", cb = function() end}  
			}))
end

function Curse:Run()
	print("Running curse: "..self.name)
	self.isrunning = true
end

function Curse:Stop()
	print("Stopping curse: "..self.name)
	self.isrunning = false
end

function Curse:IsRunning()
	return self.isrunning
end

function Curse:OnSave()
	return {isrunning = self.isrunning}
end

function Curse:OnLoad(data)
	self.isrunning = data.isrunning
	if self.isrunning then
		self:Run()
	end
end

-------------------

RotCurse = Class(Curse,function(self)
	Curse._ctor(self,
		"Rot",
		"A plague has set, and all the food is rotting away..."
		)

	self.oldrotmultiplier = TUNING.PERISH_GLOBAL_MULT
end)

function RotCurse:Run()
	Curse.Run(self)
	
	TUNING.PERISH_GLOBAL_MULT = 20
end

function RotCurse:Stop()
	Curse.Stop(self)
	
	TUNING.PERISH_GLOBAL_MULT = self.oldrotmultiplier
end

ROTCURSE = RotCurse()

-------------------

InsanityCurse = Class(Curse,function(self)
	Curse._ctor(self,
		"Insanity",
		"A whisper in the wind is crawling on your skin. You feel your nerves fraying..."
		)

	self.TUNING = {}
	self.TUNING.SANITY_DAY_GAIN = TUNING.SANITY_DAY_GAIN
	self.TUNING.SANITY_NIGHT_LIGHT = TUNING.SANITY_NIGHT_LIGHT
	self.TUNING.SANITY_NIGHT_DARK = TUNING.SANITY_NIGHT_DARK
end)

function InsanityCurse:Run()
	Curse.Run(self)
	
	TUNING.SANITY_DAY_GAIN = TUNING.SANITY_NIGHT_LIGHT
	TUNING.SANITY_NIGHT_LIGHT = TUNING.SANITY_NIGHT_DARK
	TUNING.SANITY_NIGHT_DARK = TUNING.SANITY_NIGHT_DARK*2
end

function InsanityCurse:Stop()
	Curse.Stop(self)

	TUNING.SANITY_DAY_GAIN = self.TUNING.SANITY_DAY_GAIN
	TUNING.SANITY_NIGHT_LIGHT = self.TUNING.SANITY_NIGHT_LIGHT
	TUNING.SANITY_NIGHT_DARK = self.TUNING.SANITY_NIGHT_DARK
end

INSANITYCURSE = InsanityCurse()

-------------------

HalfHungerCurse = Class(Curse,function(self)
	Curse._ctor(self,
		"HalfHunger",
		"Staying out in the wilderness has shrunken your belly in half. Woe to the hungry."
		)

	self.hungermax = TUNING.WILSON_HUNGER

end)

function HalfHungerCurse:Run()
	Curse.Run(self)
	--halve wilson's max hunger!
	self.owner.components.hunger:SetMax(TUNING.WILSON_HUNGER*0.5)
end

function HalfHungerCurse:Stop()
	Curse.Stop(self)

	self.owner.components.hunger:SetMax(self.hungermax)
end

HUNGERCURSE = HalfHungerCurse()

-------------------

LockedAwayCurse = Class(Curse, function(self)
	Curse._ctor(self,
		"LockedAway",
		"You seemed to have dropped the key to your chests while you were exploring. You can no longer open your chests."
		)
end)

function LockedAwayCurse:Run()
	Curse.Run(self)
end

function chestpostinit(inst, curse)

	local onopenpre = inst.components.container.onopenfn
	local onopen = function(inst)
		onopenpre(inst)
		inst:PushEvent("onopen")
	end

	inst.components.container.onopenfn = onopen

	--if the curse is on, don't open!
	local onopencheck = function(inst)
		if curse:IsRunning() then
			inst.AnimState:PushAnimation("closed", false)
			inst.components.container:Close()
		end
	end

	inst:ListenForEvent( "onopen", onopencheck)
end

LOCKCURSE = LockedAwayCurse()

AddPrefabPostInit("treasurechest", function(inst) chestpostinit(inst, LOCKCURSE) end )

-----------------

--put them in a table so I can randomize them
CURSES = 
{
	LOCKCURSE,
	HUNGERCURSE,
	ROTCURSE,
	INSANITYCURSE
}

function characterpostinit(inst)
	inst:AddComponent("curses")
	for k,curse in ipairs(CURSES) do
		inst.components.curses:AddCurse(curse)
		curse:SetOwner(inst)
	end
end

function StartRandomCurse(inst)

	--only pick curses that are not currently running
	local availablecurses = {}
	for k,curse in ipairs(CURSES) do
		if not curse:IsRunning() then
			table.insert(availablecurses,curse)
		end
	end

	--stop all the currently running curses so they don't stack
	for k,curse in ipairs(CURSES) do
		if curse:IsRunning() then
			curse:Stop()
		end
	end

	if #availablecurses > 0 then
		availablecurses[ math.random( #availablecurses ) ]:BeginCurse()
	end
end

--add the post init function for all the characters here here
for k,prefabname in ipairs(CHARACTERLIST) do
	AddPrefabPostInit(prefabname, characterpostinit)
end
