local _, addonTable = ...

local ipairs, pairs, GetItemCount, GetItemInfo = ipairs, pairs, GetItemCount, GetItemInfo
local GetItemIcon, GetItemCooldown, CreateFrame = GetItemIcon, GetItemCooldown, CreateFrame
local UIParent, print, table, GetTime, select = UIParent, print, table, GetTime, select
local InCombatLockdown, GameTooltip, GameTooltip_SetDefaultAnchor = InCombatLockdown, GameTooltip, GameTooltip_SetDefaultAnchor

local questItems = addonTable.questItems

addonTable.UnlockPoliQuestButton = function()
    local button = addonTable.questButtonManager.Button
    if not button:IsVisible() then
        button.Texture:SetTexture(134400)
        button.PrevButton:Disable()
        button.PrevButton:Show()
        button.NextButton:Disable()
        button.PrevButton:Show()
        button.ViewPrev.Texture:SetTexture(134400)
        button.ViewPrev:Disable()
        button.ViewPrev:Show()
        button.ViewNext.Texture:SetTexture(134400)
        button.ViewNext:Disable()
        button.ViewNext:Show()
        button:Show()
    end
    button.LockButton:Show()
    button:SetMovable(true)
end

addonTable.LockPoliQuestButton = function()
    local button = addonTable.questButtonManager.Button
    button.LockButton:Hide()
    button:SetMovable(false)
    print("|cFF5c8cc1PoliQuest:|r Button will show when you have a Shadowlands quest item in your bags.")
    print("|cFF5c8cc1/pq toggle:|r to show/move button again.")
end

do -- Manage usable quest items
  local currentItems = {}
  local itemsChanged = function()
      -- questItems >= currentItems
      for itemID,_ in pairs(questItems) do
          local item = GetItemCount(itemID)
          if item > 0 then
              if #currentItems == 0 then
                  return true
              end
              for i, v in ipairs(currentItems) do
                  if v == itemID then
                      break
                  elseif i == #currentItems then
                      return true
                  end
              end
          end
      end
      -- questItems <= currentItems
      for i,v in ipairs(currentItems) do
          if GetItemCount(v) == 0 then
              return true
          end
      end
      -- questItems == currentItems
      return false
  end

  local updateCurrentItems = function()
      currentItems = {}
      for itemID, recordedItemInfo in pairs(questItems) do
          local count = GetItemCount(itemID)
          if count > 0 then
              table.insert(currentItems, itemID)
              questItems[itemID]["count"] = count
          else
              questItems[itemID]["count"] = 0
          end
      end
  end

  local currentItemIndex
  local updateButton = function(frame, refresh)
      if #currentItems == 0 then
          currentItemIndex = nil
          frame:SetAttribute("item", nil)
          frame:Hide()
      else
          if refresh then
              currentItemIndex = 1
          end
          local itemID = currentItems[currentItemIndex]
          local icon = GetItemIcon(itemID)
          frame.Texture:SetTexture(icon)
          frame:SetAttribute("item", "item:"..itemID)
          frame:Show()
          local startTime, duration = GetItemCooldown(itemID)
          if startTime ~= 0 and duration ~= 0 then
              frame.Cooldown:SetCooldown(startTime, duration)
          else
              frame.Cooldown:SetCooldown(0, 0)
          end
          if currentItemIndex then
              local itemCount = GetItemCount(currentItems[currentItemIndex])
              if itemCount > 1 then
                  frame.FontString:SetText(itemCount)
              else
                  frame.FontString:SetText("")
              end
          end
          if #currentItems == 1 then
              frame.PrevButton:Disable()
              frame.NextButton:Disable()
              frame.ViewPrev:Disable()
              frame.ViewPrev:Hide()
              frame.ViewNext:Disable()
              frame.ViewNext:Hide()
          elseif currentItemIndex == 1 then
              frame.PrevButton:Enable()
              frame.NextButton:Enable()
              frame.ViewPrev:Disable()
              frame.ViewPrev:Hide()
              frame.ViewNext.Texture:SetTexture(GetItemIcon(currentItems[2]))
              frame.ViewNext:Enable()
              frame.ViewNext:Show()
          elseif currentItemIndex == #currentItems then
              frame.PrevButton:Enable()
              frame.NextButton:Enable()
              frame.ViewPrev.Texture:SetTexture(GetItemIcon(currentItems[#currentItems-1]))
              frame.ViewPrev:Enable()
              frame.ViewPrev:Show()
              frame.ViewNext:Disable()
              frame.ViewNext:Hide()
          else
              frame.PrevButton:Enable()
              frame.NextButton:Enable()
              frame.ViewPrev.Texture:SetTexture(GetItemIcon(currentItems[currentItemIndex-1]))
              frame.ViewPrev:Enable()
              frame.ViewPrev:Show()
              frame.ViewNext.Texture:SetTexture(GetItemIcon(currentItems[currentItemIndex+1]))
              frame.ViewNext:Enable()
              frame.ViewNext:Show()
          end
          frame:Show()
      end
  end
  
  local prevItemButton_OnClick = function(frame)
      currentItemIndex = (currentItemIndex - 2) % #currentItems + 1
      updateButton(frame:GetParent())
  end
  
  local nextItemButton_OnClick = function(frame)
      currentItemIndex = currentItemIndex % #currentItems + 1
      updateButton(frame:GetParent())
  end

  local unlockPrevNextButtons = function(frame)
      frame.PrevButton:Enable()
      frame.NextButton:Enable()
      frame.ViewPrev:Enable()
      frame.ViewNext:Enable()
  end
  
  local lockPrevNextButtons = function(frame)
      frame.PrevButton:Disable()
      frame.NextButton:Disable()
      frame.ViewPrev:Disable()
      frame.ViewNext:Disable()
  end

  local pendingUpdate
  local throttleItemCheck
  local onEvent = function(self, event, ...)
      if event == "PLAYER_REGEN_ENABLED" then
          if not pendingUpdate and #currentItems > 1 then
              unlockPrevNextButtons(self)
          end
      elseif event == "PLAYER_REGEN_DISABLED" then
          if #currentItems > 1 then
              lockPrevNextButtons(self)
          end
      elseif event == "BAG_UPDATE" or event == "BAG_UPDATE_COOLDOWN"
      or event == "PLAYER_ENTERING_WORLD" then
          if currentItemIndex then
              local itemCount = GetItemCount(currentItems[currentItemIndex])
              if itemCount > 1 then
                  self.FontString:SetText(itemCount)
              else
                  self.FontString:SetText("")
              end
          end
          throttleItemCheck = GetTime()
      elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
          addonTable.debugPrint(select(3,...))
          if currentItemIndex and questItems[currentItems[currentItemIndex]] and questItems[currentItems[currentItemIndex]]["spellID"] == select(3, ...)
          and questItems[currentItems[currentItemIndex]]["cooldown"] then
              self.Cooldown:SetCooldown(GetTime(), questItems[currentItems[currentItemIndex]]["cooldown"])
          end
      end
  end

  local onUpdate = function(self)
      if throttleItemCheck and GetTime() - throttleItemCheck > .1 then
          if itemsChanged() then
              updateCurrentItems()
              pendingUpdate = true
          end
          throttleItemCheck = nil
      end
      if pendingUpdate and not InCombatLockdown() then
          updateButton(self.Button, true)
          pendingUpdate = false
      end
  end
  
  -- quest item button manager
  addonTable.questButtonManager = CreateFrame("Frame", "PoliQuestButtonManager", UIParent)
  local questButtonManager = addonTable.questButtonManager
  questButtonManager:SetScript("OnUpdate", onUpdate)
  
  -- quest item button
  local questButton = CreateFrame("Button", "PQButton", questButtonManager, "SecureActionButtonTemplate")
  questButton.Texture = questButton:CreateTexture("PoliQuestItemButtonTexture","BACKGROUND")
  questButton.Texture:SetAllPoints(questButton)
  questButton:SetPoint("CENTER", UIParent, 0, 0)
  questButton:SetSize(64, 64)
  questButton:SetClampedToScreen(true)
  questButton:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
  questButton:SetAttribute("type", "item")
  questButton:RegisterEvent("PLAYER_REGEN_ENABLED")
  questButton:RegisterEvent("PLAYER_REGEN_DISABLED")
  questButton:RegisterEvent("BAG_UPDATE")
  questButton:RegisterEvent("BAG_UPDATE_COOLDOWN")
  questButton:RegisterEvent("PLAYER_ENTERING_WORLD")
  questButton:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player")
  questButton:SetScript("OnEvent", onEvent)
  questButton:SetScript("OnEnter", function()
      if currentItems[currentItemIndex] == nil then return end
      GameTooltip:ClearLines()
      GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
      GameTooltip:SetHyperlink(select(2, GetItemInfo(currentItems[currentItemIndex])))
      GameTooltip:Show()
  end)
  questButton:SetScript("OnLeave", function()
      GameTooltip:ClearLines()
      GameTooltip:Hide()
  end)
  questButton:RegisterForDrag("LeftButton")
  questButton:SetScript("OnDragStart", function(self) if self:IsMovable() then self:StartMoving() end end)
  questButton:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
  questButton.Cooldown = CreateFrame("Cooldown", "PoliQuestItemCooldown", questButton, "CooldownFrameTemplate")
  questButton.Cooldown:SetAllPoints(questButton)
  questButton.FontString = questButton:CreateFontString("PoliQuestItemCount", "BACKGROUND")
  questButton.FontString:SetPoint("BOTTOMRIGHT", -4, 4)
  questButton.FontString:SetFont("Fonts\\FRIZQT__.TTF", 20, "OUTLINE, MONOCHROME")
  questButtonManager.Button = questButton
  
  -- left arrow button
  local prevItemButton = CreateFrame("Button", "PQPrev", questButton, "SecureActionButtonTemplate")
  prevItemButton:SetPoint("BOTTOMRIGHT", "$parent", "TOP", 0, 0)
  prevItemButton:SetSize(32, 32)
  prevItemButton:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up")
  prevItemButton:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Down")
  prevItemButton:SetDisabledTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Disabled")
  prevItemButton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
  prevItemButton:SetScript("OnClick", prevItemButton_OnClick)
  questButton.PrevButton = prevItemButton
  
  -- right arrow button
  local nextItemButton = CreateFrame("Button", "PQNext", questButton, "SecureActionButtonTemplate")
  nextItemButton:SetPoint("BOTTOMLEFT", "$parent", "TOP", 0, 0)
  nextItemButton:SetSize(32, 32)
  nextItemButton:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
  nextItemButton:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Down")
  nextItemButton:SetDisabledTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Disabled")
  nextItemButton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
  nextItemButton:SetScript("OnClick", nextItemButton_OnClick)
  questButton.NextButton = nextItemButton
  
  -- left item view
  local prevView = CreateFrame("Button", "PoliPrevViewButton", questButton, "SecureActionButtonTemplate")
  prevView:SetPoint("RIGHT", "$parent", "LEFT", -4, 0)
  prevView:SetSize(32, 32)
  prevView:SetScript("OnClick", prevItemButton_OnClick)
  prevView.Texture = prevView:CreateTexture("PoliPrevViewButtonTexture","BACKGROUND")
  prevView.Texture:SetAllPoints(prevView)
  questButton.ViewPrev = prevView
  
  -- right item view
  local nextView = CreateFrame("Button", "PoliNextViewButton", questButton, "SecureActionButtonTemplate")
  nextView:SetPoint("LEFT", "$parent", "RIGHT", 4, 0)
  nextView:SetSize(32, 32)
  nextView:SetScript("OnClick", nextItemButton_OnClick)
  nextView.Texture = nextView:CreateTexture("PoliNextViewButtonTexture","BACKGROUND")
  nextView.Texture:SetAllPoints(nextView)
  questButton.ViewNext = nextView
  
  -- lock button
  local lockButton = CreateFrame("Button", "PoliLockButton", questButton, "SecureActionButtonTemplate")
  lockButton:SetPoint("TOPLEFT", "$parent", "BOTTOMRIGHT", 0, 0)
  lockButton:SetSize(32, 32)
  lockButton:SetNormalTexture("Interface\\Buttons\\LockButton-Unlocked-Up")
  lockButton:SetPushedTexture("Interface\\Buttons\\LockButton-Unlocked-Down")
  lockButton:SetDisabledTexture("Interface\\Buttons\\CancelButton-Up")
  lockButton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
  lockButton:SetScript("OnClick", function() addonTable.LockPoliQuestButton() end)
  lockButton:RegisterEvent("PLAYER_REGEN_ENABLED")
  lockButton:RegisterEvent("PLAYER_REGEN_DISABLED")
  lockButton:SetScript("OnEvent", function(self, event)
      if event == "PLAYER_REGEN_DISABLED" then
          lockButton:Disable()
      else
          lockButton:Enable()
      end
  end)
  lockButton:Hide()
  questButton.LockButton = lockButton
  lockButton.FontString = lockButton:CreateFontString("PoliLockButtonText", "BACKGROUND")
  lockButton.FontString:SetPoint("RIGHT", "$parent", "LEFT", 0, 0)
  lockButton.FontString:SetFont("Fonts\\FRIZQT__.TTF", 20, "OUTLINE, MONOCHROME")
  lockButton.FontString:SetText("MOVE")
  
  updateButton(questButton, true)
end