require("wrapper")
require("config")
require("stream")
require("cardUtils")
require("deck")
require("discardPile")

local zoneHandlers = {}

-- TODO add button to disable auto stacking, in case things go awry / point of order needs sorted out
-- TODO Context menu option for bouncing "bad plays" + extra card from deck to player that played it?

function onLoad()
    DiscardPile.Init()
    registerZoneHandlers()
    Deck.SpawnDecks()
end

function registerZoneHandlers()
    zoneHandlers[Config.DiscardDropZoneGuid] = DiscardPile
end

function onObjectEnterScriptingZone(zone, enterObject)
    if zoneHandlers[zone.guid] then
        zoneHandlers[zone.guid].OnEnter(enterObject)
    end
end

function onObjectLeaveScriptingZone(zone, leaveObject)
    if zoneHandlers[zone.guid] then
        zoneHandlers[zone.guid].OnLeave(leaveObject)
    end
end

function onObjectDropped(playerColor, droppedObject)
    for guid, value in pairs(zoneHandlers) do
        value.HandleDrop(playerColor, droppedObject)
    end
end

function onUpdate()
end