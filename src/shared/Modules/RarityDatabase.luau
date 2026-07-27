local RarityDatabase = {
	Common = {
		Weight = 60,
		Color = Color3.fromRGB(190, 190, 190), -- Gray
	},

	Uncommon = {
		Weight = 25,
		Color = Color3.fromRGB(85, 255, 85), -- Green
	},

	Rare = {
		Weight = 10,
		Color = Color3.fromRGB(85, 170, 255), -- Blue
	},

	Epic = {
		Weight = 4,
		Color = Color3.fromRGB(170, 85, 255), -- Purple
	},

	Legendary = {
		Weight = 1,
		Color = Color3.fromRGB(255, 170, 0), -- Orange
	},

	Mythic = {
		Weight = 0.5,
		Color = Color3.fromRGB(255, 0, 85), -- Pink/Red
	},

	Divine = {
		Weight = 0.2,
		Color = Color3.fromRGB(255, 255, 85), -- Gold
	},

	Celestial = {
		Weight = 0.05,
		Color = Color3.fromRGB(85, 255, 255), -- Cyan
	},

	Eternal = {
		Weight = 0.01,
		Color = Color3.fromRGB(255, 255, 255), -- White
	},

	Transcendent = {
		Weight = 0.005,
		Color = Color3.fromRGB(255, 80, 80), -- Crimson
	},

	Cosmic = {
		Weight = 0.002,
		Color = Color3.fromRGB(120, 70, 255), -- Deep Violet
	},

	Prismatic = {
		Weight = 0.001,
		Color = Color3.fromRGB(255, 105, 180), -- Rainbow-like theme (use gradient in UI)
	},

	Void = {
		Weight = 0.0005,
		Color = Color3.fromRGB(40, 40, 40), -- Dark Gray
	},

	Secret = {
		Weight = 0.0001,
		Color = Color3.fromRGB(0, 0, 0), -- Black
	},
}

return RarityDatabase