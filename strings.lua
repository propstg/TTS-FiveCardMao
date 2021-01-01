Strings = {
    en = {
        PlayerPlayedCard = "%s played %s",
    },
}

function Strings.get(key)
    return Strings[Config.Locale][key]
end
