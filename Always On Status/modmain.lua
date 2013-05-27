-- V2.0 Underground - downscaled the icons' size by 10% and rearranged their position
-- V1.1 Added custom background
-- V1.0 Release version
-- Created by Kiopho
----------------------------------------------------------

function gamepostinit()
	GLOBAL.TheSim:LoadPrefabDefs(MODROOT.."prefabs.xml")
end

AddSimPostInit(gamepostinit)