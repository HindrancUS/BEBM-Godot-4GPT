extends Node

const HUNTERS := {
	"Barbarian": {
		"mhp": 3, "str": 5, "dex": 4, "spd": 3, "mag": 0,
		"traits": ["fearless"],
		"abils": [],
		"ai": [],
		"binds": {"gag": 0, "hands": "rope", "legs": 0},
	},
	"Thief": {
		"mhp": 3, "str": 3, "dex": 5, "spd": 4, "mag": 0,
		"traits": [],
		"abils": ["Bolo", "Handcuffs", "Smokebomb"],
		"ai": [],
		"binds": {"gag": "leather gag", "hands": "handcuffs", "legs": 0},
	},
	"Wizard": {
		"mhp": 3, "str": 3, "dex": 2, "spd": 2, "mag": 5,
		"traits": [],
		"abils": ["Thinderbolt", "Shockwave", "MagicBinds", "Sleep"],
		"ai": ["caster"],
		"binds": {"gag": 0, "hands": 0, "legs": 0},
	},
}

const TARGETS := {
	"Amazon": {
		"mhp": 3, "str": 4, "dex": 4, "spd": 4, "mag": 0,
		"traits": ["fuery"],
		"abils": [],
		"ai": [],
		"binds": {"gag": "broad belt", "hands": "rope", "legs": "rope"},
	},
	"Sorceress": {
		"mhp": 3, "str": 2, "dex": 4, "spd": 2, "mag": 5,
		"traits": ["magicalwards", "mistrustful", "merciless", "proud"],
		"abils": ["Fireball", "Darkflame", "Charm"],
		"ai": ["caster"],
		"binds": {"gag": "necktie", "hands": "shawl", "legs": "belt"},
	},
	"Maid": {
		"mhp": 3, "str": 2, "dex": 3, "spd": 3, "mag": 0,
		"traits": ["docile", "merciful", "pacifist"],
		"abils": ["Guarded"],
		"ai": ["faint"],
		"binds": {"gag": "handkerchief", "hands": "cord", "legs": "rope"},
	},
}
