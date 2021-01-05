Strings = {
    en = {
        PlayerPlayedCard = "%s played %s",
        PlayerRemovedCardFromDeck = "%s pulled a card from the deck",
    },
}

function Strings.get(key)
    return Strings[Config.Locale][key]
end
