-- Ch.lua
return function(Window, Tabs)
    local Players = game:GetService("Players")
    local TeleportService = game:GetService("TeleportService")
    local RunService = game:GetService("RunService")
    local Lighting = game:GetService("Lighting")
    local LocalPlayer = Players.LocalPlayer
    local UserInputService = game:GetService("UserInputService")

    --== Info Section
    local InfoSection = Tabs.Info:AddSection("Chloe X Information", true)

    InfoSection:AddParagraph({
        Title = "Chloe X Alert!",
        Content = [[
This script is still under development!
There is a possibility it may get detected if used in public servers!
If you have suggestions or found bugs, please report them to <font color="rgb(0,170,255)">Discord Chloe X</font>!<br/>
<b>Use at your own risk!</b>
]],
        Icon = "water"
    })


    InfoSection:AddParagraph({
        Title = "CHLOE X Discord",
        Content = "Official link discord Chloe X!",
        Icon = "dcs",
        ButtonText = "COPY LINK DISCORD",
        ButtonCallback = function()
            if setclipboard then
                setclipboard("https://discord.com/invite/PaPvGUE8UC")
                chloex("Succesfully copied link!")
            end
        end
    })

    InfoSection:AddDivider()

    local Players = game:GetService("Players")
    local TeleportService = game:GetService("TeleportService")
    local LocalPlayer = Players.LocalPlayer

    local currentJobId = "CHX-" .. tostring(game.JobId)

    InfoSection:AddPanel({
        Title = "Server Info",
        Content = string.format(
            "<b><font color=\"rgb(0,200,255)\">Player</font></b> : <font color=\"rgb(255,255,255)\">%d/%d Player Active</font>\n<b><font color=\"rgb(255,255,0)\">JobID</font></b> : <font color=\"rgb(200,200,200)\">%s</font>",
            #Players:GetPlayers(), Players.MaxPlayers, currentJobId
        ),
        Placeholder = "Input JobID",
        Button = "Copy JobID",
        Callback = function()
            if setclipboard then
                setclipboard(currentJobId)
                chloex("Succesfully copied!")
            end
        end,
        SubButton = "Join JobID",
        SubCallback = function(text)
            if text and text ~= "" then
                local cleaned = text:gsub("^CHX%-", "")
                TeleportService:TeleportToPlaceInstance(game.PlaceId, cleaned, LocalPlayer)
            end
        end
    })

    InfoSection:AddDivider()

    InfoSection:AddButton({
        Title = "ServerHop Lowest",
        Callback = function()
            task.spawn(function()
                local HttpService = game:GetService("HttpService")
                local TeleportService = game:GetService("TeleportService")
                local PlaceId = game.PlaceId
                local Cursor
                local LowestServer = nil
                local LowestPlayers = math.huge

                repeat
                    local url = "https://games.roblox.com/v1/games/" ..
                        PlaceId .. "/servers/Public?sortOrder=Asc&limit=100" ..
                        (Cursor and "&cursor=" .. Cursor or "")
                    local success, response = pcall(function()
                        return game:HttpGet(url)
                    end)
                    if success and response then
                        local data = HttpService:JSONDecode(response)
                        for _, server in ipairs(data.data) do
                            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                                if server.playing < LowestPlayers then
                                    LowestPlayers = server.playing
                                    LowestServer = server.id
                                end
                            end
                        end
                        Cursor = data.nextPageCursor
                    else
                        break
                    end
                    task.wait(0.2)
                until not Cursor

                if LowestServer then
                    TeleportService:TeleportToPlaceInstance(PlaceId, LowestServer, game.Players.LocalPlayer)
                else
                    chloex("Tidak ada server lain ditemukan.")
                end
            end)
        end,

        SubTitle = "ServerHop Random",
        SubCallback = function()
            task.spawn(function()
                local HttpService = game:GetService("HttpService")
                local TeleportService = game:GetService("TeleportService")
                local PlaceId = game.PlaceId
                local Cursor
                local Servers = {}

                repeat
                    local url = "https://games.roblox.com/v1/games/" ..
                        PlaceId .. "/servers/Public?sortOrder=Asc&limit=100" ..
                        (Cursor and "&cursor=" .. Cursor or "")
                    local success, response = pcall(function()
                        return game:HttpGet(url)
                    end)
                    if success and response then
                        local data = HttpService:JSONDecode(response)
                        for _, server in ipairs(data.data) do
                            if server.playing < server.maxPlayers and server.id ~= game.JobId then
                                table.insert(Servers, server.id)
                            end
                        end
                        Cursor = data.nextPageCursor
                    else
                        break
                    end
                    task.wait(0.2)
                until not Cursor

                if #Servers > 0 then
                    local RandomServer = Servers[math.random(1, #Servers)]
                    TeleportService:TeleportToPlaceInstance(PlaceId, RandomServer, game.Players.LocalPlayer)
                else
                    chloex("Tidak ada server lain ditemukan.")
                end
            end)
        end
    })

    InfoSection:AddButton({
        Title = "Rejoin Server",
        Callback = function()
            local TeleportService = game:GetService("TeleportService")
            local Players = game:GetService("Players")
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, Players.LocalPlayer)
        end
    })

    --== State
    local NoclipEnabled = false
    local WalkspeedEnabled = false
    local WalkspeedValue = 16
    local XrayEnabled = false
    local FullBrightEnabled = false
    local InfJumpEnabled = false

    local function applyFullbright()
        Lighting.Ambient = Color3.new(1, 1, 1)
        Lighting.Brightness = 2
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
    end

    --== Misc
    local MiscSection = Tabs.Misc:AddSection("Booster FPS")

    MiscSection:AddToggle({
        Title = "Disable 3D Render",
        Content = "No Render Map",
        Default = false,
        Callback = function(state)
            if typeof(RunService.Set3dRenderingEnabled) == "function" then
                RunService:Set3dRenderingEnabled(not state)
            end
        end
    })

    MiscSection:AddToggle({
        Title = "Reduce Map",
        Content = "Fps Booster!",
        Default = false,
        Callback = function(value)
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") then
                    if value then
                        obj.Material = Enum.Material.Plastic
                        obj.Color = Color3.new(1, 1, 1)
                    end
                elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
                    obj.Enabled = not value
                elseif obj:IsA("Shirt") or obj:IsA("Pants") or obj:IsA("ShirtGraphic") or obj:IsA("Accessory") then
                    if value then obj:Destroy() end
                end
            end
            if workspace:FindFirstChild("Terrain") then
                workspace.Terrain.WaterWaveSize = value and 0 or 0.15
                workspace.Terrain.WaterWaveSpeed = value and 0 or 10
                workspace.Terrain.WaterReflectance = value and 0 or 1
                workspace.Terrain.WaterTransparency = value and 0 or 0.3
            end
        end
    })

    MiscSection:AddToggle({
        Title = "Black Screen",
        Content = "Create your screen fully black",
        Default = false,
        Callback = function(value)
            if value then
                if not game.CoreGui:FindFirstChild("BlackScreen") then
                    -- cari Chloeex dan pastiin DisplayOrder lebih tinggi
                    local ChloeexGui = game.CoreGui:FindFirstChild("Chloeex")
                    if ChloeexGui then
                        ChloeexGui.DisplayOrder = 10
                    end

                    -- bikin blackscreen gui
                    local frame = Instance.new("ScreenGui")
                    frame.Name = "BlackScreen"
                    frame.IgnoreGuiInset = true
                    frame.ResetOnSpawn = false
                    frame.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
                    frame.DisplayOrder = 1 -- lebih rendah dari Chloeex
                    frame.Parent = game.CoreGui

                    local bg = Instance.new("Frame")
                    bg.Size = UDim2.new(1, 0, 1, 0)
                    bg.BackgroundColor3 = Color3.new(0, 0, 0)
                    bg.ZIndex = 0
                    bg.Parent = frame
                end

                RunService:Set3dRenderingEnabled(false)
            else
                local bs = game.CoreGui:FindFirstChild("BlackScreen")
                if bs then bs:Destroy() end
                RunService:Set3dRenderingEnabled(true)
            end
        end
    })


    --== Utility
    local UtilitySection = Tabs.Misc:AddSection("Utility")

    UtilitySection:AddToggle({
        Title = "Noclip",
        Content = "Make cant touch any",
        Default = false,
        Callback = function(value)
            NoclipEnabled = value
        end
    })

    RunService.Stepped:Connect(function()
        if NoclipEnabled and LocalPlayer.Character then
            for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
                if v:IsA("BasePart") and v.CanCollide then
                    v.CanCollide = false
                end
            end
        end
    end)

    UtilitySection:AddSlider({
        Title = "Walkspeed",
        Min = 16,
        Max = 200,
        Default = 16,
        Callback = function(value)
            WalkspeedValue = value
            if WalkspeedEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.WalkSpeed = WalkspeedValue
            end
        end
    })

    UtilitySection:AddToggle({
        Title = "Enable Walkspeed",
        Content = "Added more speed!",
        Default = false,
        Callback = function(value)
            WalkspeedEnabled = value
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                LocalPlayer.Character.Humanoid.WalkSpeed = value and WalkspeedValue or 16
            end
        end
    })

    UtilitySection:AddToggle({
        Title = "Xray",
        Default = false,
        Callback = function(value)
            XrayEnabled = value
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") then
                    obj.LocalTransparencyModifier = value and 0.5 or 0
                end
            end
        end
    })

    UtilitySection:AddToggle({
        Title = "Fullbright",
        Default = false,
        Callback = function(value)
            FullBrightEnabled = value
            if value then
                applyFullbright()
            else
                Lighting.Ambient = Color3.new(0, 0, 0)
                Lighting.Brightness = 1
                Lighting.FogEnd = 1000
                Lighting.GlobalShadows = true
            end
        end
    })

    UtilitySection:AddToggle({
        Title = "Infinite Jump",
        Content = "Make You Inf Jump",
        Default = false,
        Callback = function(value)
            InfJumpEnabled = value
        end
    })

    UserInputService.JumpRequest:Connect(function()
        if InfJumpEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)

    --== Anti AFK
    local GC = getconnections or get_signal_cons
    if GC then
        for _, v in pairs(GC(LocalPlayer.Idled)) do
            if v.Disable then
                v:Disable()
            elseif v.Disconnect then
                v:Disconnect()
            end
        end
    else
        local VirtualUser = cloneref and cloneref(game:GetService("VirtualUser")) or game:GetService("VirtualUser")
        LocalPlayer.Idled:Connect(function()
            VirtualUser:CaptureController()
            VirtualUser:ClickButton2(Vector2.new())
        end)
    end
end
