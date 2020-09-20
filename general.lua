local _, ns = ...
ns = ns['__LibSpellbook-1.0']

local lib = ns.lib
if not lib then return end

local FoundSpell = ns.FoundSpell
local CleanUp    = ns.CleanUp

local supportedBookTypes = {
	covenant = true,
	pet      = true,
	pvp      = true,
	spell    = true,
	talent   = true,
}

local playerClass
local spellUpgrades = {
	DEATHKNIGHT = {
		{
			316746, -- Marrowrend (Rank 2) Blood
			316664, -- Death and Decay (Rank 2) Blood
			316575, -- Heart Strike (Rank 2) Blood
			317133, -- Vampiric Blood (Rank 2) Blood
			317090, -- Heart Strike (Rank 3) Blood
			316616, -- Rune Tap (Rank 2) Blood
			316714, -- Veteran of the Third War (Rank 2) Blood
			316634, -- Blood Boil (Rank 2) Blood
		}, -- [1]
		{
			317230, -- Empower Rune Weapon (Rank 2) Frost
			316803, -- Frost Strike (Rank 2) Frost
			343252, -- Might of the Frozen Wastes (Rank 2) Frost
			316849, -- Pillar of Frost (Rank 2) Frost
			316838, -- Rime (Rank 2) Frost
			316794, -- Remorseless Winter (Rank 2) Frost
			317214, -- Killing Machine (Rank 2) Frost
			317198, -- Obliterate (Rank 2) Frost
			278223, -- Death Strike (Rank 2) Frost
		}, -- [2]
		{
			317234, -- Scourge Strike (Rank 2) Unholy
			278223, -- Death Strike (Rank 2) Unholy
			316867, -- Festering Strike (Rank 2) Unholy
			316916, -- Death and Decay (Rank 2) Unholy
			46584, -- Raise Dead (Rank 2) Unholy
			325554, -- Dark Transformation (Rank 2) Unholy
			343755, -- Apocalypse (Rank 3) Unholy
			316941, -- Death Coil (Rank 2) Unholy
			316961, -- Apocalypse (Rank 2) Unholy
		}, -- [3]
		[5] = {
			343257, -- Death's Advance (Rank 2) Death Knight
		},
		["patch"] = "9.0.2",
		["build"] = "35938",
	},
	DEMONHUNTER = {
		{
			320412, -- Chaos Nova (Rank 2) Havoc
			320420, -- Darkness (Rank 2) Havoc
			320645, -- Metamorphosis (Rank 4) Havoc
			320413, -- Chaos Strike (Rank 2) Havoc
			320421, -- Metamorphosis (Rank 3) Havoc
			320770, -- Unrestrained Fury (Rank 1) Havoc
			320654, -- Mastery: Demonic Presence (Rank 2) Havoc
			320383, -- Demonic Wards (Rank 2) Havoc
			320422, -- Metamorphosis (Rank 2) Havoc
			320407, -- Blur (Rank 2) Havoc
			320415, -- Eye Beam (Rank 2) Havoc
			320377, -- Immolation Aura (Rank 3) Havoc
			320416, -- Fel Rush (Rank 2) Havoc
			320402, -- Blade Dance (Rank 2) Havoc
			320635, -- Vengeful Retreat (Rank 2) Havoc
			343206, -- Chaos Strike (Rank 3) Havoc
			343017, -- Fel Rush (Rank 3) Havoc
			343006, -- Unrestrained Fury (Rank 2) Havoc
		}, -- [1]
		{
			320962, -- Fiery Brand (Rank 2) Vengeance
			320381, -- Demonic Wards (Rank 2) Vengeance
			320382, -- Demonic Wards (Rank 3) Vengeance
			320794, -- Sigil of Flame (Rank 2) Vengeance
			321299, -- Mastery: Fel Blood (Rank 2) Vengeance
			321028, -- Demon Spikes (Rank 2) Vengeance
			321067, -- Metamorphosis (Rank 2) Vengeance
			321021, -- Soul Cleave (Rank 2) Vengeance
			320378, -- Immolation Aura (Rank 3) Vengeance
			321068, -- Metamorphosis (Rank 3) Vengeance
			343207, -- Soul Cleave (Rank 3) Vengeance
			320387, -- Throw Glaive (Rank 3) Vengeance
			320639, -- Fel Devastation (Rank 2) Vengeance
			343016, -- Infernal Strike (Rank 3) Vengeance
			343010, -- Fiery Brand (Rank 3) Vengeance
			320791, -- Infernal Strike (Rank 2) Vengeance
			320418, -- Sigil of Misery (Rank 2) Vengeance
			320417, -- Sigil of Silence (Rank 2) Vengeance
		}, -- [2]
		[5] = {
			320386, -- Throw Glaive (Rank 2) Demon Hunter
			183782, -- Disrupt (Rank 2) Demon Hunter
			320364, -- Immolation Aura (Rank 2) Demon Hunter
			320361, -- Disrupt (Rank 3) Demon Hunter
			320379, -- Spectral Sight (Rank 2) Demon Hunter
			320313, -- Consume Magic (Rank 2) Demon Hunter
		},
		["patch"] = "9.0.2",
		["build"] = "35938",
	},
	DRUID = {
		{
			328023, -- Moonfire (Rank 3) Balance
			328022, -- Starsurge (Rank 2) Balance
			327541, -- Starfall (Rank 2) Balance
			231042, -- Moonkin Form (Rank 2) Balance
			231050, -- Sunfire (Rank 2) Balance
			328021, -- Eclipse (Rank 2) Balance
		}, -- [1]
		{
			231283, -- Swipe (Rank 2) Feral
			231052, -- Rake (Rank 2) Feral
			231057, -- Shred (Rank 2) Feral
			231055, -- Tiger's Fury (Rank 2) Feral
			343223, -- Berserk (Rank 2) Feral
			343232, -- Shred (Rank 4) Feral
			231063, -- Shred (Rank 3) Feral
		}, -- [2]
		{
			301768, -- Frenzied Regeneration (Rank 3) Guardian
			270100, -- Bear Form (Rank 2) Guardian
			273048, -- Frenzied Regeneration (Rank 2) Guardian
			343240, -- Berserk (Rank 2) Guardian
			288826, -- Stampeding Roar (Rank 2) Guardian
			231070, -- Ironfur (Rank 2) Guardian
			231064, -- Mangle (Rank 2) Guardian
			328767, -- Survival Instincts (Rank 2) Guardian
		}, -- [3]
		{
			328025, -- Wild Growth (Rank 2) Restoration
			326228, -- Innervate (Rank 2) Restoration
			231040, -- Rejuvenation (Rank 2) Restoration
			231050, -- Sunfire (Rank 2) Restoration
			197061, -- Ironbark (Rank 2) Restoration
		}, -- [4]
		{
			326646, -- Moonfire (Rank 2) Druid
			231032, -- Regrowth (Rank 2) Druid
			328024, -- Rebirth (Rank 2) Druid
			159456, -- Travel Form (Rank 2) Druid
			327993, -- Barkskin (Rank 2) Druid
			343238, -- Entangling Roots (Rank 2) Druid
		}, -- [5]
		["patch"] = "9.0.2",
		["build"] = "35938",
	},
	HUNTER = {
		{
			231546, -- Exhilaration (Rank 2) Beast Mastery
			231548, -- Bestial Wrath (Rank 2) Beast Mastery
			262838, -- Cobra Shot (Rank 2) Beast Mastery
		}, -- [1]
		{
			321281, -- Rapid Fire (Rank 2) Marksmanship
			231546, -- Exhilaration (Rank 2) Marksmanship
			321018, -- Steady Shot (Rank 2) Marksmanship
			321293, -- Arcane Shot (Rank 2) Marksmanship
		}, -- [2]
		{
			263186, -- Kill Command (Rank 2) Survival
			231550, -- Harpoon (Rank 2) Survival
			321290, -- Wildfire Bombs (Rank 2) Survival
			321026, -- Wing Clip (Rank 2) Survival
			294029, -- Carve (Rank 2) Survival
			231546, -- Exhilaration (Rank 2) Survival
		}, -- [3]
		[5] = {
			343241, -- Aspect of the Cheetah (Rank 2) Hunter
			343247, -- Improved Traps (Rank 2) Hunter
			343242, -- Mend Pet (Rank 2) Hunter
			343244, -- Tranquilizing Shot (Rank 2) Hunter
			343248, -- Kill Shot (Rank 2) Hunter
		},
		["patch"] = "9.0.2",
		["build"] = "35938",
	},
	MAGE = {
		{
			321745, -- Prismatic Barrier (Rank 2) Arcane
			231564, -- Arcane Barrage (Rank 2) Arcane
			321742, -- Presence of Mind (Rank 2) Arcane
			343215, -- Touch of the Magi (Rank 2) Arcane
			321739, -- Arcane Power (Rank 3) Arcane
			343208, -- Arcane Power (Rank 2) Arcane
			321747, -- Slow (Rank 2) Arcane
			231565, -- Evocation (Rank 2) Arcane
			321526, -- Arcane Barrage (Rank 3) Arcane
			321752, -- Arcane Explosion (Rank 2) Arcane
			321758, -- Clearcasting (Rank 2) Arcane
			321420, -- Clearcasting (Rank 3) Arcane
		}, -- [1]
		{
			157642, -- Fireball (Rank 2) Fire
			108853, -- Fire Blast (Rank 3) Fire
			321708, -- Blazing Barrier (Rank 2) Fire
			231568, -- Fire Blast (Rank 2) Fire
			231630, -- Critical Mass (Rank 2) Fire
			343230, -- Flamestrike (Rank 2) Fire
			321709, -- Flamestrike (Rank 3) Fire
			231567, -- Fire Blast (Rank 4) Fire
			343194, -- Fireball (Rank 3) Fire
			321710, -- Combustion (Rank 2) Fire
			321707, -- Dragon's Breath (Rank 2) Fire
			321711, -- Pyroblast (Rank 2) Fire
			343222, -- Phoenix Flames (Rank 2) Fire
		}, -- [2]
		{
			343180, -- Cone of Cold (Rank 2) Frost
			343177, -- Frostbolt (Rank 2) Frost
			231582, -- Shatter (Rank 2) Frost
			321702, -- Icy Veins (Rank 2) Frost
			321699, -- Cold Snap (Rank 2) Frost
			343175, -- Ice Lance (Rank 2) Frost
			321684, -- Mastery: Icicles (Rank 2) Frost
			343183, -- Frost Nova (Rank 2) Frost
			231584, -- Brain Freeze (Rank 2) Frost
			321696, -- Blizzard (Rank 3) Frost
			236662, -- Blizzard (Rank 2) Frost
		}, -- [3]
		[5] = {
		},
		["patch"] = "9.0.2",
		["build"] = "35938",
	},
	MONK = {
		{
			322510, -- Celestial Brew (Rank 2) Brewmaster
			343743, -- Purifying Brew (Rank 2) Brewmaster
			322522, -- Stagger (Rank 2) Brewmaster
			231602, -- Vivify (Rank 2) Brewmaster
			322700, -- Spinning Crane Kick (Rank 2) Brewmaster
			322740, -- Invoke Niuzao, the Black Ox (Rank 2) Brewmaster
			325095, -- Touch of Death (Rank 3) Brewmaster
			328682, -- Zen Meditation (Rank 2) Brewmaster
			322960, -- Fortifying Brew (Rank 2) Brewmaster
			322102, -- Expel Harm (Rank 2) Brewmaster
		}, -- [1]
		{
			325214, -- Expel Harm (Rank 3) Mistweaver
			281231, -- Renewing Mist (Rank 2) Mistweaver
			343744, -- Life Coccoon (Rank 2) Mistweaver
			231876, -- Thunder Focus Tea (Rank 2) Mistweaver
			344360, -- Touch of Death (Rank 3) Mistweaver
			322104, -- Expel Harm (Rank 2) Mistweaver
			325208, -- Fortifying Brew (Rank 2) Mistweaver
			231633, -- Essence Font (Rank 2) Mistweaver
			231605, -- Enveloping Mist (Rank 2) Mistweaver
			274586, -- Vivify (Rank 2) Mistweaver
		}, -- [2]
		{
			323999, -- Invoke Xuen, the White Tiger (Rank 2) Windwalker
			322106, -- Expel Harm (Rank 2) Windwalker
			231602, -- Vivify (Rank 2) Windwalker
			325208, -- Fortifying Brew (Rank 2) Windwalker
			344487, -- Flying Serpent Kick (Rank 2) Windwalker
			325215, -- Touch of Death (Rank 3) Windwalker
			343730, -- Spinning Crane Kick (Rank 2) Windwalker
			322719, -- Afterlife (Rank 2) Windwalker
			261916, -- Blackout Kick (Rank 2) Windwalker
			261917, -- Blackout Kick (Rank 3) Windwalker
			343731, -- Disable (Rank 2) Windwalker
			231627, -- Storm, Earth, and Fire (Rank 2) Windwalker
		}, -- [3]
		[5] = {
			328669, -- Roll (Rank 2) Monk
			328670, -- Provoke (Rank 2) Monk
			322113, -- Touch of Death (Rank 2) Monk
			344359, -- Paralysis (Rank 2) Monk
		},
		["patch"] = "9.0.2",
		["build"] = "35938",
	},
	PALADIN = {
		{
			231667, -- Crusader Strike (Rank 3) Holy
			231642, -- Beacon of Light (Rank 2) Holy
			272906, -- Holy Shock (Rank 2) Holy
			231644, -- Judgment (Rank 3) Holy
			327979, -- Avenging Wrath (Rank 3) Holy
		}, -- [1]
		{
			342348, -- Crusader Strike (Rank 2) Protection
			317854, -- Hammer of the Righteous (Rank 2) Protection
			315867, -- Judgment (Rank 3) Protection
			327980, -- Consecration (Rank 3) Protection
			344172, -- Consecration (Rank 2) Protection
			231665, -- Avenger's Shield (Rank 3) Protection
			231663, -- Judgment (Rank 4) Protection
			315921, -- Word of Glory (Rank 2) Protection
			317907, -- Mastery: Divine Bulwark (Rank 2) Protection
		}, -- [2]
		{
			327981, -- Blade of Justice (Rank 2) Retribution
			317912, -- Art of War (Rank 2) Retribution
			231663, -- Judgment (Rank 4) Retribution
			342348, -- Crusader Strike (Rank 2) Retribution
			231667, -- Crusader Strike (Rank 3) Retribution
			315867, -- Judgment (Rank 3) Retribution
		}, -- [3]
		[5] = {
			326730, -- Hammer of Wrath (Rank 2) Paladin
			317872, -- Avenging Wrath (Rank 2) Paladin
			200327, -- Blessing of Sacrifice (Rank 2) Paladin
			327977, -- Judgment (Rank 2) Paladin
			317906, -- Retribution Aura (Rank 2) Paladin
			317911, -- Divine Steed (Rank 2) Paladin
		},
		["patch"] = "9.0.2",
		["build"] = "35938",
	},
	PRIEST = {
		{
			322115, -- Power Word: Radiance (Rank 2) Discipline
			343726, -- Shadowfiend (Rank 2) Discipline
			322112, -- Holy Nova (Rank 2) Discipline
			262861, -- Smite (Rank 2) Discipline
			231682, -- Mind Blast (Rank 2) Discipline
			285485, -- Focused Will (Rank 2) Discipline
			319912, -- Prayer of Mending (Rank 2) Discipline
		}, -- [1]
		{
			319912, -- Prayer of Mending (Rank 2) Holy
			322112, -- Holy Nova (Rank 2) Holy
			63733, -- Holy Words (Rank 2) Holy
			285485, -- Focused Will (Rank 2) Holy
			262861, -- Smite (Rank 2) Holy
		}, -- [2]
		{
			231688, -- Void Bolt (Rank 2) Shadow
			322110, -- Vampiric Embrace (Rank 2) Shadow
			322108, -- Dispersion (Rank 2) Shadow
			322116, -- Vampiric Touch (Rank 2) Shadow
			319899, -- Mind Blast (Rank 2) Shadow
			319908, -- Void Eruption (Rank 2) Shadow
			319904, -- Shadowfiend (Rank 2) Shadow
		}, -- [3]
		[5] = {
			327820, -- Shadow Word: Pain (Rank 2) Priest
			327821, -- Fade (Rank 2) Priest
			322107, -- Shadow Word: Death (Rank 2) Priest
			327830, -- Mass Dispel (Rank 2) Priest
		},
		["patch"] = "9.0.2",
		["build"] = "35938",
	},
	ROGUE = {
		{
			279877, -- Sinister Strike (Rank 2) Assassination
			319473, -- Mastery: Potent Assassin (Rank 2) Assassination
			231719, -- Garrote (Rank 2) Assassination
			344362, -- Slice and Dice (Rank 2) Assassination
			319066, -- Wound Poison (Rank 2) Assassination
			319032, -- Shiv (Rank 2) Assassination
			330542, -- Improved Poisons (Rank 2) Assassination
		}, -- [1]
		{
			344363, -- Evasion (Rank 2) Outlaw
			235484, -- Between the Eyes (Rank 2) Outlaw
			279876, -- Sinister Strike (Rank 2) Outlaw
			331851, -- Blade Flurry (Rank 2) Outlaw
			319600, -- Grappling Hook (Rank 2) Outlaw
			35551, -- Combat Potency (Rank 2) Outlaw
		}, -- [2]
		{
			231716, -- Eviscerate (Rank 2) Subtlety
			231718, -- Shadowstrike (Rank 2) Subtlety
			319951, -- Shuriken Storm (Rank 2) Subtlety
			319949, -- Backstab (Rank 2) Subtlety
			319178, -- Shadow Vault (Rank 2) Subtlety
			328077, -- Symbols of Death (Rank 2) Subtlety
			245751, -- Sprint (Rank 3) Subtlety
		}, -- [3]
		[5] = {
			231691, -- Sprint (Rank 2) Rogue
		},
		["patch"] = "9.0.2",
		["build"] = "35938",
	},
	SHAMAN = {
		{
			231721, -- Lava Burst (Rank 2) Elemental
			343190, -- Elemental Fury (Rank 2) Elemental
			231722, -- Chain Lightning (Rank 2) Elemental
			343226, -- Fire Elemental Totem (Rank 2) Elemental
		}, -- [1]
		{
			319930, -- Stormbringer (Rank 2) Enhancement
			343211, -- Windfury Totem (Rank 2) Enhancement
			334308, -- Chain Lightning (Rank 2) Enhancement
			334033, -- Lava Lash (Rank 2) Enhancement
		}, -- [2]
		{
			231780, -- Chain Heal (Rank 2) Restoration
			343182, -- Mana Tide Totem (Rank 2) Restoration
			343205, -- Healing Tide Totem (Rank 2) Restoration
			231721, -- Lava Burst (Rank 2) Restoration
			231785, -- Tidal Waves (Rank 2) Restoration
		}, -- [3]
		[5] = {
			343198, -- Hex (Rank 2) Shaman
			343196, -- Astral Shift (Rank 2) Shaman
			318044, -- Lightning Bolt (Rank 2) Shaman
		},
		["patch"] = "9.0.2",
		["build"] = "35938",
	},
	WARLOCK = {
		{
			334342, -- Corruption (Rank 3) Affliction
			334315, -- Unstable Affliction (Rank 3) Affliction
			231811, -- Soulstone (Rank 2) Affliction
			231791, -- Unstable Affliction (Rank 2) Affliction
			317031, -- Corruption (Rank 2) Affliction
			231792, -- Agony (Rank 2) Affliction
		}, -- [1]
		{
			231811, -- Soulstone (Rank 2) Demonology
			334727, -- Call Dreadstalkers (Rank 2) Demonology
			334585, -- Summon Demonic Tyrant (Rank 2) Demonology
			334591, -- Fel Firebolt (Rank 2) Demonology
		}, -- [2]
		{
			231793, -- Conflagrate (Rank 2) Destruction
			335174, -- Havoc (Rank 2) Destruction
			231811, -- Soulstone (Rank 2) Destruction
			335189, -- Rain of Fire (Rank 2) Destruction
			335175, -- Summon Infernal (Rank 2) Destruction
		}, -- [3]
		[5] = {
			317138, -- Unending Resolve (Rank 2) Warlock
			342914, -- Fear (Rank 2) Warlock
		},
		["patch"] = "9.0.2",
		["build"] = "35938",
	},
	WARRIOR = {
		{
			316405, -- Execute (Rank 2) Arms
			315948, -- Die by the Sword (Rank 2) Arms
			316432, -- Sweeping Strikes (Rank 2) Arms
			261900, -- Mortal Strike (Rank 2) Arms
			316440, -- Overpower (Rank 2) Arms
			316534, -- Slam (Rank 3) Arms
			316433, -- Sweeping Strikes (Rank 3) Arms
			316411, -- Colossus Smash (Rank 2) Arms
			261901, -- Slam (Rank 2) Arms
			231830, -- Execute (Rank 3) Arms
			316441, -- Overpower (Rank 3) Arms
		}, -- [1]
		{
			316435, -- Whirlwind (Rank 2) Fury
			316424, -- Enrage (Rank 2) Fury
			316402, -- Execute (Rank 2) Fury
			316425, -- Enrage (Rank 3) Fury
			316474, -- Enraged Regeneration (Rank 2) Fury
			316403, -- Execute (Rank 3) Fury
			316452, -- Raging Blow (Rank 2) Fury
			231827, -- Execute (Rank 4) Fury
			12950, -- Whirlwind (Rank 3) Fury
			316453, -- Raging Blow (Rank 3) Fury
			316828, -- Recklessness (Rank 2) Fury
			316412, -- Rampage (Rank 2) Fury
			316537, -- Bloodthirst (Rank 2) Fury
			316519, -- Rampage (Rank 3) Fury
		}, -- [2]
		{
			316405, -- Execute (Rank 2) Protection
			231834, -- Shield Slam (Rank 3) Protection
			316428, -- Vanguard (Rank 2) Protection
			316414, -- Thunder Clap (Rank 2) Protection
			316778, -- Ignore Pain (Rank 2) Protection
			316790, -- Shield Slam (Rank 4) Protection
			316464, -- Demoralizing Shout (Rank 2) Protection
			316438, -- Avatar (Rank 2) Protection
			316834, -- Shield Wall (Rank 2) Protection
			231830, -- Execute (Rank 3) Protection
			316523, -- Shield Slam (Rank 2) Protection
		}, -- [3]
		[5] = {
			231847, -- Shield Block (Rank 2) Warrior
			319157, -- Charge (Rank 2) Warrior
			319158, -- Victory Rush (Rank 2) Warrior
			316825, -- Rallying Cry (Rank 2) Warrior
		},
		["patch"] = "9.0.2",
		["build"] = "35938",
	},
}

local function ScanUpgrades()
	playerClass = playerClass or select(2, UnitClass('player'))
	local upgrades = spellUpgrades[playerClass][5] or {}
	local spec = GetSpecialization()

	if spec > 0 and spec < 5 then
		for _, spell in next, spellUpgrades[playerClass][spec] or {} do
			upgrades[#upgrades + 1] = spell
		end
	end

	local changed = false
	for _, id in next, upgrades do
		if IsPlayerSpell(id) then
			local name = GetSpellInfo(id)
			changed = FoundSpell(id, name, 'upgrade') or changed
		end
	end

	return changed
end

local function ScanCovenantAbilities()
	local changed = false

	local spells = {
		[313347] = GetSpellInfo(313347), -- Covenant Ability
		[326526] = GetSpellInfo(326526), -- Signature Ability
	}

	for id, name in next, spells do
		local newName, _, _, _, _, _, newID = GetSpellInfo(name)
		if newID ~= id then
			changed = FoundSpell(newID, newName, 'covenant') or changed
		end
	end

	return changed
end

local function ScanFlyout(flyoutId, bookType)
	local _, _, numSlots, isKnown = GetFlyoutInfo(flyoutId)

	if not isKnown or numSlots < 1 then return end

	local changed = false
	for i = 1, numSlots do
		local _, id, isKnown, name = GetFlyoutSlotInfo(flyoutId, i)

		if isKnown then
			changed = FoundSpell(id, name, bookType) or changed
		end
	end

	return changed
end

local function ScanTalents()
	local changed = false
	local spec = GetActiveSpecGroup()
	for tier = 1, MAX_TALENT_TIERS do
		for column = 1, NUM_TALENT_COLUMNS do
			local _, _, _, _, _, spellId, _, _, _, isKnown, isGrantedByAura = GetTalentInfo(tier, column, spec)
			if isKnown or isGrantedByAura then
				local name = GetSpellInfo(spellId)
				changed = FoundSpell(spellId, name, 'talent') or changed
			end
		end
	end

	return changed
end

local function ScanPvpTalents()
	local changed = false
	if C_PvP.IsWarModeDesired() then
		local selectedPvpTalents = C_SpecializationInfo.GetAllSelectedPvpTalentIDs()
		for _, talentId in next, selectedPvpTalents do
			local _, name, _, _, _, spellId = GetPvpTalentInfoByID(talentId)
			if IsPlayerSpell(spellId) then
				changed = FoundSpell(spellId, name, 'pvp') or changed
			end
		end
	end
end

local function ScanSpellbook(bookType, numSpells, offset)
	local changed = false
	offset = offset or 0

	for i = offset + 1, offset + numSpells do
		local spellType, actionId = GetSpellBookItemInfo(i, bookType)
		if spellType == 'SPELL' then
			local name, _, spellId = GetSpellBookItemName(i, bookType)
			changed = FoundSpell(spellId, name, bookType) or changed

			local link = GetSpellLink(i, bookType)
			if link then
				local id, n = link:match('spell:(%d+):%d+\124h%[(.+)%]')
				id = tonumber(id)
				if id ~= spellId then
					-- TODO: check this
					-- print('Differing ids from link and spellbook', id, spellId)
					changed = FoundSpell(id, n, bookType) or changed
				end
			end
		elseif spellType == 'FLYOUT' then
			changed = ScanFlyout(actionId, bookType)
		elseif spellType == 'PETACTION' then
			local name, _, spellId = GetSpellBookItemName(i, bookType)
			changed = FoundSpell(spellId, name, bookType) or changed
		elseif not spellType or spellType == 'FUTURESPELL' then
			break
		end
	end

	return changed
end

local function ScanSpells(event)
	local changed = false
	ns.generation = ns.generation + 1

	for tab = 1, 3 do
		local _, _, offset, numSpells = GetSpellTabInfo(tab)
		changed = ScanSpellbook('spell', numSpells, offset) or changed
	end

	changed = ScanUpgrades() or changed

	local numPetSpells = HasPetSpells()
	if numPetSpells then
		changed = ScanSpellbook('pet', numPetSpells) or changed
	end

	local inCombat = InCombatLockdown()
	if not inCombat then
		changed = ScanTalents() or changed
	end

	changed = ScanPvpTalents() or changed
	changed = ScanCovenantAbilities() or changed

	local current = ns.generation
	for id, generation in next, ns.spells.lastSeen do
		if generation < current then
			changed = true
			local bookType = ns.spells.book[id]
			if supportedBookTypes[bookType] and (not inCombat or bookType ~= 'talent') then
				CleanUp(id)
			end
		end
	end

	if changed then
		lib.callbacks:Fire('LibSpellbook_Spells_Changed')
	end

	if event == 'PLAYER_ENTERING_WORLD' then
		lib:UnregisterEvent(event, ScanSpells)
	end
end

lib:RegisterEvent('PLAYER_ENTERING_WORLD', ScanSpells)
lib:RegisterEvent('PVP_TIMER_UPDATE', ScanSpells, true)
lib:RegisterEvent('SPELLS_CHANGED', ScanSpells)
