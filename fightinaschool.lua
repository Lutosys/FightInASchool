--FIGHTINASCHOOL SCRIPT--
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local rootPart = character:FindFirstChild("HumanoidRootPart")
local uis = game:GetService("UserInputService")
local enabled = false
local CoreGui = game:GetService("StarterGui")

local Live = workspace:FindFirstChild("Live")

local enabled = false

for i, v in pairs(getgc(true)) do
    if type(v) == "function" then
        local info = debug.getinfo(v)
        if info then
            if info.name == "UpdateStruggle" then
                hookfunction(v, function()
                    return
                end)
            end
        end
    end
end

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
                IsKnockdown = false,
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
                    task.wait(0)
                    local character = LocalPlayer.Character
                    if not character then task.wait(0.1) continue end
                    local rootPart = character:FindFirstChild("HumanoidRootPart")
                    if not rootPart then task.wait(0.1) continue end

                    for _, plr in pairs(Players:GetPlayers()) do
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
        else
            notify("KILL AURA STATUS", "KILL AURA IS DISABLED")
        end
    end
end)

game.Players.LocalPlayer.CharacterAdded:Connect(function(char)
    wait(1)
    for i, v in pairs(getgc(true)) do
        if type(v) == "function" then
            local info = debug.getinfo(v)
            if info then
                if info.name == "UpdateStruggle" then
                    hookfunction(v, function()
                        return
                    end)
                end
            end
        end
    end
end)
