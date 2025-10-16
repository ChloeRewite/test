return function(Window, Tabs)
    local Players = game:GetService("Players")
    local TeleportService = game:GetService("TeleportService")
    local RunService = game:GetService("RunService")
    local Lighting = game:GetService("Lighting")
    local UserInputService = game:GetService("UserInputService")
    local GuiService = game:GetService("GuiService")
    local HttpService = game:GetService("HttpService")

    local LocalPlayer = Players.LocalPlayer
    local placeId = game.PlaceId
    local jobId = game.JobId
    local privateServerId = game.PrivateServerId

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
        Icon = "discord",
        ButtonText = "COPY LINK DISCORD",
        ButtonCallback = function()
            if setclipboard then
                setclipboard("https://discord.com/invite/PaPvGUE8UC")
                chloex("Succesfully copied link!")
            end
        end
    })

    local InfoSection1 = Tabs.Info:AddSection("Server Job Id")
    local thumb, _ = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
    local currentJobId = "CHX-" .. tostring(jobId)

    InfoSection1:AddPanel({
        Title = "Server Info",
        Content = string.format(
            "<b><font color='rgb(0,200,255)'>Player</font></b>: %d/%d\n<b><font color='rgb(255,255,0)'>JobID</font></b>: %s",
            #Players:GetPlayers(), Players.MaxPlayers, currentJobId
        ),
        Icon = thumb,
        ButtonText = "Copy JobID",
        ButtonCallback = function()
            if setclipboard then
                setclipboard(currentJobId)
                chloex("Succesfully Copied!")
            end
        end,
        SubButtonText = "Rejoin",
        SubButtonCallback = function()
            TeleportService:TeleportToPlaceInstance(placeId, jobId, LocalPlayer)
        end
    })

    local InputJobId = ""
    InfoSection1:AddInput({
        Title = "Input JobID",
        Default = "",
        Callback = function(value)
            InputJobId = value
        end
    })

    InfoSection1:AddButton({
        Title = "Join JobID",
        Callback = function()
            if InputJobId ~= "" then
                local realJobId = InputJobId:gsub("^CHX%-", "")
                TeleportService:TeleportToPlaceInstance(placeId, realJobId, LocalPlayer)
            else
                chloex("Input Job Id!")
            end
        end
    })

    InfoSection1:AddButton({
        Title = "ServerHop Lowest",
        Callback = function()
            task.spawn(function()
                local Cursor
                local LowestServer, LowestPlayers = nil, math.huge
                repeat
                    local url = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100" .. (Cursor and "&cursor=" .. Cursor or "")
                    local success, response = pcall(game.HttpGet, game, url)
                    if success and response then
                        local data = HttpService:JSONDecode(response)
                        for _, server in ipairs(data.data) do
                            if server.playing < server.maxPlayers and server.id ~= jobId then
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
                    TeleportService:TeleportToPlaceInstance(placeId, LowestServer, LocalPlayer)
                else
                    chloex("No other server found.")
                end
            end)
        end,
        SubTitle = "ServerHop Random",
        SubCallback = function()
            task.spawn(function()
                local Cursor
                local Servers = {}
                repeat
                    local url = "https://games.roblox.com/v1/games/" .. placeId .. "/servers/Public?sortOrder=Asc&limit=100" .. (Cursor and "&cursor=" .. Cursor or "")
                    local success, response = pcall(game.HttpGet, game, url)
                    if success and response then
                        local data = HttpService:JSONDecode(response)
                        for _, server in ipairs(data.data) do
                            if server.playing < server.maxPlayers and server.id ~= jobId then
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
                    local randomServer = Servers[math.random(1, #Servers)]
                    TeleportService:TeleportToPlaceInstance(placeId, randomServer, LocalPlayer)
                else
                    chloex("No available server found!")
                end
            end)
        end
    })

    InfoSection1:AddButton({
        Title = "Rejoin Server",
        Callback = function()
            TeleportService:TeleportToPlaceInstance(placeId, jobId, LocalPlayer)
        end
    })

    local MiscBooster = Tabs.Misc:AddSection("Booster FPS")

    MiscBooster:AddToggle({
        Title = "Disable 3D Render",
        Content = "No Render Map",
        Default = false,
        Callback = function(state)
            if typeof(RunService.Set3dRenderingEnabled) == "function" then
                RunService:Set3dRenderingEnabled(not state)
            end
        end
    })

    local originalStates = {}

    MiscBooster:AddToggle({
        Title = "Reduce Map",
        Content = "Fps Booster!",
        Default = false,
        Callback = function(value)
            if value then
                originalStates = {}
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("BasePart") then
                        originalStates[obj] = { Material = obj.Material, Color = obj.Color }
                        obj.Material = Enum.Material.Plastic
                        obj.Color = Color3.new(1, 1, 1)
                    elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
                        obj.Enabled = false
                    elseif obj:IsA("Shirt") or obj:IsA("Pants") or obj:IsA("ShirtGraphic") or obj:IsA("Accessory") then
                        obj.Archivable = false
                        obj.Parent = nil
                    end
                end
                if workspace:FindFirstChild("Terrain") then
                    local t = workspace.Terrain
                    t.WaterWaveSize, t.WaterWaveSpeed, t.WaterReflectance, t.WaterTransparency = 0, 0, 0, 0
                end
            else
                for obj, data in pairs(originalStates) do
                    if obj and obj:IsDescendantOf(workspace) then
                        obj.Material, obj.Color = data.Material, data.Color
                    end
                end
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if obj:IsA("ParticleEmitter") or obj:IsA("Trail") then
                        obj.Enabled = true
                    end
                end
                if workspace:FindFirstChild("Terrain") then
                    local t = workspace.Terrain
                    t.WaterWaveSize, t.WaterWaveSpeed, t.WaterReflectance, t.WaterTransparency = 0.15, 10, 1, 0.3
                end
                originalStates = {}
            end
        end
    })

    MiscBooster:AddToggle({
        Title = "Black Screen",
        Content = "Make your screen fully black",
        Default = false,
        Callback = function(value)
            local coreGui = game:GetService("CoreGui")
            local chloeUI = coreGui:FindFirstChild("Chloeex")
            local toggleUI = coreGui:FindFirstChild("ToggleUIButton")

            if value then
                if not coreGui:FindFirstChild("BlackScreen") then
                    local frame = Instance.new("ScreenGui")
                    frame.Name = "BlackScreen"
                    frame.IgnoreGuiInset = true
                    frame.ResetOnSpawn = false
                    frame.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
                    frame.DisplayOrder = 0
                    frame.Parent = coreGui

                    local bg = Instance.new("Frame")
                    bg.Size = UDim2.new(1, 0, 1, 0)
                    bg.BackgroundColor3 = Color3.new(0, 0, 0)
                    bg.ZIndex = 0
                    bg.Parent = frame
                end
                if chloeUI then chloeUI.DisplayOrder = 10 end
                if toggleUI then toggleUI.DisplayOrder = 11 end
                RunService:Set3dRenderingEnabled(false)
            else
                local bs = coreGui:FindFirstChild("BlackScreen")
                if bs then bs:Destroy() end
                RunService:Set3dRenderingEnabled(true)
            end
        end
    })

    local Misc = Tabs.Misc:AddSection("Misc")
    local NoclipEnabled, WalkspeedEnabled, InfJumpEnabled = false, false, false
    local WalkspeedValue = 16

    Misc:AddToggle({
        Title = "Noclip",
        Content = "Walk through objects",
        Default = false,
        Callback = function(v) NoclipEnabled = v end
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

    Misc:AddSlider({
        Title = "Walkspeed",
        Min = 16, Max = 200, Default = 16,
        Callback = function(val)
            WalkspeedValue = val
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
            if WalkspeedEnabled and hum then hum.WalkSpeed = val end
        end
    })

    Misc:AddToggle({
        Title = "Enable Walkspeed",
        Content = "Speed boost",
        Default = false,
        Callback = function(v)
            WalkspeedEnabled = v
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
            if hum then hum.WalkSpeed = v and WalkspeedValue or 16 end
        end
    })

    Misc:AddToggle({
        Title = "Fullbright",
        Default = false,
        Callback = function(state)
            if state then
                Lighting.Ambient = Color3.new(1, 1, 1)
                Lighting.Brightness = 2
                Lighting.FogEnd = 100000
                Lighting.GlobalShadows = false
            else
                Lighting.Ambient = Color3.new(0, 0, 0)
                Lighting.Brightness = 1
                Lighting.FogEnd = 1000
                Lighting.GlobalShadows = true
            end
        end
    })

    Misc:AddToggle({
        Title = "Infinite Jump",
        Default = false,
        Callback = function(v) InfJumpEnabled = v end
    })

    UserInputService.JumpRequest:Connect(function()
        if InfJumpEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end)

    Misc:AddSubSection("Fly Features")

    local FLYING, QEfly, iyflyspeed = false, true, 1
    local flyKeyDown, flyKeyUp

    local function getRoot(char)
        return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
    end

    local function NOFLY()
        FLYING = false
        local char = LocalPlayer.Character
        if char then
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then hum.PlatformStand = false end
            local root = char:FindFirstChild("HumanoidRootPart")
            if root then
                for _, v in pairs(root:GetChildren()) do
                    if v:IsA("BodyGyro") or v:IsA("BodyVelocity") then v:Destroy() end
                end
            end
        end
    end

    local function sFLY(vfly)
        local plr = LocalPlayer
        local char = plr.Character or plr.CharacterAdded:Wait()
        local humanoid = char:FindFirstChildOfClass("Humanoid") or char:WaitForChild("Humanoid")
        local T = getRoot(char)
        local CONTROL = {F=0,B=0,L=0,R=0,Q=0,E=0}
        local lCONTROL = {F=0,B=0,L=0,R=0,Q=0,E=0}
        local SPEED = 0

        if flyKeyDown then flyKeyDown:Disconnect() end
        if flyKeyUp then flyKeyUp:Disconnect() end

        local function FLY()
            FLYING = true
            local BG = Instance.new('BodyGyro')
            local BV = Instance.new('BodyVelocity')
            BG.P, BG.MaxTorque = 9e4, Vector3.new(9e9,9e9,9e9)
            BG.CFrame, BG.Parent, BV.Parent = T.CFrame, T, T
            BV.MaxForce = Vector3.new(9e9,9e9,9e9)
            task.spawn(function()
                repeat task.wait()
                    local cam = workspace.CurrentCamera
                    if not vfly then humanoid.PlatformStand = true end
                    SPEED = (CONTROL.L+CONTROL.R ~= 0 or CONTROL.F+CONTROL.B ~= 0 or CONTROL.Q+CONTROL.E ~= 0) and (iyflyspeed*50) or 0
                    if SPEED ~= 0 then
                        BV.Velocity = ((cam.CFrame.LookVector*(CONTROL.F+CONTROL.B)) +
                            ((cam.CFrame*CFrame.new(CONTROL.L+CONTROL.R,(CONTROL.F+CONTROL.B+CONTROL.Q+CONTROL.E)*0.2,0).p)-cam.CFrame.p)) * SPEED
                        lCONTROL = {F=CONTROL.F,B=CONTROL.B,L=CONTROL.L,R=CONTROL.R}
                    else
                        BV.Velocity = Vector3.zero
                    end
                    BG.CFrame = cam.CFrame
                until not FLYING
                BG:Destroy(); BV:Destroy()
                humanoid.PlatformStand = false
            end)
        end

        flyKeyDown = UserInputService.InputBegan:Connect(function(input)
            local k = input.KeyCode
            if k == Enum.KeyCode.W then CONTROL.F=1
            elseif k == Enum.KeyCode.S then CONTROL.B=-1
            elseif k == Enum.KeyCode.A then CONTROL.L=-1
            elseif k == Enum.KeyCode.D then CONTROL.R=1
            elseif k == Enum.KeyCode.E and QEfly then CONTROL.Q=1
            elseif k == Enum.KeyCode.Q and QEfly then CONTROL.E=-1 end
        end)

        flyKeyUp = UserInputService.InputEnded:Connect(function(input)
            local k = input.KeyCode
            if k == Enum.KeyCode.W then CONTROL.F=0
            elseif k == Enum.KeyCode.S then CONTROL.B=0
            elseif k == Enum.KeyCode.A then CONTROL.L=0
            elseif k == Enum.KeyCode.D then CONTROL.R=0
            elseif k == Enum.KeyCode.E then CONTROL.Q=0
            elseif k == Enum.KeyCode.Q then CONTROL.E=0 end
        end)

        FLY()
    end

    local function mobilefly(plr)
        FLYING = true
        local char = plr.Character or plr.CharacterAdded:Wait()
        local root = char:WaitForChild("HumanoidRootPart")
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        local cam = workspace.CurrentCamera
        local control = require(plr:WaitForChild("PlayerScripts"):WaitForChild("PlayerModule"):WaitForChild("ControlModule"))

        local bv, bg = Instance.new("BodyVelocity"), Instance.new("BodyGyro")
        bv.MaxForce = Vector3.new(9e9,9e9,9e9)
        bg.MaxTorque, bg.P, bg.D = Vector3.new(9e9,9e9,9e9), 1000, 50
        bv.Parent, bg.Parent = root, root
        humanoid.PlatformStand = true

        task.spawn(function()
            while FLYING and task.wait() do
                local move = control:GetMoveVector()
                bg.CFrame = cam.CFrame
                local dir = (cam.CFrame.RightVector*move.X + cam.CFrame.LookVector*-move.Z)
                bv.Velocity = dir * (iyflyspeed*50)
            end
            humanoid.PlatformStand = false
            bv:Destroy(); bg:Destroy()
        end)
    end

    Misc:AddSlider({
        Title = "Fly Speed",
        Min = 1, Max = 10, Default = 1,
        Callback = function(v) iyflyspeed = v end
    })

    Misc:AddToggle({
        Title = "Enable Fly",
        Content = "Toggle flight mode",
        Default = false,
        Callback = function(state)
            if state then
                if UserInputService.TouchEnabled then
                    mobilefly(LocalPlayer)
                else
                    sFLY()
                end
            else
                NOFLY()
            end
        end
    })

    local SvX = Tabs.Misc:AddSection("Server Features")
    local reconnecting, queueEnabled = true, false,
    
    SvX:AddToggle({
        Title = "Auto Reconnect",
        Default = true,
        Callback = function(state)
            if state and not reconnecting then
                reconnecting = true
                GuiService.ErrorMessageChanged:Connect(function()
                    task.wait(0.5)
                    local success = pcall(function()
                        if privateServerId ~= "" then
                            TeleportService:TeleportToPrivateServer(placeId, privateServerId, {LocalPlayer})
                        else
                            TeleportService:TeleportToPlaceInstance(placeId, jobId, LocalPlayer)
                        end
                    end)
                    if not success then
                        task.wait(2)
                        pcall(function()
                            TeleportService:Teleport(placeId, LocalPlayer)
                        end)
                    end
                end)
            else
                reconnecting = false
            end
        end
    })

    SvX:AddToggle({
        Title = "Auto Execute",
        Default = false,
        Callback = function(state)
            queueEnabled = state
            if queue_on_teleport then
                queue_on_teleport(state and [[
                    loadstring(game:HttpGet("https://raw.githubusercontent.com/MajestySkie/Chloe-X/main/Main/ChloeX"))()
                ]] or "")
            end
        end
    })

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
    end
    local VirtualUser = cloneref and cloneref(game:GetService("VirtualUser")) or game:GetService("VirtualUser")
    LocalPlayer.Idled:Connect(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new())
    end)
end
