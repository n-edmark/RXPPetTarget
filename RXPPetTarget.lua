-- RXPPetTarget (self-written)
-- Copies the RestedXP "RXPTargeting" macro into a per-character macro
-- "RXPTargetPet" and appends /petattack (plus Bane of Agony for warlocks).
-- RestedXP itself is not modified; we watch its macro and mirror changes.

local SOURCE_MACRO = "RXPTargeting"
local PET_MACRO = "RXPTargetPet"
local PET_ICON = "Spell_Shadow_SummonSuccubus"
local MAX_LENGTH = 255
-- ==== Configuration ====
-- Lines appended after the target lines, per class (English class token).
-- Change the spell, drop /petattack, or add your own class. Classes not listed
-- here are ignored and get no macro. See README.md for examples.
local CLASS_LINES = {
    WARLOCK = "/petattack [harm,nodead]\n/cast [harm,nodead] Bane of Agony",
    HUNTER = "/petattack [harm,nodead]",
}

local _, playerClass = UnitClass("player")
local PET_LINE = CLASS_LINES[playerClass]
if not PET_LINE then return end

local pending = false

local function BuildBody(sourceBody)
    -- RestedXP writes a "//" comment when the step has no targets.
    if not sourceBody or sourceBody == "" or sourceBody:sub(1, 2) == "//" then
        return PET_LINE ~= "" and PET_LINE or sourceBody or ""
    end

    local body = sourceBody:gsub("\n+$", "")
    if PET_LINE ~= "" then body = body .. "\n" .. PET_LINE end
    -- Macros are capped at 255 characters; drop the oldest target lines first,
    -- the same way RestedXP trims its own macro.
    while #body > MAX_LENGTH do
        local trimmed = body:gsub("^[^\n]*\n", "", 1)
        if trimmed == body then break end
        body = trimmed
    end
    return body
end

local function Sync()
    if InCombatLockdown() then
        pending = true
        return
    end
    pending = false

    local _, _, sourceBody = GetMacroInfo(SOURCE_MACRO)
    if not sourceBody then return end

    local body = BuildBody(sourceBody)
    local _, _, currentBody = GetMacroInfo(PET_MACRO)

    if currentBody then
        if currentBody ~= body then
            EditMacro(PET_MACRO, PET_MACRO, nil, body)
        end
    else
        local _, numPerCharacter = GetNumMacros()
        if numPerCharacter >= (MAX_CHARACTER_MACROS or 18) then return end
        CreateMacro(PET_MACRO, PET_ICON, body, true)
    end
end

-- RestedXP caches its own local reference to EditMacro when it loads (before us),
-- so hooking the global EditMacro never sees its calls. Instead react to
-- UPDATE_MACROS and also poll once a second as a fallback. Sync() only writes
-- when the body actually differs, so our own EditMacro does not loop.
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")
frame:RegisterEvent("UPDATE_MACROS")
frame:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_REGEN_ENABLED" and not pending then return end
    Sync()
end)

C_Timer.NewTicker(1, function()
    if not InCombatLockdown() then Sync() end
end)
