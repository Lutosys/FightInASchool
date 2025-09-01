--[[local key = "7656834967439"

if getgenv().EnteredKey ~= key then
    return
end--]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local rootPart = character:FindFirstChild("HumanoidRootPart")
local uis = game:GetService("UserInputService")
local enabled = false
local CoreGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local httpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

LocalPlayer.CharacterAdded:Connect(function(char)
    rootPart = char:WaitForChild("HumanoidRootPart")
end)

local Live = workspace:FindFirstChild("Live")

local enabled = false
local whitelistedPlayers = {}
local killAuraLoop
local vcgameId = 18248633989
local servers = {}

local function notify(title, desc)
    CoreGui:SetCore("SendNotification", {Title = title, Text = desc})
end

local function hookAllUpdateStruggle()
    local count = 0
    for _, v in pairs(getgc(true)) do
        if type(v) == "function" then
            local info = debug.getinfo(v, "nS")
            if info and info.name == "UpdateStruggle" then
                hookfunction(v, function() end)
                count += 1
            end
        end
    end
end

task.spawn(hookAllUpdateStruggle)

LocalPlayer.CharacterAdded:Connect(function(char)
    hookAllUpdateStruggle()
    char:WaitForChild("Core")
    hookAllUpdateStruggle()
    task.wait(0.50)
    hookAllUpdateStruggle()
end)


notify("WELCOME TO THE SCRIPT", "PRESS V FOR KILLAURA")

local function attack(user)
    if not user or not user.Character then return end

    local character = LocalPlayer.Character
    if not character then return end

    local rootPart = character:FindFirstChild("HumanoidRootPart")
    local rightHand = character:FindFirstChild("RightHand")
    local core = character:FindFirstChild("Core")
    if not rootPart or not rightHand or not core then return end

    local re = core:FindFirstChild("Communicate"):FindFirstChildOfClass("RemoteEvent")
    if not re then return end

    local head = user.Character:FindFirstChild("Head")
    local leftArm = user.Character:FindFirstChild("LeftLowerArm")
    if not head or not leftArm then return end

    local pointHead = head.Position
    local pointLeftArm = leftArm.Position

    task.spawn(function()
        pcall(function()
            re:FireServer("Slam", {
                Character = user.Character,
                Point = pointLeftArm,
                Hit = leftArm,
                Limb = "LeftHand",
                Classs = game:GetService("HttpService"):GenerateGUID(true),
            })
        end)
    end)

    task.spawn(function()
        pcall(function()
            re:FireServer("Heavy", {
                Point = pointLeftArm,
                Combo = 1,
                Class = "Amateur",
                Character = user.Character,
                Hit = head,
                Limb = "RightHand",
                Classs = game:GetService("HttpService"):GenerateGUID(true),
            }, false)
        end)
    end)

    task.spawn(function()
        pcall(function()
            re:FireServer("Attack", {
                Point = pointHead,
                Combo = 1,
                Class = "Amateur",
                IsKnockdown = true,
                Character = user.Character,
                Hit = head,
                Limb = "LeftHand",
                Classs = game:GetService("HttpService"):GenerateGUID(true),
            }, false)
        end)
    end)
end

local teleportEnabled = false 
local teleportLoopRunning = false 

local function teleportBehind(targetRoot, offsetDistance)
    if targetRoot and targetRoot.Parent then
        local backOffset = targetRoot.CFrame.LookVector * -offsetDistance
        local newPos = targetRoot.Position + backOffset
        rootPart.CFrame = CFrame.new(newPos)
    end
end

local function hasSkipHighlight(player)
    if not player.Character then return false end
    for _, obj in ipairs(player.Character:GetDescendants()) do
        if obj:IsA("Highlight") then
            return true
        end
    end
    return false
end

local function followTarget(target)
    while teleportEnabled do
        if not target or not target.Parent then return end 
        local char = target.Character
        if not char or not char.Parent then return end 
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")
        if not humanoid or not root then return end
        if humanoid.Health <= 0 then return end 
        if hasSkipHighlight(target) then return end 

        teleportBehind(root, 0.5)
        attack(target)
        task.wait(0.03)
    end
end

local function teleportLoop()
    if teleportLoopRunning then return end 
    teleportLoopRunning = true
    while teleportEnabled do
        local players = Players:GetPlayers()
        for _, target in ipairs(players) do
            if not teleportEnabled then break end 
            if target ~= LocalPlayer then
                local success, _ = pcall(function()
                    followTarget(target)
                end)
                if not success then
                    task.wait(0.05)
                end
            end
        end
        task.wait(0.05)
    end
    teleportLoopRunning = false
end

uis.InputBegan:Connect(function(key, processedevent)
    if key.KeyCode == Enum.KeyCode.V and not processedevent then
        enabled = not enabled
        if enabled then
            notify("KILL AURA STATUS", "KILL AURA IS ENABLED")
            killAuraLoop = task.spawn(function()
                while enabled do
                    task.wait(0.001)
                    pcall(function()
                        local character = LocalPlayer.Character
                        if not character then return end

                        local rootPart = character:FindFirstChild("HumanoidRootPart")
                        if not rootPart then return end

                        for _, plr in pairs(Players:GetPlayers()) do
                            if not table.find(whitelistedPlayers, plr) then
                                if plr ~= LocalPlayer and plr.Character and plr.Character.Humanoid.Health > 0 then
                                    local primaryPart = plr.Character:FindFirstChild("HumanoidRootPart")
                                    if primaryPart then
                                        local distance = (rootPart.Position - primaryPart.Position).Magnitude
                                        if distance < 40 then
                                            attack(plr)
                                            task.wait(0)
                                        end
                                    end
                                end
                            end
                        end
                    end)
                end
            end)
        else
            notify("KILL AURA STATUS", "KILL AURA IS DISABLED")
        end
    elseif not processedevent and key.KeyCode == Enum.KeyCode.C then
        teleportEnabled = not teleportEnabled
        if teleportEnabled then
            task.spawn(teleportLoop)
            notify("AUTOFARM","AUTOFARM IS ENABLED")
        else
            notify("AUTOFARM","AUTOFARM IS DISABLED")
        end
    end
end)

task.spawn(function()
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    local list = playerGui:WaitForChild("Main"):WaitForChild("Chat").Main.Core.CanvasGroup.List

    list.ChildAdded:Connect(function(child)
        pcall(function()
            if child.Name ~= "CHAT_CELL" then return end
            local label = child:FindFirstChild("Label", true)
            if not label then return end

            local msg = label.Text:lower()
            if not (msg:find(LocalPlayer.Name:lower()) or msg:find(LocalPlayer.DisplayName:lower())) then return end

            for _, v in pairs(game.Players:GetPlayers()) do
                if v == LocalPlayer then continue end
                if msg:find(v.Name:lower()) or msg:find(v.DisplayName:lower()) or msg:find(tostring(v.UserId)) then
                    if msg:find("/whitelist") then
                        if not table.find(whitelistedPlayers, v) then
                            table.insert(whitelistedPlayers, v)
                            notify("WHITELIST ADD","Added player to whitelist: "..v.DisplayName)
                        else
                            notify("WHITELIST INFO","Player is already whitelisted: "..v.DisplayName)
                        end
                    elseif msg:find("/blacklist") then
                        local idx = table.find(whitelistedPlayers, v)
                        if idx then
                            table.remove(whitelistedPlayers, idx)
                            notify("WHITELIST REMOVE","Removed player from whitelist: "..v.DisplayName)
                        else
                            notify("WHITELIST INFO","Player is not whitelisted: "..v.DisplayName)
                        end
                    elseif msg:find("/tpto") then
                        local targetPos = v.Character.PrimaryPart.Position
                        local tweenInfo = TweenInfo.new(3)
                        for i, e in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
                            if e:IsA("BasePart") then
                                task.spawn(function()
                                    local tween = TweenService:Create(
                                        e,
                                        TweenInfo.new(6, Enum.EasingStyle.Linear),
                                        {CFrame = CFrame.new(targetPos)}
                                    )
                                    tween:Play()
                                end)
                            end
                        end
                    elseif msg:find("/kill") then
                        task.spawn(function()
                            local startTime = os.clock()
                            local maxFollowTime = 9 
                            local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
                            local rootPart = character:WaitForChild("HumanoidRootPart")

                            while v and v.Character and v.Character.Humanoid.Health > 0 and v.Character:FindFirstChild("HumanoidRootPart") and os.clock() - startTime < maxFollowTime do
                                local targetRoot = v.Character.HumanoidRootPart
                                attack(v)
                                rootPart.CFrame = CFrame.new(targetRoot.Position - targetRoot.CFrame.LookVector * 2)
                                task.wait(0.03)
                            end
                        end)
                        break
                    end
                elseif msg:find("/vc") then
                    local success, result = pcall(function()
                        return httpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/18248633989/servers/Public?sortOrder=Asc&limit=100"))
                    end)
                    if success and result and result.data then
                        for i, v in ipairs(result.data) do
                            if v.playing < v.maxPlayers and v.id ~= game.JobId then
                                table.insert(servers, v.id)
                            end
                        end
                    end

                    if #servers > 0 then
                        local serverid = servers[math.random(1,#servers)]
                        TeleportService:TeleportToPlaceInstance(vcgameId, serverid, game.Players.LocalPlayer)
                    end
                end
            end
        end)
    end)
end)
