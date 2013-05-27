-- V2.03 Bugfix : the game won't crash if you use the shortcut for the backpack while not equipped
-- V2.02 Bugfix : if you are resurrected with the amulet you'll end up losing it like originally intended
-- V2.01 Bugfix : the game won't crash anymore when you downgrade to a smaller inventory version
-- V2.0 Underground - added shortcuts for the crafting tab (R) and the backpack (B) + cosmetic change to the crafting tab
-- V1.2 Increased the zoom out without the game making you go back to the default zoom
-- V1.1 Increased the size of the backpacks
-- V1 Realease version
-- Created By Kiohpo
------------------------------------------------------------------------------------------------------------

Vector3 = GLOBAL.Vector3

function inventorypostinit(component,inst)

	inst.components.inventory.maxslots = 25
	inst.components.inventory.numequipslots = 5

end

function krampussackpostinit(inst)

	local slotpos = {}
	
	for y = 0, 9 do
	table.insert(slotpos, Vector3(-37, -y*75 + 338 ,0))
	table.insert(slotpos, Vector3(-37 +75, -y*75 + 338 ,0))
	end
	
	inst.components.container.numslots = #slotpos
	inst.components.container.widgetslotpos = slotpos
	inst.components.container.widgetanimbank = nil
	inst.components.container.widgetanimbuild = nil
	inst.components.container.widgetbgimage = "mods/RPG HUD/images/krampus_sack_bg.tex"
	inst.components.container.widgetpos = Vector3(-76,-57,0)
	
	inst.components.equippable.equipslot = GLOBAL.EQUIPSLOTS.PACK
	inst.components.inventoryitem.cangoincontainer = true

end

function piggybackpostinit(inst)

	local slotpos = {}
	
	for y = 0, 6 do
	table.insert(slotpos, Vector3(-162, -y*75 + 240 ,0))
	table.insert(slotpos, Vector3(-162 +75, -y*75 + 240 ,0))
	end

	inst.components.container.numslots = #slotpos
	inst.components.container.widgetslotpos = slotpos
	inst.components.container.widgetanimbank = "ui_krampusbag_2x8"
	inst.components.container.widgetanimbuild = "ui_krampusbag_2x8"
	inst.components.container.widgetpos = Vector3(0,-75,0)

	inst.components.equippable.equipslot = GLOBAL.EQUIPSLOTS.PACK
	inst.components.inventoryitem.cangoincontainer = true
	inst.components.equippable.walkspeedmult = 1

end

function backpackpostinit(inst)
	
	local slotpos = {}
	for y = 0, 4 do
	table.insert(slotpos, Vector3(-162, -y*75 + 112 ,0))
	table.insert(slotpos, Vector3(-162 +75, -y*75 + 112 ,0))
	end
	
	inst.components.container.numslots = #slotpos
	inst.components.container.widgetslotpos = slotpos
	inst.components.container.widgetanimbank = "ui_krampusbag_2x5"
	inst.components.container.widgetanimbuild = "ui_krampusbag_2x5"
	inst.components.container.widgetpos = Vector3(0,-50,0)
	
	inst.components.equippable.equipslot = GLOBAL.EQUIPSLOTS.PACK
	inst.components.inventoryitem.cangoincontainer = true

end

function amuletpostinit(inst)
	
	inst.components.equippable.equipslot = GLOBAL.EQUIPSLOTS.NECK

end

function gamepostinit()

	GLOBAL.TheSim:LoadPrefabDefs(MODROOT.."prefabs.xml")
	
end

AddComponentPostInit("inventory", inventorypostinit)
AddPrefabPostInit("backpack", backpackpostinit)
AddPrefabPostInit("krampus_sack", krampussackpostinit)
AddPrefabPostInit("piggyback", piggybackpostinit)
AddPrefabPostInit("amulet", amuletpostinit)
AddSimPostInit(gamepostinit)

table.insert(GLOBAL.EQUIPSLOTS, "PACK")
GLOBAL.EQUIPSLOTS.PACK = "pack"
table.insert(GLOBAL.EQUIPSLOTS, "NECK")
GLOBAL.EQUIPSLOTS.NECK = "neck"


function chesterpostinit(inst)

	local slotpos = {}
    for y = 3, 0, -1 do
		for x = 0, 3 do
		table.insert(slotpos, Vector3(80*x-80*2+40, 80*y-80*2+40,0))
		end
	end

	inst.components.container.widgetanimbank = nil
	inst.components.container.widgetanimbuild = nil
	inst.components.container.widgetbgimage = "mods/RPG HUD/images/container.tex"
	inst.components.container.widgetpos = Vector3(0,-200,0)
	inst.components.container.numslots = #slotpos
	inst.components.container.widgetslotpos = slotpos

end

function treasurechestpostinit(inst)

	local slotpos = {}
	for y = 3, 0, -1 do
		for x = 0, 3 do
		table.insert(slotpos, Vector3(80*x-80*2+40, 80*y-80*2+40,0))
		end
	end

	inst.components.container.widgetanimbank = nil
	inst.components.container.widgetanimbuild = nil
	inst.components.container.widgetbgimage = "mods/RPG HUD/images/container.tex"
	inst.components.container.numslots = #slotpos
	inst.components.container.widgetslotpos = slotpos

end

function iceboxpostinit(inst)

	local slotpos = {}
	for y = 3, 0, -1 do
		for x = 0, 3 do
			table.insert(slotpos, Vector3(80*x-80*2+40, 80*y-80*2+40,0))
		end
	end

	inst.components.container.widgetanimbank = nil
	inst.components.container.widgetanimbuild = nil
	inst.components.container.widgetbgimage = "mods/RPG HUD/images/container.tex"
	inst.components.container.numslots = #slotpos
	inst.components.container.widgetslotpos = slotpos

end

AddPrefabPostInit("chester", chesterpostinit)
AddPrefabPostInit("treasurechest", treasurechestpostinit)
AddPrefabPostInit("icebox", iceboxpostinit)