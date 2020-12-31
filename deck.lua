Deck = {}
Deck.deckObject = nil

-- TODO add message when someone draws
-- TODO maybe add "draw" button

function Deck.SpawnDecks()
    Deck.deckObject = getObjectFromGUID(Config.DeckGuid)

    Wait.time(function()
        for i = 2, Config.DecksToSpawn do
            Deck.deckObject.clone({position = Deck.deckObject.getPosition()})
        end
    end, 0.1)

    Wait.time(|| Deck.deckObject.shuffle(), 1)
end