require "../stream"
require "../strings"
local mockagne = require "mockagne"
local when = mockagne.when
local any = mockagne.any
local verify = mockagne.verify
local verifyNoCall = mockagne.verify_no_call

describe("PlayerHands", function()
    local wrapperMock = nil
    local colorMock = nil

    before_each(function()
        colorMock = mockagne.getMock()
        wrapperMock = mockagne.getMock()
        wrapperMock.Color = colorMock

        _G.Config = { Locale = "en" }
        _G.Wrapper = wrapperMock

        when(colorMock.fromString("Red")).thenAnswer("Red")

        require("../playerHand")

        _G.Player = {
            White = createMockPlayer("White"),
            Red = createMockPlayer("Red"),
            Orange = createMockPlayer("Orange"),
            Yellow = createMockPlayer("Yellow"),
            Green = createMockPlayer("Green"),
            Blue = createMockPlayer("Blue"),
            Purple = createMockPlayer("Purple"),
            Pink = createMockPlayer("Pink"),
        }
    end)

    function createMockPlayer(color)
        local player = {}
        player.steam_name = color
        player.color = color
        player.handObjects = {}
        player.getHandObjectsCalledWith = nil
        player.getHandTransformCalledWith = nil
        function player.getHandObjects(index)
            player.getHandObjectsCalledWith = index
            return player.handObjects
        end
        function player.getHandTransform(index)
            player.getHandTransformCalledWith = index
            return { position = "second hand position for " .. color }
        end
        return player
    end

    describe("HandleDrop", function()
        it("should move card to player's 2nd hand when another player puts card directly in 1st hand", function()
            local card = mockagne.getMock()
            _G.Player.White.handObjects = {card}

            PlayerHands.HandleDrop("Red", card)

            assert.equal(_G.Player.White.getHandObjectsCalledWith, 1)
            assert.equal(_G.Player.White.getHandTransformCalledWith, 2)
            verify(card.setPosition("second hand position for White"))
        end)

        it("should show messages when player tries dropping card directly in another player's hand", function()
            local card = mockagne.getMock()
            _G.Player.White.handObjects = {card}

            PlayerHands.HandleDrop("Red", card)

            verify(Wrapper.broadcastToAll("Don't put cards directly in player hands", "Red"))
            verify(Wrapper.broadcastToAll("Put cards in card zone in front of player", "Red"))
        end)

        it("should do nothing if dropped object is not in any hands", function()
            local card = mockagne.getMock()

            PlayerHands.HandleDrop("Red", card)

            verifyNoCall(Wrapper.broadcastToAll(any(), any()))
            verifyNoCall(card.setPosition(any()))
        end)

        it("should do nothing if dropped object was dropped into player's hand by that player", function()
            local card = mockagne.getMock()
            _G.Player.Red.handObjects = {card}

            PlayerHands.HandleDrop("Red", card)

            assert.equal(_G.Player.Red.getHandObjectsCalledWith, 1)
            assert.equal(_G.Player.Red.getHandTransformCalledWith, nil)
            verifyNoCall(Wrapper.broadcastToAll(any(), any()))
            verifyNoCall(card.setPosition(any()))
        end)
    end)
end)