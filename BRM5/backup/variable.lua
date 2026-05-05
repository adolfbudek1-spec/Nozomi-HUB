local var = {}
var.MATERIAL_LIST = {
	"Asphalt", "SmoothPlastic", "Plastic", "Wood", "WoodPlanks", "Marble",
	"Granite", "Cobblestone", "Brick", "Concrete", "Metal",
	"DiamondPlate", "Foil", "Glass", "Neon", "Ice",
}

var.MAP = {
		["Locked Room"] = {
			Color = Color3.fromRGB(255, 140, 0),
			Location = {
				["Jewel Vault Key"] = Vector3.new(225.921173, 61.490303, -419.975952),
				["Plant Office Key"] = Vector3.new(930.580322265625, 70.2718276977539, 1214.3507080078125),
				["Bank Security Keycard"] = Vector3.new(-26.267191, 61.876308, 727.933655),
				["Research Gate Key"] = Vector3.new(-272.11932373046875, 52.62570190429688, -40.89002990722656),
				["Armory Gate Key"] = Vector3.new(635.6052856445312, 30.002111434936523, 366.84417724609375),
				["Conference Room Key"] = Vector3.new(771.127929, 50.724399, -599.473205),
				["Apartment 8 stone Key"] = Vector3.new(-15.152880668640137, 89.40548706054688, 701.5458984375),
				["Apartment 16 stone Key"] = Vector3.new(181.8520050048828, 87.84469604492188, 933.168212890625),
				["Utility Gate Key"] = Vector3.new(-292.013153, 58.080730, 361.684539),
				["Gate Key"] = Vector3.new(591.852050, 64.106178, -401.657165),
				["Meeting Room Key"] = Vector3.new(-193.502487, 109.679810, 828.702454),
				["Room 05 Key"] = Vector3.new(119.5669937133789, 129.85096740722656, 245.61355590820312),
				["Emergency Exit Key"] = Vector3.new(532.496948, 159.353073, 518.654479),
				["Safe Key"] = Vector3.new(-176.86761474609375, 137.1813507080078, 478.2950744628906),
			}
		},
		["Exfiltration Point"] = {
			Color = Color3.fromRGB(255, 50, 50),
			Location = {
				["Whitehall Exfil"]   = Vector3.new(-480.913757, 119.326133, 412.614044),
				["Raised Park Exfil"] = Vector3.new(438.363433, 128.790588, 1422.658203),
				["Pier Mall Exfil"]   = Vector3.new(1978.230957, 140.720733, 662.592712),
				["Helicopter Position"] = Vector3.new(1978.230957, 140.720733, 662.592712),
			}
		}
	}


return var