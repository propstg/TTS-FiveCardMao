Strings = {
    en = {
        ["PlayerPlayedCard"] = "%s played %s",
        ["PlayerRemovedCardFromDeck"] = "%s pulled a card from the deck",
        ["OnlyPlayCardsInDiscardPile"] = "Please only play cards in the discard pile",
        ["ReturnedCardToPlayer"] = "%s returned %s to %s",
        ["GavePlayerCard"] = "%s gave a card to %s",
        ["Label_Context_Return"] = "Return",
        ["Label_Context_ReturnPenalty"] = "Return + Penalty",
    },
}

function Strings.get(key)
    return Strings[Config.Locale][key]
end
