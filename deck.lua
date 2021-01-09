Deck = {}
Deck.deckObject = nil

-- TODO add "draw" button to replace draw context menu option
--      unless person who used context menu option can be determined

function Deck.SpawnDecks()
    Deck.deckObject = Wrapper.getObjectFromGUID(Config.DeckGuid)

    Wait.time(function()
        for i = 2, Config.DecksToSpawn do
            Deck.deckObject.clone({position = Deck.deckObject.getPosition()})
        end
    end, 0.1)

    Wait.time(function() Deck.deckObject.shuffle() end, 1)
end

function Deck.HandleObjectRemoved(_, object)
    Wait.frames(function()
        if object.held_by_color ~= nil then
            local message = Strings.get("PlayerRemovedCardFromDeck"):format(Player[object.held_by_color].steam_name)
            local color = Wrapper.Color.fromString(object.held_by_color)
            Wrapper.broadcastToAll(message, color)
        end
    end, 3)
end