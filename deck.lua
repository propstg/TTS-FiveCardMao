Deck = {}
Deck.deckObject = nil

function Deck.SpawnDecks()
    --for i = 1, Config.DecksToSpawn do
        Deck.spawnDeck()
    --end
    Wait.time(function()
        print (#(Deck.deckObject.getObjects()))
        for i = 2, Config.DecksToSpawn do
            Deck.deckObject.clone({position = Deck.deckObject.getPosition()})
        end
        print (#(Deck.deckObject.getObjects()))
    end, 1)
end

function Deck.spawnDeck()
    Wrapper.spawnObject({
        type = "deck",
        position = {x=-2, y=0, z=0},
        rotation = {x=180, y=0, z=0},
        scale = {x=1.2, y=1.2, z=1.2},
        callback_function = function(obj)
            if not Deck.deckObject then
                Deck.deckObject = obj
            end
        end
    })
end