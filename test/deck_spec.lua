require "../stream"
local mockagne = require "mockagne"
local when = mockagne.when
local any = mockagne.any
local verify = mockagne.verify
local verifyNoCall = mockagne.verify_no_call

describe("deck", function()
    local wrapperMock = nil
    local waitMock = nil
    local deckObjectMock = nil
    local deckObjectPosition = {x = 0, y = 0, z = 0}

    before_each(function()
        wrapperMock = mockagne.getMock()
        waitMock = mockagne.getMock()
        deckObjectMock = mockagne.getMock()

        _G.Config = {
            DeckGuid = "deckGuid",
            DecksToSpawn = 1,
        }
        _G.Wrapper = wrapperMock
        _G.Wait = waitMock

        when(wrapperMock.getObjectFromGUID("deckGuid")).thenAnswer(deckObjectMock)
        when(deckObjectMock.getPosition()).thenAnswer(deckObjectPosition)

        require("../deck")
    end)

    it("should get deck from save file", function()
        Deck.SpawnDecks()

        verify(wrapperMock.getObjectFromGUID("deckGuid"))
    end)

    it("should not clone deck when config option is set to 1 deck", function()
        _G.Config.DecksToSpawn = 1

        Deck.SpawnDecks()

        verifyNoCall(deckObjectMock.getPosition)
        verifyNoCall(deckObjectMock.clone)

        waitMock.stored_calls[1].args[1]()

        verifyNoCall(deckObjectMock.getPosition)
        verifyNoCall(deckObjectMock.clone)
    end)

    it("should clone deck when config option is set to 2 decks", function()
        _G.Config.DecksToSpawn = 2

        Deck.SpawnDecks()

        verifyNoCall(deckObjectMock.getPosition)
        verifyNoCall(deckObjectMock.clone)

        waitMock.stored_calls[1].args[1]()

        verify(deckObjectMock.getPosition())
        verify(deckObjectMock.clone({position = deckObjectPosition}))
    end)

    it("should shuffle the deck", function()
        Deck.SpawnDecks()

        verifyNoCall(deckObjectMock.shuffle())

        waitMock.stored_calls[2].args[1]()

        verify(deckObjectMock.shuffle())
    end)
end)