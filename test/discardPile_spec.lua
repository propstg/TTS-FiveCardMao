require "../stream"
require "../cardUtils"
local mockagne = require "mockagne"
local when = mockagne.when
local any = mockagne.any
local verify = mockagne.verify
local verifyNoCall = mockagne.verify_no_call

describe("deck", function()
    local wrapperMock = nil
    local waitMock = nil
    local colorMock = nil

    before_each(function()
        colorMock = mockagne.getMock()
        wrapperMock = mockagne.getMock()
        wrapperMock.Color = colorMock

        _G.Config = {
            DiscardDropZoneGuid = "discardDropZoneGuid",
            DiscardFirstCardZoneGuid = "discardFirstCardZoneGuid",
            Locale = "en",
        }
        _G.Wrapper = wrapperMock
        _G.Player = {Red = {steam_name = "Blarglebottoms"}}
        _G.Strings = mockagne.getMock()

        when(_G.Strings.get("PlayerPlayedCard")).thenAnswer("mock string %s %s")
        when(colorMock.fromString("Red")).thenAnswer("mock color")

        require("../discardPile")
    end)

    it("should grab objects using guids from config on init", function()
        when(wrapperMock.getObjectFromGUID("discardDropZoneGuid")).thenAnswer("fake drop zone object")
        when(wrapperMock.getObjectFromGUID("discardFirstCardZoneGuid")).thenAnswer("fake first card zone object")

        DiscardPile.Init()

        verify(wrapperMock.getObjectFromGUID("discardDropZoneGuid"))
        verify(wrapperMock.getObjectFromGUID("discardFirstCardZoneGuid"))

        assert.equal("fake drop zone object", DiscardPile.discardDropZone)
        assert.equal("fake first card zone object", DiscardPile.discardSlot1)
    end)

    it("should add objects to cardsHeld on enter", function()
        assert.equal(0, #DiscardPile.cardsHeld)

        DiscardPile.OnEnter("object")
    
        assert.equal(1, #DiscardPile.cardsHeld)
        assert.equal("object", DiscardPile.cardsHeld[1])
    end)

    it("should remove object from cardsHeld on leave", function()
        DiscardPile.cardsHeld = {}
        table.insert(DiscardPile.cardsHeld, "object")

        assert.equal(1, #DiscardPile.cardsHeld)
        assert.equal("object", DiscardPile.cardsHeld[1])

        DiscardPile.OnLeave("object")
    
        assert.equal(0, #DiscardPile.cardsHeld)
    end)

    it("should do nothing when card is not in cardsHeld on leave", function()
        DiscardPile.cardsHeld = {}

        assert.equal(0, #DiscardPile.cardsHeld)

        DiscardPile.OnLeave("object")
    
        assert.equal(0, #DiscardPile.cardsHeld)
    end)

    it("should handle first card dropped on HandleDrop", function()
        local object = {}
        object.sticky = true
        object.setRotationSmoothCalled = false
        object.setPositionSmoothCalled = false
        object.setPositionSmoothCalledWith = nil
        object.getName = function() return "card name" end
        function object.setRotationSmooth(position) object.setRotationSmoothCalled = true end
        function object.setPositionSmooth(position, _, _)
            object.setPositionSmoothCalled = true
            object.setPositionSmoothCalledWith = position
        end
        DiscardPile.cardsHeld = {object}
        DiscardPile.discardDropZone = mockagne.getMock()
        DiscardPile.discardSlot1 = mockagne.getMock()

        when(DiscardPile.discardDropZone.getObjects()).thenAnswer({})
        when(DiscardPile.discardSlot1.getPosition()).thenAnswer("discard slot 1 position")

        DiscardPile.HandleDrop("Red", object)

        assert.equal(0, #DiscardPile.cardsHeld)
        assert.equal(object, DiscardPile.lastCardPlaced)
        assert.equal(false, object.sticky)
        assert.equal(true, object.setRotationSmoothCalled)
        assert.equal(true, object.setPositionSmoothCalled)
        assert.equal("discard slot 1 position", object.setPositionSmoothCalledWith)

        verify(wrapperMock.broadcastToAll("mock string Blarglebottoms card name", "mock color"));
    end)

    it("should handle additional cards dropped on HandleDrop", function()
        local object = {}
        object.sticky = true
        object.setRotationSmoothCalled = false
        object.setPositionSmoothCalled = false
        object.setPositionSmoothCalledWith = nil
        object.getName = function() return "card name" end
        function object.setRotationSmooth(position) object.setRotationSmoothCalled = true end
        function object.setPositionSmooth(position)
            object.setPositionSmoothCalled = true
            object.setPositionSmoothCalledWith = position
        end
        DiscardPile.cardsHeld = {object}
        DiscardPile.discardDropZone = mockagne.getMock()
        DiscardPile.discardSlot1 = mockagne.getMock()
        DiscardPile.lastCardPlaced = mockagne.getMock()

        when(DiscardPile.discardDropZone.getObjects()).thenAnswer({DiscardPile.lastCardPlaced})
        when(DiscardPile.lastCardPlaced.getPosition()).thenAnswer({x = 1, y = 1})

        DiscardPile.HandleDrop("Red", object)

        assert.equal(0, #DiscardPile.cardsHeld)
        assert.equal(object, DiscardPile.lastCardPlaced)
        assert.equal(false, object.sticky)
        assert.equal(true, object.setRotationSmoothCalled)
        assert.equal(true, object.setPositionSmoothCalled)
        assert.equal(1.75, object.setPositionSmoothCalledWith.x)
        assert.equal(2, object.setPositionSmoothCalledWith.y)

        verify(wrapperMock.broadcastToAll("mock string Blarglebottoms card name", "mock color"));
    end)

    it("should do nothing when card is not in cardsHeld on HandleDrop", function()
        DiscardPile.cardsHeld = {}

        assert.equal(0, #DiscardPile.cardsHeld)

        DiscardPile.HandleDrop("object")
    
        assert.equal(0, #DiscardPile.cardsHeld)
    end)
end)