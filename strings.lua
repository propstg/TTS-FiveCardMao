Strings = {
    en = {
        PlayerPlayedCard = "%s played %s",
        PlayerRemovedCardFromDeck = "%s pulled a card from the deck",
        OnlyPlayCardsInDiscardPile = "Please only play cards in the discard pile",
    },
}

function Strings.get(key)
    return Strings[Config.Locale][key]
end
