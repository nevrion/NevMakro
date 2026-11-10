local _, NM = ...

local PREFIX = "NM1"

local function esc(s)
    return (tostring(s or ""):gsub("[^%w_%.%-]", function(c) return ("%%%02X"):format(c:byte()) end))
end

local function unesc(s)
    return (s:gsub("%%(%x%x)", function(h) return string.char(tonumber(h, 16)) end))
end

local function split(s, sep)
    local out, from = {}, 1
    while true do
        local i = s:find(sep, from, true)
        if not i then out[#out + 1] = s:sub(from) break end
        out[#out + 1] = s:sub(from, i - 1)
        from = i + 1
    end
    return out
end

-- Text-Code eines Rezepts: nur Buchstaben, Ziffern und die Trennzeichen ~ | , ; =
function NM.ExportRecipe(r)
    local blocks = {}
    for _, b in ipairs(r.blocks) do
        local conds = {}
        for _, g in ipairs(NM.COND_GROUPS) do
            local id = b.conds and b.conds[g.key]
            if id and id ~= "any" then conds[#conds + 1] = esc(g.key) .. "=" .. esc(id) end
        end
        blocks[#blocks + 1] = table.concat({
            esc(b.type), esc(b.text), esc(b.target or "normal"), esc(b.join), esc(b.reset), table.concat(conds, ";"),
        }, ",")
    end
    return table.concat({
        PREFIX, esc(r.name), r.showTooltip and "1" or "0", r.long and "1" or "0", table.concat(blocks, "|"),
    }, "~")
end

local function validOpt(list, id)
    for _, v in ipairs(list) do if v.id == id then return true end end
end

-- Liest einen Text-Code und liefert ein neues Rezept oder nil und eine Fehlermeldung.
-- Es wird nichts ausgeführt: nur bekannte Bausteintypen, Ziele, Bedingungen und Texte werden übernommen.
function NM.ImportRecipe(code)
    code = strtrim(code or ""):gsub("%s+", "")
    local head = split(code, "~")
    if head[1] ~= PREFIX or #head < 5 then return nil, "Das ist kein NevMakro-Code." end

    local r = {
        name = NM.Trunc(unesc(head[2]), 16), showTooltip = head[3] == "1", long = head[4] == "1",
        perChar = true, blocks = {},
    }
    if r.name == "" then r.name = "Importiert" end

    for _, bs in ipairs(split(head[5], "|")) do
        local f = split(bs, ",")
        local t = unesc(f[1] or "")
        if NM.BT[t] and #r.blocks < NM.MAX_BLOCKS then
            local b = { type = t, text = NM.Trunc(unesc(f[2] or ""), 255), conds = {} }
            local target = unesc(f[3] or "")
            b.target = validOpt(NM.TARGETS, target) and target or "normal"
            if unesc(f[4] or "") == "or" then b.join = "or" end
            local reset = unesc(f[5] or "")
            if validOpt(NM.RESETS, reset) then b.reset = reset end
            for _, c in ipairs(split(f[6] or "", ";")) do
                local kv = split(c, "=")
                local key, id = unesc(kv[1] or ""), unesc(kv[2] or "")
                for _, g in ipairs(NM.COND_GROUPS) do
                    if g.key == key and validOpt(g.opts, id) then b.conds[key] = id end
                end
            end
            r.blocks[#r.blocks + 1] = b
        end
    end
    if #r.blocks == 0 then return nil, "Der Code enthält keine gültigen Bausteine." end
    return r
end
