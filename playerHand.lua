PlayerHands = {}

function PlayerHands.Init() end
function PlayerHands.OnEnter(enterObject) end
function PlayerHands.OnLeave(leaveObject) end

PlayerHands.PlayerColors = { "White", "Red", "Orange", "Yellow", "Green", "Blue", "Purple", "Pink" }

function PlayerHands.HandleDrop(droppingPlayerColor, droppedObject)
    local handsObjectIsIn = Stream.of(PlayerHands.PlayerColors)
        .map(function(color) return Player[color] end)
        .filter(function(player) return player ~= nil end)
        .filter(function(player)
            return Stream.of(player.getHandObjects(1))
                .anyMatch(function(value)
                    return value == droppedObject
                end)
        end)
        .map(function(player) return player.color end)
        .collect()

    if #handsObjectIsIn == 0 then
        return
    end

    local playerReceivingHand = handsObjectIsIn[1]
    if playerReceivingHand ~= droppingPlayerColor then
        PlayerHands.broadcastMessage("Red", "Don't put cards directly in player hands.")
        PlayerHands.broadcastMessage("Red", "Put cards in card zone in front of player.")
        droppedObject.ignore_fog_of_war = true
        droppedObject.setPosition(Player[playerReceivingHand].getHandTransform(2).position)
    end
end

function PlayerHands.broadcastMessage(playerColor, message)
    local color = Wrapper.Color.fromString(playerColor)
    Wrapper.broadcastToAll(message, color)
end