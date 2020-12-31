function getCardsIgnoringCard(cards, cardToIgnore)
    return Stream.of(cards)
        .filter(function(card) return card ~= cardToIgnore end)
        .collect()
end

function flipCardOverIfNeeded(card)
    if card.is_face_down then
        card.flip()
    end
end

function findObjectIndexInTable(table, object)
    for i, v in pairs(table) do
        if v == object then
            return i
        end
    end

    return -1
end