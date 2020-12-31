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
        local cardName = droppedObject.getName()
        Wrapper.broadcastToAll(Player[playerColor].steam_name .. " played a " .. cardName)

        table.remove(DiscardPile.cardsHeld, index)
        flipCardOverIfNeeded(droppedObject)

        local cardsInPile = getCardsIgnoringCard(DiscardPile.discardDropZone.getObjects(), droppedObject)

        droppedObject.sticky = false

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