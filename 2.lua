--== WebhookLib.lua ==--
local HttpService = game:GetService("HttpService")
local Players     = game:GetService("Players")

local request = http_request or request or (syn and syn.request) or (http and http.request)
if not request then
    warn("Executor not support http_request")
    return { Links = {}, Send = function() end, Start = function() end }
end

local WebhookLib = {}

WebhookLib.Links = {
    Admin      = "https://discord.com/api/webhooks/xxxxx/xxxxx",
    Hunt       = "https://discord.com/api/webhooks/xxxxx/xxxxx",
    ServerLuck = "https://discord.com/api/webhooks/xxxxx/xxxxx"
}

WebhookLib.Colors = {
    ["Megalodon Hunt"]      = 0xFF0000,
    ["Ghost Shark Hunt"]    = 0x00FFFF,
    ["Shark Hunt"]          = 0x0000FF,
    ["Worm Hunt"]           = 0x808080,
    ["Admin - Ghost Worm"]  = 0x800080,
    ["Admin - Black Hole"]  = 0x000000,
    ["Admin - Meteor Rain"] = 0xFFA500,
    ["Server Luck"]         = 0x39FF14
}

WebhookLib.Ignore = {
    UIListLayout = true,
    Cloudy = true, Day = true, Night = true,
    Storm = true, Snow = true, Wind = true,
    Mutated = true, Radiant = true,
    ["Increased Luck"] = true,
    ["Sparkling Cove"] = true,
    ["Admin - Shocked"] = true,
    ["Admin - Super Mutated"] = true,
}

WebhookLib.HuntEvents = {
    ["Shark Hunt"]       = true,
    ["Worm Hunt"]        = true,
    ["Ghost Shark Hunt"] = true,
    ["Megalodon Hunt"]   = true,
}

WebhookLib.AdminEvents = {
    ["Admin - Black Hole"]  = true,
    ["Admin - Ghost Worm"]  = true,
    ["Admin - Super Luck"]  = true,
    ["Admin - Meteor Rain"] = true,
}

function WebhookLib.GetServerLink(isGlobal)
    if isGlobal then
        return "https://www.roblox.com/games/" .. tostring(game.PlaceId)
    end
    if game.PrivateServerId ~= "" then
        return ("https://www.roblox.com/games/%s?privateServerLinkCode=%s"):format(
            tostring(game.PlaceId), tostring(game.PrivateServerId)
        )
    end
    return ("https://www.roblox.com/games/start?placeId=%s&gameInstanceId=%s"):format(
        tostring(game.PlaceId), tostring(game.JobId)
    )
end

function WebhookLib.Send(eventType, eventName, isGlobal)
    if _G.WebhookDisabled then return end
    if WebhookLib.Ignore[eventName] then return end

    local url = (eventType == "Admin"      and WebhookLib.Links.Admin)
             or (eventType == "Hunt"       and WebhookLib.Links.Hunt)
             or (eventType == "ServerLuck" and WebhookLib.Links.ServerLuck)
    if not url or url == "" then return end

    url = url:match("^%s*(.-)%s*$") -- trim spasi

    local color      = WebhookLib.Colors[eventName] or WebhookLib.Colors["Server Luck"]
    local serverLink = WebhookLib.GetServerLink(isGlobal)
    local playersNow = #Players:GetPlayers()
    local maxPlayers = Players.MaxPlayers or 0
    local playerText = playersNow.."/"..maxPlayers.." players"
    local isoTime    = os.date("!%Y-%m-%dT%H:%M:%SZ")

    local embed = {
        title       = "ᯓ Chloe X Chloe X Chloe X",
        description = "Wakey wakeyyyy! Chloe found some event :",
        url         = "https://discord.gg/PaPvGUE8UC",
        color       = color,
        fields      = {
            { name = "〢Event Name :",    value = "```❯ "..eventName.."```" },
            { name = "〢Event Spawned :", value = "```❯ "..isoTime.."```" },
            { name = "〢Server Player :", value = "```❯ "..playerText.."```" },
            { name = "〢Link Server :",   value = "```❯ [Join Here]("..serverLink..")```" },
            { name = "〢Note :",          value = "*Once the event ends this link may not working!*" }
        },
        footer = {
            text     = "Chloe X Webhook",
            icon_url = "https://i.imgur.com/WltO8IG.png"
        },
        timestamp = isoTime,
        image     = { url = "https://media.tenor.com/-i05eopE1VEAAAAC/gawr-gura-baseball.gif" }
    }

    local res = request({
        Url     = url,
        Method  = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body    = HttpService:JSONEncode({
            username   = "Aqua Aqua Aqua",
            avatar_url = "https://i.imgur.com/9afHGRy.jpeg",
            embeds     = { embed }
        })
    })

    if res then
        print(string.format("[WebhookLib] %s | Status: %s", eventType, tostring(res.StatusCode)))
        if res.Body and res.Body ~= "" then
            print("[WebhookLib] Body:", res.Body)
        end
    else
        warn("[WebhookLib] Request failed (no response)")
    end
end

function WebhookLib.Start()
    task.spawn(function()
        local gui = Players.LocalPlayer:WaitForChild("PlayerGui")
        local eventsGui = gui:WaitForChild("Events", 10)
        if not eventsGui then return end

        local frame       = eventsGui:WaitForChild("Frame")
        local eventsFrame = frame:WaitForChild("Events")

        for _, child in ipairs(eventsFrame:GetChildren()) do
            if child:IsA("GuiObject") then
                if WebhookLib.HuntEvents[child.Name] then
                    child:GetPropertyChangedSignal("Visible"):Connect(function()
                        if child.Visible then WebhookLib.Send("Hunt", child.Name, false) end
                    end)
                elseif WebhookLib.AdminEvents[child.Name] then
                    child:GetPropertyChangedSignal("Visible"):Connect(function()
                        if child.Visible then WebhookLib.Send("Admin", child.Name, true) end
                    end)
                end
            end
        end

        local serverLuck = frame:FindFirstChild("Server Luck")
        if serverLuck and serverLuck:FindFirstChild("Server") then
            local luckFrame = serverLuck.Server
            luckFrame:GetPropertyChangedSignal("Visible"):Connect(function()
                if luckFrame.Visible then
                    local counter = luckFrame:FindFirstChild("LuckCounter")
                    local text    = counter and counter.Text or "x?"
                    WebhookLib.Send("ServerLuck", "Server Luck "..text, false)
                end
            end)
        end
    end)
end

_G.WebhookLib = WebhookLib
return WebhookLib
