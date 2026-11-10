local _, NM = ...

-- Zauber als {ID, englischer Name}: der Name wird beim Übernehmen in der Client-Sprache aufgelöst
local function S(id, en, extra)
    local b = { type = "spell", id = id, en = en }
    for k, v in pairs(extra or {}) do b[k] = v end
    return b
end
local function B(t, extra)
    local b = { type = t }
    for k, v in pairs(extra or {}) do b[k] = v end
    return b
end

NM.CLASS_TEMPLATES = {
    HUNTER = {
        { name = "Pet + Arkaner Schuss", desc = "Pet greift an, dann Arkaner Schuss. Symbol zeigt den Zauber.",
          blocks = { B("petattack"), S(3044, "Arcane Shot") } },
        { name = "Pet rufen/heilen/beleben", tipAuto = true, desc = "Eine Taste fürs Tier: tot = wiederbeleben, lebt = heilen, fehlt = rufen. Das Symbol wechselt passend mit.",
          blocks = { S(982, "Revive Pet", { conds = { pet = "petdead" } }), S(136, "Mend Pet", { conds = { pet = "petalive" }, join = "or" }), S(883, "Call Pet", { conds = { pet = "nopet" }, join = "or" }) } },
        { name = "Mal des Jägers + Pet", desc = "Markiert das Ziel und schickt das Pet los.",
          blocks = { S(1130, "Hunter's Mark"), B("petattack") } },
        { name = "Schlangenbiss, Schuss", desc = "Wechselt bei jedem Druck zwischen Schlangenbiss und Arkanem Schuss, Reset bei neuem Ziel.",
          blocks = { { type = "castseq", castIds = { 1978, 3044 }, castEn = { "Serpent Sting", "Arcane Shot" }, reset = "target" } } },
        { name = "Sich tot stellen", desc = "Totstellen, vorher Auto-Angriff beenden.",
          blocks = { B("stopattack"), S(5384, "Feign Death") } },
    },
    MAGE = {
        { name = "Verwandlung auf Fokus", desc = "Schaf auf den Fokus, sonst auf das Ziel.",
          blocks = { S(118, "Polymorph", { target = "focus" }) } },
        { name = "Gegenzauber Mouseover", desc = "Unterbricht das Ziel unter der Maus, sonst dein Ziel.",
          blocks = { S(2139, "Counterspell", { target = "mouseover" }) } },
        { name = "Frostblitz/Feuerball", desc = "Frostblitz, mit Shift Feuerball. Eine Taste, zwei Schulen.",
          blocks = { S(133, "Fireball", { conds = { mod = "shift" } }), S(116, "Frostbolt", { join = "or" }) } },
        { name = "Nova / Blinzeln", desc = "Frost-Nova, mit Strg Blinzeln.",
          blocks = { S(1953, "Blink", { conds = { mod = "ctrl" } }), S(122, "Frost Nova", { join = "or" }) } },
    },
    WARRIOR = {
        { name = "Sturmangriff + Kampfrausch", desc = "Angriff, Blutrausch gleich mit.",
          blocks = { S(100, "Charge"), S(2687, "Bloodrage") } },
        { name = "Heldenhafter Stoß", desc = "Heroic Strike mit Auto-Angriff.",
          blocks = { B("startattack"), S(78, "Heroic Strike") } },
        { name = "Spott Mouseover", desc = "Spottet das Ziel unter der Maus, sonst dein Ziel.",
          blocks = { S(355, "Taunt", { target = "mouseover" }) } },
        { name = "Hinrichten, sonst Überw.", desc = "Hinrichten, wenn möglich; sonst Überwältigen.",
          blocks = { S(5308, "Execute"), S(7384, "Overpower", { join = "or" }) } },
    },
    PALADIN = {
        { name = "Heiliges Licht Mouseover", desc = "Heilt das Ziel unter der Maus, sonst dein Ziel.",
          blocks = { S(635, "Holy Light", { target = "mouseover" }) } },
        { name = "Läutern Mouseover", desc = "Entfernt Gift/Krankheit/Magie bei Mouseover.",
          blocks = { S(4987, "Cleanse", { target = "mouseover" }) } },
        { name = "Urteil + Siegel", desc = "Siegel der Rechtschaffenheit, Urteil im Anschluss.",
          blocks = { S(21084, "Seal of Righteousness"), S(20271, "Judgement") } },
        { name = "Gottesschild + Handauflegen", desc = "Shift = Handauflegen, sonst Göttlicher Schutz.",
          blocks = { S(633, "Lay on Hands", { conds = { mod = "shift" } }), S(642, "Divine Shield", { join = "or" }) } },
    },
    ROGUE = {
        { name = "Tarnung + Hinterhalt", desc = "In Tarnung Hinterhalt, sonst Tarnen.",
          blocks = { S(8676, "Ambush", { conds = { stealth = "stealth" } }), S(1784, "Stealth", { conds = { stealth = "nostealth" }, join = "or" }) } },
        { name = "Tritt Mouseover", desc = "Unterbricht das Ziel unter der Maus, sonst dein Ziel.",
          blocks = { S(1766, "Kick", { target = "mouseover" }) } },
        { name = "Finsterer Stoß + Ausweiden", desc = "Strg = Ausweiden, sonst Finsterer Stoß.",
          blocks = { S(2098, "Eviscerate", { conds = { mod = "ctrl" } }), S(1752, "Sinister Strike", { join = "or" }) } },
        { name = "Schlossknacken", desc = "Schloss knacken und gleich das Item (Truhe, Kiste) benutzen. Item im Baukasten eintragen.",
          blocks = { S(1804, "Pick Lock"), B("item") } },
        { name = "Sprinten + Entrinnen", desc = "Shift = Entrinnen, sonst Sprinten.",
          blocks = { S(5277, "Evasion", { conds = { mod = "shift" } }), S(2983, "Sprint", { join = "or" }) } },
    },
    PRIEST = {
        { name = "Schild Mouseover", desc = "Machtwort: Schild auf Mouseover, sonst auf dein Ziel.",
          blocks = { S(17, "Power Word: Shield", { target = "mouseover" }) } },
        { name = "Erneuerung Mouseover", desc = "Erneuerung auf das Ziel unter der Maus.",
          blocks = { S(139, "Renew", { target = "mouseover" }) } },
        { name = "Blitzheilung Mouseover", desc = "Schnelle Heilung auf Mouseover, Shift = auf dich selbst.",
          blocks = { S(2061, "Flash Heal", { target = "self", conds = { mod = "shift" } }), S(2061, "Flash Heal", { target = "mouseover", join = "or" }) } },
        { name = "Schmerz, Mind Blast", desc = "Wechselt zwischen Schattenwort: Schmerz und Gedankenschlag.",
          blocks = { { type = "castseq", castIds = { 589, 8092 }, castEn = { "Shadow Word: Pain", "Mind Blast" }, reset = "target" } } },
    },
    SHAMAN = {
        { name = "Heilwelle Mouseover", desc = "Heilt Mouseover, sonst Ziel; mit Shift dich selbst.",
          blocks = { S(331, "Healing Wave", { target = "self", conds = { mod = "shift" } }), S(331, "Healing Wave", { target = "mouseover", join = "or" }) } },
        { name = "Schock-Wechsel", desc = "Erdschock; mit Shift Flammenschock.",
          blocks = { S(8050, "Flame Shock", { conds = { mod = "shift" } }), S(8042, "Earth Shock", { join = "or" }) } },
        { name = "Reinigen (Feind)", desc = "Entfernt Magie von einem feindlichen Ziel, sonst nichts.",
          blocks = { S(370, "Purge", { conds = { ttype = "harm" } }) } },
        { name = "Geisterwolf", desc = "Geisterwolf per Tastendruck.",
          blocks = { S(2645, "Ghost Wolf") } },
    },
    WARLOCK = {
        { name = "Schattenblitz + Pet", desc = "Pet angreifen lassen, dann Schattenblitz.",
          blocks = { B("petattack"), S(686, "Shadow Bolt") } },
        { name = "Fluch Fokus", desc = "Fluch der Agonie auf den Fokus, sonst Ziel.",
          blocks = { S(980, "Curse of Agony", { target = "focus" }) } },
        { name = "Aderlass + Lebensentzug", desc = "Shift = Aderlass (Mana), sonst Lebensentzug.",
          blocks = { S(1454, "Life Tap", { conds = { mod = "shift" } }), S(689, "Drain Life", { join = "or" }) } },
        { name = "Furcht Mouseover", desc = "Furcht auf das Ziel unter der Maus, sonst dein Ziel.",
          blocks = { S(5782, "Fear", { target = "mouseover" }) } },
    },
    DRUID = {
        { name = "Rejuvenation Mouseover", desc = "Verjüngung auf Mouseover, sonst Ziel; mit Shift dich selbst.",
          blocks = { S(774, "Rejuvenation", { target = "self", conds = { mod = "shift" } }), S(774, "Rejuvenation", { target = "mouseover", join = "or" }) } },
        { name = "Heilende Berührung", desc = "Heilt Mouseover, sonst Ziel.",
          blocks = { S(5185, "Healing Touch", { target = "mouseover" }) } },
        { name = "Gestaltwechsel Kampf", desc = "Bär im Kampf, Katze außerhalb.",
          blocks = { S(5487, "Bear Form", { conds = { combat = "combat" } }), S(768, "Cat Form", { conds = { combat = "nocombat" }, join = "or" }) } },
        { name = "Mondfeuer, Zorn", desc = "Wechselt zwischen Mondfeuer und Zorn, Reset bei neuem Ziel.",
          blocks = { { type = "castseq", castIds = { 8921, 5176 }, castEn = { "Moonfire", "Wrath" }, reset = "target" } } },
    },
}

NM.GENERAL_TEMPLATES = {
    { name = "Beide Schmuckstücke", desc = "Löst beide angelegten Schmuckstücke gemeinsam aus.",
      blocks = { B("item", { text = "13" }), B("item", { text = "14" }) } },
    { name = "Absteigen", desc = "Steigt vom Reittier ab.",
      blocks = { B("dismount") } },
    { name = "Reittier an/aus", desc = "Eine Taste: abgestiegen = aufsitzen, auf dem Reittier = absteigen. Reittier im Baukasten eintragen.",
      blocks = { B("dismount"), B("item", { conds = { mount = "nomounted" } }) } },
    { name = "Trank im Kampf", desc = "Benutzt deinen Trank nur im Kampf. Trank im Baukasten eintragen.",
      blocks = { B("item", { conds = { combat = "combat" } }) } },
    { name = "Heilstein + Trank", desc = "Heilstein und Heiltrank mit einer Taste, jeder hat seine eigene Abklingzeit. Beide Items eintragen.",
      blocks = { B("item"), B("item") } },
    { name = "Essen und Trinken", desc = "Isst und trinkt nur außerhalb des Kampfs. Essen und Getränk eintragen.",
      blocks = { B("item", { conds = { combat = "nocombat" } }), B("item", { conds = { combat = "nocombat" } }) } },
    { name = "Feind + Angriff", tip = false, desc = "Visiert den nächsten Feind an, falls du keinen im Ziel hast, und startet den Auto-Angriff.",
      blocks = { B("raw", { text = "/targetenemy [noharm]" }), B("startattack") } },
    { name = "Notbremse", tip = false, desc = "Bricht Zauber und Auto-Angriff ab und ruft das Pet zurück.",
      blocks = { B("stopcasting"), B("stopattack"), B("petfollow") } },
    { name = "Gruppe: Pull-Ansage", tip = false, desc = "Schreibt in den Gruppenchat, dass gepullt wird.",
      blocks = { B("raw", { text = "/p Pull in 5 Sekunden, bitte bereit machen!" }) } },
    { name = "Gruppe: Mana-Pause", tip = false, desc = "Sagt der Gruppe, dass du Mana brauchst.",
      blocks = { B("raw", { text = "/p Ich brauche kurz Mana, bitte kurz warten." }) } },
    { name = "Ziel: Totenkopf", tip = false, desc = "Markiert dein Ziel mit dem Totenkopf.",
      blocks = { B("raw", { text = "/script SetRaidTarget(\"target\", 8)" }) } },
    { name = "Ziel: Kreuz", tip = false, desc = "Markiert dein Ziel mit dem roten Kreuz.",
      blocks = { B("raw", { text = "/script SetRaidTarget(\"target\", 7)" }) } },
    { name = "Assist Mouseover", tip = false, desc = "Übernimmt das Ziel des Spielers unter der Maus (sonst deines Ziels), z.B. dem Tank.",
      blocks = { B("raw", { text = "/assist [@mouseover,help,exists][]" }) } },
    { name = "Buff entfernen", desc = "Entfernt einen Buff per Tastendruck. Buffname im Baukasten eintragen.",
      blocks = { B("cancelaura") } },
}

-- Berufe: ids = Eröffnungszauber je Rang, craft = Herstellungsberuf. Felder ohne Namen bleiben leer.
NM.PROFESSIONS = {
    enchanting     = { ids = { 7411, 7412, 7413, 13920 }, craft = true },
    alchemy        = { ids = { 2259, 3101, 3464, 11611 }, craft = true },
    blacksmithing  = { ids = { 2018, 3100, 3538, 9785 }, craft = true },
    engineering    = { ids = { 4036, 4037, 4038, 12656 }, craft = true },
    leatherworking = { ids = { 2108, 3104, 3811, 10662 }, craft = true },
    tailoring      = { ids = { 3908, 3909, 3910, 12180 }, craft = true },
    cooking        = { ids = { 2550, 3102, 3413, 18260 }, craft = true },
    mining         = { ids = { 2575, 2576, 3564, 10248 } },
    herbalism      = { ids = { 2366, 2368, 3570, 11993 } },
    skinning       = { ids = { 8613, 8617, 8618, 10768 } },
    fishing        = { ids = { 7620, 7731, 7732, 18248 } },
}

NM.PROFESSION_TEMPLATES = {
    { name = "Rezept + Item", need = "craft", desc = "Immer dasselbe Item mit einem Rezept verwenden (z.B. Verzauberkunst skillen). Rezept und Item im Baukasten eintragen, Berufsfenster offen lassen, eine Taste drücken.",
      blocks = { B("spell"), B("item") } },
    { name = "Entzaubern", need = "enchanting", desc = "Entzaubern und gleich das Item aus der Tasche eintragen, das aufgelöst werden soll.",
      blocks = { S(13262, "Disenchant"), B("item") } },
    { name = "Kochfeuer", need = "cooking", desc = "Entzündet ein Kochfeuer, damit du kochen kannst.",
      blocks = { S(818, "Basic Campfire") } },
    { name = "Schmelzen", need = "mining", desc = "Öffnet das Schmelzfenster.",
      blocks = { S(2656, "Smelting") } },
    { name = "Erz suchen", need = "mining", desc = "Schaltet das Erz-Tracking an.",
      blocks = { S(2580, "Find Minerals") } },
    { name = "Kräuter suchen", need = "herbalism", desc = "Schaltet das Kräuter-Tracking an.",
      blocks = { S(2383, "Find Herbs") } },
    { name = "Sammel-Tracking", need = { "mining", "herbalism" }, desc = "Kräuter und Erz suchen mit einer Taste, bei jedem Druck wird gewechselt.",
      blocks = { { type = "castseq", castIds = { 2383, 2580 }, castEn = { "Find Herbs", "Find Minerals" } } } },
    { name = "Angeln", need = "fishing", desc = "Angeln starten. Köder im Baukasten als Gegenstand davor setzen.",
      blocks = { S(7620, "Fishing") } },
}

local function known(id)
    if IsPlayerSpell and IsPlayerSpell(id) then return true end
    if IsSpellKnown and IsSpellKnown(id) then return true end
end

-- Liefert Set der erkannten Berufe (key = true) und eine Liste ihrer Anzeigenamen
function NM.DetectProfessions()
    local names = {}
    if GetProfessions and GetProfessionInfo then
        for _, idx in pairs({ GetProfessions() }) do
            if idx then names[(GetProfessionInfo(idx))] = true end
        end
    end
    if GetNumSkillLines and GetSkillLineInfo then
        for i = 1, GetNumSkillLines() do
            local n, header = GetSkillLineInfo(i)
            if n and not header then names[n] = true end
        end
    end
    local have, list = {}, {}
    for key, def in pairs(NM.PROFESSIONS) do
        local found = names[NM.SpellName(def.ids[1]) or ""] 
        for _, id in ipairs(def.ids) do
            if known(id) then found = true end
        end
        if found then
            have[key] = true
            if def.craft then have.craft = true end
            list[#list + 1] = NM.SpellName(def.ids[1]) or key
        end
    end
    table.sort(list)
    return have, list
end

function NM.ProfessionTemplates(have, all)
    local out = {}
    for _, t in ipairs(NM.PROFESSION_TEMPLATES) do
        local ok = all
        if not ok then
            ok = true
            for _, k in ipairs(type(t.need) == "table" and t.need or { t.need }) do
                if not have[k] then ok = false end
            end
        end
        if ok then out[#out + 1] = t end
    end
    return out
end

local function SpellText(id, en)
    local n = NM.SpellName(id)
    return (n and n ~= "") and n or en
end

-- Baut aus einer Vorlage ein neues Rezept (Zaubernamen in der Client-Sprache)
function NM.Instantiate(tpl)
    local r = { name = NM.Trunc(tpl.name, 16), showTooltip = tpl.tip ~= false, tipAuto = tpl.tipAuto, perChar = true, long = false, blocks = {} }
    for _, src in ipairs(tpl.blocks) do
        local b = { type = src.type, text = src.text or "", target = src.target or "normal", join = src.join, reset = src.reset, conds = {} }
        for k, v in pairs(src.conds or {}) do b.conds[k] = v end
        if src.id then
            b.text = SpellText(src.id, src.en)
        elseif src.castIds then
            local parts = {}
            for i, id in ipairs(src.castIds) do parts[i] = SpellText(id, src.castEn[i]) end
            b.text = table.concat(parts, ", ")
        end
        r.blocks[#r.blocks + 1] = b
    end
    return r
end
