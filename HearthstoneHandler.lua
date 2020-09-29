local _, addonTable = ...

--luacheck: globals C_GossipInfo GossipFrameNpcNameText StaticPopup1Button1 UnitLevel UnitName CreateFrame
local C_GossipInfo, UnitLevel, UnitName = C_GossipInfo, UnitLevel, UnitName

local innWhitelist = addonTable.innWhitelist

do -- Set hearthstone
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

  local onConfirmBinder = function()
      if UnitLevel("player") < 60 then
          local targetName = UnitName("target")
          if GossipFrameNpcNameText:GetText() and innWhitelist[GossipFrameNpcNameText:GetText()]
          or targetName and innWhitelist[targetName] then
              StaticPopup1Button1:Click()
          end
      end
  end

  local onEvent = function(self, event, ...)
      if event == "GOSSIP_SHOW" then
          onGossipShow_setHearth()
      elseif event == "CONFIRM_BINDER" then
          onConfirmBinder()
      elseif event == "GOSSIP_CLOSED" then
          onConfirmBinder()
      end
  end
  
  local hearthHandler = CreateFrame("Frame", "PoliHearthHandler")
  hearthHandler:SetScript("OnEvent", onEvent)
  hearthHandler.Events = {
     "GOSSIP_SHOW",
     "CONFIRM_BINDER",
     "GOSSIP_CLOSED"
  }
  addonTable.hearthHandler = hearthHandler
end