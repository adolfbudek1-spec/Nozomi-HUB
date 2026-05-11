--[[============== VARIABLE ==============]]
local Variable = {}

Variable.MATERIAL_LIST = {
	"Asphalt","SmoothPlastic","Plastic","Wood","WoodPlanks","Marble",
	"Granite","Cobblestone","Brick","Concrete","Metal",
	"DiamondPlate","Foil","Glass","Neon","Ice",
}

Variable.MAP = {
	["Locked Room"] = {
		Color = Color3.fromRGB(255, 140, 0),
		Location = {
			["Jewel Vault Key"]        = Vector3.new(225.921173,  61.490303, -419.975952),
			["Locker Room"]            = Vector3.new(106.772880,  29.601280, -200.412780),
			["Plant Office Key"]       = Vector3.new(930.580322,  70.271827, 1214.350708),
			["Bank Security Keycard"]  = Vector3.new(-26.267191,  61.876308,  727.933655),
			["Research Gate Key"]      = Vector3.new(-272.119323, 52.625701,  -40.890029),
			["Armory Gate Key"]        = Vector3.new(635.605285,  30.002111,  366.844177),
			["Conference Room Key"]    = Vector3.new(771.127929,  50.724399, -599.473205),
			["Apartment 8 stone Key"]  = Vector3.new(-15.152880,  89.405487,  701.545898),
			["Apartment 16 stone Key"] = Vector3.new(181.852005,  87.844696,  933.168212),
			["Utility Gate Key"]       = Vector3.new(-292.013153, 58.080730,  361.684539),
			["Gate Key"]               = Vector3.new(591.852050,  64.106178, -401.657165),
			["Meeting Room Key"]       = Vector3.new(-193.502487,109.679810,  828.702454),
			["Room 05 Key"]            = Vector3.new(119.566993, 129.850967,  245.613555),
			["Emergency Exit Key"]     = Vector3.new(532.496948, 159.353073,  518.654479),
			["Safe Key"]               = Vector3.new(-176.867614,137.181350,  478.295074),
		}
	},
	["Exfiltration Point"] = {
		Color = Color3.fromRGB(255, 50, 50),
		Location = {
			["Whitehall Exfil"]     = Vector3.new(-480.913757, 119.326133,  412.614044),
			["Raised Park Exfil"]   = Vector3.new(438.363433,  128.790588, 1422.658203),
			["Pier Mall Exfil"]     = Vector3.new(1978.230957, 140.720733,  662.592712),
			["Helicopter Position"] = Vector3.new(1978.230957, 140.720733,  662.592712),
		}
	}
}

-- Game place ID → mode name
Variable.GAME_MODES = {
	[4747446334] = "Zombie Mode",
	[3701546109] = "Open World",
}

return Variable
