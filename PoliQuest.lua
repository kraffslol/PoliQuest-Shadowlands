local _, addonTable = ...

-- luacheck: globals InCombatLockdown ipairs string _G POLIQUEST_DEBUG_ENABLED print SLASH_PoliQuest1 SLASH_PoliQuest2 SlashCmdList CreateFrame PoliSavedVars PoliQuestConfigFrame PQButton print select
local InCombatLockdown, ipairs, string, CreateFrame = InCombatLockdown, ipairs, string, CreateFrame
local print, select = print, select

_G["PoliQuest"] = addonTable

addonTable.debugPrint = function(text)
    if POLIQUEST_DEBUG_ENABLED then
        print("|cFF5c8cc1PoliQuest:|r " .. text)
    end
end

local registerEvents = function(frame)
    for _, v in ipairs(frame.Events) do
        frame:RegisterEvent(v)
    end
end

SLASH_PoliQuest1 = "/poliquest"
SLASH_PoliQuest2 = "/pq"

SlashCmdList["PoliQuest"] = function(msg)
    local cmd, arg = string.split(" ", msg)
    if cmd == "" then
        if PoliQuestConfigFrame:IsVisible() then
            PoliQuestConfigFrame:Hide()
        else
            PoliQuestConfigFrame:Show()
        end
    elseif cmd == "toggle" then
        if InCombatLockdown() then
            print("Quest Item Button can only be locked/unlocked outside of combat.")
        elseif not PQButton.LockButton:IsVisible() then
            addonTable.UnlockPoliQuestButton()
        else
            addonTable.LockPoliQuestButton()
        end
    else
        print("|cFF5c8cc1/pq:|r feature control")
        print("|cFF5c8cc1/pq toggle:|r edit button position")
    end
end

do -- Load and set variables
    local onEvent = function(self, event, ...)
        if event == "ADDON_LOADED" and ... == "PoliQuest" then
            if PoliSavedVars == nil then
                PoliSavedVars = {}
                self.UnlockPoliQuestButton()
                registerEvents(self.questAndDialogHandler)
                PoliQuestOptionFrame1CheckButton:SetChecked(true)
                PoliQuestLootAutomationEnabled = true
                PoliQuestOptionFrame2CheckButton:SetChecked(false)
                PoliQuestStrictAutomation = false
                PoliQuestOptionFrame3CheckButton:SetChecked(false)
                PoliQuestOptionFrame4CheckButton:SetChecked(false)
                PoliQuestOptionFrame5CheckButton:SetChecked(false)
            else
                if PoliSavedVars.questAutomationEnabled then
                    registerEvents(self.questAndDialogHandler)
                    PoliQuestOptionFrame1CheckButton:SetChecked(true)
                else
                    PoliQuestOptionFrame1CheckButton:SetChecked(false)
                end
                
                if PoliSavedVars.questLootAutomationEnabled then
                    PoliQuestOptionFrame2CheckButton:SetChecked(true)
                    PoliQuestLootAutomationEnabled = true
                else
                    PoliQuestOptionFrame2CheckButton:SetChecked(false)
                    PoliQuestLootAutomationEnabled = false
                end
                
                if PoliSavedVars.questStrictAutomation then
                    PoliQuestOptionFrame3CheckButton:SetChecked(true)
                    PoliQuestStrictAutomation = true
                else
                    PoliQuestOptionFrame3CheckButton:SetChecked(false)
                    PoliQuestStrictAutomation = false
                end
                
                if not PoliQuestOptionFrame1CheckButton:GetChecked() then
                    PoliQuestOptionFrame2CheckButton:Disable()
                    PoliQuestOptionFrame3CheckButton:Disable()
                elseif not PoliQuestOptionFrame2CheckButton:GetChecked() then
                    PoliQuestOptionFrame3CheckButton:Disable()
                end
                
                if PoliSavedVars.questLootEquipAutomationEnabled then
                    registerEvents(self.questLootHandler)
                    PoliQuestOptionFrame4CheckButton:SetChecked(true)
                else
                    PoliQuestOptionFrame4CheckButton:SetChecked(false)
                end
                
                 if PoliSavedVars.hearthAutomationEnabled then
                     PoliQuestOptionFrame5CheckButton:SetChecked(true)
                     if not PoliSavedVars.questAutomationEnabled then
                        registerEvents(self.hearthHandler)
                    end
                 else
                    PoliQuestOptionFrame5CheckButton:SetChecked(false)
                 end
                self.questButtonManager.Button:ClearAllPoints()
                self.questButtonManager.Button:SetPoint(PoliSavedVars.relativePoint, UIParent, PoliSavedVars.xOffset, PoliSavedVars.yOffset)
            end
            self.addonLoadedFrame:UnregisterEvent("ADDON_LOADED")
        elseif event == "PLAYER_LOGOUT" then
            PoliSavedVars.questAutomationEnabled = PoliQuestOptionFrame1CheckButton:GetChecked()
            PoliSavedVars.questLootAutomationEnabled = PoliQuestOptionFrame2CheckButton:GetChecked()
            PoliSavedVars.questStrictAutomation = PoliQuestOptionFrame3CheckButton:GetChecked()
            PoliSavedVars.questLootEquipAutomationEnabled = PoliQuestOptionFrame4CheckButton:GetChecked()
            PoliSavedVars.hearthAutomationEnabled = PoliQuestOptionFrame5CheckButton:GetChecked()
            PoliSavedVars.relativePoint, PoliSavedVars.xOffset, PoliSavedVars.yOffset = select(3, self.questButtonManager.Button:GetPoint(1))
        end
    end
    local addonLoadedFrame = CreateFrame("Frame")
    addonLoadedFrame:RegisterEvent("ADDON_LOADED")
    addonLoadedFrame:RegisterEvent("PLAYER_LOGOUT")
    addonLoadedFrame:SetScript("OnEvent", function(_, event, ...) onEvent(addonTable, event, ...) end)
    addonTable.addonLoadedFrame = addonLoadedFrame
end