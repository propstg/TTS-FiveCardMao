DiscardPile = {}

DiscardPile.discardDropZone = nil
DiscardPile.discardSlot1 = nil
DiscardPile.discardSlot2 = nil
DiscardPile.discardSlot3 = nil
DiscardPile.cardsHeld = {}
DiscardPile.lastCardPlaced = nil

function DiscardPile.Init() 
    DiscardPile.discardDropZone = getObjectFromGUID(Config.DiscardDropZoneGuid)
    DiscardPile.discardSlot1 = getObjectFromGUID("2f98d0")
    DiscardPile.discardSlot2 = getObjectFromGUID("98d62d")
    DiscardPile.discardSlot3 = getObjectFromGUID("dc688d")
end

function DiscardPile.OnEnter(enterObject)
    print ("Card is being held over drop zone")
    table.insert(DiscardPile.cardsHeld, enterObject)
end

function DiscardPile.OnLeave(leaveObject)
    index = findObjectIndexInTable(DiscardPile.cardsHeld, leaveObject)
    if index >= 0 then
        print ("Card is no longer held over drop zone")
        table.remove(DiscardPile.cardsHeld, index)
    end
end

function DiscardPile.HandleDrop(playerColor, droppedObject)
    print("HANDLER")
    index = findObjectIndexInTable(DiscardPile.cardsHeld, droppedObject)
    if index >= 0 then
        table.remove(DiscardPile.cardsHeld, index)
        flipCardOverIfNeeded(droppedObject)

        print(DiscardPile.discardDropZone)
        local cardsInPile = getCardsIgnoringCard(DiscardPile.discardDropZone.getObjects(), droppedObject)

        droppedObject.sticky = false

        if #cardsInPile == 0 then
            print ("Putting card in slot 1")
            droppedObject.setPositionSmooth(DiscardPile.discardSlot1.getPosition(), false, true)
        else
            print("locking cards...")
            Stream.of(cardsInPile)
                .forEach(function(card) 
                    print("locking card")
                    card.setLock(true)
                end)
            
            print("placing played card")
            local newPosition = DiscardPile.lastCardPlaced.getPosition()
            newPosition.x = newPosition.x + 0.75
            newPosition.y = newPosition.y + 1
            droppedObject.setPositionSmooth(newPosition, false, true)

            print("unlocking cards...")
            Stream.of(cardsInPile)
                .forEach(function(card) 
                    print("unlocking card")
                    card.setLock(false)
                end)
        end

        DiscardPile.lastCardPlaced = droppedObject
    end
end