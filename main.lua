require("wrapper")
require("config")
require("strings")
require("stream")
require("cardUtils")
require("deck")
require("discardPile")
require("playerHand")

local zoneHandlers = {}
local leaveHandlers = {}

-- TODO add button to disable auto stacking, in case things go awry / point of order needs sorted out
-- TODO sort cards button for hand

function onLoad()
    DiscardPile.Init()
    registerLeaveHandlers()
    registerZoneHandlers()
    PlayerHands.Init()
    Deck.SpawnDecks()
end

function registerLeaveHandlers()
    leaveHandlers[Config.DeckGuid] = Deck
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
    PlayerHands.HandleDrop(playerColor, droppedObject)
end

function onObjectLeaveContainer(container, object)
    if leaveHandlers[container.guid] then
        leaveHandlers[container.guid].HandleObjectRemoved(container, object)
    end
end

function onUpdate()
end