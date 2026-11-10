local ADDON, NM = ...
_G.NevMakro = NM

local ICON_QUESTION = 134400
local MACRO_MAX = 255

NM.MACRO_MAX = MACRO_MAX

function NM.Print(msg)
    print("|cff4fc3f7NevMakro:|r " .. msg)
end

-- Kompatibilitaet: neue C_*-APIs zuerst, alte globale Funktionen als Rueckfall
function NM.SpellName(id)
    if C_Spell and C_Spell.GetSpellName then return C_Spell.GetSpellName(id) end
    if GetSpellInfo then return (GetSpellInfo(id)) end
end

function NM.PickupSpell(id)
    if C_Spell and C_Spell.PickupSpell then return C_Spell.PickupSpell(id) end
    return PickupSpell(id)
end

function NM.ItemName(id)
    if C_Item and C_Item.GetItemNameByID then return C_Item.GetItemNameByID(id) end
    return (GetItemInfo(id))
end

-- Liefert Name und Art ("spell"/"item") dessen, was gerade am Mauszeiger haengt
function NM.CursorName()
    local kind, a, b, c = GetCursorInfo()
    if kind == "spell" then
        local name = type(c) == "number" and NM.SpellName(c) or nil
        if not name and a and b and GetSpellBookItemName then name = GetSpellBookItemName(a, b) end
        return name, kind
    elseif kind == "item" then
        return NM.ItemName(a), kind
    end
end

local function Trunc(s, n)
    local out, cnt = {}, 0
    for ch in s:gmatch("[%z\1-\127\194-\244][\128-\191]*") do
        cnt = cnt + 1
        if cnt > n then break end
        out[#out + 1] = ch
    end
    return table.concat(out)
end
NM.Trunc = Trunc

---------------------------------------------------------------------------
-- Bausteine
---------------------------------------------------------------------------

NM.LONG_MAX = 1500
NM.MAX_BLOCKS = 40

NM.TARGETS = {
    { id = "normal",    label = "Ziel" },
    { id = "mouseover", label = "Mouseover", cond = "@mouseover,exists,nodead", fallback = true },
    { id = "focus",     label = "Fokus",     cond = "@focus,exists,nodead",     fallback = true },
    { id = "self",      label = "Selbst",    cond = "@player" },
    { id = "pet",       label = "Pet",       cond = "@pet,exists",              fallback = true },
    { id = "targettarget", label = "Ziel des Ziels", cond = "@targettarget,exists,nodead", fallback = true },
}

NM.COND_GROUPS = {
    { key = "mod", label = "Taste", opts = {
        { id = "any", label = "egal" },
        { id = "shift", label = "Shift", c = "mod:shift" },
        { id = "ctrl", label = "Strg", c = "mod:ctrl" },
        { id = "alt", label = "Alt", c = "mod:alt" },
        { id = "shiftctrl", label = "Shift + Strg", c = "mod:shift,mod:ctrl" },
        { id = "none", label = "keine Taste", c = "nomod" } } },
    { key = "combat", label = "Kampf", opts = {
        { id = "any", label = "egal" },
        { id = "combat", label = "im Kampf", c = "combat" },
        { id = "nocombat", label = "außer Kampf", c = "nocombat" } } },
    { key = "ttype", label = "Ziel ist", opts = {
        { id = "any", label = "egal" },
        { id = "harm", label = "feindlich", c = "harm,nodead" },
        { id = "help", label = "freundlich", c = "help,nodead" },
        { id = "dead", label = "tot", c = "dead" },
        { id = "exists", label = "vorhanden", c = "exists" },
        { id = "noexists", label = "nicht vorhanden", c = "noexists" } } },
    { key = "pet", label = "Pet", opts = {
        { id = "any", label = "egal" },
        { id = "pet", label = "vorhanden", c = "pet" },
        { id = "nopet", label = "keins", c = "nopet" } } },
    { key = "stealth", label = "Tarnung", opts = {
        { id = "any", label = "egal" },
        { id = "stealth", label = "getarnt", c = "stealth" },
        { id = "nostealth", label = "nicht getarnt", c = "nostealth" } } },
    { key = "mount", label = "Reittier", opts = {
        { id = "any", label = "egal" },
        { id = "mounted", label = "beritten", c = "mounted" },
        { id = "nomounted", label = "nicht beritten", c = "nomounted" } } },
    { key = "group", label = "Gruppe", opts = {
        { id = "any", label = "egal" },
        { id = "group", label = "in Gruppe/Raid", c = "group" },
        { id = "nogroup", label = "solo", c = "nogroup" } } },
}

NM.RESETS = {
    { id = "none", label = "kein Reset" },
    { id = "target", label = "Ziel", c = "target" },
    { id = "combat", label = "Kampf", c = "combat" },
    { id = "tc", label = "Ziel/Kampf", c = "target/combat" },
    { id = "10", label = "10 s", c = "10" },
    { id = "30", label = "30 s", c = "30" },
}

NM.BT_ORDER = { "spell", "castseq", "item", "petattack", "petfollow", "petpassive", "petdefensive",
    "startattack", "stopattack", "stopcasting", "targetenemy", "focus", "dismount", "cancelaura", "say", "raw" }

NM.BT = {
    spell        = { label = "Zauber",             cmd = "/cast",         param = true, targetable = true, tip = true },
    castseq      = { label = "Reihenfolge",        cmd = "/castsequence", param = true, reset = true },
    item         = { label = "Gegenstand",         cmd = "/use",          param = true, tip = true },
    petattack    = { label = "Pet: Angriff",       cmd = "/petattack",    defaults = "harm,nodead" },
    petfollow    = { label = "Pet: Folgen",        cmd = "/petfollow" },
    petpassive   = { label = "Pet: Passiv",        cmd = "/petpassive" },
    petdefensive = { label = "Pet: Defensiv",      cmd = "/petdefensive" },
    startattack  = { label = "Auto-Angriff an",    cmd = "/startattack",  defaults = "harm,nodead" },
    stopattack   = { label = "Auto-Angriff aus",   cmd = "/stopattack" },
    stopcasting  = { label = "Zauber abbrechen",   cmd = "/stopcasting" },
    targetenemy  = { label = "Nächster Feind",     cmd = "/targetenemy" },
    focus        = { label = "Fokus setzen",       cmd = "/focus",        targetable = true },
    dismount     = { label = "Absteigen",          cmd = "/dismount" },
    cancelaura   = { label = "Buff entfernen",     cmd = "/cancelaura",   param = true },
    say          = { label = "Sagen",              cmd = "/say",          param = true },
    raw          = { label = "Eigener Befehl",     raw = true,            param = true },
}

local function ById(list, id)
    for _, v in ipairs(list) do if v.id == id then return v end end
    return list[1]
end
NM.ById = ById

function NM.CondCount(b)
    local n = 0
    for _, g in ipairs(NM.COND_GROUPS) do
        local id = b.conds and b.conds[g.key]
        if id and id ~= "any" then n = n + 1 end
    end
    return n
end

-- Liefert Befehl und Klausel ("[Bedingungen] Argument") eines Bausteins
function NM.BuildParts(b)
    local bt = NM.BT[b.type]
    if not bt then return nil end
    local arg = strtrim(b.text or "")
    if bt.raw then
        if arg == "" then return nil end
        if arg:sub(1, 1) ~= "/" then arg = "/" .. arg end
        return "raw", arg, true
    end
    if bt.param and arg == "" then return nil end

    local base = {}
    if bt.defaults then base[#base + 1] = bt.defaults end
    for _, g in ipairs(NM.COND_GROUPS) do
        local id = b.conds and b.conds[g.key]
        local o = id and ById(g.opts, id)
        if o and o.c then base[#base + 1] = o.c end
    end

    local clause
    local tg = bt.targetable and ById(NM.TARGETS, b.target or "normal")
    if tg and tg.cond then
        local c1 = {}
        for i, v in ipairs(base) do c1[i] = v end
        c1[#c1 + 1] = tg.cond
        clause = "[" .. table.concat(c1, ",") .. "]"
        if tg.fallback then clause = clause .. "[" .. table.concat(base, ",") .. "]" end
    else
        clause = #base > 0 and ("[" .. table.concat(base, ",") .. "]") or ""
    end

    if bt.reset then
        local r = ById(NM.RESETS, b.reset or "none")
        if r.c then arg = "reset=" .. r.c .. " " .. arg end
    end
    if arg ~= "" then clause = (clause ~= "" and (clause .. " ") or "") .. arg end
    return bt.cmd, clause, false
end

-- Zeilenliste ohne #showtooltip, dazu der Name fuer das Leistensymbol
function NM.BuildLines(recipe)
    local out, first, lastCmd = {}, nil, nil
    for _, b in ipairs(recipe.blocks) do
        local cmd, clause, raw = NM.BuildParts(b)
        if cmd then
            local bt = NM.BT[b.type]
            if not first and bt.tip and not tonumber(strtrim(b.text)) then first = strtrim(b.text) end
            if raw then
                out[#out + 1] = clause
                lastCmd = nil
            elseif b.join == "or" and lastCmd == cmd and clause ~= "" then
                out[#out] = out[#out] .. "; " .. clause
            else
                out[#out + 1] = clause ~= "" and (cmd .. " " .. clause) or cmd
                lastCmd = cmd
            end
        end
    end
    return out, first
end

-- Liefert den Makrotext fuers Spiel und bei langen Rezepten zusaetzlich den Text fuer den Klick-Button
function NM.BuildBody(recipe)
    local lines, first = NM.BuildLines(recipe)
    if #lines == 0 then return "" end
    local head = recipe.showTooltip and ("#showtooltip" .. (first and (" " .. first) or "")) or nil
    if recipe.long and recipe.id then
        local outer = {}
        if head then outer[1] = head end
        outer[#outer + 1] = "/click NevMakroRun" .. recipe.id
        return table.concat(outer, "\n"), table.concat(lines, "\n")
    end
    if head then table.insert(lines, 1, head) end
    return table.concat(lines, "\n")
end

---------------------------------------------------------------------------
-- Lange Makros: gesicherter Klick-Button traegt den eigentlichen Text
---------------------------------------------------------------------------

function NM.EnsureRunButton(recipe)
    if InCombatLockdown() then return false end
    local name = "NevMakroRun" .. recipe.id
    local btn = _G[name] or CreateFrame("Button", name, UIParent, "SecureActionButtonTemplate")
    btn:RegisterForClicks("AnyUp", "AnyDown")
    btn:SetAttribute("useOnKeyDown", false)
    btn:SetAttribute("type", "macro")
    btn:SetAttribute("macrotext", recipe.inner or "")
    return true
end

function NM.SyncButtons()
    if InCombatLockdown() then NM.pendingSync = true return end
    NM.pendingSync = nil
    for _, r in ipairs(NM.db.recipes) do
        if r.long and r.id and r.inner then NM.EnsureRunButton(r) end
    end
end

function NM.SaveRecipe(r)
    local body, inner = NM.BuildBody(r)
    if body == "" then return nil, "Das Makro ist noch leer." end
    if inner then
        if #inner > NM.LONG_MAX then
            return nil, ("Das lange Makro hat %d Zeichen (maximal %d)."):format(#inner, NM.LONG_MAX)
        end
        r.inner = inner
        if not NM.EnsureRunButton(r) then return nil, "Im Kampf nicht möglich." end
    end
    local idx, name = NM.SaveMacro(r.name, body, r.perChar, r.macroName)
    if not idx then return nil, name end
    r.macroName = name
    return idx, name, #body, inner and #inner
end

---------------------------------------------------------------------------
-- Makros speichern / platzieren
---------------------------------------------------------------------------

-- oldName: bisheriger Name desselben Rezepts, damit Umbenennen die Leistenplatzierung behaelt
function NM.SaveMacro(name, body, perChar, oldName)
    if InCombatLockdown() then return nil, "Im Kampf nicht möglich." end
    name = Trunc(strtrim(name or ""), 16)
    if name == "" then return nil, "Bitte einen Namen eingeben." end
    if #body > MACRO_MAX then
        return nil, ("Makro ist %d Zeichen lang (maximal %d)."):format(#body, MACRO_MAX)
    end

    local function edit(idx)
        local ok = pcall(EditMacro, idx, name, nil, body)
        if not ok then ok = pcall(EditMacro, idx, name, ICON_QUESTION, body) end
        return ok
    end

    local idx = GetMacroIndexByName(name)
    if idx and idx > 0 then
        if not edit(idx) then return nil, "Makro konnte nicht geändert werden." end
        return GetMacroIndexByName(name), name
    end

    if oldName and oldName ~= name then
        local oidx = GetMacroIndexByName(oldName)
        if oidx and oidx > 0 then
            if not edit(oidx) then return nil, "Makro konnte nicht umbenannt werden." end
            return GetMacroIndexByName(name), name
        end
    end

    local numAcc, numChar = GetNumMacros()
    local maxAcc, maxChar = MAX_ACCOUNT_MACROS or 120, MAX_CHARACTER_MACROS or 18
    if perChar and numChar >= maxChar then
        return nil, ("Alle %d Charakter-Makroplätze sind belegt."):format(maxChar)
    elseif not perChar and numAcc >= maxAcc then
        return nil, ("Alle %d Account-Makroplätze sind belegt."):format(maxAcc)
    end

    local ok, res = pcall(CreateMacro, name, ICON_QUESTION, body, perChar and true or false)
    if not ok then return nil, "Makro konnte nicht angelegt werden: " .. tostring(res) end
    local nidx = GetMacroIndexByName(name)
    if not nidx or nidx == 0 then return nil, "Makro wurde nicht angelegt." end
    return nidx, name
end

---------------------------------------------------------------------------
-- Leisten-Assistent
---------------------------------------------------------------------------

-- Zusätze, die der Leisten-Assistent vor den Zauber setzt (Reihenfolge = Reihenfolge im Makro)
NM.BAR_EXTRAS = {
    { key = "stopCasting", label = "Zauber abbrechen", line = "/stopcasting",
      tip = "Bricht einen laufenden Zauber ab, bevor der neue beginnt (Spam-Tasten)." },
    { key = "dismount", label = "Absteigen", line = "/dismount",
      tip = "Steigt vom Reittier ab, bevor der Zauber gewirkt wird." },
    { key = "targetEnemy", label = "Feind anvisieren", line = "/targetenemy [noharm]",
      tip = "Visiert den nächsten Feind an, wenn du kein feindliches Ziel hast." },
    { key = "petAttack", label = "Pet-Angriff", line = "/petattack [harm,nodead]",
      tip = "Das Pet greift dein Ziel an (Hunter, Hexenmeister)." },
    { key = "startAttack", label = "Kampf starten", line = "/startattack [harm,nodead]",
      tip = "Schaltet den Auto-Angriff ein, sobald du einen Feind im Ziel hast." },
}

function NM.BuildBarBody(spellName, opts)
    local lines = { "#showtooltip " .. spellName }
    for _, ex in ipairs(NM.BAR_EXTRAS) do
        if opts[ex.key] then lines[#lines + 1] = ex.line end
    end
    local tg = ById(NM.TARGETS, opts.target or "normal")
    local clause = ""
    if tg.cond then
        clause = "[" .. tg.cond .. "]" .. (tg.fallback and "[] " or " ")
    end
    lines[#lines + 1] = "/cast " .. clause .. spellName
    return table.concat(lines, "\n")
end

function NM.ScanBar()
    local rows = {}
    local applied = NM.char.applied
    for slot = 1, 120 do
        local kind, id = GetActionInfo(slot)
        if kind == "spell" and id then
            local name = NM.SpellName(id)
            if name then
                rows[#rows + 1] = { slot = slot, kind = "spell", id = id, name = name, icon = GetActionTexture(slot) }
            end
        elseif kind == "macro" and applied[slot] then
            local info = applied[slot]
            if GetMacroInfo(id) == info.macro then
                rows[#rows + 1] = { slot = slot, kind = "ours", info = info, name = info.spell, icon = GetActionTexture(slot) }
            end
        end
    end
    return rows
end

local function UniqueName(base, own)
    local name = Trunc(base, 16)
    local n = 1
    while true do
        local idx = GetMacroIndexByName(name)
        if not idx or idx == 0 or name == own then return name end
        n = n + 1
        name = Trunc(base, 13) .. n
    end
end

function NM.ApplyPet(row, opts)
    if InCombatLockdown() then return false, "Im Kampf nicht möglich." end
    local body = NM.BuildBarBody(row.name, opts)
    local mname = UniqueName("NM-" .. row.name)
    local idx, err = NM.SaveMacro(mname, body, opts.perChar)
    if not idx then return false, err end
    mname = err

    ClearCursor()
    PickupMacro(idx)
    PlaceAction(row.slot)
    ClearCursor()

    local kind = GetActionInfo(row.slot)
    if kind ~= "macro" then return false, "Makro konnte nicht auf Platz " .. row.slot .. " gelegt werden." end
    NM.char.applied[row.slot] = { macro = mname, spell = row.name, id = row.id }
    return true
end

function NM.UndoPet(row)
    if InCombatLockdown() then return false, "Im Kampf nicht möglich." end
    local info = row.info
    local idx = GetMacroIndexByName(info.macro)
    ClearCursor()
    if idx and idx > 0 then DeleteMacro(idx) end
    NM.PickupSpell(info.id)
    PlaceAction(row.slot)
    ClearCursor()
    NM.char.applied[row.slot] = nil
    return true
end

---------------------------------------------------------------------------
-- Start
---------------------------------------------------------------------------

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("PLAYER_REGEN_ENABLED")
f:SetScript("OnEvent", function(_, event, name)
    if event == "PLAYER_LOGIN" then
        if NM.db then NM.SyncButtons() end
        return
    elseif event == "PLAYER_REGEN_ENABLED" then
        if NM.pendingSync and NM.db then NM.SyncButtons() end
        return
    end
    if name ~= ADDON then return end
    NevMakroDB = NevMakroDB or {}
    NevMakroChar = NevMakroChar or {}
    local db = NevMakroDB
    db.recipes = db.recipes or {}
    db.opts = db.opts or { petAttack = true, startAttack = false, perChar = true }
    db.opts.target = db.opts.target or "normal"
    db.nextId = db.nextId or 1
    NevMakroChar.applied = NevMakroChar.applied or {}
    NM.db, NM.char = db, NevMakroChar
    NM.Print("geladen. |cffffff00/nm|r öffnet den Makro-Baukasten, |cffffff00/nm leiste|r den Leisten-Assistenten.")
end)

SLASH_NEVMAKRO1 = "/nm"
SLASH_NEVMAKRO2 = "/nevmakro"
SlashCmdList["NEVMAKRO"] = function(msg)
    msg = strlower(strtrim(msg or ""))
    if NM.ToggleUI then NM.ToggleUI((msg == "leiste" or msg == "pet") and 2 or 1) end
end
