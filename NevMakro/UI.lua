local _, NM = ...

local W, H = 880, 640
local RIGHT_X = 170
local ui

local uidn = 0
local function uid()
    uidn = uidn + 1
    return "NevMakroW" .. uidn
end

local function DeepCopy(t)
    if type(t) ~= "table" then return t end
    local c = {}
    for k, v in pairs(t) do c[k] = DeepCopy(v) end
    return c
end

---------------------------------------------------------------------------
-- Widget-Helfer (alle templated Widgets bekommen einen eindeutigen Namen)
---------------------------------------------------------------------------

local function Tip(frame, text)
    frame:HookScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(type(text) == "function" and text(self) or text, 1, 1, 1, 1, true)
        GameTooltip:Show()
    end)
    frame:HookScript("OnLeave", function() GameTooltip:Hide() end)
end

local FLAT = "Interface\\Buttons\\WHITE8X8"
local T = {
    bg = { 0.055, 0.06, 0.08, 0.97 }, panel = { 0.095, 0.105, 0.135, 1 }, field = { 0.04, 0.045, 0.06, 1 },
    edge = { 0.2, 0.22, 0.28, 1 }, btn = { 0.15, 0.17, 0.22, 1 }, btnHover = { 0.21, 0.24, 0.31, 1 },
    text = { 0.9, 0.92, 0.96 }, dim = { 0.55, 0.6, 0.68 }, accent = { 0.31, 0.76, 0.97 },
}

local function Flat(f, bg, edge)
    f:SetBackdrop({ bgFile = FLAT, edgeFile = FLAT, edgeSize = 1, insets = { left = 1, right = 1, top = 1, bottom = 1 } })
    f:SetBackdropColor(unpack(bg))
    f:SetBackdropBorderColor(unpack(edge or T.edge))
end

local function Panel(parent, bg)
    local f = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    Flat(f, bg or T.panel)
    return f
end

local function Button(parent, text, w, h, onclick)
    local b = CreateFrame("Button", uid(), parent, "BackdropTemplate")
    b:SetSize(w, h or 22)
    Flat(b, T.btn)
    local fs = b:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    fs:SetPoint("CENTER", 0, 0)
    b:SetFontString(fs)
    b:SetDisabledFontObject("GameFontHighlight")
    b:SetText(text)
    b:SetScript("OnEnter", function(self)
        if self:IsEnabled() then self:SetBackdropColor(unpack(T.btnHover)); self:SetBackdropBorderColor(unpack(T.accent)) end
    end)
    b:SetScript("OnLeave", function(self)
        if self:IsEnabled() then self:SetBackdropColor(unpack(T.btn)); self:SetBackdropBorderColor(unpack(T.edge)) end
    end)
    b:SetScript("OnMouseDown", function(self) if self:IsEnabled() then self:SetBackdropColor(0.08, 0.09, 0.12, 1) end end)
    b:SetScript("OnMouseUp", function(self) if self:IsEnabled() then self:SetBackdropColor(unpack(T.btnHover)) end end)
    b:SetScript("OnDisable", function(self)
        self:SetBackdropColor(T.accent[1] * 0.35, T.accent[2] * 0.35, T.accent[3] * 0.35, 1)
        self:SetBackdropBorderColor(unpack(T.accent))
    end)
    b:SetScript("OnEnable", function(self) self:SetBackdropColor(unpack(T.btn)); self:SetBackdropBorderColor(unpack(T.edge)) end)
    if onclick then b:SetScript("OnClick", onclick) end
    return b
end

local function Label(parent, text, font)
    local l = parent:CreateFontString(nil, "OVERLAY", font or "GameFontNormal")
    l:SetText(text or "")
    l:SetJustifyH("LEFT")
    if not font or font == "GameFontNormal" or font == "GameFontNormalLarge" then
        l:SetTextColor(unpack(T.accent))
    elseif font == "GameFontHighlight" or font == "GameFontHighlightSmall" then
        l:SetTextColor(unpack(T.text))
    else
        l:SetTextColor(unpack(T.dim))
    end
    return l
end

local function Check(parent, text, onclick)
    local c = CreateFrame("CheckButton", uid(), parent, "BackdropTemplate")
    c:SetSize(18, 18)
    Flat(c, T.field)
    c:SetCheckedTexture(FLAT)
    local t = c:GetCheckedTexture()
    t:SetVertexColor(unpack(T.accent))
    t:ClearAllPoints()
    t:SetPoint("TOPLEFT", 4, -4)
    t:SetPoint("BOTTOMRIGHT", -4, 4)
    c.label = Label(c, text, "GameFontHighlight")
    c.label:SetPoint("LEFT", c, "RIGHT", 6, 0)
    c:SetScript("OnEnter", function(self) self:SetBackdropBorderColor(unpack(T.accent)) end)
    c:SetScript("OnLeave", function(self) self:SetBackdropBorderColor(unpack(T.edge)) end)
    c:SetScript("OnClick", function(self) onclick(self:GetChecked() and true or false) end)
    return c
end

local function Edit(parent, w)
    local e = CreateFrame("EditBox", uid(), parent, "BackdropTemplate")
    e:SetSize(w, 22)
    Flat(e, T.field)
    e:SetFontObject("GameFontHighlight")
    e:SetAutoFocus(false)
    e:SetTextInsets(6, 6, 0, 0)
    e:SetScript("OnEscapePressed", e.ClearFocus)
    e:SetScript("OnEnterPressed", e.ClearFocus)
    e:SetScript("OnEditFocusGained", function(self) self:SetBackdropBorderColor(unpack(T.accent)) end)
    e:SetScript("OnEditFocusLost", function(self) self:SetBackdropBorderColor(unpack(T.edge)) end)
    return e
end

local function PopupFrame(parent, w, h)
    local f = CreateFrame("Frame", uid(), parent, "BackdropTemplate")
    f:SetFrameStrata("TOOLTIP")
    Flat(f, { 0.075, 0.085, 0.11, 0.99 }, T.accent)
    f:SetSize(w, h)
    f:EnableMouse(true)
    f:Hide()
    return f
end

local function ScrollList(parent, visible, rowH, buildRow, updateRow)
    local L = { rows = {}, data = {}, offset = 0, visible = visible }
    for i = 1, visible do
        local r = buildRow(parent, i)
        r:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, -(i - 1) * rowH)
        r:SetPoint("RIGHT", parent, "RIGHT", 0, 0)
        r:SetHeight(rowH)
        L.rows[i] = r
    end
    function L:Refresh()
        local maxOff = math.max(0, #self.data - self.visible)
        if self.offset > maxOff then self.offset = maxOff end
        for i, r in ipairs(self.rows) do
            local item = self.data[self.offset + i]
            if item then r:Show(); updateRow(r, item) else r:Hide() end
        end
    end
    function L:SetData(d) self.data = d; self:Refresh() end
    function L:Scroll(d) self.offset = math.max(0, self.offset + d); self:Refresh() end
    parent:EnableMouseWheel(true)
    parent:SetScript("OnMouseWheel", function(_, delta) L:Scroll(-delta) end)
    return L
end

local function CycleOption(list, id, step)
    for i, v in ipairs(list) do
        if v.id == id then return list[((i - 1 + step) % #list) + 1].id end
    end
    return list[1].id
end

---------------------------------------------------------------------------
-- Baukasten
---------------------------------------------------------------------------

local cur  -- aktuell bearbeitetes Rezept
local RefreshBuilder

local function RefreshPreview()
    local b = ui.builder
    if not cur then
        b.preview:SetText("")
        b.counter:SetText("")
        return
    end
    local body, inner = NM.BuildBody(cur)
    local text, n, max
    if body == "" then
        text = "|cff888888(noch leer)|r"
        n, max = 0, cur.long and NM.LONG_MAX or NM.MACRO_MAX
    elseif inner then
        text = "|cffaaaaaaIm Spiel-Makro:|r\n" .. body .. "\n|cffaaaaaaIm Klick-Button:|r\n" .. inner
        n, max = #inner, NM.LONG_MAX
    else
        text, n, max = body, #body, NM.MACRO_MAX
    end
    b.preview:SetText(text)
    b.counter:SetText(("%s%d / %d Zeichen|r"):format(n > max and "|cffff5555" or "|cffaaaaaa", n, max))
end

local function CondSummary(b)
    local parts = {}
    for _, g in ipairs(NM.COND_GROUPS) do
        local id = b.conds and b.conds[g.key]
        if id and id ~= "any" then parts[#parts + 1] = g.label .. ": " .. NM.ById(g.opts, id).label end
    end
    return table.concat(parts, "\n")
end

local function BuildBlockRow(parent)
    local row = CreateFrame("Frame", nil, parent)
    row.bg = row:CreateTexture(nil, "BACKGROUND")
    row.bg:SetPoint("TOPLEFT", 0, -1)
    row.bg:SetPoint("BOTTOMRIGHT", 0, 1)
    row.bg:SetColorTexture(1, 1, 1, 0.035)
    row.label = Label(row, "", "GameFontNormal")
    row.label:SetWidth(104)
    row.label:SetPoint("LEFT", 6, 0)

    row.del = Button(row, "X", 22, 22, function(self)
        local r = self:GetParent()
        table.remove(cur.blocks, r.index)
        RefreshBuilder()
    end)
    row.del:SetPoint("RIGHT", 0, 0)
    Tip(row.del, "Baustein entfernen")

    row.dup = Button(row, "+", 22, 22, function(self)
        local r = self:GetParent()
        if #cur.blocks >= NM.MAX_BLOCKS then return end
        table.insert(cur.blocks, r.index + 1, DeepCopy(r.block))
        RefreshBuilder()
    end)
    row.dup:SetPoint("RIGHT", row.del, "LEFT", -1, 0)
    Tip(row.dup, "Baustein duplizieren (z.B. denselben Zauber mit anderer Taste oder anderem Ziel)")

    row.down = Button(row, "v", 22, 22, function(self)
        local r, bl = self:GetParent(), cur.blocks
        if r.index < #bl then bl[r.index], bl[r.index + 1] = bl[r.index + 1], bl[r.index]; RefreshBuilder() end
    end)
    row.down:SetPoint("RIGHT", row.dup, "LEFT", -1, 0)
    Tip(row.down, "Nach unten")

    row.up = Button(row, "^", 22, 22, function(self)
        local r, bl = self:GetParent(), cur.blocks
        if r.index > 1 then bl[r.index], bl[r.index - 1] = bl[r.index - 1], bl[r.index]; RefreshBuilder() end
    end)
    row.up:SetPoint("RIGHT", row.down, "LEFT", -1, 0)
    Tip(row.up, "Nach oben")

    row.join = Button(row, "", 56, 22, function(self)
        local b = self:GetParent().block
        b.join = (b.join == "or") and "and" or "or"
        RefreshBuilder()
    end)
    row.join:SetPoint("RIGHT", row.up, "LEFT", -6, 0)
    Tip(row.join, "Zeile: eigene Makro-Zeile, alle Zeilen werden nacheinander versucht.\n\nODER: wird mit dem Baustein darüber zu EINER Zeile verbunden - der erste Fall, dessen Bedingungen zutreffen, gewinnt (z.B. Shift = auf mich selbst, sonst auf das Ziel).")

    row.cond = Button(row, "", 84, 22, function(self)
        ui.builder.ShowCond(self:GetParent())
    end)
    row.cond:SetPoint("RIGHT", row.join, "LEFT", -2, 0)
    Tip(row.cond, function(self)
        local s = CondSummary(self:GetParent().block)
        return "Bedingungen: wann dieser Baustein greift (Taste, Kampf, Zielart, Pet, Tarnung, Reittier, Gruppe)." .. (s ~= "" and ("\n\nAktiv:\n" .. s) or "")
    end)

    row.target = Button(row, "", 96, 22, function(self)
        local b = self:GetParent().block
        b.target = CycleOption(NM.TARGETS, b.target or "normal", 1)
        RefreshBuilder()
    end)
    row.target:SetPoint("RIGHT", row.cond, "LEFT", -2, 0)
    Tip(row.target, "Ziel. Klick wechselt: Ziel, Mouseover (sonst Ziel), Fokus, Selbst, Pet, Ziel des Ziels.")

    row.reset = Button(row, "", 96, 22, function(self)
        local b = self:GetParent().block
        b.reset = CycleOption(NM.RESETS, b.reset or "none", 1)
        RefreshBuilder()
    end)
    row.reset:SetPoint("RIGHT", row.cond, "LEFT", -2, 0)
    Tip(row.reset, "Wann die Reihenfolge von vorn beginnt. Klick wechselt: kein Reset, Ziel, Kampf, Ziel/Kampf, 10 s, 30 s.")

    row.edit = Edit(row, 100)
    row.edit:SetScript("OnTextChanged", function(self, user)
        if user then
            self:GetParent().block.text = self:GetText()
            RefreshPreview()
        end
    end)
    local function receive(self)
        local name = NM.CursorName()
        if name then
            local b = self:GetParent().block
            if b.type == "castseq" and strtrim(self:GetText()) ~= "" then name = self:GetText() .. ", " .. name end
            self:SetText(name)
            b.text = name
            ClearCursor()
            RefreshPreview()
        end
    end
    row.edit:SetScript("OnReceiveDrag", receive)
    row.edit:HookScript("OnMouseUp", function(self) if GetCursorInfo() then receive(self) end end)
    Tip(row.edit, function(self)
        local t = self:GetParent().block.type
        if t == "say" then return "Text, der gesagt wird." end
        if t == "raw" then return "Beliebige Makro-Zeile, z.B. /cast [mod:alt] Frostblitz. Bedingungen und Ziel musst du hier selbst schreiben." end
        if t == "item" then return "Gegenstand aus Taschen oder Leiste hierher ziehen, Namen tippen oder Slot-Nummer (13 oder 14 für Schmuckstücke)." end
        if t == "castseq" then return "Zauber nacheinander, durch Komma getrennt. Zauber hierher ziehen hängt sie hinten an." end
        if t == "cancelaura" then return "Name des Buffs, der entfernt wird." end
        return "Zauber aus dem Zauberbuch oder von der Leiste hierher ziehen, oder Namen tippen."
    end)
    return row
end

local function UpdateBlockRow(row, b)
    local idx
    for i, x in ipairs(cur.blocks) do if x == b then idx = i break end end
    row.block, row.index = b, idx
    local bt = NM.BT[b.type]
    if not bt then return end

    row.label:SetText(bt.label)
    row.cond:SetShown(not bt.raw)
    row.target:SetShown(bt.targetable and true or false)
    row.reset:SetShown(bt.reset and true or false)
    row.join:SetShown(idx > 1 and not bt.raw)
    row.edit:SetShown(bt.param and true or false)

    local n = NM.CondCount(b)
    row.cond:SetText(n > 0 and ("Wenn (" .. n .. ")") or "Wenn ...")
    row.join:SetText(b.join == "or" and "ODER" or "Zeile")
    row.target:SetText(NM.ById(NM.TARGETS, b.target or "normal").label)
    row.reset:SetText(NM.ById(NM.RESETS, b.reset or "none").label)

    if bt.param then
        local right = (bt.targetable and row.target) or (bt.reset and row.reset) or (not bt.raw and row.cond) or row.up
        row.edit:ClearAllPoints()
        row.edit:SetPoint("LEFT", row.label, "RIGHT", 6, 0)
        row.edit:SetPoint("RIGHT", right, "LEFT", -6, 0)
        if row.edit:GetText() ~= (b.text or "") then row.edit:SetText(b.text or "") end
        row.edit:SetCursorPosition(0)
    end
end

local function AddBlock(b)
    if not cur then return end
    if #cur.blocks >= NM.MAX_BLOCKS then
        NM.Print("Maximal " .. NM.MAX_BLOCKS .. " Bausteine pro Makro.")
        return
    end
    b.text = b.text or ""
    b.target = b.target or "normal"
    b.conds = b.conds or {}
    cur.blocks[#cur.blocks + 1] = b
end

local function SelectRecipe(r)
    cur = r
    RefreshBuilder()
end

local function NewRecipe()
    local db = NM.db
    local r = { id = db.nextId, name = "Neues Makro", showTooltip = true, perChar = true, long = false, blocks = {} }
    db.nextId = db.nextId + 1
    table.insert(db.recipes, r)
    SelectRecipe(r)
end

local function DuplicateRecipe()
    if not cur then return end
    local db = NM.db
    local r = DeepCopy(cur)
    r.id = db.nextId
    db.nextId = db.nextId + 1
    r.macroName, r.inner = nil, nil
    r.name = NM.Trunc(cur.name, 14) .. " 2"
    table.insert(db.recipes, r)
    SelectRecipe(r)
end

function RefreshBuilder()
    local b = ui.builder
    b.recipeList:SetData(NM.db.recipes)
    local has = cur ~= nil
    b.editor:SetShown(has)
    if b.condPop:IsShown() then
        local ok = false
        if has then for _, x in ipairs(cur.blocks) do if x == b.condPop.block then ok = true break end end end
        if ok then b.condPop:Update() else b.condPop:Hide() end
    end
    if not has then return end

    if b.name:GetText() ~= cur.name then b.name:SetText(cur.name) end
    b.tooltipCheck:SetChecked(cur.showTooltip)
    b.perCharCheck:SetChecked(cur.perChar)
    b.longCheck:SetChecked(cur.long)
    b.blockList:SetData(cur.blocks)
    RefreshPreview()
end

local function SaveAndPickup()
    if not cur then return end
    local idx, name, len, innerLen = NM.SaveRecipe(cur)
    if not idx then NM.Print("|cffff5555" .. tostring(name) .. "|r") return end
    if innerLen then
        NM.Print(("Makro \"%s\" gespeichert (Klick-Makro, %d Zeichen Text)."):format(name, innerLen))
    else
        NM.Print(("Makro \"%s\" gespeichert (%d Zeichen)."):format(name, len))
    end

    local slot = tonumber(ui.builder.slotBox:GetText())
    ClearCursor()
    PickupMacro(idx)
    if slot and slot >= 1 and slot <= 120 then
        PlaceAction(slot)
        ClearCursor()
        NM.Print("Auf Leistenplatz " .. slot .. " gelegt.")
    else
        NM.Print("Das Makro hängt am Mauszeiger - jetzt auf einen Leistenplatz klicken.")
    end
    RefreshBuilder()
end

local TEMPLATES = {
    { label = "Pet-Angriff + Zauber", make = function()
        AddBlock({ type = "petattack" })
        AddBlock({ type = "spell" })
    end },
    { label = "Zauber auf Mouseover", make = function()
        AddBlock({ type = "spell", target = "mouseover" })
    end },
    { label = "Shift = Selbst, sonst Ziel", make = function()
        AddBlock({ type = "spell", target = "self", conds = { mod = "shift" } })
        AddBlock({ type = "spell", join = "or" })
    end },
    { label = "Schmuckstück + Zauber", make = function()
        AddBlock({ type = "item", text = "13" })
        AddBlock({ type = "spell" })
    end },
    { label = "Rotation (Reihenfolge)", make = function()
        AddBlock({ type = "castseq", reset = "tc" })
    end },
    { label = "Pet-Steuerung (Shift/Strg)", make = function()
        AddBlock({ type = "petattack", conds = { mod = "none" } })
        AddBlock({ type = "petfollow", conds = { mod = "shift" } })
        AddBlock({ type = "petpassive", conds = { mod = "ctrl" } })
    end },
}

local function BuildCondPopup(parent)
    local pop = PopupFrame(parent, 280, 40 + #NM.COND_GROUPS * 26 + 34)
    local title = Label(pop, "Bedingungen (alle müssen zutreffen)", "GameFontNormal")
    title:SetPoint("TOPLEFT", 12, -12)
    pop.btns = {}
    for i, g in ipairs(NM.COND_GROUPS) do
        local y = -36 - (i - 1) * 26
        Label(pop, g.label, "GameFontHighlight"):SetPoint("TOPLEFT", 12, y - 4)
        local b = Button(pop, "", 150, 22, function()
            local blk = pop.block
            blk.conds = blk.conds or {}
            blk.conds[g.key] = CycleOption(g.opts, blk.conds[g.key] or "any", 1)
            RefreshBuilder()
        end)
        b:SetPoint("TOPRIGHT", -12, y)
        pop.btns[i] = b
    end
    local done = Button(pop, "Fertig", 100, 22, function() pop:Hide() end)
    done:SetPoint("BOTTOM", 0, 10)
    function pop:Update()
        for i, g in ipairs(NM.COND_GROUPS) do
            local id = self.block.conds and self.block.conds[g.key] or "any"
            local o = NM.ById(g.opts, id)
            self.btns[i]:SetText(id ~= "any" and ("|cff55ff55" .. o.label .. "|r") or o.label)
        end
    end
    return pop
end

local function BuildBuilder(parent)
    local p = CreateFrame("Frame", nil, parent)
    p:SetAllPoints()
    ui.builder = p

    local lp = Panel(p)
    lp:SetPoint("TOPLEFT", -8, 8)
    lp:SetPoint("BOTTOMLEFT", -8, -8)
    lp:SetWidth(RIGHT_X - 4)
    local ep = Panel(p)
    ep:SetPoint("TOPLEFT", RIGHT_X, 8)
    ep:SetPoint("BOTTOMRIGHT", 8, -8)

    Label(p, "MEINE MAKROS", "GameFontNormalSmall"):SetPoint("TOPLEFT", 0, 0)

    local listHost = CreateFrame("Frame", nil, p)
    listHost:SetPoint("TOPLEFT", 0, -22)
    listHost:SetSize(150, 13 * 22)
    p.recipeList = ScrollList(listHost, 13, 22, function(host)
        local b = CreateFrame("Button", nil, host)
        b:SetHighlightTexture(FLAT)
        b:GetHighlightTexture():SetVertexColor(1, 1, 1, 0.06)
        b.sel = b:CreateTexture(nil, "BACKGROUND")
        b.sel:SetAllPoints()
        b.sel:SetColorTexture(T.accent[1], T.accent[2], T.accent[3], 0.22)
        b.bar = b:CreateTexture(nil, "ARTWORK")
        b.bar:SetColorTexture(unpack(T.accent))
        b.bar:SetPoint("TOPLEFT", 0, 0)
        b.bar:SetPoint("BOTTOMLEFT", 0, 0)
        b.bar:SetWidth(3)
        b.text = Label(b, "", "GameFontHighlight")
        b.text:SetPoint("LEFT", 10, 0)
        b.text:SetPoint("RIGHT", -4, 0)
        b:SetScript("OnClick", function(self) SelectRecipe(self.recipe) end)
        return b
    end, function(row, r)
        row.recipe = r
        row.text:SetText(r.name ~= "" and r.name or "(ohne Name)")
        row.sel:SetShown(r == cur)
        row.bar:SetShown(r == cur)
    end)

    local up = Button(p, "Hoch", 78, 20, function() p.recipeList:Scroll(-1) end)
    up:SetPoint("TOPLEFT", listHost, "BOTTOMLEFT", 0, -4)
    local down = Button(p, "Runter", 78, 20, function() p.recipeList:Scroll(1) end)
    down:SetPoint("LEFT", up, "RIGHT", 4, 0)
    local new = Button(p, "Neues Makro", 160, 24, NewRecipe)
    new:SetPoint("TOPLEFT", up, "BOTTOMLEFT", 0, -6)
    local dup = Button(p, "Makro duplizieren", 160, 24, DuplicateRecipe)
    dup:SetPoint("TOPLEFT", new, "BOTTOMLEFT", 0, -4)

    local share = Button(p, "Teilen (Code)", 160, 24, function() ui.ShowShare(false) end)
    share:SetPoint("TOPLEFT", dup, "BOTTOMLEFT", 0, -4)
    Tip(share, "Erzeugt einen Text-Code dieses Makros, den du Freunden schicken kannst.")
    local imp = Button(p, "Importieren", 160, 24, function() ui.ShowShare(true) end)
    imp:SetPoint("TOPLEFT", share, "BOTTOMLEFT", 0, -4)
    Tip(imp, "Code von einem Freund einfügen und als neues Makro übernehmen.")

    local hint = Label(p, "Tipp: Zauber und Gegenstände lassen sich aus Zauberbuch, Taschen oder Leiste direkt in die Textfelder ziehen.", "GameFontDisableSmall")
    hint:SetPoint("TOPLEFT", imp, "BOTTOMLEFT", 0, -10)
    hint:SetWidth(160)
    hint:SetJustifyV("TOP")

    p.condPop = BuildCondPopup(p)
    function p.ShowCond(row)
        local pop = p.condPop
        if pop:IsShown() and pop.block == row.block then pop:Hide() return end
        pop.block = row.block
        pop:ClearAllPoints()
        pop:SetPoint("TOPRIGHT", row.cond, "BOTTOMRIGHT", 0, -2)
        pop:Update()
        pop:Show()
    end

    -- Editor
    local e = CreateFrame("Frame", nil, p)
    e:SetPoint("TOPLEFT", RIGHT_X + 10, -2)
    e:SetPoint("BOTTOMRIGHT", -2, 0)
    p.editor = e

    Label(e, "Name"):SetPoint("TOPLEFT", 0, -4)
    p.name = Edit(e, 150)
    p.name:SetPoint("TOPLEFT", 44, 0)
    p.name:SetMaxLetters(16)
    p.name:SetScript("OnTextChanged", function(self, user)
        if user and cur then
            cur.name = self:GetText()
            p.recipeList:Refresh()
        end
    end)

    p.tooltipCheck = Check(e, "Icon folgt dem Zauber", function(v) cur.showTooltip = v; RefreshPreview() end)
    p.tooltipCheck:SetPoint("LEFT", p.name, "RIGHT", 14, 0)
    Tip(p.tooltipCheck, "#showtooltip: Das Leistensymbol zeigt den ersten Zauber des Makros samt Abklingzeit.")

    p.perCharCheck = Check(e, "Nur dieser Charakter", function(v) cur.perChar = v end)
    p.perCharCheck:SetPoint("TOPLEFT", 44, -24)
    Tip(p.perCharCheck, "An: Charakter-Makro (wenige Plätze). Aus: Account-Makro, für alle Charaktere sichtbar. Wirkt nur beim ersten Speichern.")

    p.longCheck = Check(e, "Langes Makro (Klick-Button)", function(v)
        cur.long = v
        if v and not cur.id then cur.id = NM.db.nextId; NM.db.nextId = cur.id + 1 end
        RefreshBuilder()
    end)
    p.longCheck:SetPoint("LEFT", p.perCharCheck, "RIGHT", 160, 0)
    Tip(p.longCheck, "Normale Makros sind im Spiel auf 255 Zeichen begrenzt. Als langes Makro liegt im Spiel nur eine Zeile (/click ...), der eigentliche Text (bis " .. NM.LONG_MAX .. " Zeichen) steckt in einem Klick-Button des Addons. Änderungen werden nur außerhalb des Kampfs übernommen.")

    Label(e, "Bausteine (werden von oben nach unten ausgeführt)"):SetPoint("TOPLEFT", 0, -52)
    local blockHost = CreateFrame("Frame", nil, e)
    blockHost:SetPoint("TOPLEFT", 0, -72)
    blockHost:SetPoint("RIGHT", 0, 0)
    blockHost:SetHeight(8 * 26)
    p.blockList = ScrollList(blockHost, 8, 26, BuildBlockRow, UpdateBlockRow)

    local menu = PopupFrame(p, 410, 16 * 22 + 12)
    p.menu = menu
    local ty, ky = -6, -6
    local function menuButton(text, x, y, fn)
        local b = Button(menu, text, 190, 22, function() menu:Hide(); fn(); RefreshBuilder() end)
        b:SetPoint("TOPLEFT", x, y)
    end
    for _, id in ipairs(NM.BT_ORDER) do
        menuButton(NM.BT[id].label, 6, ty, function() AddBlock({ type = id }) end)
        ty = ty - 22
    end
    Label(menu, "Vorlagen", "GameFontNormalSmall"):SetPoint("TOPLEFT", 214, -6)
    ky = -22
    for _, t in ipairs(TEMPLATES) do
        menuButton(t.label, 212, ky, t.make)
        ky = ky - 22
    end

    local add = Button(e, "+ Baustein", 110, 24, function()
        if menu:IsShown() then menu:Hide() else menu:Show() end
    end)
    add:SetPoint("TOPLEFT", blockHost, "BOTTOMLEFT", 0, -6)
    menu:SetPoint("BOTTOMLEFT", add, "TOPLEFT", 0, 2)
    local bUp = Button(e, "Hoch", 60, 24, function() p.blockList:Scroll(-1) end)
    bUp:SetPoint("LEFT", add, "RIGHT", 10, 0)
    local bDown = Button(e, "Runter", 60, 24, function() p.blockList:Scroll(1) end)
    bDown:SetPoint("LEFT", bUp, "RIGHT", 4, 0)
    local scrollHint = Label(e, "(Mausrad scrollt durch lange Makros)", "GameFontDisableSmall")
    scrollHint:SetPoint("LEFT", bDown, "RIGHT", 10, 0)

    Label(e, "Vorschau"):SetPoint("TOPLEFT", add, "BOTTOMLEFT", 0, -8)

    local box = CreateFrame("Frame", nil, e, "BackdropTemplate")
    box:SetPoint("TOPLEFT", add, "BOTTOMLEFT", 0, -24)
    box:SetPoint("RIGHT", 0, 0)
    box:SetHeight(100)
    Flat(box, T.field)
    p.preview = Label(box, "", "GameFontHighlightSmall")
    p.preview:SetTextColor(0.65, 0.95, 0.7)
    p.preview:SetPoint("TOPLEFT", 8, -8)
    p.preview:SetPoint("BOTTOMRIGHT", -8, 8)
    p.preview:SetJustifyV("TOP")

    p.counter = Label(e, "", "GameFontHighlightSmall")
    p.counter:SetPoint("BOTTOMRIGHT", box, "TOPRIGHT", 0, 4)
    p.counter:SetJustifyH("RIGHT")

    local save = Button(e, "Speichern & aufnehmen", 180, 26, SaveAndPickup)
    save:SetPoint("TOPLEFT", box, "BOTTOMLEFT", 0, -10)
    Tip(save, "Legt das Makro im Spiel an (oder aktualisiert es) und hängt es an den Mauszeiger oder legt es auf den angegebenen Leistenplatz.")

    local chat = Button(e, "Im Chat zeigen", 110, 26, function()
        if not cur then return end
        local body, inner = NM.BuildBody(cur)
        if body == "" then NM.Print("Das Makro ist noch leer.") return end
        NM.Print("Makrotext" .. (inner and " (Spiel-Makro)" or "") .. ":")
        for line in (body .. "\n"):gmatch("(.-)\n") do print("  " .. line) end
        if inner then
            NM.Print("Text im Klick-Button:")
            for line in (inner .. "\n"):gmatch("(.-)\n") do print("  " .. line) end
        end
    end)
    chat:SetPoint("LEFT", save, "RIGHT", 8, 0)
    Tip(chat, "Gibt den kompletten Makrotext im Chatfenster aus (bei langen Makros ist die Vorschau zu klein).")

    local del = Button(e, "Rezept löschen", 120, 26, function()
        for i, r in ipairs(NM.db.recipes) do
            if r == cur then table.remove(NM.db.recipes, i) break end
        end
        cur = NM.db.recipes[1]
        RefreshBuilder()
        NM.Print("Rezept gelöscht. Ein bereits gespeichertes Makro im Spiel bleibt bestehen.")
    end)
    del:SetPoint("LEFT", chat, "RIGHT", 8, 0)

    local slotLabel = Label(e, "Leistenplatz:", "GameFontHighlightSmall")
    slotLabel:SetPoint("LEFT", del, "RIGHT", 14, 0)
    p.slotBox = Edit(e, 40)
    p.slotBox:SetPoint("LEFT", slotLabel, "RIGHT", 8, 0)
    p.slotBox:SetNumeric(true)
    p.slotBox:SetMaxLetters(3)
    Tip(p.slotBox, "Leistenplatz 1-120 (Hauptleiste 1-12, darüber 13-24 usw.). Leer lassen, wenn du das Makro selbst auf die Leiste ziehen willst.")

    return p
end

---------------------------------------------------------------------------
-- Pet-Angriff-Assistent
---------------------------------------------------------------------------

local selected = {}

local function BuildWizard(parent)
    local p = CreateFrame("Frame", nil, parent)
    p:SetAllPoints()
    ui.wizard = p

    local info = Label(p, "Wähle Zauber von deinen Aktionsleisten und was davor passieren soll. Der Assistent ersetzt sie durch ein Makro (Symbol, Abklingzeit und Taste bleiben am selben Platz). \"Rückgängig\" legt den Original-Zauber wieder hin.", "GameFontHighlight")
    info:SetPoint("TOPLEFT", 0, 0)
    info:SetPoint("RIGHT", 0, 0)
    info:SetJustifyV("TOP")
    info:SetHeight(34)

    local opts = NM.db.opts
    Label(p, "ZUSÄTZE VOR DEM ZAUBER", "GameFontNormalSmall"):SetPoint("TOPLEFT", 0, -44)
    local colW = 200
    for i, ex in ipairs(NM.BAR_EXTRAS) do
        local c = Check(p, ex.label, function(v) opts[ex.key] = v end)
        c:SetPoint("TOPLEFT", ((i - 1) % 3) * colW, -62 - math.floor((i - 1) / 3) * 24)
        c:SetChecked(opts[ex.key])
        Tip(c, ex.tip)
    end
    local c3 = Check(p, "Charakter-Makros nutzen", function(v) opts.perChar = v end)
    c3:SetPoint("TOPLEFT", 2 * colW, -86)
    c3:SetChecked(opts.perChar)
    Tip(c3, "Aus: Account-Makros (mehr Platz, für alle Charaktere sichtbar).")

    local tgLabel = Label(p, "Ziel des Zaubers:", "GameFontHighlight")
    tgLabel:SetPoint("TOPLEFT", 2, -118)
    local tgBtn = Button(p, "", 130, 22, function(self)
        opts.target = CycleOption(NM.TARGETS, opts.target or "normal", 1)
        self:SetText(NM.ById(NM.TARGETS, opts.target).label)
    end)
    tgBtn:SetPoint("LEFT", tgLabel, "RIGHT", 10, 0)
    tgBtn:SetText(NM.ById(NM.TARGETS, opts.target or "normal").label)
    Tip(tgBtn, "Klick wechselt: Ziel, Mouseover (sonst Ziel), Fokus, Selbst, Pet, Ziel des Ziels. Für Heilzauber meist Mouseover.")

    local host = CreateFrame("Frame", nil, p)
    host:SetPoint("TOPLEFT", 0, -148)
    host:SetPoint("RIGHT", -90, 0)
    host:SetHeight(11 * 24)

    p.list = ScrollList(host, 11, 24, function(h)
        local row = CreateFrame("Frame", nil, h)
        row.check = Check(row, "", function(v) selected[row.item.slot] = v or nil end)
        row.check:SetPoint("LEFT", 0, 0)
        row.icon = row:CreateTexture(nil, "ARTWORK")
        row.icon:SetSize(20, 20)
        row.icon:SetPoint("LEFT", row.check, "RIGHT", 4, 0)
        row.text = Label(row, "", "GameFontHighlight")
        row.text:SetPoint("LEFT", row.icon, "RIGHT", 6, 0)
        return row
    end, function(row, it)
        row.item = it
        row.check:SetChecked(selected[it.slot] and true or false)
        row.icon:SetTexture(it.icon)
        if it.kind == "ours" then
            row.text:SetText(("Platz %d  |cff55ff55%s|r  |cffaaaaaa(Leisten-Makro)|r"):format(it.slot, it.name))
        else
            row.text:SetText(("Platz %d  %s"):format(it.slot, it.name))
        end
    end)

    local function rescan()
        for k in pairs(selected) do selected[k] = nil end
        p.list:SetData(NM.ScanBar())
    end
    p.rescan = rescan

    local side = CreateFrame("Frame", nil, p)
    side:SetPoint("TOPRIGHT", 0, -148)
    side:SetSize(84, 11 * 24)
    local sy = 0
    local function sideButton(text, fn, tip)
        local b = Button(side, text, 84, 24, fn)
        b:SetPoint("TOPLEFT", 0, sy)
        sy = sy - 28
        if tip then Tip(b, tip) end
        return b
    end
    sideButton("Hoch", function() p.list:Scroll(-3) end)
    sideButton("Runter", function() p.list:Scroll(3) end)
    sideButton("Einlesen", rescan, "Aktionsleisten neu einlesen")
    sideButton("Alle", function()
        for _, it in ipairs(p.list.data) do selected[it.slot] = true end
        p.list:Refresh()
    end)
    sideButton("Keine", function()
        for k in pairs(selected) do selected[k] = nil end
        p.list:Refresh()
    end)

    local function run(kind, fn, verb)
        local ok, fail, lastErr = 0, 0, nil
        for _, it in ipairs(p.list.data) do
            if selected[it.slot] and it.kind == kind then
                local good, err = fn(it)
                if good then ok = ok + 1 else fail = fail + 1; lastErr = err end
            end
        end
        if ok == 0 and fail == 0 then
            NM.Print("Nichts ausgewählt (" .. (kind == "spell" and "Zauber" or "Leisten-Makros") .. " markieren).")
        else
            NM.Print(("%d %s%s"):format(ok, verb, fail > 0 and (", " .. fail .. " fehlgeschlagen: " .. tostring(lastErr)) or "."))
        end
        rescan()
    end

    local apply = Button(p, "Auf Zauber anwenden", 200, 26, function()
        run("spell", function(it) return NM.ApplyPet(it, opts) end, "Zauber umgestellt")
    end)
    apply:SetPoint("TOPLEFT", host, "BOTTOMLEFT", 0, -10)
    Tip(apply, "Ersetzt die markierten Zauber auf der Leiste durch Makros mit den gewählten Zusätzen.")

    local undo = Button(p, "Rückgängig", 120, 26, function()
        run("ours", function(it) return NM.UndoPet(it) end, "Makros zurückgesetzt")
    end)
    undo:SetPoint("LEFT", apply, "RIGHT", 8, 0)
    Tip(undo, "Löscht die markierten Leisten-Makros und legt den Original-Zauber wieder auf den Platz.")

    return p
end

---------------------------------------------------------------------------
-- Hauptfenster
---------------------------------------------------------------------------

local ShowTab

local function BuildShare(parent)
    local pop = PopupFrame(parent, 560, 130)
    pop:SetFrameStrata("FULLSCREEN_DIALOG")
    pop:SetPoint("CENTER")
    pop.title = Label(pop, "", "GameFontNormal")
    pop.title:SetPoint("TOPLEFT", 14, -14)
    pop.box = Edit(pop, 520)
    pop.box:SetPoint("TOPLEFT", 18, -40)
    pop.box:SetMaxLetters(0)
    pop.info = Label(pop, "", "GameFontHighlightSmall")
    pop.info:SetPoint("TOPLEFT", pop.box, "BOTTOMLEFT", -4, -6)
    pop.import = Button(pop, "Als neues Makro übernehmen", 200, 24, function()
        local r, err = NM.ImportRecipe(pop.box:GetText())
        if not r then pop.info:SetText("|cffff5555" .. err .. "|r") return end
        local db = NM.db
        r.id = db.nextId
        db.nextId = db.nextId + 1
        table.insert(db.recipes, r)
        pop:Hide()
        SelectRecipe(r)
        NM.Print("Makro \"" .. r.name .. "\" importiert. Prüfe es und klicke auf Speichern.")
    end)
    pop.import:SetPoint("BOTTOMLEFT", 14, 12)
    local close = Button(pop, "Schließen", 100, 24, function() pop:Hide() end)
    close:SetPoint("BOTTOMRIGHT", -14, 12)
    pop.box:SetScript("OnEscapePressed", function() pop:Hide() end)
    return pop
end

function NM.ShowShare(importMode)
    local pop = ui.sharePop
    pop:Show()
    pop.import:SetShown(importMode)
    if importMode then
        pop.title:SetText("Makro importieren")
        pop.info:SetText("Code mit Strg+V einfügen, dann auf \"Als neues Makro übernehmen\" klicken.")
        pop.box:SetText("")
        pop.box:SetFocus()
    else
        if not cur then pop:Hide() return end
        pop.title:SetText("Makro teilen: " .. (cur.name or ""))
        pop.info:SetText("Alles markiert: Strg+C kopiert den Code, dann im Chat oder Discord an Freunde schicken. Zaubernamen setzen die gleiche Spielsprache voraus.")
        pop.box:SetText(NM.ExportRecipe(cur))
        pop.box:SetFocus()
        pop.box:HighlightText()
    end
end

local function BuildSuggest(parent)
    local p = CreateFrame("Frame", nil, parent)
    p:SetAllPoints()
    ui.suggest = p

    local classLoc, classFile = UnitClass("player")
    local data = {}
    for _, t in ipairs(NM.CLASS_TEMPLATES[classFile] or {}) do data[#data + 1] = t end
    for _, t in ipairs(NM.GENERAL_TEMPLATES) do data[#data + 1] = t end

    local head = Label(p, "Vorschläge für " .. tostring(classLoc) .. " (und allgemeine Makros). \"Übernehmen\" legt ein Rezept im Baukasten an, das du anpassen und speichern kannst.", "GameFontHighlight")
    head:SetPoint("TOPLEFT", 0, 0)
    head:SetPoint("RIGHT", 0, 0)
    head:SetJustifyH("LEFT")

    local host = CreateFrame("Frame", nil, p)
    host:SetPoint("TOPLEFT", 0, -34)
    host:SetPoint("RIGHT", -90, 0)
    host:SetHeight(9 * 46)

    p.list = ScrollList(host, 9, 46, function(h)
        local row = CreateFrame("Frame", nil, h, "BackdropTemplate")
        Flat(row, T.panel)
        row.name = Label(row, "", "GameFontNormal")
        row.name:SetPoint("TOPLEFT", 10, -7)
        row.desc = Label(row, "", "GameFontHighlightSmall")
        row.desc:SetPoint("TOPLEFT", row.name, "BOTTOMLEFT", 0, -2)
        row.desc:SetPoint("RIGHT", -140, 0)
        row.take = Button(row, "Übernehmen", 120, 24, function(self)
            local r = NM.Instantiate(self:GetParent().tpl)
            local db = NM.db
            r.id = db.nextId
            db.nextId = db.nextId + 1
            table.insert(db.recipes, r)
            SelectRecipe(r)
            ShowTab(1)
        end)
        row.take:SetPoint("RIGHT", -8, 0)
        return row
    end, function(row, t)
        row.tpl = t
        row.name:SetText(t.name)
        row.desc:SetText(t.desc or "")
    end)
    p.list:SetData(data)

    local side = CreateFrame("Frame", nil, p)
    side:SetPoint("TOPRIGHT", 0, -34)
    side:SetSize(84, 60)
    Button(side, "Hoch", 84, 24, function() p.list:Scroll(-3) end):SetPoint("TOPLEFT", 0, 0)
    Button(side, "Runter", 84, 24, function() p.list:Scroll(3) end):SetPoint("TOPLEFT", 0, -28)
    return p
end

function ShowTab(n)
    ui.currentTab = n
    ui.builder.menu:Hide()
    ui.builder.condPop:Hide()
    ui.builder:SetShown(n == 1)
    ui.wizard:SetShown(n == 2)
    ui.suggest:SetShown(n == 3)
    ui.sharePop:Hide()
    for i = 1, 3 do ui.tabs[i]:SetEnabled(n ~= i) end
    if n == 2 then ui.wizard.rescan() end
    if n == 1 then RefreshBuilder() end
end

local function CreateMain()
    local _, classFile = UnitClass("player")
    local cc = RAID_CLASS_COLORS and RAID_CLASS_COLORS[classFile]
    if cc then T.accent = { cc.r, cc.g, cc.b } end

    local f = CreateFrame("Frame", "NevMakroFrame", UIParent, "BackdropTemplate")
    Flat(f, T.bg, { 0.02, 0.02, 0.03, 1 })
    f:SetSize(W, H)
    f:SetPoint("CENTER")
    f:SetFrameStrata("DIALOG")
    f:SetMovable(true)
    f:SetClampedToScreen(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    tinsert(UISpecialFrames, "NevMakroFrame")
    ui = f

    local header = f:CreateTexture(nil, "BACKGROUND")
    header:SetPoint("TOPLEFT", 1, -1)
    header:SetPoint("TOPRIGHT", -1, -1)
    header:SetHeight(58)
    header:SetColorTexture(0.085, 0.095, 0.125, 1)
    local line = f:CreateTexture(nil, "ARTWORK")
    line:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, 0)
    line:SetPoint("TOPRIGHT", header, "BOTTOMRIGHT", 0, 0)
    line:SetHeight(2)
    line:SetColorTexture(unpack(T.accent))

    local logo = f:CreateTexture(nil, "ARTWORK")
    logo:SetSize(34, 34)
    logo:SetPoint("TOPLEFT", 14, -12)
    logo:SetTexture("Interface\\Icons\\INV_Scroll_03")
    logo:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    local title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", logo, "TOPRIGHT", 10, -2)
    title:SetText("Nev|cffffffffMakro|r")
    title:SetTextColor(unpack(T.accent))
    local sub = Label(f, "Makros per Klick bauen, teilen und für deine Klasse vorschlagen lassen", "GameFontDisableSmall")
    sub:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -3)

    local close = Button(f, "X", 26, 26, function() f:Hide() end)
    close:SetPoint("TOPRIGHT", -12, -16)

    f.tabs = {
        Button(f, "Makro-Baukasten", 150, 26, function() ShowTab(1) end),
        Button(f, "Leisten-Assistent", 140, 26, function() ShowTab(2) end),
        Button(f, "Vorschläge", 120, 26, function() ShowTab(3) end),
    }
    f.tabs[3]:SetPoint("RIGHT", close, "LEFT", -18, 0)
    f.tabs[2]:SetPoint("RIGHT", f.tabs[3], "LEFT", -4, 0)
    f.tabs[1]:SetPoint("RIGHT", f.tabs[2], "LEFT", -4, 0)

    local content = CreateFrame("Frame", nil, f)
    content:SetPoint("TOPLEFT", 22, -82)
    content:SetPoint("BOTTOMRIGHT", -22, 22)

    BuildBuilder(content)
    BuildWizard(content)
    BuildSuggest(content)
    f.sharePop = BuildShare(f)
    f.ShowShare = NM.ShowShare
    f:Hide()
end

function NM.ToggleUI(tab)
    if not NM.db then return end
    tab = tab or 1
    if not ui then CreateMain() end
    if ui:IsShown() and ui.currentTab == tab then
        ui:Hide()
        return
    end
    if not cur then cur = NM.db.recipes[1] end
    ui:Show()
    if not cur then NewRecipe() end
    ShowTab(tab)
end
