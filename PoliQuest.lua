local _, addonTable = ...

local questItems = addonTable.questItems
local itemEquipLocToEquipSlot = addonTable.itemEquipLocToEquipSlot
local questNameToID = addonTable.questNameToID
local dialogWhitelist = addonTable.dialogWhitelist

SLASH_PoliQuest1 = "/poliquest"
SLASH_PoliQuest2 = "/pq"

local questButtonManager
local buttonLocked = true
local onEnterScript
local unlockButton = function()

    -- put icon in place and show if no current quest item
    local button = questButtonManager.Button
    if not button:IsVisible() then
        buttonTexture = button.Texture:GetTexture()
        button.Texture:SetTexture(134400)
        onEnterScript = button:GetScript("OnEnter")
        button:SetScript("OnEnter", nil)
        button.PrevButton:Disable()
        button.NextButton:Disable()
        button:Show()
    end
    
    -- make button movable
    button:SetMovable(true)
    button:RegisterForDrag("LeftButton")
    button:SetScript("OnDragStart", function(self) self:StartMoving() end)
    button:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
    -- show "Unlocked" text
    
end

local lockButton = function()
    local button = questButtonManager.Button
    if onEnterScript then
        onEnterScript = button:GetScript("OnEnter", onEnterScript)
        button:Hide()
    end
    button:SetMovable(false)
end

SlashCmdList["PoliQuest"] = function(msg)
    local cmd, arg = string.split(" ", msg)
    if cmd == "" then
        -- no message. open configuration menu
        -- allow user to edit location of UI elements
        -- allow user to disable certain features of the addon
    elseif cmd == "toggle" then
        if InCombatLockdown() then
            print("Quest Item Button can only be locked/unlocked outside of combat.")
        elseif buttonLocked then
            unlockButton()
            buttonLocked = false
        else
            lockButton()
            buttonLocked = true
        end
    else
        print("|cFF5c8cc1/pq:|r feature control")
        print("|cFF5c8cc1/pq toggle:|r edit button position")
    end
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
                frame.ViewPrev.Texture:SetTexture(GetItemIcon(currentItems[#currentItems-1]))
                frame.ViewPrev:Enable()
                frame.ViewPrev:Show()
                frame.ViewNext.Texture:SetTexture(GetItemIcon(currentItems[#currentItems+1]))
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
            throttleItemCheck = GetTime()
        elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
            print(...)
            if currentItemIndex and questItems[currentItems[currentItemIndex]]["spellID"] == select(3, ...) and questItems[currentItems[currentItemIndex]]["cooldown"] then
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
    
    questButtonManager = CreateFrame("Frame", "PoliQuestButtonManager", UIParent)
    local questButton = CreateFrame("Button", "PoliQuestItemButton", questButtonManager, "SecureActionButtonTemplate")
    questButtonManager.Button = questButton
    questButtonManager:SetScript("OnUpdate", onUpdate)
    questButton.Texture = questButton:CreateTexture("PoliQuestItemButtonTexture","BACKGROUND")
    questButton.Texture:SetAllPoints(questButton)
    questButton:SetPoint("CENTER", UIParent, -300, -175)
    questButton:SetSize(64, 64)
    questButton:SetAttribute("type", "item")
    questButton:RegisterEvent("PLAYER_REGEN_ENABLED")
    questButton:RegisterEvent("PLAYER_REGEN_DISABLED")
    questButton:RegisterEvent("BAG_UPDATE")
    questButton:RegisterEvent("BAG_UPDATE_COOLDOWN")
    questButton:RegisterEvent("PLAYER_ENTERING_WORLD")
    questButton:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player")
    questButton:SetScript("OnEvent", onEvent)
    questButton:SetScript("OnEnter", function()
        GameTooltip:ClearLines()
        GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
        GameTooltip:SetHyperlink(select(2, GetItemInfo(currentItems[currentItemIndex])))
        GameTooltip:Show()
    end)
    questButton:SetScript("OnLeave", function()
        GameTooltip:ClearLines()
        GameTooltip:Hide()
    end)
    
    questButton.Cooldown = CreateFrame("Cooldown", "PoliQuestItemCooldown", questButton, "CooldownFrameTemplate")
    questButton.Cooldown:SetAllPoints(questButton)
    
    questButton.FontString = questButton:CreateFontString("PoliQuestItemCount", "BACKGROUND")
    questButton.FontString:SetPoint("BOTTOMRIGHT", -4, 4)
    questButton.FontString:SetTextHeight(16)
    
    local prevItemButton = CreateFrame("Button", "PoliPrevItemButton", questButton, "SecureActionButtonTemplate")
    prevItemButton:SetPoint("BOTTOMRIGHT", "$parent", "TOP", 0, 0)
    prevItemButton:SetSize(32, 32)
    prevItemButton:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up")
    prevItemButton:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Down")
    prevItemButton:SetDisabledTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Disabled")
    prevItemButton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
    prevItemButton:SetScript("OnClick", prevItemButton_OnClick)
    questButton.PrevButton = prevItemButton
    
    local nextItemButton = CreateFrame("Button", "PoliNextItemButton", questButton, "SecureActionButtonTemplate")
    nextItemButton:SetPoint("BOTTOMLEFT", "$parent", "TOP", 0, 0)
    nextItemButton:SetSize(32, 32)
    nextItemButton:SetNormalTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
    nextItemButton:SetPushedTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Down")
    nextItemButton:SetDisabledTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Disabled")
    nextItemButton:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
    nextItemButton:SetScript("OnClick", nextItemButton_OnClick)
    questButton.NextButton = nextItemButton
    
    local prevView = CreateFrame("Button", "PoliPrevViewButton", questButton, "SecureActionButtonTemplate")
    prevView:SetPoint("RIGHT", "$parent", "LEFT", -4, 0)
    prevView:SetSize(32, 32)
    prevView:SetScript("OnClick", prevItemButton_OnClick)
    prevView.Texture = prevView:CreateTexture("PoliPrevViewButtonTexture","BACKGROUND")
    prevView.Texture:SetAllPoints(prevView)
    questButton.ViewPrev = prevView
    
    local nextView = CreateFrame("Button", "PoliNextViewButton", questButton, "SecureActionButtonTemplate")
    nextView:SetPoint("LEFT", "$parent", "RIGHT", 4, 0)
    nextView:SetSize(32, 32)
    nextView:SetScript("OnClick", nextItemButton_OnClick)
    nextView.Texture = nextView:CreateTexture("PoliNextViewButtonTexture","BACKGROUND")
    nextView.Texture:SetAllPoints(nextView)
    questButton.ViewNext = nextView
    
    updateButton(questButton, true)
    if not buttonLocked then
        unlockButton()
    end
end


local questAndDialogHandler
local transmogCare = false
local upgradeCare = false
do -- Manage quests and dialog
    local questIDToName = {}
    local numQuests = 0
    local initializeQuestIDToName = function()
        for k,v in pairs(questNameToID) do
            questIDToName[v] = k
            numQuests = numQuests + 1
        end
    end
    
    local activeQuests
    local printActiveQuests = function()
        local quests = ""
        for _, v in ipairs(activeQuests) do
            quests = string.join(", ", quests, v)
        end
        print("Active quests: " .. string.sub(quests, 3))
    end
    local initializeActiveQuests = function()
        activeQuests = {}
        for k, v in pairs(questNameToID) do
            if C_QuestLog.GetLogIndexForQuestID(v) then
                table.insert(activeQuests, v)
            end
        end
        printActiveQuests()
    end
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
    
    
        for _, v in ipairs(activeQuests) do
            local questDialog = dialogWhitelist[questIDToName[v]]
            if questDialog then
                if type(questDialog["npc"]) == "string" then
                    if questDialog["npc"] == GossipFrameNpcNameText:GetText() then
                        searchDialogOptions(questDialog)
                    end
                else
                    for i, v in ipairs(questDialog["npc"]) do
                        if questDialog["npc"][i] == GossipFrameNpcNameText:GetText() then
                            if searchDialogOptions(questDialog) then
                                return
                            end
                        end
                    end
                end
            end
        end
    end
    
    local whitelistedInns = {
        ["Host Ta'rela"] = true,
        ["Slumbar Valorum"] = true
    }
    local onGossipShow_setHearth = function()
        if whitelistedInns[GossipFrameNpcNameText:GetText()] then
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
    
    local validateQuest = function(questValue)
        if type(questValue) == "string" then
            return questNameToID[questValue] ~= nil
        else
            return questIDToName[questValue] ~= nil
        end
    end
    
    local insertQuest = function(questID)
        for i, v in ipairs(activeQuests) do
            if v == questID then
                return
            end
        end
        table.insert(activeQuests, questID)
        --print(string.join(" ", "Quest added:", C_QuestLog.GetTitleForQuestID(questID), questID))
        printActiveQuests()
    end
    
    local removeQuest = function(questID)
        for i, v in ipairs(activeQuests) do
            if v == questID then
                table.remove(activeQuests, i)
                print(string.join(" ", "Quest removed:", C_QuestLog.GetTitleForQuestID(questID), questID))
                printActiveQuests()
            end
        end
    end
    
    local completeQuest = function()
        for i=1, GetNumActiveQuests() do
            local questName, isComplete = GetActiveTitle(i)
            if questNameToID[questName] and isComplete then
                SelectActiveQuest(i)
                removeQuest(questName)
                return
            end
        end
    end
    
    local acceptQuest = function()
        for i=1, GetNumAvailableQuests() do
            local questID = select(5, GetAvailableQuestInfo(i))
            if questIDToName[questID] then
                SelectAvailableQuest(i)
                insertQuest(questID)
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

    local onQuestDetail = function()
        if QuestInfoTitleHeader and questNameToID[QuestInfoTitleHeader:GetText()] then
            insertQuest(questNameToID[QuestInfoTitleHeader:GetText()])
            AcceptQuest()
        end
    end

    local onQuestProgress = function()
        if QuestProgressTitleText then
            local questID = questNameToID[QuestProgressTitleText:GetText()]
            if questID and C_QuestLog.IsComplete(questID) then
                removeQuest(questNameToID[QuestProgressTitleText:GetText()])
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
                largest = { itemsDetails[i] }
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
        elseif transmogCare then
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
            elseif upgradeCare then
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
    
    local onQuestComplete = function()
        if QuestInfoTitleHeader and questNameToID[QuestInfoTitleHeader:GetText()] then
            removeQuest(QuestInfoTitleHeader:GetText())
            local questRewardIndex = getQuestRewardChoice()
            if questRewardIndex then
                GetQuestReward(questRewardIndex)
            end
        end
    end

    local onQuestLogUpdate = function()
        local num = GetNumAutoQuestPopUps()
        if num > 0 then
            for i=1,num do
                local questID = GetAutoQuestPopUp(i)
                if questIDToName[questID] then
                    AutoQuestPopUpTracker_OnMouseDown(AUTO_QUEST_POPUP_TRACKER_MODULE:GetBlock(questID))
                end
            end
        end
    end

    local onConfirmBinder = function()
        if UnitLevel("player") < 60 then
            local targetName = UnitName("target")
            if GossipFrameNpcNameText:GetText() and whitelistedInns[GossipFrameNpcNameText:GetText()]
            or targetName and whitelistedInns[targetName] then
                StaticPopup1Button1:Click()
            end
        end
    end

    local onEvent = function(self, event, ...)
        if event == "GOSSIP_SHOW" then
            onGossipShow_questGossip()
            onGossipShow_setHearth()
        elseif event == "GOSSIP_CONFIRM" then
            
        elseif event == "QUEST_GREETING" then
            onQuestGreeting()
        elseif event == "QUEST_DETAIL" then
            onQuestDetail()
        elseif event == "QUEST_PROGRESS" then
            onQuestProgress()
        elseif event == "QUEST_COMPLETE" then
            print("quest complete")
            onQuestComplete()
        elseif event == "QUEST_LOG_UPDATE" then
            onQuestLogUpdate()
        elseif event == "QUEST_ACCEPT_CONFIRM" then
        
        elseif event == "QUEST_REMOVED" then
            local questID = ...
            removeQuest(questID)
        elseif event == "CONFIRM_BINDER" then
            onConfirmBinder()
        elseif event == "GOSSIP_CLOSED" then
            onConfirmBinder()
        elseif event == "PLAYER_ENTERING_WORLD" then
            initializeQuestIDToName()
            initializeActiveQuests()
        end
    end
    
    questAndDialogHandler = CreateFrame("Frame")
    questAndDialogHandler:RegisterEvent("GOSSIP_SHOW")
    questAndDialogHandler:RegisterEvent("GOSSIP_CONFIRM")
    questAndDialogHandler:RegisterEvent("QUEST_GREETING")
    questAndDialogHandler:RegisterEvent("QUEST_DETAIL")
    questAndDialogHandler:RegisterEvent("QUEST_PROGRESS")
    questAndDialogHandler:RegisterEvent("QUEST_COMPLETE")
    questAndDialogHandler:RegisterEvent("QUEST_LOG_UPDATE")
    questAndDialogHandler:RegisterEvent("QUEST_ACCEPT_CONFIRM")
    questAndDialogHandler:RegisterEvent("QUEST_REMOVED")
    questAndDialogHandler:RegisterEvent("CONFIRM_BINDER")
    questAndDialogHandler:RegisterEvent("PLAYER_ENTERING_WORLD")
    questAndDialogHandler:SetScript("OnEvent", onEvent)
end

do -- Equip higher ilvl quest loot

    local scanningTooltip = CreateFrame("GameTooltip", "PoliScanningTooltip", nil, "GameTooltipTemplate")
    PoliScanningTooltip:SetOwner(WorldFrame, "ANCHOR_NONE")
    
    local questLootItemLink, questLootReceivedTime
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
        local specs = GetItemSpecInfo(itemLink)
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
        if itemEquipLoc ~= "" then
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
                table.insert(questLootItemLinks, questLootItemLink)
                questLootReceivedTime = GetTime()
            end
        elseif event == "PLAYER_EQUIPMENT_CHANGED" then
            if questLootItemLink and C_Item.GetItemName(ItemLocation:CreateFromEquipmentSlot(...)) == GetItemInfo(questLootItemLink) then
                for i, v in ipairs(questLootItemLinks) do
                    if questLootItemLink == v then
                        table.remove(questLootItemLinks, i)
                    end
                end
                if #questLootItemLinks == 0 then
                    questLootReceivedTime = nil
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
            if bagID and slotIndex then
                local upgrade, slotID = isUpgrade(bagID, slotIndex)
                if upgrade then
                    EquipItemByName(questLootItemLinks[#questLootItemLinks], slotID)
                else
                    table.remove(questLootItemLinks)
                    if #questLootItemLinks == 0 then
                        questLootReceivedTime = nil
                    end
                end
            end
        end
    end
    
    local questLootHandler = CreateFrame("Frame")
    questLootHandler:RegisterEvent("QUEST_LOOT_RECEIVED")
    questLootHandler:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
    questLootHandler:SetScript("OnEvent", onEvent)
    questLootHandler:SetScript("OnUpdate", onUpdate)
end

do -- Manage quest emotes

    local targetWhitelist = {
        ["Runestone of Rituals"] = {
            ["questID"] = 58621,
            ["emote"] = "kneel"
        },
        ["Runestone of Plague"] = {
            ["questID"] = 58621,
            ["emote"] = "bleed"
        },
        ["Runestone of Chosen"] = {
            ["questID"] = 58621,
            ["emote"] = "salute"
        },
        ["Runestone of Constucts"] = {
            ["questID"] = 58621,
            ["emote"] = "flex"
        },
        ["Runestone of Eyes"] = {
            ["questID"] = 58621,
            ["emote"] = "sneak"
        }
    }

    local onEvent = function(self, event, ...)
        if event == "PLAYER_TARGET_CHANGED" then
            local targetName = UnitName("target")
            if targetName and targetWhitelist[targetName] and C_QuestLog.GetLogIndexForQuestID(targetWhitelist[targetName]["questID"]) then
                print("doing emote")
                DoEmote(targetWhitelist[targetName]["emote"])
            end
        elseif event == "CHAT_MSG_SAY" then
        
        end
    end

    local emoteFrame = CreateFrame("Frame", "PoliQuestEmoteManager", UIParent)
    emoteFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
    emoteFrame:RegisterEvent("CHAT_MSG_SAY")
    emoteFrame:SetScript("OnEvent", onEvent)
end