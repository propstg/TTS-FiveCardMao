require "../stream"
require "../cardUtils"
require "../strings"
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
        _G.Player = {
            Red = {steam_name = "Blarglebottoms"},
            Blue = {steam_name = "Blueglebottoms"},
        }
        function _G.Player.Red.getHandTransform(handIndex) return {position = "red hand position " .. handIndex} end

        when(colorMock.fromString("Red")).thenAnswer("mock color")

        require("../discardPile")

        DiscardPile.discardDropZone = mockagne.getMock()
        DiscardPile.discardSlot1 = mockagne.getMock()
        DiscardPile.lastCardPlaced = mockagne.getMock()
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

    it("should show rejected message when dropped object is not a card", function()
        local object = {}
        object.tag = "Deck"
        DiscardPile.cardsHeld = {object}

        DiscardPile.HandleDrop("Red", object)

        verify(wrapperMock.broadcastToAll("Please only play cards in the discard pile", "mock color"));
    end)

    it("should handle first card dropped on HandleDrop", function()
        local object = createMockCard()
        DiscardPile.cardsHeld = {object}

        when(DiscardPile.discardDropZone.getObjects()).thenAnswer({})
        when(DiscardPile.discardSlot1.getPosition()).thenAnswer("discard slot 1 position")

        DiscardPile.HandleDrop("Red", object)

        assert.equal(0, #DiscardPile.cardsHeld)
        assert.equal(object, DiscardPile.lastCardPlaced)
        assert.is_false(object.sticky)
        assert.is_true(object.setRotationSmoothCalled)
        assert.is_true(object.setPositionSmoothCalled)
        assert.equal("discard slot 1 position", object.setPositionSmoothCalledWith)

        verify(wrapperMock.broadcastToAll("Blarglebottoms played card name", "mock color"));
    end)

    it("should handle additional cards dropped on HandleDrop", function()
        local object = createMockCard()
        DiscardPile.cardsHeld = {object}

        when(DiscardPile.discardDropZone.getObjects()).thenAnswer({DiscardPile.lastCardPlaced})
        when(DiscardPile.lastCardPlaced.getPosition()).thenAnswer({x = 1, y = 1})

        DiscardPile.HandleDrop("Red", object)

        assert.equal(0, #DiscardPile.cardsHeld)
        assert.equal(object, DiscardPile.lastCardPlaced)
        assert.is_false(object.sticky)
        assert.is_true(object.setRotationSmoothCalled)
        assert.is_true(object.setPositionSmoothCalled)
        assert.equal(1.75, object.setPositionSmoothCalledWith.x)
        assert.equal(2, object.setPositionSmoothCalledWith.y)

        verify(wrapperMock.broadcastToAll("Blarglebottoms played card name", "mock color"));
    end)

    it("should set PlayedBy variable when card is played", function()
        local object = createMockCard()
        DiscardPile.cardsHeld = {object}

        when(DiscardPile.discardDropZone.getObjects()).thenAnswer({DiscardPile.lastCardPlaced})
        when(DiscardPile.lastCardPlaced.getPosition()).thenAnswer({x = 1, y = 1})

        DiscardPile.HandleDrop("Red", object)

        assert.equal("PlayedBy", object.setVarCalledWith[1].variableName)
        assert.equal("Red", object.setVarCalledWith[1].value)
    end)

    it("should register addContextMenuItems on played card", function()
        local object = createMockCard()
        DiscardPile.cardsHeld = {object}

        when(DiscardPile.discardDropZone.getObjects()).thenAnswer({DiscardPile.lastCardPlaced})
        when(DiscardPile.lastCardPlaced.getPosition()).thenAnswer({x = 1, y = 1})

        DiscardPile.HandleDrop("Red", object)

        assert.equal("Return", object.addContextMenuItemCalledWith[1].label)
        assert.equal("Return + Penalty", object.addContextMenuItemCalledWith[2].label)
    end)

    describe("return context menu item", function()
        local card = nil

        before_each(function()
            card = createMockCard()
            DiscardPile.cardsHeld = {card}
            when(DiscardPile.discardDropZone.getObjects()).thenAnswer({DiscardPile.lastCardPlaced})
            when(DiscardPile.lastCardPlaced.getPosition()).thenAnswer({x = 1, y = 1})

            DiscardPile.HandleDrop("Red", card)
            card.addContextMenuItemCalledWith[1].handlerFunction("Blue")
        end)

        it("should set ReturnedBy variable to player that used the menu item", function()
            assert.equal("ReturnedBy", card.setVarCalledWith[2].variableName)
            assert.equal("Blue", card.setVarCalledWith[2].value)
        end)

        it("should broadcast message to everyone when menu item used", function()
            verify(wrapperMock.broadcastToAll("Blueglebottoms returned card name to Blarglebottoms"))
        end)

        it("should move card to the hand zone in front of the player that played the card", function()
            assert.equal("red hand position 2", card.setPositionSmoothCalledWith)
        end)

        it("should remove context menu items from card after using", function()
            assert.is_true(card.clearContextMenuCalled)
        end)
    end)

    describe("return + penalty context menu item", function()
        local card = nil
        local takeObjectCalledWith = nil

        before_each(function()
            card = createMockCard()
            DiscardPile.cardsHeld = {card}
            when(DiscardPile.discardDropZone.getObjects()).thenAnswer({DiscardPile.lastCardPlaced})
            when(DiscardPile.lastCardPlaced.getPosition()).thenAnswer({x = 1, y = 1})
            _G.Deck = {
                deckObject = {
                    takeObject = function(obj)
                        takeObjectCalledWith = obj
                    end
                }
            }

            DiscardPile.HandleDrop("Red", card)
            card.addContextMenuItemCalledWith[2].handlerFunction("Blue")
        end)
        
        it("should set ReturnedBy variable to player that used the menu item", function()
            assert.equal("ReturnedBy", card.setVarCalledWith[2].variableName)
            assert.equal("Blue", card.setVarCalledWith[2].value)
        end)

        it("should broadcast messages to everyone when menu item used", function()
            verify(wrapperMock.broadcastToAll("Blueglebottoms returned card name to Blarglebottoms"))
            verify(wrapperMock.broadcastToAll("Blueglebottoms gave a card to Blarglebottoms"))
        end)

        it("should move card to the hand zone in front of the player that played the card", function()
            assert.equal("red hand position 2", card.setPositionSmoothCalledWith)
        end)

        it("should move additional penalty card to the hand zone in front of the player that played the card", function()
            assert.not_nil(takeObjectCalledWith)
            assert.equal("red hand position 2", takeObjectCalledWith.position)
        end)

        it("should set GivenBy variable to player that used the menu item on penalty card", function()
            assert.not_nil(takeObjectCalledWith)
            assert.not_nil(takeObjectCalledWith.callback_function)

            local newCard = createMockCard()
            takeObjectCalledWith.callback_function(newCard)

            assert.equal("GivenBy", newCard.setVarCalledWith[1].variableName)
            assert.equal("Blue", newCard.setVarCalledWith[1].value)
        end)

        it("should remove context menu items from card after using", function()
            assert.is_true(card.clearContextMenuCalled)
        end)
    end)

    it("should do nothing when card is not in cardsHeld on HandleDrop", function()
        DiscardPile.cardsHeld = {}

        assert.equal(0, #DiscardPile.cardsHeld)

        DiscardPile.HandleDrop("object")
    
        assert.equal(0, #DiscardPile.cardsHeld)
    end)

    function createMockCard()
        local object = {}
        object.sticky = true
        object.tag = "Card"
        object.setRotationSmoothCalled = false
        object.setPositionSmoothCalled = false
        object.clearContextMenuCalled = false
        object.setPositionSmoothCalledWith = nil
        object.addContextMenuItemCalledWith = {}
        object.setVarCalledWith = {}
        object.getName = function() return "card name" end
        function object.setRotationSmooth(position) object.setRotationSmoothCalled = true end
        function object.setPositionSmooth(position, _, _)
            object.setPositionSmoothCalled = true
            object.setPositionSmoothCalledWith = position
        end
        function object.addContextMenuItem(label, handlerFunction)
            table.insert(object.addContextMenuItemCalledWith, {
                label = label, handlerFunction = handlerFunction
            })
        end
        function object.setVar(variableName, value)
            table.insert(object.setVarCalledWith, {
                variableName = variableName, value = value
            })
        end
        function object.clearContextMenu()
            object.clearContextMenuCalled = true
        end
        return object
    end
end)