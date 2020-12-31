local mockagne = require "mockagne"
local when = mockagne.when
local verify = mockagne.verify
local verifyNoCall = mockagne.verify_no_call

describe("cardUtils", function()
    before_each(function()
        require("../stream")
        require("../cardUtils")
    end)

    describe("getCardsIgnoringCard", function()
        it("should return table without provided card", function()
            local cards = {"card1", "card2", "card3"}

            local filteredCards = getCardsIgnoringCard(cards, "card1")

            assert.are.same(filteredCards, {"card2", "card3"})
        end)

        it("should return same table if provided card not found", function()
            local cards = {"card1", "card2", "card3"}

            local filteredCards = getCardsIgnoringCard(cards, "card4")

            assert.are.same(filteredCards, cards)
        end)
    end)

    describe("flipCardOverIfNeeded", function()
        it("should flip card if face down", function()
            local cardMock = mockagne.getMock()
            cardMock.is_face_down = true

            flipCardOverIfNeeded(cardMock)

            verify(cardMock.flip())
        end)

        it("should not flip card if face up", function()
            local cardMock = mockagne.getMock()
            cardMock.is_face_down = false

            flipCardOverIfNeeded(cardMock)

            verifyNoCall(cardMock.flip())
        end)
    end)

    describe("findObjectIndexInTable", function()
        it("should return index when found", function()
            local table = {"object"}
            local object = "object"

            local result = findObjectIndexInTable(table, object)

            assert.equals(result, 1)
        end)
    
        it("should return -1 when not found", function()
            local table = {}
            local object = "object"

            local result = findObjectIndexInTable(table, object)

            assert.equals(result, -1)
        end)
    end)
end)