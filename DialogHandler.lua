local _, addonTable = ...

local C_GossipInfo, ipairs, C_QuestLog, GetNumActiveQuests = C_GossipInfo, ipairs, C_QuestLog, GetNumActiveQuests
local type, C_Item, ItemLocation, table, GetActiveTitle = type, C_Item, ItemLocation, table, GetActiveTitle
local string, GetInventoryItemLink, GetItemStatDelta = string, GetInventoryItemLink, GetItemStatDelta
local GetItemInfo, select, GetTime, SelectActiveQuest = GetItemInfo, select, GetTime, SelectActiveQuest
local GetNumAvailableQuests, GetAvailableQuestInfo, SelectActiveQuest, AcceptQuest = GetNumAvailableQuests, GetAvailableQuestInfo, SelectActiveQuest, AcceptQuest
local IsQuestCompletable, CompleteQuest, math, GetQuestItemLink = IsQuestCompletable, CompleteQuest, math, GetQuestItemLink
local GetDetailedItemLevelInfo, GetItemSpecInfo, pairs, GetNumQuestChoices = GetDetailedItemLevelInfo, GetItemSpecInfo, pairs, GetNumQuestChoices
local GetLootSpecialization, GetSpecializationInfo, GetSpecialization, GetQuestReward = GetLootSpecialization, GetSpecializationInfo, GetSpecialization, GetQuestReward
local GetNumAutoQuestPopUps, GetAutoQuestPopUp, CAMPAIGN_QUEST_TRACKER_MODULE = GetNumAutoQuestPopUps, GetAutoQuestPopUp, CAMPAIGN_QUEST_TRACKER_MODULE
local UIErrorsFrame, UnitLevel, UnitName, SelectAvailableQuest = UIErrorsFrame, UnitLevel, UnitName, SelectAvailableQuest
local AutoQuestPopUpTracker_OnMouseDown, GetQuestProgressBarPercent = AutoQuestPopUpTracker_OnMouseDown, GetQuestProgressBarPercent

local questNames = addonTable.questNames
local questIDToName = addonTable.questIDToName
local dialogWhitelist = addonTable.dialogWhitelist
local innWhitelist = addonTable.innWhitelist
local itemEquipLocToEquipSlot = addonTable.itemEquipLocToEquipSlot

local reportQuestProgressLastRun
local reportQuestProgressRefreshPending

do -- Manage quests and dialog
  local searchDialogOptions = function(questDialog)
      local gossipOptions = C_GossipInfo.GetOptions()
      local numOptions = C_GossipInfo.GetNumOptions()
      for i=1, numOptions do
          local gossip = gossipOptions[i]
          local dialog = questDialog["dialog"]
          if type(dialog) == "string" then
              if questDialog["dialog"] == gossip["name"] then
                  C_GossipInfo.SelectOption(i)
                  return true
              end
          else
              for _, v in ipairs(dialog) do
                  if v == gossip["name"] then
                      C_GossipInfo.SelectOption(i)
                      return true
                  end
              end
          end
      end
  end
  
  local onGossipShow_questGossip = function()
      local actQuests = C_GossipInfo.GetActiveQuests()
      for i, v in ipairs(actQuests) do
          if questIDToName[v.questID] and v.isComplete then
              C_GossipInfo.SelectActiveQuest(i)
              return
          end
      end
  
      local availableQuests = C_GossipInfo.GetAvailableQuests()
      for i, v in ipairs(availableQuests) do
          if questIDToName[v.questID] then
              C_GossipInfo.SelectAvailableQuest(i)
              return
          end
      end
  
      local numQuests = C_QuestLog.GetNumQuestLogEntries()
      for i=1, numQuests do
          local questName = C_QuestLog.GetInfo(i).title
          local questDialog = dialogWhitelist[questName]
          if questDialog then
              if type(questDialog["npc"]) == "string" then
                  if questDialog["npc"] == GossipFrameNpcNameText:GetText() then
                      searchDialogOptions(questDialog)
                  end
              else
                  for j, v in ipairs(questDialog["npc"]) do
                      if questDialog["npc"][j] == GossipFrameNpcNameText:GetText() then
                          if searchDialogOptions(questDialog) then
                              return
                          end
                      end
                  end
              end
          end
      end
  end
  
  local onGossipShow_setHearth = function()
      if innWhitelist[GossipFrameNpcNameText:GetText()] then
          local gossipOptions = C_GossipInfo.GetOptions()
          local numOptions = C_GossipInfo.GetNumOptions()
          for i=1, numOptions do
              if gossipOptions[i]["type"] == "binder" then
                  C_GossipInfo.SelectOption(i)
                  StaticPopup1Button1:Click("LeftButton")
              end
          end
      end
  end
  
  -- completes a quest
  local completeQuest = function()
      for i=1, GetNumActiveQuests() do
          local questName, isComplete = GetActiveTitle(i)
          if questNames[string.lower(questName)] and isComplete then
              addonTable.debugPrint("onQuestGreeting | completeQuest | SelectActiveQuest: " .. questName)
              SelectActiveQuest(i)
              return
          end
      end
  end
  
  -- adds a quest
  local acceptQuest = function()
      for i=1, GetNumAvailableQuests() do
          local questID = select(5, GetAvailableQuestInfo(i))
          if questIDToName[questID] then
              SelectAvailableQuest(i)
              return
          end
      end
  end
  
  local onQuestGreeting = function()
      if completeQuest() then
          return
      elseif acceptQuest() then
          return
      end
  end

  -- adds a quest
  local onQuestDetail = function()
      if QuestInfoTitleHeader then
          if QuestInfoTitleHeader:GetText() and QuestInfoTitleHeader:GetText() ~= "" then
              if questNames[string.lower(QuestInfoTitleHeader:GetText())] then
                  AcceptQuest()
              end
          else
              QuestFrame:Hide()
          end
      end
  end

  -- completes a quest
  local onQuestProgress = function()
      if QuestProgressTitleText then
          if questNames[string.lower(QuestProgressTitleText:GetText())] and IsQuestCompletable() then
              CompleteQuest()
          end
      end
  end

  local calculateStatIncrease = function(itemLink)
      local equipSlot = select(9, GetItemInfo(itemLink))
      local potentialDestSlots = itemEquipLocToEquipSlot[equipSlot]
      if potentialDestSlots then
          if type(potentialDestSlots) == "number" then
              local currentItemLink = GetInventoryItemLink("player", potentialDestSlots)
              if currentItemLink == nil then
                  return nil
              else
                  local statDifferences = GetItemStatDelta(itemLink, currentItemLink)
                  if potentialDestSlots == 1 or potentialDestSlots == 2 or potentialDestSlots == 3 or potentialDestSlots == 5
                  or potentialDestSlots == 6 or potentialDestSlots == 7 or potentialDestSlots == 8 or potentialDestSlots == 9
                  or potentialDestSlots == 10 or potentialDestSlots == 15 or potentialDestSlots == 16 or potentialDestSlots == 17 then
                      return statDifferences["ITEM_MOD_STAMINA_SHORT"]
                  end
              end
          else
              if potentialDestSlots[1] == 13 then
                  return nil
              end
              local slot1Link = GetInventoryItemLink("player", potentialDestSlots[1])
              local slot2Link = GetInventoryItemLink("player", potentialDestSlots[2])
              if slot1Link == nil or slot2Link == nil then
                  return nil
              else
                  local statDif1 = GetItemStatDelta(itemLink, slot1Link)
                  local statDif2 = GetItemStatDelta(itemLink, slot2Link)
                  return math.max(statDif1["ITEM_MOD_STAMINA_SHORT"] or 0, statDif2["ITEM_MOD_STAMINA_SHORT"] or 0)
              end
          end
      end
  end
  
  local getItemsDetails = function(numChoices)
      local itemDetails = {}
      for i=1, numChoices do
          local itemLink = GetQuestItemLink("choice", i)
          local itemEquipLoc, _, vendorPrice = select(9, GetItemInfo(itemLink))
          if itemEquipLoc == "" then
              return nil
          end
          table.insert(itemDetails, {
              ["choiceIndex"] = i,
              ["equipSlot"] = itemEquipLocToEquipSlot[itemEquipLoc],
              ["ilvl"] = GetDetailedItemLevelInfo(itemLink),
              ["specs"] = GetItemSpecInfo(itemLink) or {},
              ["statIncrease"] = calculateStatIncrease(itemLink),
              ["vendorPrice"] = vendorPrice
          })
      end
      return itemDetails
  end
  
  local calcIlvlDifference = function(itemDetails)
      local itemIlvl = itemDetails["ilvl"]
      local equipSlot = itemDetails["equipSlot"]
      if type(equipSlot) == "number" then
          return itemIlvl - C_Item.GetCurrentItemLevel(ItemLocation:CreateFromEquipmentSlot(equipSlot))
      else
          local ilvl1 = C_Item.GetCurrentItemLevel(ItemLocation:CreateFromEquipmentSlot(equipSlot[1]))
          local ilvl2 = C_Item.GetCurrentItemLevel(ItemLocation:CreateFromEquipmentSlot(equipSlot[2]))
          return ilvl1 > ilvl2 and itemIlvl - ilvl2 or itemIlvl - ilvl1
      end
  end
  
  local missingItem = function(itemsDetails)
      for k, v in pairs(itemsDetails) do
          local equipSlot = v["equipSlot"]
          if type(equipSlot) == "number" then
              if GetInventoryItemLink("player", equipSlot) == nil then
                  return true
              end
          else
              if GetInventoryItemLink("player", equipSlot[1]) == nil or GetInventoryItemLink("player", equipSlot[2]) == nil then
                  return true
              end
          end
      end
      return false
  end
  
  local getLargestSpecUpgrade = function(itemsDetails, lootSpec)
      local specItemsDetails = {}
      for _, v in ipairs(itemsDetails) do
          local specs = v["specs"]
          if #specs == 0 then
              table.insert(specItemsDetails, v)
          else
              for i=1, #specs do
                  if specs[i] == lootSpec then
                      table.insert(specItemsDetails, v)
                      break
                  end
              end
          end
      end
      if #specItemsDetails == 0 then
          return nil
      elseif #specItemsDetails == 1 then
          return specItemsDetails
      elseif missingItem(specItemsDetails) then
          return nil
      else
          local largest = { specItemsDetails[1] }
          local largestDifference = calcIlvlDifference(specItemsDetails[1])
          for i=2, #specItemsDetails do
              local difference = calcIlvlDifference(specItemsDetails[i])
              if difference > largestDifference then
                  largest = { specItemsDetails[i] }
                  largestDifference = difference
              elseif difference == largestDifference then
                  table.insert(largest, specItemsDetails[i])
              end
          end
          return largest
      end
  end
  
  local getMaxStatGrowthItems = function(itemsDetails)
      
      for _, v in ipairs(itemsDetails) do
          if v["statIncrease"] == nil then
              return nil  -- return nil if item can't be compared
          end
      end
      
      local largestGrowthItems = { itemsDetails[1] }
      local largestGrowth = itemsDetails[1]["statIncrease"]
      for i=2, #itemsDetails do
          local growth = itemsDetails[i]["statIncrease"]
          if growth > largestGrowth then
              largestGrowth = growth
          elseif growth == largestGrowth then
              table.insert(largestGrowthItems, itemsDetails[i])
          end
      end
      return largestGrowthItems
  end
  
  local getMaxVendorIndex = function(itemsDetails)
      local maxVendorPrice = itemsDetails[1]["vendorPrice"]
      local maxVendorPriceIndex = 1
      for i=2, #itemsDetails do
          local vendorPrice = itemsDetails[i]["vendorPrice"]
          if vendorPrice > maxVendorPrice then
              maxVendorPriceIndex = i
              maxVendorPrice = vendorPrice
          end
      end
      return itemsDetails[maxVendorPriceIndex]["choiceIndex"]
  end
  
  local getQuestRewardChoice = function()
      local numChoices = GetNumQuestChoices()
      if numChoices <= 1 then
          return 1
      elseif not PoliQuestLootAutomationEnabled then
          return
      else
          local lootSpec = GetLootSpecialization()
          if lootSpec == 0 then
              lootSpec = GetSpecializationInfo(GetSpecialization())
          end
          local itemsDetails = getItemsDetails(numChoices)
          if itemsDetails == nil then
              return  -- quest loot has choice that isn't equippable. let player choose.
          end
          local largestSpecUpgrade = getLargestSpecUpgrade(itemsDetails, lootSpec)
          if largestSpecUpgrade == nil then
              return  -- no spec upgrades or missing equipped item. let player choose.
          elseif #largestSpecUpgrade == 1 then
              return largestSpecUpgrade[1]["choiceIndex"]
          elseif PoliQuestStrictAutomation then
              return
          else
              local maxStatGrowthItems = getMaxStatGrowthItems(largestSpecUpgrade)
              if maxStatGrowthItems == nil then
                  return  -- items can't be compared. let player choose.
              else
                  return getMaxVendorIndex(maxStatGrowthItems)
              end
          end
      end
  end
  
  -- completes a quest
  local onQuestComplete = function()
      if QuestInfoTitleHeader and questNames[string.lower(QuestInfoTitleHeader:GetText())] then
          local questRewardIndex = getQuestRewardChoice()
          if questRewardIndex then
              GetQuestReward(questRewardIndex)
          end
      end
  end

  -- adds a quest
  local onQuestLogUpdate_selectPopups = function()
      local num = GetNumAutoQuestPopUps()
      if num > 0 then
          for i=1,num do
              local questID = GetAutoQuestPopUp(i)
              if questIDToName[questID] then
                  AutoQuestPopUpTracker_OnMouseDown(CAMPAIGN_QUEST_TRACKER_MODULE:GetBlock(questID))
              end
          end
      end
  end

  local questProgresses = {}
  local initializeQuestProgresses = function()
      for i=1, C_QuestLog.GetNumQuestLogEntries() do
          local questInfo = C_QuestLog.GetInfo(i)
          if not questInfo.isHidden then
              local questID = questInfo.questID
              if questID > 0 then
                  questProgresses[questID] = GetQuestProgressBarPercent(questID)
              end
          end
      end
  end
  
  local questProgressChanged = function(questID, newProgress)
      local oldProgress = questProgresses[questID]
      if not oldProgress or oldProgress ~= newProgress then
          return true
      else
          return false
      end
  end
  local onQuestLogUpdate_reportQuestProgress = function()
      for i=1, C_QuestLog.GetNumQuestLogEntries() do
          local questID = C_QuestLog.GetQuestIDForLogIndex(i)
          local progress  = GetQuestProgressBarPercent(questID)
          if progress > 0 and questProgressChanged(questID, progress) then
              local oldProgress = questProgresses[questID] or 0
              questProgresses[questID] = progress
              UIErrorsFrame:AddMessage(C_QuestLog.GetInfo(i).title .. ": " .. progress .. "% (" .. string.format("%+.1f", progress-oldProgress) .. "%)" , 1, 1, 0, 1)
          end
      end
      reportQuestProgressLastRun = GetTime()
      reportQuestProgressRefreshPending = false
  end

  local onConfirmBinder = function()
      if UnitLevel("player") < 60 then
          local targetName = UnitName("target")
          if GossipFrameNpcNameText:GetText() and innWhitelist[GossipFrameNpcNameText:GetText()]
          or targetName and innWhitelist[targetName] then
              StaticPopup1Button1:Click()
          end
      end
  end
  
  local onQuestAccepted = function(questID)
      C_QuestLog.AddQuestWatch(questID, 1)
  end

  local onEvent = function(self, event, ...)
      if event == "GOSSIP_SHOW" then
          onGossipShow_questGossip()
          if PoliQuestOptionFrame5CheckButton:GetChecked() then
              onGossipShow_setHearth()
          end
      elseif event == "QUEST_GREETING" then
          onQuestGreeting()
      elseif event == "QUEST_DETAIL" then
          onQuestDetail()
      elseif event == "QUEST_PROGRESS" then
          onQuestProgress()
      elseif event == "QUEST_COMPLETE" then
          onQuestComplete()
      elseif event == "QUEST_LOG_UPDATE" then
          onQuestLogUpdate_selectPopups()
          reportQuestProgressRefreshPending = true
      elseif event == "CONFIRM_BINDER" then
          if PoliQuestOptionFrame5CheckButton:GetChecked() then
              onConfirmBinder()
          end
      elseif event == "GOSSIP_CLOSED" then
          if PoliQuestOptionFrame5CheckButton:GetChecked() then
              onConfirmBinder()
          end
      elseif event == "QUEST_ACCEPTED" then
          onQuestAccepted(...)
      elseif event == "QUEST_REMOVED" then
          questProgresses[...] = nil
      elseif event == "PLAYER_ENTERING_WORLD" then
          initializeQuestProgresses()
      end
  end
  
  local questAndDialogHandler = CreateFrame("Frame", "PoliQuestAndDialogHandler")
  questAndDialogHandler:SetScript("OnEvent", onEvent)
  questAndDialogHandler:RegisterEvent("PLAYER_ENTERING_WORLD")
  questAndDialogHandler:SetScript("OnUpdate", function()
      if reportQuestProgressRefreshPending and (reportQuestProgressLastRun or 0) + .1 < GetTime() then
          onQuestLogUpdate_reportQuestProgress()
      end
  end)
  questAndDialogHandler.Events = {
     "GOSSIP_SHOW",
     "QUEST_GREETING",
     "QUEST_DETAIL",
     "QUEST_PROGRESS",
     "QUEST_COMPLETE",
     "QUEST_LOG_UPDATE",
     "CONFIRM_BINDER",
     "GOSSIP_CLOSED",
     "QUEST_ACCEPTED",
     "QUEST_REMOVED"
  }
  addonTable.questAndDialogHandler = questAndDialogHandler
end