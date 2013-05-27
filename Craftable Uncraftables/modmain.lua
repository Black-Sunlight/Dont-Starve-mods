STRINGS = GLOBAL.STRINGS
RECIPETABS = GLOBAL.RECIPETABS
Recipe = GLOBAL.Recipe
Ingredient = GLOBAL.Ingredient

STRINGS.RECIPE_DESC.SILK = "Полная паучья благодать!"
STRINGS.RECIPE_DESC.WALRUSHAT = "Если Морж сумел, то и я сумею это сделать!"
STRINGS.RECIPE_DESC.BUTTER = "Оно пахнет цветами!"
STRINGS.RECIPE_DESC.LIVINGLOG = "Конечно я в своём уме! Бревнам не отвечаю..."
STRINGS.RECIPE_DESC.KRAMPUS_SACK = "Мне интересно, кому он принаджелал?"
STRINGS.RECIPE_DESC.TRUNK_SUMMER = "Не очень толстые..."
STRINGS.RECIPE_DESC.TRUNK_WINTER = "Хороший и тёплый!"
STRINGS.RECIPE_DESC.COOKEDMANDRAKE = "Это морковь прожаренная магически!"
STRINGS.RECIPE_DESC.TENTACLESPIKE = "Не держитесь за острый конец!"
STRINGS.RECIPE_DESC.POOP = "Это действительно необходимо?"
STRINGS.RECIPE_DESC.BEARDHAIR = "Властью этой бороды я буду снова жить!"
STRINGS.RECIPE_DESC.HORN = "Управление мясом, ну т.е. Beefalo!"
STRINGS.RECIPE_DESC.PIGSKIN = "Хвост движеться..."
STRINGS.RECIPE_DESC.PETALS_EVIL = "Злее нежели обычные цветы"
STRINGS.RECIPE_DESC.TENTACLESPOTS = "Скрафченные генеталии. Хм."
STRINGS.RECIPE_DESC.HOUNDSTOOTH = "Острое!"
STRINGS.RECIPE_DESC.GEARS = "Полезная коллекция механического ... хлама"
STRINGS.RECIPE_DESC.SPIDERGLAND = "Заживи свои мини бо-бо"
STRINGS.RECIPE_DESC.REDGEM = "Он сияет огненной энергией"
STRINGS.RECIPE_DESC.BLUEGEM = "Он блестит как снег"


Recipe( "silk", { Ingredient("beefalowool", 2), Ingredient("rope", 1) }, RECIPETABS.REFINE, 1 )
Recipe( "walrushat", { Ingredient("silk", 6), Ingredient("beefalowool", 6) }, RECIPETABS.REFINE, 2 )
Recipe( "butter", { Ingredient("butterflywings", 3), Ingredient("seeds", 3), Ingredient("honey", 3) }, RECIPETABS.REFINE, 2 )
Recipe( "livinglog", { Ingredient("log", 4), Ingredient("nightmarefuel", 6), Ingredient("petals_evil", 6) }, RECIPETABS.REFINE, 2 )
Recipe( "krampus_sack", { Ingredient("charcoal", 3), Ingredient("goldnugget", 5), Ingredient("purplegem", 1) }, RECIPETABS.REFINE, 2 )
Recipe( "trunk_winter", { Ingredient("trunk_summer", 1), Ingredient("meat", 3), Ingredient("smallmeat", 5) }, RECIPETABS.REFINE, 2 )
Recipe( "trunk_summer", { Ingredient("meat", 3), Ingredient("smallmeat", 5) }, RECIPETABS.REFINE, 2 )
Recipe( "cookedmandrake", { Ingredient("carrot", 2), Ingredient("nightmarefuel", 3), Ingredient("charcoal", 3) }, RECIPETABS.REFINE, 2 )
Recipe( "tentaclespike", { Ingredient("stinger", 3), Ingredient("tentaclespots", 5) }, RECIPETABS.REFINE, 2 )
Recipe( "spiderhat", { Ingredient("silk", 10), Ingredient("beefalowool", 5), Ingredient("petals_evil", 4) }, RECIPETABS.REFINE, 2 )
Recipe( "poop", { Ingredient("petals", 4), Ingredient("seeds", 1) }, RECIPETABS.REFINE, 2 )
Recipe( "beardhair", { Ingredient("silk", 2), Ingredient("petals_evil", 4) }, RECIPETABS.REFINE, 2 )
Recipe( "horn", { Ingredient("beefalowool", 5), Ingredient("silk", 5), Ingredient("pigskin", 2) }, RECIPETABS.REFINE, 2 )
Recipe( "pigskin", { Ingredient("silk", 2), Ingredient("cutreeds", 2), }, RECIPETABS.REFINE, 2 )
Recipe( "tentaclespots", { Ingredient("turf_marsh", 4), Ingredient("papyrus", 2), Ingredient("silk", 3) }, RECIPETABS.REFINE, 2 )
Recipe( "petals_evil", { Ingredient("petals", 5), Ingredient("smallmeat", 1) }, RECIPETABS.REFINE, 2 )
Recipe( "houndstooth", { Ingredient("silk", 3), Ingredient("petals_evil", 3), Ingredient("stinger", 1) }, RECIPETABS.REFINE, 2 )
Recipe( "gears", { Ingredient("cutstone", 2), Ingredient("goldnugget", 2), Ingredient("flint", 3) }, RECIPETABS.REFINE, 2 )
Recipe( "spidergland", { Ingredient("silk", 2), Ingredient("honey", 1), Ingredient("ash", 1) }, RECIPETABS.REFINE, 2 )
Recipe( "redgem", { Ingredient("charcoal", 4), Ingredient("nightmarefuel", 5), Ingredient("feather_robin", 2) }, RECIPETABS.REFINE, 2)
Recipe( "bluegem", { Ingredient("petals_evil", 6), Ingredient("nightmarefuel", 5), Ingredient("feather_robin_winter", 2) }, RECIPETABS.REFINE, 2)