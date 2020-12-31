
DiscardPile = {}

DiscardPile.discardDropZone = nil
DiscardPile.discardSlot1 = nil
DiscardPile.discardSlot2 = nil
DiscardPile.discardSlot3 = nil
DiscardPile.cardsHeld = {}

function DiscardPile.Init() 
    DiscardPile.discardDropZone = getObjectFromGUID(DISCARD_DROP_ZONE)
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
    index = findObjectIndexInTable(discardPile.cardsHeld, droppedObject)
    if index >= 0 then
        table.remove(discardPile.cardsHeld, index)
        droppedObject.sticky = false
        flipCardOverIfNeeded(droppedObject)

        local cardsInSlot1 = getCardsIgnoringCard(discardSlot1.getObjects(), droppedObject)
        local cardsInSlot2 = getCardsIgnoringCard(discardSlot2.getObjects(), droppedObject)
        local cardsInSlot3 = getCardsIgnoringCard(discardSlot3.getObjects(), droppedObject)

        print ("Cards in slot1 " .. #cardsInSlot1)
        print ("Cards in slot2 " .. #cardsInSlot2)
        print ("Cards in slot3 " .. #cardsInSlot3)

        if #cardsInSlot1 == 0 then
            print ("Putting card in slot 1")
            droppedObject.setPositionSmooth(discardSlot1.getPosition(), false, true)
        elseif #cardsInSlot2 == 0 then
            print ("Putting card in slot 2")
            droppedObject.setPositionSmooth(discardSlot2.getPosition(), false, true)
        elseif #cardsInSlot3 == 0 then
            print ("Putting card in slot 3")
            droppedObject.setPositionSmooth(discardSlot3.getPosition(), false, true)
        else
            local discardSlot4 = discardSlot3.getPosition()
            discardSlot4.x = discardSlot4.x + 2

            droppedObject.setPosition(discardSlot4)

            Stream.of(cardsInSlot2)
                .forEach(function(card) 
                    print("moving card to slot 1")
                    card.setPosition(discardSlot1.getPosition(), false, true)
                end)

            Stream.of(cardsInSlot3)
                .forEach(function(card) 
                    print("moving card to slot 2")
                    card.setPosition(discardSlot2.getPosition(), false, true)
                end)

            print ("moving dropped card to slot 3")
            droppedObject.setPosition(discardSlot3Pos, false, false)
        end
    end
end