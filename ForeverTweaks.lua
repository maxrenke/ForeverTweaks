-- ForeverTweaks (formerly QuestFilter): personal tweaks for WoW Forever. See README.md.
-- /ft lists the commands.
SLASH_FOREVERTWEAKS1 = "/ft"
SlashCmdList.FOREVERTWEAKS = function()
  for _, line in ipairs({
    "/ftquests (/qf) - quest automation on or off",
    "/ftlayout (/qflayout) - re-apply the HUD layout",
    "/ftparty (/qfparty) - re-apply the party frame layout",
    "/ftdump (/qfdump) - dump Edit Mode systems for layout work",
  }) do print("|cff99e6f2ForeverTweaks|r " .. line) end
end
-- Vanilla quests (ID in ForeverTweaksVanilla) are accepted and turned in automatically.
-- Everything else opens normally. Hold Shift at the NPC to handle a quest by hand.
local f = CreateFrame("Frame")

local function on()
  return ForeverTweaksDB.enabled and not IsShiftKeyDown()
end

local function vanilla(id)
  return id and id > 0 and ForeverTweaksVanilla[id]
end

f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("GOSSIP_SHOW")
f:RegisterEvent("QUEST_DETAIL")
f:RegisterEvent("QUEST_PROGRESS")
f:RegisterEvent("QUEST_COMPLETE")

f:SetScript("OnEvent", function(_, event, arg)
  if event == "ADDON_LOADED" then
    if arg == "ForeverTweaks" then
      ForeverTweaksDB = ForeverTweaksDB or { enabled = true }
    end
    return
  end
  if not on() then return end

  if event == "GOSSIP_SHOW" then
    -- Turn in finished vanilla quests first, then pick up new vanilla ones.
    for _, q in ipairs(C_GossipInfo.GetActiveQuests()) do
      if q.isComplete and vanilla(q.questID) then
        C_GossipInfo.SelectActiveQuest(q.questID)
        return
      end
    end
    for _, q in ipairs(C_GossipInfo.GetAvailableQuests()) do
      if vanilla(q.questID) then
        C_GossipInfo.SelectAvailableQuest(q.questID)
        return
      end
    end
  elseif vanilla(GetQuestID()) then
    if event == "QUEST_DETAIL" then
      AcceptQuest()
    elseif event == "QUEST_PROGRESS" and IsQuestCompletable() then
      CompleteQuest()
    elseif event == "QUEST_COMPLETE" and GetNumQuestChoices() <= 1 then
      -- Reward choices are left to you.
      GetQuestReward(GetNumQuestChoices())
    end
  end
end)

SLASH_QUESTFILTER1 = "/ftquests"
SLASH_QUESTFILTER2 = "/qf"
SlashCmdList.QUESTFILTER = function()
  ForeverTweaksDB.enabled = not ForeverTweaksDB.enabled
  print("ForeverTweaks quest automation " .. (ForeverTweaksDB.enabled and "on" or "off"))
end

-- One-time macro restore (2026-11-04): creates any missing launch macros as account macros. Safe to delete afterwards.
local MACROS = {
  { "Big Plates", 132150, "/run SetCVar(\"nameplateMinScale\",1) SetCVar(\"nameplateMaxScale\",1) SetCVar(\"nameplateSelectedScale\",1.3) print(\"Plates:\", GetCVar(\"nameplateMinScale\"), GetCVar(\"nameplateMaxScale\"), GetCVar(\"nameplateSelectedScale\"))" },
  { "Big Chat", 133471, "/run for i=1,NUM_CHAT_WINDOWS do local f=_G[\"ChatFrame\"..i] if f then FCF_SetChatWindowFontSize(nil,f,16) end end print(\"Chat font: 16\")" },
  { "Attack", 1109508, "#showtooltip Attack\n/startattack" },
  { "HS Downrank", 135891, "#showtooltip\n/startattack\n/cast [mod:ctrl] Holy Strike(Rank 1); Holy Strike(Rank 2)" },
  { "Seal Downrank", 135924, "#showtooltip\n/startattack\n/cast [mod:ctrl] Seal of the Crusader(Rank 1); Seal of the Crusader(Rank 1)" },
  { "Judge Twist", 135959, "#showtooltip Judgement\n/startattack\n/cast Judgement\n/cast [mod:ctrl] Seal of the Crusader; [mod:shift] Seal of Righteousness;" },
  { "Heal Self", 135920, "#showtooltip\n/cast [mod:shift,@mouseover,help,nodead][mod:shift,help,nodead][mod:shift,@player] Flash of Light; [@mouseover,help,nodead][help,nodead][@player] Holy Light" },
  { "HoJ Stop", 135963, "#showtooltip Hammer of Justice\n/stopcasting\n/cast [@mouseover,harm,nodead][] Hammer of Justice" },
  { "Blessing", 135906, "#showtooltip\n/cast [mod:shift,@mouseover,help,nodead][mod:shift,help][mod:shift,@player] Blessing of Kings; [mod:ctrl,@mouseover,help,nodead][mod:ctrl,help][mod:ctrl,@player] Blessing of Wisdom; [@mouseover,help,nodead][help][@player] Blessing of Might" },
  { "RF Toggle", 135962, "#showtooltip Righteous Fury\n/cancelaura [mod:shift] Righteous Fury\n/cast [nomod] Righteous Fury" },
  { "Bubble Hearth", 134414, "#showtooltip Hearthstone\n/cast Divine Shield\n/cast Divine Protection\n/use Hearthstone" },
  { "Heal Pot", 134831, "#showtooltip\n/use Major Healing Potion\n/use Superior Healing Potion\n/use Greater Healing Potion\n/use Healing Potion\n/use Lesser Healing Potion\n/use Minor Healing Potion" },
  { "Sit", 132930, "/sit" },
  { "Healthstone", 135230,"#showtooltip\n/use Major Healthstone\n/use Greater Healthstone\n/use Healthstone\n/use Lesser Healthstone\n/use Minor Healthstone" },
}
local seed = CreateFrame("Frame")
seed:RegisterEvent("PLAYER_LOGIN")
seed:SetScript("OnEvent", function()
  C_Timer.After(3, function()
    if InCombatLockdown() then print("ForeverTweaks: in combat, /reload later to restore macros") return end
    local made, had = 0, 0
    for _, m in ipairs(MACROS) do
      if GetMacroIndexByName(m[1]) == 0 then
        local ok, err = pcall(CreateMacro, m[1], m[2], m[3], false)
        if ok then made = made + 1 else print("ForeverTweaks: could not create macro " .. m[1] .. ": " .. tostring(err)) end
      else
        had = had + 1
        local ok, err = pcall(EditMacro, GetMacroIndexByName(m[1]), nil, m[2])
        if not ok then print("ForeverTweaks: could not set icon on " .. m[1] .. ": " .. tostring(err)) end
      end
    end
    local fta = GetMacroIndexByName("FTA Target") if fta > 0 then pcall(EditMacro, fta, nil, 134442) end
    print("ForeverTweaks macros: " .. made .. " created, " .. had .. " already there")
  end)
end)

-- Widsith, Pally Seal Cooldowns and One Key Fishing use custom minimap buttons that Leatrix Plus cannot hide.
-- Re-register them as standard LibDBIcon buttons (Leatrix shows those on hover) and hide the originals.
local WRAP = {
  { "WidsithRecordingIcon", "Widsith", "Interface\\AddOns\\Widsith\\media\\flame" },
  { "PallySealCooldownsMinimapButton", "Pally Seals", "Interface\\Icons\\Spell_Holy_SealOfMight" },
  { "OneKeyFishingMinimapButton", "One Key Fishing", "Interface\\Icons\\Trade_Fishing" },
  -- LootGoblin's button has no global name: find it among the Minimap children by the fields it sets
  { function()
      for _, c in ipairs({ Minimap:GetChildren() }) do
        if not (c.IsForbidden and c:IsForbidden()) and c.minimapAngle ~= nil and c.highlight and c.mask and c.border then return c end
      end
    end, "LootGoblin", "Interface\\AddOns\\LootGoblin\\Brand.tga", { 0.27, 0.77, 0.065, 0.565 } },
}
local wrap = CreateFrame("Frame")
wrap:RegisterEvent("PLAYER_LOGIN")
wrap:SetScript("OnEvent", function()
  C_Timer.After(5, function()
    local ldb = LibStub and LibStub("LibDataBroker-1.1", true)
    local icon = LibStub and LibStub("LibDBIcon-1.0", true)
    if not ldb or not icon then return end
    ForeverTweaksDB.icons = ForeverTweaksDB.icons or {}
    for _, w in ipairs(WRAP) do
      local orig = type(w[1]) == "function" and w[1]() or _G[w[1]]
      if orig and not icon:IsRegistered("QF_" .. w[2]) then
        local obj = ldb:NewDataObject("QF_" .. w[2], {
          type = "launcher", label = w[2], icon = w[3], iconCoords = w[4],
          OnClick = function(_, btn) orig:Click(btn) end,
          OnTooltipShow = function(tip) tip:AddLine(w[2]) end,
        })
        ForeverTweaksDB.icons[w[2]] = ForeverTweaksDB.icons[w[2]] or {}
        icon:Register("QF_" .. w[2], obj, ForeverTweaksDB.icons[w[2]])
        orig:Hide()
        orig:HookScript("OnShow", orig.Hide)
      end
    end
  end)
end)

-- Waypoint UI (2026-11-06): off-screen navigator marker sits far out near the screen edge instead of
-- hugging the character (fixed radius, not tied to camera zoom). Runs once; change later in its settings.
local wpuiNav = CreateFrame("Frame")
wpuiNav:RegisterEvent("PLAYER_LOGIN")
wpuiNav:SetScript("OnEvent", function()
  if not WaypointDB_Global or ForeverTweaksDB.wpuiNav then return end
  WaypointDB_Global.NavigatorDynamicDistance = false
  WaypointDB_Global.NavigatorDistance = 3
  ForeverTweaksDB.wpuiNav = true
end)

-- One Key Fishing back as the only fishing addon (2026-11-05, Stand and Fish parked): K = fishing action,
-- Shift-K = fishing mode, its lures / container opening / indicator back on. Removes Stand and Fish's
-- "Fish Button" macro and its action-bar slot. Runs once per character.
local okfBack = CreateFrame("Frame")
okfBack:RegisterEvent("PLAYER_LOGIN")
okfBack:SetScript("OnEvent", function()
  C_Timer.After(6, function()
    if not C_AddOns.IsAddOnLoaded("OneKeyFishing") then return end
    local me = UnitName("player") .. "-" .. GetRealmName()
    ForeverTweaksDB.okfBack = ForeverTweaksDB.okfBack or {}
    if ForeverTweaksDB.okfBack[me] then return end
    if InCombatLockdown() then print("ForeverTweaks: in combat, /reload later to set One Key Fishing keys") return end
    local idx = GetMacroIndexByName("Fish Button")
    if idx > 0 then
      for slot = 1, 180 do
        local kind, id = GetActionInfo(slot)
        if kind == "macro" and id == idx then PickupAction(slot) ClearCursor() end
      end
      DeleteMacro(idx)
    end
    SetBinding("CTRL-ALT-K")
    SetBinding("K", "ONEKEYFISHING_ACTION")
    SetBinding("SHIFT-K", "ONEKEYFISHING_TOGGLE")
    SaveBindings(GetCurrentBindingSet())
    local s = OneKeyFishingDB and OneKeyFishingDB.settings
    if s then s.lure, s.openContainers, s.indicator = true, true, true end
    ForeverTweaksDB.okfBack[me] = true
    print("ForeverTweaks: One Key Fishing on K (Shift-K = fishing mode)")
  end)
end)

-- Stacked action bars (2026-11-05): bar 2 (bottom left) right above the main bar, bar 3 (bottom right) above bar 2,
-- each one row of 12, centred, like the retail layout. Runs once for the active custom Edit Mode layout.
local stack = CreateFrame("Frame")
stack:RegisterEvent("PLAYER_LOGIN")
stack:SetScript("OnEvent", function()
  C_Timer.After(4, function()
    if ForeverTweaksDB.barsStacked or InCombatLockdown() then return end
    local ok, err = pcall(function()
      local AB, IDX = Enum.EditModeSystem.ActionBar, Enum.EditModeActionBarSystemIndices
      local S = Enum.EditModeActionBarSetting
      local info = C_EditMode.GetLayouts()
      -- activeLayout counts the preset layouts first; GetLayouts().layouts holds only custom ones
      local presets = EditModePresetLayoutManager and #EditModePresetLayoutManager:GetCopyOfPresetLayouts() or 2
      local layout = info.layouts[info.activeLayout - presets]
      if not layout then print("ForeverTweaks: active Edit Mode layout is a preset; copy it to a custom layout to stack bars") return end
      local function frameName(index)
        local f = EditModeManagerFrame:GetRegisteredSystemFrame(AB, index)
        return f and f:GetName()
      end
      local below = { [IDX.Bar2] = frameName(IDX.MainBar), [IDX.Bar3] = frameName(IDX.Bar2) }
      for _, sys in ipairs(layout.systems) do
        if sys.system == AB and below[sys.systemIndex] then
          sys.isInDefaultPosition = false
          sys.anchorInfo = { point = "BOTTOM", relativeTo = below[sys.systemIndex], relativePoint = "TOP", offsetX = 0, offsetY = 2 }
          for _, s in ipairs(sys.settings) do
            if s.setting == S.Orientation then s.value = 0 end -- horizontal
            if s.setting == S.NumRows then s.value = 1 end
            if s.setting == S.NumIcons then s.value = 12 end
          end
        end
      end
      C_EditMode.SaveLayouts(info)
    end)
    if ok then
      ForeverTweaksDB.barsStacked = true
      print("ForeverTweaks: action bars 2 and 3 stacked above the main bar. /reload to see it.")
    else
      print("ForeverTweaks: could not stack action bars: " .. tostring(err))
    end
  end)
end)

-- /qfdump (2026-11-05): records Edit Mode systems, their settings enums and visible frames near the screen
-- centre into ForeverTweaksDB.dump, so the HUD layout can be set by code. /reload afterwards to write it to disk.
SLASH_QFDUMP1 = "/ftdump"
SLASH_QFDUMP2 = "/qfdump"
SlashCmdList.QFDUMP = function()
  local d = { systems = {}, enums = {}, frames = {}, screen = { UIParent:GetWidth(), UIParent:GetHeight(), UIParent:GetEffectiveScale() } }
  for k, v in pairs(Enum) do
    if type(k) == "string" and k:find("^EditMode") then
      local t = {}
      for n, x in pairs(v) do t[n] = x end
      d.enums[k] = t
    end
  end
  for _, f in ipairs(EditModeManagerFrame.registeredSystemFrames or {}) do
    local p, rel, rp, x, y = f:GetPoint(1)
    d.systems[#d.systems + 1] = {
      system = f.system, index = f.systemIndex, name = f:GetName(),
      label = f.GetSystemName and f:GetSystemName() or nil, shown = f:IsShown(),
      point = { p, rel and rel.GetName and rel:GetName() or tostring(rel), rp, x, y },
      center = { f:GetCenter() }, size = { f:GetSize() },
    }
  end
  for _, f in ipairs({ UIParent:GetChildren() }) do
    if not (f.IsForbidden and f:IsForbidden()) then
      pcall(function()
        local name = f:GetName()
        if name and f:IsVisible() and f:GetCenter() then
          local x, y = f:GetCenter()
          local w, h = f:GetSize()
          if w < 900 and h < 400 then
            d.frames[#d.frames + 1] = { name = name, center = { x, y }, size = { w, h }, strata = f:GetFrameStrata() }
          end
        end
      end)
    end
  end
  ForeverTweaksDB.dump = d
  print("ForeverTweaks: dump saved (" .. #d.systems .. " systems, " .. #d.frames .. " frames). /reload to write it.")
end

-- /qflayout (2026-11-05): HUD layout by code. Centred stack from the bottom: XP bar, Action Bar 1, 2, 3.
-- Bar art off. Swing timer and seal bar right above the stack, stance bar left of bar 3. Positions are in UIParent units (screen is about 2133 x 1200). /reload afterwards.
SLASH_QFLAYOUT1 = "/ftlayout"
SLASH_QFLAYOUT2 = "/qflayout"
SlashCmdList.QFLAYOUT = function()
  if InCombatLockdown() then print("ForeverTweaks: leave combat first") return end
  local M, AB, IDX, S = EditModeManagerFrame, Enum.EditModeSystem.ActionBar, Enum.EditModeActionBarSystemIndices, Enum.EditModeActionBarSetting
  local function step(label, fn)
    local ok, err = pcall(fn)
    print("ForeverTweaks layout: " .. label .. (ok and " ok" or (" FAILED: " .. tostring(err))))
  end
  local function place(f, point, x, y)
    f:ClearAllPoints()
    f:SetPoint(point, UIParent, point, x, y)
    M:OnSystemPositionChange(f)
  end
  local BAR_H, GAP = 45, 2
  step("edit mode", function() ShowUIPanel(M) end)
  step("xp bar", function() place(M:GetRegisteredSystemFrame(Enum.EditModeSystem.StatusTrackingBar, 1), "BOTTOM", 0, 0) end)
  local bars = { { IDX.MainBar, 19 }, { IDX.Bar2, 19 + BAR_H + GAP }, { IDX.Bar3, 19 + 2 * (BAR_H + GAP) } }
  for _, b in ipairs(bars) do
    step("action bar " .. b[1], function()
      local f = M:GetRegisteredSystemFrame(AB, b[1])
      M:OnSystemSettingChange(f, S.Orientation, 0)
      M:OnSystemSettingChange(f, S.NumRows, 1)
      M:OnSystemSettingChange(f, S.NumIcons, 12)
      if b[1] == IDX.MainBar then
        M:OnSystemSettingChange(f, S.HideBarArt, 1)
        M:OnSystemSettingChange(f, S.HideBarScrolling, 1)
      else
        M:OnSystemSettingChange(f, S.AlwaysShowButtons, 1)
      end
      place(f, "BOTTOM", 0, b[2])
    end)
  end
  step("stance bar", function() place(M:GetRegisteredSystemFrame(AB, IDX.StanceBar), "BOTTOM", -301, 19 + 2 * (BAR_H + GAP)) end)
  step("save", function() M:SaveLayoutChanges() end)
  step("close edit mode", function() HideUIPanel(M) end)

  -- Addon frames: saved positions, applied by each addon on /reload. CENTER offsets; screen bottom is -600.
  step("BetterSwingTimer", function() BetterSwingTimerDB.point, BetterSwingTimerDB.offsetX, BetterSwingTimerDB.offsetY = "CENTER", 0, -425 end)
  step("Pally Seal Cooldowns", function() PallySealCooldownsDB.x, PallySealCooldownsDB.y = 0, -375 end)
  print("ForeverTweaks layout: done, /reload to apply the addon positions")
end


-- Party frames (2026-11-07): raid-style 72x72 squares in class colors, stacked to the left of the player portrait,
-- ordered tank > healer > dps > you (Blizzard's own role sort puts you alphabetically among the dps).
-- /qfparty re-applies the Edit Mode part; it also runs once per character at login.
local ROLE_ORDER = { TANK = 1, HEALER = 2, DAMAGER = 3, NONE = 3 }
local function QFPartySort(a, b)
  local pa, pb = UnitIsUnit(a, "player"), UnitIsUnit(b, "player")
  if pa ~= pb then return pb end
  local ra, rb = ROLE_ORDER[UnitGroupRolesAssigned(a)] or 3, ROLE_ORDER[UnitGroupRolesAssigned(b)] or 3
  if ra ~= rb then return ra < rb end
  local na, nb = UnitName(a), UnitName(b)
  if na and nb then return na < nb end
  if na or nb then return na ~= nil end
  return a < b
end
local function QFApplyPartySort()
  if InCombatLockdown() or not CompactPartyFrame or CompactPartyFrame.flowSortFunc == QFPartySort then return end
  CompactPartyFrame:SetFlowSortFunction(QFPartySort)
end

local function QFPartyLayout()
  if InCombatLockdown() then print("ForeverTweaks: leave combat first") return end
  local M, S = EditModeManagerFrame, Enum.EditModeUnitFrameSetting
  local function step(label, fn)
    local ok, err = pcall(fn)
    print("ForeverTweaks party: " .. label .. (ok and " ok" or (" FAILED: " .. tostring(err))))
  end
  SetCVar("raidFramesDisplayClassColor", "1")
  step("edit mode", function() ShowUIPanel(M) end)
  step("party frames", function()
    local f = M:GetRegisteredSystemFrame(Enum.EditModeSystem.UnitFrame, Enum.EditModeUnitFrameSystemIndices.Party)
    M:OnSystemSettingChange(f, S.UseRaidStylePartyFrames, 1)
    M:OnSystemSettingChange(f, S.UseHorizontalGroups, 0)
    M:OnSystemSettingChange(f, S.ShowPartyFrameBackground, 0)
    M:OnSystemSettingChange(f, S.FrameWidth, 72)
    M:OnSystemSettingChange(f, S.FrameHeight, 72)
    if Enum.SortPlayersBy and Enum.SortPlayersBy.Role then M:OnSystemSettingChange(f, S.SortPlayersBy, Enum.SortPlayersBy.Role) end
    -- Right edge 8 units left of the player frame; a full party's bottom lines up with the player frame's bottom.
    local k = PlayerFrame:GetEffectiveScale() / UIParent:GetEffectiveScale()
    local x, y = PlayerFrame:GetLeft() * k - 8, PlayerFrame:GetBottom() * k + 5 * 72 + 4
    f:ClearAllPoints()
    f:SetPoint("TOPRIGHT", UIParent, "BOTTOMLEFT", x, y)
    M:OnSystemPositionChange(f)
  end)
  step("save", function() M:SaveLayoutChanges() end)
  step("close edit mode", function() HideUIPanel(M) end)
  C_Timer.After(0.5, QFApplyPartySort)
end
SLASH_QFPARTY1 = "/ftparty"
SLASH_QFPARTY2 = "/qfparty"
SlashCmdList.QFPARTY = QFPartyLayout

local partyFrames = CreateFrame("Frame")
partyFrames:RegisterEvent("PLAYER_ENTERING_WORLD")
partyFrames:RegisterEvent("GROUP_ROSTER_UPDATE")
partyFrames:RegisterEvent("PLAYER_REGEN_ENABLED")
partyFrames:SetScript("OnEvent", function(_, event)
  if event == "PLAYER_ENTERING_WORLD" then
    C_Timer.After(8, function()
      local me = UnitName("player") .. "-" .. GetRealmName()
      ForeverTweaksDB.partyLayout = ForeverTweaksDB.partyLayout or {}
      if not ForeverTweaksDB.partyLayout[me] and not InCombatLockdown() then
        QFPartyLayout()
        ForeverTweaksDB.partyLayout[me] = true
      end
      QFApplyPartySort()
    end)
  else
    QFApplyPartySort()
  end
end)

-- Platynator (2026-11-06): import the Jamestone profile (wago.io/xFmq0meO5, built for WoW Forever) once per character.
local platyImport = CreateFrame("Frame")
platyImport:RegisterEvent("PLAYER_LOGIN")
platyImport:SetScript("OnEvent", function()
  C_Timer.After(3, function()
    if not (Platynator and Platynator.API and Platynator.API.ImportString) then return end
    local me = UnitName("player") .. "-" .. GetRealmName()
    ForeverTweaksDB.platyImport = ForeverTweaksDB.platyImport or {}
    if ForeverTweaksDB.platyImport[me] then return end
    local ok, err = pcall(Platynator.API.ImportString, [[PLATY!1!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]], "Jamestone")
    if ok then ForeverTweaksDB.platyImport[me] = true else print("ForeverTweaks: Platynator import failed: " .. tostring(err)) end
  end)
end)

-- Details! (2026-11-06): WoW Forever theme, applied once per character. Classic Blizzard window skin ("WoW Interface"),
-- Friz Quadrata text, class-colored bars, Forever teal (#99e6f2, same as Forever Quest Tint) on the title and status bar.
-- Window sits bottom right above the bags. Skips Details' first-run welcome window.
local detailsTheme = CreateFrame("Frame")
detailsTheme:RegisterEvent("PLAYER_LOGIN")
detailsTheme:SetScript("OnEvent", function()
  C_Timer.After(7, function()
    if not (Details and Details.GetInstance) then return end
    local me = UnitName("player") .. "-" .. GetRealmName()
    ForeverTweaksDB.detailsTheme = ForeverTweaksDB.detailsTheme or {}
    if ForeverTweaksDB.detailsTheme[me] then return end
    if InCombatLockdown() then print("ForeverTweaks: in combat, /reload later to theme Details") return end
    local ok, err = pcall(function()
      if DetailsWelcomeWindow then DetailsWelcomeWindow:Hide() end
      local inst = Details:GetInstance(1)
      if not inst then return end
      if not inst:IsEnabled() then inst:EnableInstance() end
      inst:ChangeSkin("WoW Interface")
      inst:SetBarSettings(16, "Blizzard", true)
      inst:SetBarTextSettings(11, "Friz Quadrata TT", nil, false, false, true, true)
      inst:AttributeMenu(nil, nil, nil, "Friz Quadrata TT", 11, { 0.6, 0.9, 0.95, 1 })
      inst:StatusBarColor(0.6, 0.9, 0.95, 1)
      inst:SetSize(250, 140)
      inst.baseframe:ClearAllPoints()
      inst.baseframe:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -60, 90)
      inst:SaveMainWindowPosition()
    end)
    if ok then ForeverTweaksDB.detailsTheme[me] = true else print("ForeverTweaks: Details theme failed: " .. tostring(err)) end
  end)
end)
