--[[
***************************************************************
Created by: AlBug
Date: 05.03.2013

Upgraded by WrathOf to not require override of recipes.lua file
***************************************************************
]]

Recipe = GLOBAL.Recipe
Ingredient = GLOBAL.Ingredient


local function AB_ChangeRecipeIngredients(name, newingredients)
	local recipe = GLOBAL.GetRecipe(name)
	if recipe then recipe.ingredients = newingredients end
end

local function AB_ChangeRecipeLevel(name, newlevel)
	local recipe = GLOBAL.GetRecipe(name)
	if recipe then
		recipe.level = newlevel
		return true
	else
		return false
	end
end


local function modGamePostInit()

	--Make rope available at start of new game instead of requiring it to be researched first
	--Don't change recipes in the event unable to change the rope recipe
	if AB_ChangeRecipeLevel("rope", 0) then
		AB_ChangeRecipeIngredients("turf_road", { Ingredient("turf_rocky", 1), Ingredient("turf_woodfloor", 1) } )
		AB_ChangeRecipeIngredients("backpack", { Ingredient("cutgrass", 6), Ingredient("twigs", 6) } )
		AB_ChangeRecipeIngredients("fishingrod", { Ingredient("twigs", 2), Ingredient("rope", 2) } )
		AB_ChangeRecipeIngredients("axe", { Ingredient("twigs", 1), Ingredient("flint", 1), Ingredient("rope", 1) } )
		AB_ChangeRecipeIngredients("pickaxe", { Ingredient("twigs", 2), Ingredient("flint", 2), Ingredient("rope", 1) } )
		AB_ChangeRecipeIngredients("shovel", { Ingredient("twigs", 2), Ingredient("flint", 2), Ingredient("rope", 1) } )
		AB_ChangeRecipeIngredients("pitchfork", { Ingredient("twigs", 2), Ingredient("flint", 2),      Ingredient("rope", 1) } )
		AB_ChangeRecipeIngredients("goldenaxe", { Ingredient("twigs", 4), Ingredient("goldnugget", 2), Ingredient("rope", 2) } )
		AB_ChangeRecipeIngredients("goldenshovel", { Ingredient("twigs", 4), Ingredient("goldnugget", 2), Ingredient("rope", 2) } )
		AB_ChangeRecipeIngredients("goldenpickaxe", { Ingredient("twigs", 4), Ingredient("goldnugget", 2), Ingredient("rope", 2) } )
		AB_ChangeRecipeIngredients("amulet", { Ingredient("goldnugget", 6), Ingredient("nightmarefuel", 4), Ingredient("redgem", 1), Ingredient("rope", 1) } )
		AB_ChangeRecipeIngredients("icestaff", { Ingredient("spear", 1), Ingredient("bluegem", 1),Ingredient("rope", 1) } )
		AB_ChangeRecipeIngredients("rope", { Ingredient("cutgrass", 3) } )
		AB_ChangeRecipeIngredients("strawhat", { Ingredient("cutgrass", 6) } )
		AB_ChangeRecipeIngredients("winterhat", { Ingredient("beefalowool", 4), Ingredient("rope", 1) } )
		AB_ChangeRecipeIngredients("beemine", { Ingredient("boards", 1), Ingredient("killerbee", 4), Ingredient("honey", 1) } )
		AB_ChangeRecipeIngredients("wall_wood_item", { Ingredient("log", 2), Ingredient("rope", 1) } )
		AB_ChangeRecipeIngredients("boomerang", { Ingredient("boards", 2), Ingredient("rope", 1) } )
		AB_ChangeRecipeIngredients("beebox", { Ingredient("boards", 2), Ingredient("honeycomb", 1), Ingredient("honey", 2), Ingredient("bee", 4) } )
	end

end

AddGamePostInit(modGamePostInit)
