local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local rootPart = character:FindFirstChild("HumanoidRootPart")
local uis = game:GetService("UserInputService")
local enabled = false
local CoreGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")

local Live = workspace:FindFirstChild("Live")

local enabled = false
local whitelistedPlayers = {}

local function hookUpdateStruggle()
    for i, v in pairs(getgc(true)) do
        if type(v) == "function" then
            local info = debug.getinfo(v)
            if info and info.name == "UpdateStruggle" then
                hookfunction(v, function() end)
            end
        end
    end
end

hookUpdateStruggle()

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(1)
    hookUpdateStruggle()
end)

local function notify(title, desc)
    CoreGui:SetCore("SendNotification", {Title = title, Text = desc})
end

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

local killAuraLoop
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
                                        if distance < 35 then
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
                                local tween = TweenService:Create(
                                    e,
                                    TweenInfo.new(6, Enum.EasingStyle.Linear),
                                    {CFrame = CFrame.new(targetPos)}
                                )
                                tween:Play()
                                notify("TELEPORT INFO",("TELEPORTING TO : "..v.DisplayName))
                                return
                            end
                        end
                    end
                end
            end
        end)
    end)
end)
