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
        { name = "Pet rufen/heilen", desc = "Kein Pet: Tier rufen. Pet da: Tier heilen. Eine Taste für beides.",
          blocks = { S(883, "Call Pet", { conds = { pet = "nopet" } }), S(136, "Mend Pet", { conds = { pet = "pet" }, join = "or" }) } },
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

-- Berufe: Felder ohne Namen bleiben leer und werden im Baukasten ausgefüllt
NM.PROFESSION_TEMPLATES = {
    { name = "VZ/Handwerk: Rezept + Item", desc = "Beruf: Rezept und immer dasselbe Item verwenden (z.B. Verzauberkunst skillen). Im Baukasten Rezeptnamen und Item eintragen (Item aus der Tasche ins Feld ziehen), Verzauberfenster offen lassen, eine Taste drücken.",
      blocks = { B("spell"), B("item") } },
    { name = "Entzaubern", desc = "Beruf: Entzaubern und gleich das Item aus der Tasche eintragen, das aufgelöst werden soll.",
      blocks = { S(13262, "Disenchant"), B("item") } },
    { name = "Schlossknacken", desc = "Beruf (Schurke): Schloss knacken und gleich das Item (Truhe, Kiste) benutzen.",
      blocks = { S(1804, "Pick Lock"), B("item") } },
    { name = "Sammel-Tracking wechseln", desc = "Beruf: Kräuter und Erz suchen mit einer Taste, bei jedem Druck wird gewechselt.",
      blocks = { { type = "castseq", castIds = { 2383, 2580 }, castEn = { "Find Herbs", "Find Minerals" } } } },
    { name = "Angeln", desc = "Beruf: Angeln starten. Köder im Baukasten als Gegenstand davor setzen.",
      blocks = { S(7620, "Fishing") } },
}

local function SpellText(id, en)
    local n = NM.SpellName(id)
    return (n and n ~= "") and n or en
end

-- Baut aus einer Vorlage ein neues Rezept (Zaubernamen in der Client-Sprache)
function NM.Instantiate(tpl)
    local r = { name = NM.Trunc(tpl.name, 16), showTooltip = tpl.tip ~= false, perChar = true, long = false, blocks = {} }
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
