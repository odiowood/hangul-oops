--- === HanEng ===
---
--- 한/영 오타 변환기 · 한영키를 안 눌러 잘못 친 텍스트를 선택 후 단축키로 제자리 변환.
--- 순수 Lua 구현(외부 의존성 없음). 두벌식 기준, 방향 자동 감지.
---
--- 만든 사람: odiowood
--- Download: https://github.com/odiowood/hangul-oops

local obj = {}
obj.__index = obj

obj.name = "HanEng"
obj.version = "1.0"
obj.author = "odiowood"
obj.homepage = "https://github.com/odiowood/hangul-oops"
obj.license = "MIT - https://opensource.org/licenses/MIT"

-- ─────────────────────────────────────────────────────────────────────
-- 변환 엔진 (순수 Lua)
-- ─────────────────────────────────────────────────────────────────────

-- 두벌식 키 → 자모
local KEY_TO_JAMO = {
    q = "ㅂ", w = "ㅈ", e = "ㄷ", r = "ㄱ", t = "ㅅ",
    y = "ㅛ", u = "ㅕ", i = "ㅑ", o = "ㅐ", p = "ㅔ",
    a = "ㅁ", s = "ㄴ", d = "ㅇ", f = "ㄹ", g = "ㅎ",
    h = "ㅗ", j = "ㅓ", k = "ㅏ", l = "ㅣ",
    z = "ㅋ", x = "ㅌ", c = "ㅊ", v = "ㅍ", b = "ㅠ",
    n = "ㅜ", m = "ㅡ",
    Q = "ㅃ", W = "ㅉ", E = "ㄸ", R = "ㄲ", T = "ㅆ",
    O = "ㅒ", P = "ㅖ",
}
-- Shift 변형이 없는 대문자는 소문자와 동일한 자모
for ch in ("yuiahjklzxcvbnmsdfg"):gmatch(".") do
    KEY_TO_JAMO[ch:upper()] = KEY_TO_JAMO[ch]
end

local CHO = { "ㄱ","ㄲ","ㄴ","ㄷ","ㄸ","ㄹ","ㅁ","ㅂ","ㅃ","ㅅ","ㅆ","ㅇ","ㅈ","ㅉ","ㅊ","ㅋ","ㅌ","ㅍ","ㅎ" }
local JUNG = { "ㅏ","ㅐ","ㅑ","ㅒ","ㅓ","ㅔ","ㅕ","ㅖ","ㅗ","ㅘ","ㅙ","ㅚ","ㅛ","ㅜ","ㅝ","ㅞ","ㅟ","ㅠ","ㅡ","ㅢ","ㅣ" }
local JONG = { "","ㄱ","ㄲ","ㄳ","ㄴ","ㄵ","ㄶ","ㄷ","ㄹ","ㄺ","ㄻ","ㄼ","ㄽ","ㄾ","ㄿ","ㅀ","ㅁ","ㅂ","ㅄ","ㅅ","ㅆ","ㅇ","ㅈ","ㅊ","ㅋ","ㅌ","ㅍ","ㅎ" }

local CHO_IDX, JUNG_IDX, JONG_IDX = {}, {}, {}
for i, v in ipairs(CHO)  do CHO_IDX[v]  = i - 1 end   -- 0-based
for i, v in ipairs(JUNG) do JUNG_IDX[v] = i - 1 end
for i, v in ipairs(JONG) do JONG_IDX[v] = i - 1 end

local VOWELS = {}
for _, v in ipairs(JUNG) do VOWELS[v] = true end

-- 복합 중성(이중모음)  앞모음+뒤모음 → 합성모음
local JUNG_COMBINE = {
    ["ㅗㅏ"]="ㅘ", ["ㅗㅐ"]="ㅙ", ["ㅗㅣ"]="ㅚ",
    ["ㅜㅓ"]="ㅝ", ["ㅜㅔ"]="ㅞ", ["ㅜㅣ"]="ㅟ",
    ["ㅡㅣ"]="ㅢ",
}
-- 복합 종성(겹받침)  앞받침+뒤자음 → 겹받침
local JONG_COMBINE = {
    ["ㄱㅅ"]="ㄳ", ["ㄴㅈ"]="ㄵ", ["ㄴㅎ"]="ㄶ",
    ["ㄹㄱ"]="ㄺ", ["ㄹㅁ"]="ㄻ", ["ㄹㅂ"]="ㄼ", ["ㄹㅅ"]="ㄽ",
    ["ㄹㅌ"]="ㄾ", ["ㄹㅍ"]="ㄿ", ["ㄹㅎ"]="ㅀ", ["ㅂㅅ"]="ㅄ",
}
-- 겹받침 → {앞받침, 뒤자음}  (뒤 자음이 다음 글자 초성으로 이동할 때 분해)
local JONG_SPLIT = {
    ["ㄳ"]={"ㄱ","ㅅ"}, ["ㄵ"]={"ㄴ","ㅈ"}, ["ㄶ"]={"ㄴ","ㅎ"},
    ["ㄺ"]={"ㄹ","ㄱ"}, ["ㄻ"]={"ㄹ","ㅁ"}, ["ㄼ"]={"ㄹ","ㅂ"}, ["ㄽ"]={"ㄹ","ㅅ"},
    ["ㄾ"]={"ㄹ","ㅌ"}, ["ㄿ"]={"ㄹ","ㅍ"}, ["ㅀ"]={"ㄹ","ㅎ"}, ["ㅄ"]={"ㅂ","ㅅ"},
}

-- 한글 → 영타 역매핑
local CHO_TO_KEY = {
    ["ㄱ"]="r",["ㄲ"]="R",["ㄴ"]="s",["ㄷ"]="e",["ㄸ"]="E",["ㄹ"]="f",["ㅁ"]="a",["ㅂ"]="q",["ㅃ"]="Q",
    ["ㅅ"]="t",["ㅆ"]="T",["ㅇ"]="d",["ㅈ"]="w",["ㅉ"]="W",["ㅊ"]="c",["ㅋ"]="z",["ㅌ"]="x",["ㅍ"]="v",["ㅎ"]="g",
}
local JUNG_TO_KEYS = {
    ["ㅏ"]="k",["ㅐ"]="o",["ㅑ"]="i",["ㅒ"]="O",["ㅓ"]="j",["ㅔ"]="p",["ㅕ"]="u",["ㅖ"]="P",["ㅗ"]="h",
    ["ㅘ"]="hk",["ㅙ"]="ho",["ㅚ"]="hl",["ㅛ"]="y",["ㅜ"]="n",["ㅝ"]="nj",["ㅞ"]="np",["ㅟ"]="nl",
    ["ㅠ"]="b",["ㅡ"]="m",["ㅢ"]="ml",["ㅣ"]="l",
}
local JONG_TO_KEYS = {
    [""]="",["ㄱ"]="r",["ㄲ"]="R",["ㄳ"]="rt",["ㄴ"]="s",["ㄵ"]="sw",["ㄶ"]="sg",["ㄷ"]="e",["ㄹ"]="f",
    ["ㄺ"]="fr",["ㄻ"]="fa",["ㄼ"]="fq",["ㄽ"]="ft",["ㄾ"]="fx",["ㄿ"]="fv",["ㅀ"]="fg",["ㅁ"]="a",
    ["ㅂ"]="q",["ㅄ"]="qt",["ㅅ"]="t",["ㅆ"]="T",["ㅇ"]="d",["ㅈ"]="w",["ㅊ"]="c",["ㅋ"]="z",["ㅌ"]="x",["ㅍ"]="v",["ㅎ"]="g",
}
local JAMO_TO_KEYS = {}  -- 단독 호환 자모 역매핑
for k, v in pairs(CHO_TO_KEY)   do JAMO_TO_KEYS[k] = v end
for k, v in pairs(JUNG_TO_KEYS)  do if not JAMO_TO_KEYS[k] then JAMO_TO_KEYS[k] = v end end

-- ASCII 대소문자 스왑 (한글 등 멀티바이트는 건드리지 않음)
local function swapcaseAscii(s)
    return (s:gsub("%a", function(c)
        local b = c:byte()
        if b >= 65 and b <= 90 then return string.char(b + 32) end
        if b >= 97 and b <= 122 then return string.char(b - 32) end
        return c
    end))
end

-- 영타 → 한글(완성형 조립)
local function engToKor(text)
    -- Caps Lock 보정: 알파벳 중 대문자가 우세하면 케이스를 통째로 뒤집는다.
    local up, low = 0, 0
    for c in text:gmatch("%a") do
        local b = c:byte()
        if b >= 65 and b <= 90 then up = up + 1 elseif b >= 97 and b <= 122 then low = low + 1 end
    end
    if up > low then text = swapcaseAscii(text) end

    local out = {}
    local cho, jung, jong = nil, nil, nil

    local function emit()
        if cho and jung then
            local code = 0xAC00 + (CHO_IDX[cho] * 21 + JUNG_IDX[jung]) * 28 + (jong and JONG_IDX[jong] or 0)
            out[#out + 1] = utf8.char(code)
        elseif cho then
            out[#out + 1] = cho
        elseif jung then
            out[#out + 1] = jung
        end
        cho, jung, jong = nil, nil, nil
    end

    for _, cp in utf8.codes(text) do
        local ch = utf8.char(cp)
        local jamo = KEY_TO_JAMO[ch]
        if not jamo then
            emit(); out[#out + 1] = ch
        elseif VOWELS[jamo] then                       -- ── 모음 ──
            if cho and not jung then
                jung = jamo
            elseif jung and not jong then
                local comb = JUNG_COMBINE[jung .. jamo]
                if comb then jung = comb else emit(); cho = nil; jung = jamo end
            elseif jong then
                local sp = JONG_SPLIT[jong]
                if sp then
                    jong = sp[1]; local move = sp[2]; emit(); cho, jung, jong = move, jamo, nil
                else
                    local move = jong; jong = nil; emit(); cho, jung, jong = move, jamo, nil
                end
            else
                emit(); cho = nil; jung = jamo; jong = nil
            end
        else                                            -- ── 자음 ──
            if not cho and not jung then
                cho = jamo
            elseif cho and not jung then
                emit(); cho = jamo
            elseif jung and not jong then
                if not cho then emit(); cho = jamo
                elseif JONG_IDX[jamo] then jong = jamo
                else emit(); cho = jamo end
            elseif jong then
                local comb = JONG_COMBINE[jong .. jamo]
                if comb then jong = comb else emit(); cho = jamo end
            end
        end
    end
    emit()
    return table.concat(out)
end

-- 한글 → 영타
local function korToEng(text)
    local out = {}
    for _, cp in utf8.codes(text) do
        if cp >= 0xAC00 and cp <= 0xD7A3 then          -- 완성형 음절
            local s = cp - 0xAC00
            local cho  = CHO[math.floor(s / (21 * 28)) + 1]
            local jung = JUNG[math.floor((s % (21 * 28)) / 28) + 1]
            local jong = JONG[(s % 28) + 1]
            out[#out + 1] = CHO_TO_KEY[cho] .. JUNG_TO_KEYS[jung] .. JONG_TO_KEYS[jong]
        else
            local ch = utf8.char(cp)
            out[#out + 1] = JAMO_TO_KEYS[ch] or ch
        end
    end
    return table.concat(out)
end

local function hasHangul(text)
    for _, cp in utf8.codes(text) do
        if (cp >= 0xAC00 and cp <= 0xD7A3) or (cp >= 0x3131 and cp <= 0x3163) then
            return true
        end
    end
    return false
end

-- 방향 자동 감지 후 변환 (순수 함수 · 테스트 가능)
function obj.convertText(text)
    if hasHangul(text) then return korToEng(text) else return engToKor(text) end
end

-- ─────────────────────────────────────────────────────────────────────
-- 클립보드 처리 + 단축키 동작
-- ─────────────────────────────────────────────────────────────────────

local function backupPasteboard()
    local str = hs.pasteboard.getContents()            -- 텍스트 없으면 nil
    local ok, all = pcall(hs.pasteboard.readAllData)
    return { str = str, all = (ok and all) or nil }
end

local function restorePasteboard(b)
    if not b then return end
    if b.str ~= nil then
        hs.pasteboard.setContents(b.str)               -- 텍스트 복원(확실)
    elseif b.all then
        pcall(hs.pasteboard.writeAllData, b.all)        -- 비텍스트 폴백
    end
end

function obj:convertSelection()
    local backup = backupPasteboard()

    -- 선택 텍스트 복사 후 클립보드 갱신 대기(최대 0.4초)
    local before = hs.pasteboard.changeCount()
    hs.eventtap.keyStroke({ "cmd" }, "c", 0)
    local waited = 0
    while hs.pasteboard.changeCount() == before and waited < 0.4 do
        hs.timer.usleep(10000); waited = waited + 0.01
    end

    local selected = nil
    if hs.pasteboard.changeCount() ~= before then selected = hs.pasteboard.readString() end
    if not selected or selected == "" then
        restorePasteboard(backup)
        hs.alert.show("변환할 텍스트를 선택하세요", 0.8)
        return
    end

    local ok, converted = pcall(obj.convertText, selected)
    if not ok or not converted or converted == "" then
        restorePasteboard(backup)
        hs.alert.show("변환 실패", 0.8)
        return
    end

    hs.pasteboard.setContents(converted)
    hs.timer.usleep(30000)                              -- 클립보드 반영 대기
    hs.eventtap.keyStroke({ "cmd" }, "v", 0)
    hs.timer.doAfter(0.15, function() restorePasteboard(backup) end)
end

-- ─────────────────────────────────────────────────────────────────────
-- 단축키 관리 + 메뉴바 UI (코드 편집 없이 단축키 변경)
-- ─────────────────────────────────────────────────────────────────────

local SETTINGS_KEY = "HanEng.hotkey"       -- 저장 위치(재시작해도 유지)
local MOD_ORDER = { "ctrl", "alt", "shift", "cmd" }
local MOD_SYMBOL = { cmd = "⌘", shift = "⇧", ctrl = "⌃", alt = "⌥" }

-- 단축키를 보기 좋은 기호로 (예: {"cmd","shift"}, ";" → "⌘⇧;")
local function fmtHotkey(mods, key)
    local s = ""
    for _, m in ipairs(MOD_ORDER) do
        if hs.fnutils.contains(mods, m) then s = s .. MOD_SYMBOL[m] end
    end
    local k = key
    if k == "space" then k = "Space" elseif #k == 1 then k = k:upper() else k = k:upper() end
    return s .. k
end

-- 프리셋 목록
local PRESETS = {
    { mods = { "cmd", "shift" },  key = ";" },
    { mods = { "cmd", "shift" },  key = "\\" },
    { mods = { "cmd" },           key = "'" },
    { mods = { "ctrl", "alt" },   key = "space" },
    { mods = { "ctrl", "alt" },   key = "k" },
}

-- 실제로 단축키를 (재)바인딩
function obj:_applyHotkey(mods, key, persist)
    if self._hotkeyObj then self._hotkeyObj:delete(); self._hotkeyObj = nil end
    self._mods, self._key = mods, key
    self._hotkeyObj = hs.hotkey.bind(mods, key, function() self:convertSelection() end)
    if persist then hs.settings.set(SETTINGS_KEY, { mods = mods, key = key }) end
    self:_refreshMenu()
end

-- 메뉴바 메뉴 갱신
function obj:_refreshMenu()
    if not self._menubar then return end
    local cur = fmtHotkey(self._mods, self._key)
    local presetItems = {}
    for _, p in ipairs(PRESETS) do
        local label = fmtHotkey(p.mods, p.key)
        presetItems[#presetItems + 1] = {
            title = label .. (label == fmtHotkey({ "cmd", "shift" }, ";") and "  (기본값)" or ""),
            checked = (label == cur),
            fn = function()
                self:_applyHotkey(p.mods, p.key, true)
                hs.alert.show("단축키 변경됨:  " .. label, 1)
            end,
        }
    end
    self._menubar:setMenu({
        { title = "현재 단축키:  " .. cur, disabled = true },
        { title = "-" },
        { title = "단축키 바꾸기", menu = presetItems },
        { title = "직접 지정 (다음에 누르는 키로)…", fn = function() self:_recordHotkey() end },
        { title = "-" },
        { title = "사용법 열기", fn = function() hs.execute("open https://github.com/odiowood/hangul-oops") end },
        { title = "만든 사람: odiowood", disabled = true },
    })
end

-- "직접 지정": 다음에 누르는 키 조합을 새 단축키로 (수식 키 1개 이상 필요)
function obj:_recordHotkey()
    if self._recorder then self._recorder:stop(); self._recorder = nil end
    hs.alert.show("바꿀 단축키를 지금 누르세요…\n(⌘ ⇧ ⌃ ⌥ 중 하나 이상과 함께)", 3)
    self._recorder = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(e)
        local key = hs.keycodes.map[e:getKeyCode()]
        if not key or key == "" then return true end
        local f = e:getFlags()
        local mods = {}
        if f.ctrl then mods[#mods + 1] = "ctrl" end
        if f.alt then mods[#mods + 1] = "alt" end
        if f.shift then mods[#mods + 1] = "shift" end
        if f.cmd then mods[#mods + 1] = "cmd" end
        if #mods == 0 then
            hs.alert.show("수식 키(⌘ ⇧ ⌃ ⌥)와 함께 눌러주세요", 1)
            return true                       -- 계속 대기
        end
        self._recorder:stop(); self._recorder = nil
        self:_applyHotkey(mods, key, true)
        hs.alert.show("단축키 변경됨:  " .. fmtHotkey(mods, key), 1)
        return true                           -- 이 입력은 삼킴
    end)
    self._recorder:start()
end

--- HanEng:bindHotkeys(mapping)
--- Method
--- 단축키 지정 + 메뉴바 아이콘 생성. 저장된 사용자 지정 단축키가 있으면 그것을 우선한다.
--- 예: spoon.HanEng:bindHotkeys({ convert = {{"cmd","shift"}, ";"} })
function obj:bindHotkeys(mapping)
    -- 기본 단축키(설정 파일에 저장된 값이 없을 때 사용)
    local defMods, defKey = { "cmd", "shift" }, ";"
    if mapping and mapping.convert then
        defMods, defKey = mapping.convert[1], mapping.convert[2]
    end
    if not self._menubar then
        self._menubar = hs.menubar.new()
        if self._menubar then self._menubar:setTitle("가A") end
    end
    local saved = hs.settings.get(SETTINGS_KEY)
    if saved and saved.mods and saved.key then
        self:_applyHotkey(saved.mods, saved.key, false)     -- 저장된 사용자 지정 우선
    else
        self:_applyHotkey(defMods, defKey, false)
    end
    return self
end

return obj
