--[[
    
***************************************************************
Created by: Jamie Cheng
Date: February 20, 2013
Description: Every 5 days, the player gets a new curse applied to them.
	This is a sample mod that shows how to:
	- create dialog boxes
	- create and use your own classes
	- save / load a custom component
	- override functions inside the script while keeping it relatively future-safe
***************************************************************

]]

modimport "scripts\\curses.lua"

DAYS_PER_CURSE = 5

function simpostinit(player)
    player:ListenForEvent( "daytime", function(it, data) 
		local num_days = GLOBAL.GetClock():GetNumCycles()
		if (num_days + 1) % DAYS_PER_CURSE == 0 then
			StartRandomCurse(player)
		end

    end, GLOBAL.GetWorld())  
end

--add a post init to the sim starting up
AddSimPostInit(simpostinit)
