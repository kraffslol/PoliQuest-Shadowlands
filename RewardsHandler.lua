local _, addonTable = ...

local select, GetItemInfo, NUM_BAG_SLOTS, pairs, ipairs = select, GetItemInfo, NUM_BAG_SLOTS, pairs, ipairs
local ItemLocation, C_Item, GetInventoryItemLink = ItemLocation, C_Item, GetInventoryItemLink
local table, GetTime, type, GetSpecializationInfo, GetSpecialization = table, GetTime, type, GetSpecializationInfo, GetSpecialization
local GetContainerNumSlots, GetContainerItemLink, GetItemSpecInfo = GetContainerNumSlots, GetContainerItemLink, GetItemSpecInfo
local InCombatLockdown, EquipItemByName, _G, CreateFrame = InCombatLockdown, EquipItemByName, _G, CreateFrame

local itemEquipLocToEquipSlot = addonTable.itemEquipLocToEquipSlot

do -- Equip higher ilvl quest loot
  local scanningTooltip = CreateFrame("GameTooltip", "PoliScanningTooltip", nil, "GameTooltipTemplate")
  scanningTooltip:SetOwner(WorldFrame, "ANCHOR_NONE")
  
  local questLootReceivedTime
  local isBoP = function(itemLink)
      scanningTooltip:ClearLines()
      scanningTooltip:SetHyperlink(itemLink)
      for i=1, scanningTooltip:NumLines() do
          if _G["PoliScanningTooltipTextLeft" .. i]:GetText() == "Binds when picked up" then
              return true
          end
      end
      return false
  end
  
  local isSpecItem = function(itemLink)
      local specs = GetItemSpecInfo(itemLink) or {}
      if #specs == 0 then
          return true
      end
      local currentSpec = GetSpecializationInfo(GetSpecialization())
      for _, spec in pairs(specs) do
          if currentSpec == spec then
              return true
          end
      end
      return false
  end
  
  local isBoPEquipableSpecItem = function(itemLink)
      local itemEquipLoc = select(9, GetItemInfo(itemLink))
      if itemEquipLoc ~= "" and itemEquipLocToEquipSlot[itemEquipLoc] then
          if isBoP(itemLink) and isSpecItem(itemLink) then
              return true
          end
      end
      return false
  end
  
  local getBagAndSlot = function(itemName)
      for bagID = 0, NUM_BAG_SLOTS do
          for slotIndex = 1, GetContainerNumSlots(bagID) do
              local containerItemLink = GetContainerItemLink(bagID, slotIndex)
              if containerItemLink and GetItemInfo(containerItemLink) == itemName then
                  return bagID, slotIndex
              end
          end
      end
      return nil
  end
  
  local isUpgrade = function(bagID, slotIndex)
      local mixin = ItemLocation:CreateFromBagAndSlot(bagID, slotIndex)
      local itemIlvl = C_Item.GetCurrentItemLevel(mixin)
      local itemEquipLoc = select(9, GetItemInfo(C_Item.GetItemLink(mixin)))
      local equipSlot = itemEquipLocToEquipSlot[itemEquipLoc]
      if type(equipSlot) == "number" then
          if GetInventoryItemLink("player", equipSlot) == nil then
              return true, equipSlot
          else
              local equipIlvl = C_Item.GetCurrentItemLevel(ItemLocation:CreateFromEquipmentSlot(equipSlot))
              if itemIlvl - equipIlvl > 0 then
                  return true, equipSlot
              end
          end
      else
          if GetInventoryItemLink("player", equipSlot[1]) == nil then
              return true, equipSlot[1]
          elseif GetInventoryItemLink("player", equipSlot[2]) == nil then
              return true, equipSlot[2]
          else
              local equipIlvl1 = C_Item.GetCurrentItemLevel(ItemLocation:CreateFromEquipmentSlot(equipSlot[1]))
              local equipIlvl2 = C_Item.GetCurrentItemLevel(ItemLocation:CreateFromEquipmentSlot(equipSlot[2]))
              if equipIlvl1 > equipIlvl2 then
                  if itemIlvl - equipIlvl2 > 0 then
                      return true, equipSlot[2]
                  end
              else
                  if itemIlvl - equipIlvl1 > 0 then
                      return true, equipSlot[1]
                  end
              end
          end
      end
      return false
  end
  
  local questLootItemLinks = {}
  local onEvent = function(self, event, ...)
      if event == "QUEST_LOOT_RECEIVED" then
          local link = select(2, ...)
          if isBoPEquipableSpecItem(link) then
              addonTable.debugPrint("is BOP")
              table.insert(questLootItemLinks, link)
              questLootReceivedTime = GetTime()
          end
      elseif event == "PLAYER_EQUIPMENT_CHANGED" then
          if #questLootItemLinks > 0 then
              local itemLoc = ItemLocation:CreateFromEquipmentSlot(...)
              if itemLoc:IsValid() then
                  local equippedItemName = C_Item.GetItemName(ItemLocation:CreateFromEquipmentSlot(...))
                  addonTable.debugPrint(equippedItemName.." equipped") 
                  for i, v in ipairs(questLootItemLinks) do
                      if equippedItemName == GetItemInfo(v) then
                          table.remove(questLootItemLinks, i)
                      end
                  end
                  if #questLootItemLinks == 0 then
                      questLootReceivedTime = nil
                  end
              end
          end
      end
  end
  
  -- write edge case for when quest loot is received but no bag space
  local onUpdate = function()
      if #questLootItemLinks > 0 and GetTime() - questLootReceivedTime > 1 and not InCombatLockdown() then
          questLootReceivedTime = GetTime()
          local bagID, slotIndex = getBagAndSlot(GetItemInfo(questLootItemLinks[#questLootItemLinks]))
          -- Can only identify if it is an upgrade if it is found in bag
          addonTable.debugPrint("looking for item")
          if bagID and slotIndex then
              local upgrade, slotID = isUpgrade(bagID, slotIndex)
              if upgrade then
                  addonTable.debugPrint("is upgrade. attempting to equip.")
                  EquipItemByName(questLootItemLinks[#questLootItemLinks], slotID)
              else
                  addonTable.debugPrint("not an upgrade.")
                  table.remove(questLootItemLinks)
                  if #questLootItemLinks == 0 then
                      questLootReceivedTime = nil
                  end
              end
          end
      end
  end
  
  local questLootHandler = CreateFrame("Frame", "PoliQuestLootHandler")
  questLootHandler.Events = {
      "QUEST_LOOT_RECEIVED",
      "PLAYER_EQUIPMENT_CHANGED"
  }
  questLootHandler:SetScript("OnEvent", onEvent)
  questLootHandler:SetScript("OnUpdate", onUpdate)
  addonTable.questLootHandler = questLootHandler
end