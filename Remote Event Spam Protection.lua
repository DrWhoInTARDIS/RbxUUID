--From yours truly: DrWhoInTARDIS
local events, playerTotalEvents = {} , {}
local TRACK_TIME_SEC = 10
local SINGLE_EVENT_LIMIT = 10
local TOTAL_EVENT_LIMIT = 30

function setupEvent(re :Instance|RemoteEvent)
    pcall(function()
        assert(re:IsA("RemoteEvent"))

        local e :Event = re.OnServerEvent
        events[e] = {}
        
        local counter = e:Connect(function(player)
            if events[e] ~= nil then
                events[e][player] = events[e][player] and events[e][player] + 1 or 1
                playerTotalEvents[player] = playerTotalEvents[player] and playerTotalEvents[player] +1 or 1

                --print(player,"Fired:",re:GetFullName(),"Single:",events[e][player],"Total:",playerTotalEvents[player])
                if events[e][player] > SINGLE_EVENT_LIMIT then
                    print(player,"Reached Single Event Limit!!!!!!!!!!!")
                end

                if playerTotalEvents[player] > TOTAL_EVENT_LIMIT then
                    print(player,"Reached Total Event Limit!!!!!!!!!!")
                end
            end
        end)

        spawn(function()
            while counter.Connected and wait(TRACK_TIME_SEC) do
                events[e] = {}
            end
        end)
    end)
end

for k,v in ipairs(game:GetDescendants()) do
    setupEvent(v)
end

game.DescendantAdded:Connect(setupEvent)
game.DescendantRemoving:Connect(function(v)
    pcall(function()
        if v:IsA("RemoteEvent") then
            events[v.OnServerEvent] = nil
        end
    end)
end)

spawn(function()
    while wait(TRACK_TIME_SEC) do
        playerTotalEvents = {}
    end
end)
