STRINGS = GLOBAL.STRINGS
RECIPETABS = GLOBAL.RECIPETABS
Recipe = GLOBAL.Recipe
Ingredient = GLOBAL.Ingredient

STRINGS.RECIPE_DESC.SILK = "������ ������ ���������!"
STRINGS.RECIPE_DESC.WALRUSHAT = "���� ���� �����, �� � � ����� ��� �������!"
STRINGS.RECIPE_DESC.BUTTER = "��� ������ �������!"
STRINGS.RECIPE_DESC.LIVINGLOG = "������� � � ���� ���! ������� �� �������..."
STRINGS.RECIPE_DESC.KRAMPUS_SACK = "��� ���������, ���� �� �����������?"
STRINGS.RECIPE_DESC.TRUNK_SUMMER = "�� ����� �������..."
STRINGS.RECIPE_DESC.TRUNK_WINTER = "������� � �����!"
STRINGS.RECIPE_DESC.COOKEDMANDRAKE = "��� ������� ����������� ���������!"
STRINGS.RECIPE_DESC.TENTACLESPIKE = "�� ��������� �� ������ �����!"
STRINGS.RECIPE_DESC.POOP = "��� ������������� ����������?"
STRINGS.RECIPE_DESC.BEARDHAIR = "������� ���� ������ � ���� ����� ����!"
STRINGS.RECIPE_DESC.HORN = "���������� �����, �� �.�. Beefalo!"
STRINGS.RECIPE_DESC.PIGSKIN = "����� ���������..."
STRINGS.RECIPE_DESC.PETALS_EVIL = "���� ������ ������� �����"
STRINGS.RECIPE_DESC.TENTACLESPOTS = "����������� ���������. ��."
STRINGS.RECIPE_DESC.HOUNDSTOOTH = "������!"
STRINGS.RECIPE_DESC.GEARS = "�������� ��������� ������������� ... �����"
STRINGS.RECIPE_DESC.SPIDERGLAND = "������ ���� ���� ��-��"
STRINGS.RECIPE_DESC.REDGEM = "�� ����� �������� ��������"
STRINGS.RECIPE_DESC.BLUEGEM = "�� ������� ��� ����"


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