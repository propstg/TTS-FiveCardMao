describe("strings", function()
    it("should return correct string for locale and key", function()
        _G.Config = {
            Locale = "en"
        }

        require("../strings")

        assert(Strings.get("PlayerPlayedCard"), "%s played %s")
    end)
end)