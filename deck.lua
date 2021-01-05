Deck = {}
Deck.deckObject = nil

-- TODO maybe add "draw" button

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
        local message = Strings.get("PlayerRemovedCardFromDeck"):format(Player[object.held_by_color].steam_name)
        local color = Wrapper.Color.fromString(object.held_by_color)
        Wrapper.broadcastToAll(message, color)
    end, 3)
end