Deck = {}
Deck.deckObject = nil

function Deck.SpawnDecks()
    Deck.spawnDeck()

    Wait.time(function()
        for i = 2, Config.DecksToSpawn do
            Deck.deckObject.clone({position = Deck.deckObject.getPosition()})
        end
    end, 1)
end

function Deck.spawnDeck()
    Wrapper.spawnObject({
        type = "deck",
        position = {x=-10.5, y=0, z=0},
        rotation = {x=180, y=0, z=0},
        scale = {x=1.2, y=1.2, z=1.2},
        callback_function = function(obj)
            if not Deck.deckObject then
                Deck.deckObject = obj
            end
        end
    })
end