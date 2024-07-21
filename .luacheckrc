std = 'lua51'

quiet = 1 -- suppress report output for files without warnings.

only = {
	'011', -- syntax error
	'111', -- setting an undefined global variable
	'112', -- mutating an undefined global variable
	'113', -- accessing an undefined global variable
	'611', -- a line consists of nothing but whitespace
	'612', -- a line contains trailing whitespace
	'613', -- trailing whitespace in a string
	'614', -- trailing whitespace in a comment
	'621', -- inconsistent indentation (SPACE followed by TAB)
}

read_globals = {
	-- Addons and Libraries
	'AdiDebug',
	'LibStub',

	-- Lua API
	'geterrorhandler',

	-- FrameXML
	'CreateFrame',

	-- namespaces
	'C_PvP',
	'C_SpecializationInfo',
	'C_Spell',
	'C_SpellBook',
	'Enum',

	-- WoW API
	'GetFlyoutInfo',
	'GetFlyoutSlotInfo',
	'GetPvpTalentInfoByID',
	'InCombatLockdown',
	'IsPlayerSpell',
}