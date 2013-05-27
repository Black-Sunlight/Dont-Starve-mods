local Curses = Class(function(self, inst)
    self.inst = inst
    self.curses = {}
end)

function Curses:AddCurse(curse)
	table.insert( self.curses, curse )
end

function Curses:OnSave()
	local cursesavedata = {}
	for k,v in ipairs(self.curses) do
		cursesavedata[v:GetName()] = v:OnSave()
	end

	return cursesavedata
end

function Curses:OnLoad(data)
	for k,v in ipairs(self.curses) do
		local cursedata = data[v:GetName()]

		--jcheng: very important to check when loading! Otherwise if you change your save format, you could crash the game
		if cursedata ~= nil then
			print("loading "..v:GetName())
			v:OnLoad(cursedata)
		else
			print("unable to load "..v:GetName())
		end
	end
end	

return Curses
