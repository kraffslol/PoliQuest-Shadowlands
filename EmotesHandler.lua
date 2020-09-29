local _, addonTable = ...

local UnitName, C_QuestLog, DoEmote, pairs, string, print, string = UnitName, C_QuestLog, DoEmote, pairs, string, print, string

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
  
  local messageWhitelist = {
      ["dance"] = "dance",
      ["Introductions"] = "introduce",
      ["praise"] = "praise", -- 
      ["thank"] = "thank",
      ["cheering"] = "cheer",
      ["strong"] = "flex" -- Just disappointed.
  }

  local pendingEmote
  local onEvent = function(self, event, ...)
      if event == "PLAYER_TARGET_CHANGED" then
          local targetName = UnitName("target")
          if targetName and targetWhitelist[targetName] and C_QuestLog.GetLogIndexForQuestID(targetWhitelist[targetName]["questID"]) then
              DoEmote(targetWhitelist[targetName]["emote"])
          elseif pendingEmote and targetName == "Playful Trickster" then
              DoEmote(pendingEmote)
              pendingEmote = nil
          end
      elseif event == "CHAT_MSG_MONSTER_SAY"  then
          local message, name = ...
          if name == "Playful Trickster" then
              for k, v in pairs(messageWhitelist) do
                  if string.match(message, k) then
                      if UnitName("target") ~= "Playful Trickster" then
                          print("|cFF5c8cc1PoliQuest:|r |cFFFF0000Make sure to target Playerful Trickster!|r")
                          pendingEmote = v
                          return
                      end
                      DoEmote(v)
                  end
              end
              if pendingEmote and (string.match(message, "not right") or string.match(message, "Just disappointed") or string.match(message, "I told you the rules")) then
                  pendingEmote = nil
              end
          end
      end
  end

  local emoteFrame = CreateFrame("Frame", "PoliQuestEmoteManager", UIParent)
  emoteFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
  emoteFrame:RegisterEvent("CHAT_MSG_MONSTER_SAY")
  emoteFrame:SetScript("OnEvent", onEvent)
  addonTable.emoteHandler = emoteFrame
end