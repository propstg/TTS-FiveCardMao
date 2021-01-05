DiscardPile = {}

DiscardPile.discardDropZone = nil
DiscardPile.discardSlot1 = nil
DiscardPile.cardsHeld = {}
DiscardPile.lastCardPlaced = nil

-- TODO Track who played what
-- TODO Add button to return cards to hand

function DiscardPile.Init()
    DiscardPile.discardDropZone = Wrapper.getObjectFromGUID(Config.DiscardDropZoneGuid)
    DiscardPile.discardSlot1 = Wrapper.getObjectFromGUID(Config.DiscardFirstCardZoneGuid)
end

function DiscardPile.OnEnter(enterObject)
    table.insert(DiscardPile.cardsHeld, enterObject)
end

function DiscardPile.OnLeave(leaveObject)
    index = findObjectIndexInTable(DiscardPile.cardsHeld, leaveObject)
    if index >= 0 then
        table.remove(DiscardPile.cardsHeld, index)
    end
end

function DiscardPile.HandleDrop(playerColor, droppedObject)
    index = findObjectIndexInTable(DiscardPile.cardsHeld, droppedObject)
    if index >= 0 then
        if droppedObject.tag ~= "Card" then
            DiscardPile.broadcastRejectedMessage(playerColor, cardName)
            return
        end

        local cardName = droppedObject.getName()
        DiscardPile.broadcastPlayedMessage(playerColor, cardName)

        table.remove(DiscardPile.cardsHeld, index)
        flipCardOverIfNeeded(droppedObject)

        local cardsInPile = getCardsIgnoringCard(DiscardPile.discardDropZone.getObjects(), droppedObject)

        droppedObject.sticky = false
        droppedObject.setRotationSmooth({x=0, y=0, z=0}, false, true)

        if #cardsInPile == 0 then
            droppedObject.setPositionSmooth(DiscardPile.discardSlot1.getPosition(), false, true)
        else
            Stream.of(cardsInPile).forEach(function(card) card.setLock(true) end)
            local newPosition = DiscardPile.lastCardPlaced.getPosition()
            newPosition.x = newPosition.x + 0.75
            newPosition.y = newPosition.y + 1
            droppedObject.setPositionSmooth(newPosition, false, true)

            Stream.of(cardsInPile).forEach(function(card) card.setLock(false) end)
        end

        DiscardPile.lastCardPlaced = droppedObject
    end
end

function DiscardPile.broadcastPlayedMessage(playerColor, cardName)
    local message = Strings.get("PlayerPlayedCard"):format(Player[playerColor].steam_name, cardName)
    DiscardPile.broadcastMessage(playerColor, message)
end

function DiscardPile.broadcastRejectedMessage(playerColor)
    local message = Strings.get("OnlyPlayCardsInDiscardPile")
    DiscardPile.broadcastMessage(playerColor, message)
end

function DiscardPile.broadcastMessage(playerColor, message)
    local color = Wrapper.Color.fromString(playerColor)
    Wrapper.broadcastToAll(message, color)
end