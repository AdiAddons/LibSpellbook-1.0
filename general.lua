local _, ns = ...

local lib = ns.lib

local FoundSpell = ns.FoundSpell
local CleanUp    = ns.CleanUp

local supportedBookTypes = {
	spell  = true,
	pet    = true,
	talent = true,
	pvp    = true,
}

-- ScanRanks

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
		local selectedPvpTalents = C_SpecializationInfo.GetAllSelectedPvpTalentIDs
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
					print('Differing ids from link and spellbook', id, spellId)
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

local function ScanSpells()
	local changed = false
	ns.generation = ns.generation + 1

	for tab = 1, 2 do
		local _, _, offset, numSpells = GetSpellTabInfo(tab)
		changed = ScanSpellbook('spell', numSpells, offset) or changed
	end

	local numPetSpells = HasPetSpells()
	if numPetSpells then
		changed = ScanSpellbook('pet', numPetSpells) or changed
	end

	local inCombat = InCombatLockdown()

	if not inCombat then
		changed = ScanTalents() or changed
	end

	changed = ScanPvpTalents() or changed
	-- TODO: scan ranks

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
end

lib:RegisterEvent('SPELLS_CHANGED', ScanSpells)
lib:RegisterEvent('PLAYER_ENTERING_WORLD', ScanSpells)
