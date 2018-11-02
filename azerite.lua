local _, ns = ...

local lib        = ns.lib
local FoundSpell = ns.FoundSpell
local CleanUp    = ns.CleanUp

local azeriteSlots = {
	[_G.INVSLOT_HEAD]     = true,
	[_G.INVSLOT_SHOULDER] = true,
	[_G.INVSLOT_CHEST]    = true,
}

-- azeriteSpells[spellID] = '135' -- slots concatenated
local azeriteSpells = {}

local function CleanCache(slot)
	local changed = false
	for spellId, slots in next, azeriteSpells do
		slots = slots:gsub(slot, '')
		if slots == '' then
			azeriteSpells[spellId] = nil
			CleanUp(spellId)
			changed = true
		else
			azeriteSpells[spellId] = slots
		end
	end

	return changed
end

local function GetSelectedPowers(itemLocation)
	local powers = {}
	local azeriteLevel = C_AzeriteItem.GetPowerLevel(C_AzeriteItem.FindActiveAzeriteItem())
	local tiers = C_AzeriteEmpoweredItem.GetAllTierInfo(itemLocation)

	for tier, info in next, tiers do
		-- the last tier is just increasing the item level
		if tier < #tiers and info.unlockLevel <= azeriteLevel then
			for _, powerID in next, info.azeritePowerIDs do
				if C_AzeriteEmpoweredItem.IsPowerSelected(itemLocation, powerID) then
					powers[powerID] = true
				end
			end
		end
	end

	return powers
end

local function ScanAzeriteItem(event, itemLocation)
	local changed = false

	if not itemLocation:IsEquipmentSlot() then
		return changed
	end

	local powers = GetSelectedPowers(itemLocation)

	for powerId in next, powers do
		local spellId = C_AzeriteEmpoweredItem.GetPowerInfo(powerId).spellID
		local slots = azeriteSpells[spellId]
		local slot = itemLocation:GetEquipmentSlot()
		if slots then
			if not slots:find(slot) then
				azeriteSpells[spellId] = slots .. slot
			end
		else
			azeriteSpells[spellId] = tostring(slot)
			changed = FoundSpell(spellId, GetSpellInfo(spellId), 'azerite') or changed
		end
	end

	return changed
end

local function ScanEquipmentSlot(event, slot, isEmpty)
	local changed = false

	if azeriteSlots[slot] then
		if isEmpty then
			changed = CleanCache(slot) or changed
			return changed
		end

		local itemLocation = ItemLocation:CreateFromEquipmentSlot(slot)
		local isAzeriteItem = C_AzeriteEmpoweredItem.IsAzeriteEmpoweredItem(itemLocation)
		if isAzeriteItem then
			changed = ScanAzeriteItem(event, itemLocation) or changed
		end
	end

	return changed
end

local function ScanAzeriteSpells(event)
	local changed = false
	for slot in next, azeriteSlots do
		local isEmpty = not GetInventoryItemID('player', slot)
		changed = ScanEquipmentSlot(event, slot, isEmpty) or changed
	end

	if changed then
		lib.callbacks:Fire('LibSpellbook_Spells_Changed')
	end

	if event == 'PLAYER_ENTERING_WORLD' then
		lib:UnregisterEvent(event, ScanAzeriteSpells)
	end
end

lib:RegisterEvent('PLAYER_EQUIPMENT_CHANGED', ScanEquipmentSlot)
lib:RegisterEvent('AZERITE_EMPOWERED_ITEM_SELECTION_UPDATED', ScanAzeriteItem)
lib:RegisterEvent('PLAYER_ENTERING_WORLD', ScanAzeriteSpells)
