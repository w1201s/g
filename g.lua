local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")

local eventstore = {
    ToolCollect = ReplicatedStorage.Events.ToolCollect,
    ToyEvent = ReplicatedStorage.Events.ToyEvent,
    PlayerHiveCommand = ReplicatedStorage.Events.PlayerHiveCommand,
    ClaimHive = ReplicatedStorage.Events.ClaimHive
}

local mapstore = {
    HiddenStickers = Workspace.HiddenStickers,
    Flowers = Workspace.Flowers,
    Collectibles = Workspace.Collectibles,
    -- Snowflakes = Workspace.Particles.Snowflakes
}

local togglestore = {
    AutoDig = false,
    CollectHiddenStickers = false
}

local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/jensonhirst/Orion/main/source')))()

local Window = OrionLib:MakeWindow({
    Name = "☄Space Hub",
    HidePremium = false,
    SaveConfig = true,
    ConfigFolder = "Dev",
    IntroEnabled = false,
    IntroText = "☄Space Hub | RBscr1pts⭐"
})

local Farm = Window:MakeTab({
    Name = "Farm",
    Icon = "",
    PremiumOnly = false
})

local Event = Window:MakeTab({
    Name = "Event",
    Icon = "",
    PremiumOnly = false
})

local Mobs = Window:MakeTab({
	Name = "Mobs",
	Icon = "",
	PremiumOnly = false
})

local Items = Window:MakeTab({
	Name = "Items",
	Icon = "",
	PremiumOnly = false
})
wait(2)
local Player = Window:MakeTab({
	Name = "Misc",
	Icon = "",
	PremiumOnly = false
})

local Extra = Window:MakeTab({
	Name = "Extra",
	Icon = "",
	PremiumOnly = false
})
wait(1)
local Webhook = Window:MakeTab({
    Name = "Webhook",
    Icon = "",
    PremiumOnly = false
})

local Settings = Window:MakeTab({
    Name = "Settings",
    Icon = "",
    PremiumOnly = false
})


Settings:AddBind({
        Name = "Toggle Gui",
        Default = Enum.KeyCode.LeftControl,
        Hold = false,
        Callback = function()
            if game.CoreGui.Orion.Enabled == true then
                game.CoreGui.Orion.Enabled = false
            elseif game.CoreGui.Orion.Enabled == false then
                game.CoreGui.Orion.Enabled = true
            end
        end 
    })


--Farm / Two
local Section = Farm:AddSection({
	Name = "Farm"
})

Farm:AddToggle({
    Name = "Auto Dig",
    Default = false,
    Save = true,
    Callback = function(Value)
        togglestore.AutoDig = Value
        if Value then
            startAutoDig()
        end
    end    
})

function startAutoDig()
    spawn(function()
        while true do
            if togglestore.AutoDig then
                eventstore.ToolCollect:FireServer()
            end
            task.wait(0.09)
        end
    end)
end


local selectedField = "nil"
local selectedFarm = "nil"
local farmRadius = 40

local fieldPositions = {
    ["BamBoo Field"] = CFrame.new(93, 20, -25),
    ["Blue Field"] = CFrame.new(113.7, 4, 101.5),
    ["Cactus Field"] = CFrame.new(-194, 68, -107),
    ["Clover Field"] = CFrame.new(174, 34, 189),
    ["Coconut Field"] = CFrame.new(-255, 72, 459),
    ["Dandelion Field"] = CFrame.new(-30, 4, 225),
    ["Stump Field"] = CFrame.new(420, 117, -178),
    ["MountainTop Field"] = CFrame.new(76, 176, -181),
    ["Mushroom Field"] = CFrame.new(-91, 4, 116),
    ["Pepper Patch"] = CFrame.new(-486, 124, 517),
    ["Pineapple Field"] = CFrame.new(262, 68, -201),
    ["PineTree Field"] = CFrame.new(-338, 69, -180),
    ["Pumpkin Field"] = CFrame.new(-186, 68.5, -194),
    ["Rose Field"] = CFrame.new(-322, 20, 124),
    ["Spider Field"] = CFrame.new(-57.2, 20, -5.3),
    ["StrawBerry Field"] = CFrame.new(-179, 20, -14),
    ["Sunflower Field"] = CFrame.new(-208, 4, 185)
}

local farmPriorities = {
    "Coconuts",
    "Flames",
    "Bubbles",
    "Balloons"
}

Farm:AddDropdown({
    Name = "Select Field",
    Default = "nil",
    Save = true,
    Options = {"BamBoo Field", "Blue Field", "Cactus Field", "Clover Field", "Coconut Field", "Dandelion Field", "Stump Field", "MountainTop Field", "Mushroom Field", "Pepper Patch", "Pineapple Field", "PineTree Field", "Pumpkin Field", "Rose Field", "Spider Field", "StrawBerry Field", "Sunflower Field"},
    Callback = function(Value)
        selectedField = Value
    end
})

Farm:AddDropdown({
    Name = "Select Farm Mode",
    Default = "Walk",
    Save = true,
    Options = {"Tween", "TweenFast", "Walk"},
    Callback = function(Value)
        selectedFarm = Value
    end
})

Farm:AddToggle({
    Name = "Farm Coconuts",
    Default = false,
    Callback = function(Value)
        shared.farmCoconuts = Value
    end
})

Farm:AddToggle({
    Name = "Farm Flames",
    Default = false,
    Callback = function(Value)
        shared.farmFlames = Value
    end
})

Farm:AddToggle({
    Name = "Farm Bubbles",
    Default = false,
    Callback = function(Value)
        shared.farmBubbles = Value
    end
})

Farm:AddToggle({
    Name = "Farm Balloons",
    Default = false,
    Callback = function(Value)
        shared.farmBalloons = Value
    end
})

function isWithinFieldRadius(position, fieldPosition)
    return (position - fieldPosition).Magnitude <= farmRadius
end

function findNearestCrosshair(currentPosition)
    local nearestCrosshair = nil
    local shortestDistance = math.huge
    for _, crosshair in pairs(game.Workspace.Particles:GetChildren()) do
        if crosshair.Name == "Crosshair" and crosshair:IsA("Part") then
            local distance = (crosshair.Position - currentPosition).Magnitude
            if distance < shortestDistance then
                nearestCrosshair = crosshair
                shortestDistance = distance
            end
        end
    end
    return nearestCrosshair
end

function findNearestFlame(currentPosition)
    local nearestFlame = nil
    local shortestDistance = math.huge
    for _, flame in pairs(workspace.PlayerFlames:GetChildren()) do
        local distance = (flame.Position - currentPosition).Magnitude
        if distance < shortestDistance then
            nearestFlame = flame
            shortestDistance = distance
        end
    end
    return nearestFlame
end

function findNearestBubble(currentPosition)
    local nearestBubble = nil
    local shortestDistance = math.huge
    for _, bubble in pairs(workspace.Particles:GetChildren()) do
        if bubble.Name == "Bubble" and bubble:IsA("Part") then
            local distance = (bubble.Position - currentPosition).Magnitude
            if distance < shortestDistance then
                nearestBubble = bubble
                shortestDistance = distance
            end
        end
    end
    return nearestBubble
end

function findNearestBalloon(currentPosition)
    local nearestBalloon = nil
    local shortestDistance = math.huge
    local balloonPosition = nil

    for _, balloon in pairs(workspace.Balloons.FieldBalloons:GetChildren()) do
        local balloonBody = balloon:FindFirstChild("BalloonBody")
        if balloonBody then
            local distance = (balloonBody.Position - currentPosition).Magnitude
            if distance <= farmRadius and distance < shortestDistance then
                nearestBalloon = balloonBody
                shortestDistance = distance
                balloonPosition = balloonBody.Position
            end
        end
    end

    return nearestBalloon, balloonPosition
end

function findNearestCoconut(currentPosition)
    local nearestCoconut = nil
    local shortestDistance = math.huge
    for _, coconut in pairs(workspace.Particles:GetChildren()) do
        if coconut.Name == "WarningDisk" and coconut:IsA("Part") then
            local distance = (coconut.Position - currentPosition).Magnitude
            if distance < shortestDistance then
                nearestCoconut = coconut
                shortestDistance = distance
            end
        end
    end
    return nearestCoconut
end

function getFarmTargets(currentPosition, spawnPosition)
    local targets = {}
    
    for _, priority in ipairs(farmPriorities) do
        if priority == "Coconuts" and shared.farmCoconuts then
            local nearestCoconut = findNearestCoconut(currentPosition)
            if nearestCoconut and isWithinFieldRadius(nearestCoconut.Position, spawnPosition.Position) then
                table.insert(targets, nearestCoconut)
            end
        elseif priority == "Balloons" and shared.farmBalloons then
            local nearestBalloon, balloonPosition = findNearestBalloon(currentPosition)
            if nearestBalloon and balloonPosition then
                table.insert(targets, nearestBalloon)
            end
        elseif priority == "Flames" and shared.farmFlames then
            local nearestFlame = findNearestFlame(currentPosition)
            if nearestFlame and isWithinFieldRadius(nearestFlame.Position, spawnPosition.Position) then
                table.insert(targets, nearestFlame)
            end
        elseif priority == "Bubbles" and shared.farmBubbles then
            local nearestBubble = findNearestBubble(currentPosition)
            if nearestBubble and isWithinFieldRadius(nearestBubble.Position, spawnPosition.Position) then
                table.insert(targets, nearestBubble)
            end
        elseif priority == "Crosshair" and shared.farmCrosshair then
            local nearestCrosshair = findNearestCrosshair(currentPosition)
            if nearestCrosshair then table.insert(targets, nearestCrosshair) end
        end
    end
    
    return targets
end

function waitAfterCoconut(player, position)
    task.wait(3)
end

function startTweenFarm()
    spawn(function()
        while shared.a11 do
            local player = game.Players.LocalPlayer
            local tweenService = game:GetService("TweenService")
            local info = TweenInfo.new(0.5)
        
            local currentPosition = player.Character.HumanoidRootPart.Position
            local spawnPosition = fieldPositions[selectedField]
            local distance = (currentPosition - spawnPosition.Position).Magnitude

            if distance > farmRadius then
                player.Character.HumanoidRootPart.CFrame = spawnPosition
            end

            local targets = getFarmTargets(currentPosition, spawnPosition)
            
            if #targets > 0 then
                for _, target in ipairs(targets) do
                    local targetPosition = target.Position
                    local targetCFrame = CFrame.new(targetPosition.X, player.Character.HumanoidRootPart.Position.Y, targetPosition.Z)
                    local tween = tweenService:Create(player.Character.HumanoidRootPart, info, {CFrame = targetCFrame})
                    tween:Play()
                    tween.Completed:Wait()
                    
                    if target.Name == "WarningDisk" then
                        waitAfterCoconut(player, targetPosition)
                    end
                end
            else
                for _, collectible in pairs(workspace.Collectibles:GetChildren()) do
                    if collectible.Transparency == 0 and isWithinFieldRadius(collectible.Position, spawnPosition.Position) then
                        local targetPosition = collectible.Position
                        local targetCFrame = CFrame.new(targetPosition.X, player.Character.HumanoidRootPart.Position.Y, targetPosition.Z)
                        local tween = tweenService:Create(player.Character.HumanoidRootPart, info, {CFrame = targetCFrame})
                        tween:Play()
                        tween.Completed:Wait()
                    end
                end
            end

            task.wait(0.01)
        end
    end)
end

function startTweenFastFarm()
    spawn(function()
        while shared.a12 do
            local player = game.Players.LocalPlayer
            local tweenService = game:GetService("TweenService")
            local info = TweenInfo.new(0.2)
        
            local currentPosition = player.Character.HumanoidRootPart.Position
            local spawnPosition = fieldPositions[selectedField]
            local distance = (currentPosition - spawnPosition.Position).Magnitude

            if distance > farmRadius then
                player.Character.HumanoidRootPart.CFrame = spawnPosition
            end

            local targets = getFarmTargets(currentPosition, spawnPosition)
            
            if #targets > 0 then
                for _, target in ipairs(targets) do
                    local targetPosition = target.Position
                    local targetCFrame = CFrame.new(targetPosition.X, player.Character.HumanoidRootPart.Position.Y, targetPosition.Z)
                    local tween = tweenService:Create(player.Character.HumanoidRootPart, info, {CFrame = targetCFrame})
                    tween:Play()
                    tween.Completed:Wait()
                    
                    if target.Name == "WarningDisk" then
                        waitAfterCoconut(player, targetPosition)
                    end
                end
            else
                for _, collectible in pairs(workspace.Collectibles:GetChildren()) do
                    if collectible.Transparency == 0 and isWithinFieldRadius(collectible.Position, spawnPosition.Position) then
                        local targetPosition = collectible.Position
                        local targetCFrame = CFrame.new(targetPosition.X, player.Character.HumanoidRootPart.Position.Y, targetPosition.Z)
                        local tween = tweenService:Create(player.Character.HumanoidRootPart, info, {CFrame = targetCFrame})
                        tween:Play()
                        tween.Completed:Wait()
                    end
                end
            end

            task.wait(0.01)
        end
    end)
end

function startWalkFarm()
    spawn(function()
        while shared.a13 do
            local player = game.Players.LocalPlayer
            local character = player.Character
            local humanoid = character:FindFirstChild("Humanoid")
            
            local currentPosition = character.HumanoidRootPart.Position
            local spawnPosition = fieldPositions[selectedField]
            local distance = (currentPosition - spawnPosition.Position).Magnitude

            if distance > farmRadius then
                character.HumanoidRootPart.CFrame = spawnPosition
            end

            local targets = getFarmTargets(currentPosition, spawnPosition)
            
            if #targets > 0 then
                for _, target in ipairs(targets) do
                    humanoid:MoveTo(Vector3.new(target.Position.X, character.HumanoidRootPart.Position.Y, target.Position.Z))
                    humanoid.MoveToFinished:Wait()
                    
                    if target.Name == "WarningDisk" then
                        waitAfterCoconut(player, target.Position)
                    end
                end
            else
                for _, collectible in pairs(workspace.Collectibles:GetChildren()) do
                    if collectible.Transparency == 0 and isWithinFieldRadius(collectible.Position, spawnPosition.Position) then
                        humanoid:MoveTo(Vector3.new(collectible.Position.X, character.HumanoidRootPart.Position.Y, collectible.Position.Z))
                        humanoid.MoveToFinished:Wait()
                    end
                end
            end

            task.wait(0.1)
        end
    end)
end

Farm:AddToggle({
    Name = "Auto Farm",
    Default = false,
    Save = true,
    Callback = function(Value)
        if Value then
            if selectedFarm == "Tween" then
                shared.a11 = true
                startTweenFarm()
            elseif selectedFarm == "TweenFast" then
                shared.a12 = true
                startTweenFastFarm()
            elseif selectedFarm == "Walk" then
                shared.a13 = true
                startWalkFarm()
            end
        else
            shared.a11 = false
            shared.a12 = false
            shared.a13 = false
        end
    end
})




local sellMethod = "Tween"
local isSelling = false

Farm:AddToggle({
    Name = "Auto Sell",
    Default = false,
    Callback = function(Value)
        shared.autoSell = Value
        if shared.autoSell then
            spawn(function()
                while shared.autoSell do
                    local player = game.Players.LocalPlayer
                    local capacity = player.CoreStats.Capacity.Value
                    local pollen = player.CoreStats.Pollen.Value

                    if pollen >= capacity * 0.99 then
                        local originalPosition = player.Character.HumanoidRootPart.CFrame
                        local wasAutoFarming = shared.a11 or shared.a12 or shared.a13
                        local hiveNumber = tostring(player.Honeycomb.Value)

                        shared.a11, shared.a12, shared.a13 = false, false, false

                        local sellPosition = workspace.Honeycombs[hiveNumber].LightHolder.CFrame * CFrame.new(0, -5, -5)

                        -- Проверка, что игрок стоит на земле
                        local raycastParams = RaycastParams.new()
                        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
                        raycastParams.FilterDescendantsInstances = {player.Character}
                        local raycastResult = workspace:Raycast(player.Character.HumanoidRootPart.Position, Vector3.new(0, -100, 0), raycastParams)
                        if raycastResult then
                            sellPosition = CFrame.new(raycastResult.Position) * CFrame.new(0, 3, 0)
                        end

                        local tweenService = game:GetService("TweenService")
                        local tweenInfo = TweenInfo.new(1, Enum.EasingStyle.Linear)
                        local tween = tweenService:Create(player.Character.HumanoidRootPart, tweenInfo, {CFrame = sellPosition})
                        tween:Play()
                        tween.Completed:Wait()
                        task.wait(0)

                        isSelling = true

                        local sellConnection
                        sellConnection = game:GetService("RunService").Heartbeat:Connect(function()
                            if isSelling then
                                player.Character.HumanoidRootPart.CFrame = sellPosition
                            else
                                sellConnection:Disconnect()
                            end
                        end)

                        repeat
                            local buttonText = player.PlayerGui.ScreenGui.ActivateButton.TextBox.Text
                            if buttonText == 'Make Honey' then
                                game.ReplicatedStorage.Events.PlayerHiveCommand:FireServer("ToggleHoneyMaking")
                            end
                            task.wait(0)
                        until player.CoreStats.Pollen.Value == 0 or not shared.autoSell

                        task.wait(8)
                        isSelling = false

                        if shared.autoSell and player.CoreStats.Pollen.Value < capacity * 0.1 then
                            if wasAutoFarming then
                                if selectedFarm == "Tween" then
                                    shared.a11 = true
                                    startTweenFarm()
                                elseif selectedFarm == "TweenFast" then
                                    shared.a12 = true
                                    startTweenFastFarm()
                                elseif selectedFarm == "Walk" then
                                    shared.a13 = true
                                    startWalkFarm()
                                end
                            else
                                player.Character.HumanoidRootPart.CFrame = originalPosition
                            end
                        end
                    end
                    task.wait(0)
                end
            end)
        end
    end    
})


Farm:AddToggle({
    Name = "Auto Place Splinkler",
    Default = false,
    Callback = function(cointr)
         getgenv().turnoff4 = cointr
         while turnoff4 == true do 
local A = {["Name"] = "Sprinkler Builder"}
local Event = game:GetService("ReplicatedStorage").Events.PlayerActivesCommand
Event:FireServer(A)
            wait(30) end
    end    
})

local Section = Farm:AddSection({
	Name = "Other"
})

Farm:AddToggle({
    Name = "Auto Use Micro-Converter",
    Default = false,
    Callback = function(cointr)
         getgenv().turnoff4 = cointr
         while turnoff4 == true do
local player = game:GetService("Players").LocalPlayer
local pollenLbl = player.Character:FindFirstChild("ProgressLabel",true)
local maxpollen = tonumber(pollenLbl.Text:match("%d+$"))
wait(0.1)                                                                       
if player.CoreStats.Pollen.Value>=maxpollen then
local Ass = {["Name"] = "Micro-Converter"}
Event = game:GetService("ReplicatedStorage").Events.PlayerActivesCommand
Event:FireServer(Ass)
end
end
end
})
Farm:AddToggle({
    Name = "Auto Use Instant Converter",
    Default = false,
    Callback = function(cointr)
         getgenv().turnoff4 = cointr
         while turnoff4 == true do
local player = game:GetService("Players").LocalPlayer
local pollenLbl = player.Character:FindFirstChild("ProgressLabel",true)
local maxpollen = tonumber(pollenLbl.Text:match("%d+$"))
wait(0.3)
if player.CoreStats.Pollen.Value>=maxpollen then do
local zakharpidor = {[1] = "Instant Converter"}
game:GetService("ReplicatedStorage").Events.ToyEvent:FireServer(unpack(zakharpidor))
end
wait(0.3)
elseif player.CoreStats.Pollen.Value>=maxpollen then do
zakharpidor = {[1] = "Instant Converter B"}
game:GetService("ReplicatedStorage").Events.ToyEvent:FireServer(unpack(zakharpidor))
wait(0.3) end
elseif player.CoreStats.Pollen.Value>=maxpollen then do
zakharpidor = {[1] = "Instant Converter C"}
game:GetService("ReplicatedStorage").Events.ToyEvent:FireServer(unpack(zakharpidor))
end
end
end
end})

Farm:AddToggle({
    Name = "Auto Use Coconut",
    Default = false,
    Callback = function(cointr)
         getgenv().turnoff4 = cointr
         while turnoff4 == true do 
local Coconut = {["Name"] = "Coconut"}
Event = game:GetService("ReplicatedStorage").Events.PlayerActivesCommand
Event:FireServer(Coconut)
            wait(11) end
        end
})
Farm:AddToggle({
    Name = "Auto Use Gumdrops",
    Default = false,
    Callback = function(cointr)
         getgenv().turnoff4 = cointr
         while turnoff4 == true do
local Gumdrops = {["Name"] = "Gumdrops"}
Event = game:GetService("ReplicatedStorage").Events.PlayerActivesCommand
Event:FireServer(Gumdrops)
wait(3)
end
end
})

local Section = Extra:AddSection({
	Name = "Mask"
})

Extra:AddDropdown({
    Name = "Equip Mask",
    Default = "nil",
    Options = {"Gummy Mask","Demon Mask","Diamond Mask","Bubble Mask","Fire Mask","Honey Mask",},
    Callback = function(Value)
if Value == "Gummy Mask" then 
A_1 = "Equip"
A_2 = {["Mute"] = true
    , ["Type"] = "Gummy Mask", ["Category"] = "Accessory"}
Event = game:GetService("ReplicatedStorage").Events.ItemPackageEvent
Event:InvokeServer(A_1, A_2)
elseif Value == "Demon Mask" then
A_3 = "Equip"
A_4 = {["Mute"] = true
    , ["Type"] = "Demon Mask", ["Category"] = "Accessory"}
Event = game:GetService("ReplicatedStorage").Events.ItemPackageEvent
Event:InvokeServer(A_3, A_4)
elseif Value == "Diamond Mask" then
A_5 = "Equip"
A_6 = {["Mute"] = true
    , ["Type"] = "Diamond Mask", ["Category"] = "Accessory"}
Event = game:GetService("ReplicatedStorage").Events.ItemPackageEvent
Event:InvokeServer(A_5, A_6)
elseif Value == "Bubble Mask" then
A_7 = "Equip"
A_8 = {["Mute"] = true
    , ["Type"] = "Bubble Mask", ["Category"] = "Accessory"}
Event = game:GetService("ReplicatedStorage").Events.ItemPackageEvent
Event:InvokeServer(A_7, A_8)
elseif Value == "Fire Mask" then
A_9 = "Equip"
A_10 = {["Mute"] = true
    , ["Type"] = "Fire Mask", ["Category"] = "Accessory"}
Event = game:GetService("ReplicatedStorage").Events.ItemPackageEvent
Event:InvokeServer(A_9, A_10)
elseif Value == "Honey Mask" then 
A_11 = "Equip"
A_12 = {["Mute"] = true
    , ["Type"] = "Honey Mask", ["Category"] = "Accessory"}
Event = game:GetService("ReplicatedStorage").Events.ItemPackageEvent
Event:InvokeServer(A_11, A_12)
end
end
})



-- BeeSmas





-- Player / Four

local speedEnabled = false
local jumpEnabled = false
local originalSpeed
local originalJumpPower
local currentSpeed
local currentJumpPower

local function getOriginalValues()
    local character = game.Players.LocalPlayer.Character or game.Players.LocalPlayer.CharacterAdded:Wait()
    originalSpeed = character.Humanoid.WalkSpeed
    originalJumpPower = character.Humanoid.JumpPower
end

getOriginalValues()

local Section = Player:AddSection({
    Name = "Player Speed"
})

Player:AddToggle({
	Name = "Enable Speed",
	Default = false,
	Callback = function(Value)
		speedEnabled = Value
		if not speedEnabled then
			game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = originalSpeed
		end
	end    
})

Player:AddTextbox({
    Name = "Set Speed 1-150",
    Default = tostring(math.floor(originalSpeed)),
    TextDisappear = true,
    Callback = function(Value)
        local inputSpeed = tonumber(Value)
        if inputSpeed and inputSpeed >= 1 and inputSpeed <= 150 then
            currentSpeed = math.floor(inputSpeed)
            Player.Character.Humanoid.WalkSpeed = currentSpeed
        end
    end
})

local Section = Player:AddSection({
    Name = "Player Jump Power"
})

Player:AddToggle({
	Name = "Enable Jump Power",
	Default = false,
	Callback = function(Value)
		jumpEnabled = Value
		if not jumpEnabled then
			game.Players.LocalPlayer.Character.Humanoid.JumpPower = originalJumpPower
		end
	end    
})

Player:AddTextbox({
    Name = "Set Jump Power 1-200",
    Default = tostring(math.floor(originalJumpPower)),
    TextDisappear = true,
    Callback = function(Value)
        local inputJumpPower = tonumber(Value)
        if inputJumpPower and inputJumpPower >= 1 and inputJumpPower <= 200 then
            currentJumpPower = math.floor(inputJumpPower)
            Player.Character.Humanoid.JumpPower = currentJumpPower
        end
    end
})

game:GetService("RunService").Heartbeat:Connect(function()
    if speedEnabled then
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = currentSpeed
    end
    if jumpEnabled then
        game.Players.LocalPlayer.Character.Humanoid.JumpPower = currentJumpPower
    end
end)

local Section = Player:AddSection({
	Name = "Misc"
})

local noclipEnabled = false

Player:AddToggle({
	Name = "Noclip",
	Default = false,
	Callback = function(Value)
		noclipEnabled = Value
	end    
})

togglestore.CollectHiddenStickers = false

Player:AddButton({
	Name = "Collect Hidden Stickers",
	Callback = function()
        togglestore.CollectHiddenStickers = true

        if togglestore.CollectHiddenStickers then
            for i, v in mapstore.HiddenStickers:GetChildren() do
                fireclickdetector(v.ClickDetector)
            end
        end
  	end    
})

game:GetService('RunService').Stepped:Connect(function()
    if noclipEnabled then
        for _, part in pairs(game.Players.LocalPlayer.Character:GetDescendants()) do
            if part:IsA('BasePart') and part.CanCollide then
                part.CanCollide = false
            end
        end
    end
end)

-- Teleports | Four

local Section = Extra:AddSection({
    Name = "Teleports"
})

Extra:AddButton({
	Name = "TP To Hive",
	Callback = function()
    local player = game:GetService("Players").LocalPlayer
    player.Character:MoveTo(player.SpawnPos.Value.p)
  	end    
})

Extra:AddDropdown({
    Name = "Teleport To Shop - ",
    Default = "nil",
    Options = {"Bee Shop","First Tool Shop","Second Tool Shop (15+ bees)","MountainTop Shop (25+ bees)","Spirit Shop (35+ bees)","Dapper Bear's Shop","GumBall Shop","Blue Clubhouse","Red Clubhouse","Ticket Shop","RoyalJelly Shop","Ticket RoyalJelly Shop","Treat Shop","Moon","Nuoc"},
    Callback = function(Value)
if Value == "Bee Shop" then 
game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-136.8, 4.6, 243.4)
elseif Value == "First Tool Shop" then game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(86, 4.6, 294)
elseif Value == "Second Tool Shop (10+ bees)" then game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(165, 69, -161)
elseif Value == "MountainTop Shop (25+ bees)" then game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-18, 176, -137)
elseif Value == "Spirit Shop (35+ bees)" then game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-501, 52, 474)
elseif Value == "Dapper Bear's Shop" then game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(456.7, 137.9, -313.8)
elseif Value == "GumBall Shop" then game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(269, 25257.55, -724.2)
elseif Value == "Blue Clubhouse" then game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(292, 4, 98)
elseif Value == "Red Clubhouse" then game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-334, 21, 216)
elseif Value == "Ticket Shop" then game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-12.8, 184, -222.2)
elseif Value == "RoyalJelly Shop" then game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-297, 53, 68)
elseif Value == "Ticket RoyalJelly Shop" then game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(81, 18, 240)
elseif Value == "Treat Shop" then game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-228.2, 5, 89.4)
elseif Value == "Moon" then game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(21,88,-54)
elseif Value == "Nuoc" then game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-426,70,38)
end
end
})


Extra:AddDropdown({
    Name = "Teleport To Bear - ",
    Default = "nil",
    Options = {"Black Bear","Brown Bear","Panda Bear","Polar Bear","Science Bear","Mother Bear","Spirit Bear","Gummy Bear","Onett","Tunnel Bear","Stick Bug",},
    Callback = function(Value)
if Value == "Black Bear" then 
game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-258.1, 5, 299.7) 
elseif Value == "Brown Bear" then game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(282, 46, 236) 
elseif Value == "Panda Bear" then game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(106.3, 35, 50.1) 
elseif Value == "Polar Bear" then game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-106, 119, -77)
elseif Value == "Science Bear" then game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(267, 103, 20)
elseif Value == "Mother Bear" then game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-183.898, 5.64093, 83.4582)
elseif Value == "Spirit Bear" then game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-363.936, 105.284, 485.853)
elseif Value == "Gummy Bear" then game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(271.624, 25292.9, -850.958) 
elseif Value == "Tunnel Bear" then game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(313.654, 6.81172, -46.9131)
elseif Value == "Onett" then game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-9.41592, 232.791, -520.278)
elseif Value == "Stick Bug" then game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-129.2, 50.0709, 148.288)
end
end
})

Extra:AddDropdown({
    Name = "Teleport To Field - ",
    Default = "nil",
    Options = {"BamBoo Field","Blue Field","Cactus Field","Clover Field","Coconut Field","Dandelion Field","Stump Field","MountainTop Field","Mushroom Field","Pepper Patch","Pineapple Field","PineTree Field","Pumpkin Field","Rose Field","Spider Field","StrawBerry Field","Sunflower Field",},
    Callback = function(Value)
if Value == "BamBoo Field" then 
game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(93, 20, -25)
elseif Value == "Blue Field" then game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(113.7, 4, 101.5)
elseif Value == "Cactus Field" then game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-194, 68, -107)
elseif Value == "Clover Field" then game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(174, 34, 189)
elseif Value == "Coconut Field" then game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-255,72,459)
elseif Value == "Dandelion Field" then game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-30, 4, 225)
elseif Value == "Stump Field" then game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(420,117,-178)
elseif Value == "MountainTop Field" then game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(76, 176, -181)
elseif Value == "Mushroom Field" then game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-91, 4, 116)
elseif Value == "Pepper Patch" then game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-486,124,517)
elseif Value == "Pineapple Field" then game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(262, 68, -201)
elseif Value == "PineTree Field" then game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-318, 68, -150)
elseif Value == "Pumpkin Field" then game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-486,124,517)
elseif Value == "Pineapple Field" then game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-194, 68, -182)
elseif Value == "Rose Field" then game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-322, 20, 124)
elseif Value == "Spider Field" then game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-57.2, 20, -5.3)
elseif Value == "StrawBerry Field" then game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(262, 68, -201)
elseif Value == "Sunflower Field" then game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-208, 4, 185)
end
end
})

Extra:AddDropdown({
    Name = "Teleport To Booster - ",
    Default = "nil",
    Options = {"Ant","Bluefield Boost","Blueberry Dispenser","Club Honey","Gumdrop Dispenser","Glue Dispenser","Honeystorm Dispensor","Instant Honey Convertor","MountainTop Boost","Nectar Condenser","Redfield Boost","Sprout Dispenser","Star Hut","Strawberry Dispenser","Treat Dispenser",},
    Callback = function(Value)
if Value == "Ant" then 
game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(125, 32, 495)
elseif Value == "Blue Field" then game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(113.7, 4, 101.5)
elseif Value == "Bluefield Boost" then game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(272, 58, 86)
elseif Value == "Blueberry Dispenser" then game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(307, 5, 134)
elseif Value == "Club Honey" then game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(44.8, 5, 319.6)
elseif Value == "Gumdrop Dispenser" then game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(68, 21.8, 26)
elseif Value == "Glue Dispenser" then game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(269, 25257.546875, -724)
elseif Value == "Honeystorm Dispensor" then game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(238.4, 33.3, 165.6)
elseif Value == "Instant Honey Convertor" then game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(282, 68, -62)
elseif Value == "MountainTop Boost" then game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-40, 176, -191.7)
elseif Value == "Nectar Condenser" then game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-416.7, 101.5, 342.8)
elseif Value == "Redfield Boost" then game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-315.5, 21, 240)
elseif Value == "Sprout Dispenser" then game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-269.26, 26.56, 267.31)
elseif Value == "Star Hut" then game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(135.9, 64.6, 322.1)
elseif Value == "Strawberry Dispenser" then game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-320.5, 46, 272.5)
elseif Value == "Treat Dispenser" then game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(193.9, 68, -123)
end
end
})

local Section = Items:AddSection({
    Name = "Dispensers"
})

Items:AddButton({
	Name = "Use All Dispensers",
	Callback = function()
      local A_1 = "Glue Dispenser"
                  Event = game:GetService("ReplicatedStorage").Events.ToyEvent
                  Event:FireServer(A_1)
                  A_1 = "Gingerbread House"
                  Event = game:GetService("ReplicatedStorage").Events.ToyEvent
                  Event:FireServer(A_1)
                  A_1 = "Wealth Clock"
                  Event = game:GetService("ReplicatedStorage").Events.ToyEvent
                  Event:FireServer(A_1)
                  A_1 = "Coconut Dispenser"
                  Event = game:GetService("ReplicatedStorage").Events.ToyEvent
                  Event:FireServer(A_1)
                  A_1 = "Strawberry Dispenser"
                  Event = game:GetService("ReplicatedStorage").Events.ToyEvent
                  Event:FireServer(A_1)
                  A_1 = "Treat Dispenser"
                  Event = game:GetService("ReplicatedStorage").Events.ToyEvent
                  Event:FireServer(A_1)
                  A_1 = "Free Ant Pass Dispenser"
                  Event = game:GetService("ReplicatedStorage").Events.ToyEvent
                  Event:FireServer(A_1)
                  A_1 = "Blueberry Dispenser"
                  Event = game:GetService("ReplicatedStorage").Events.ToyEvent
                  Event:FireServer(A_1)
                  A_1 = "Honey Dispenser"
                  Event = game:GetService("ReplicatedStorage").Events.ToyEvent
                  Event:FireServer(A_1)
                  A_1 = "Free Royal Jelly Dispenser"
                  Event = game:GetService("ReplicatedStorage").Events.ToyEvent
                  Event:FireServer(A_1)
                  end
})

Items:AddToggle({
    Name = "Auto Use All Dispensers",
    Default = false,
    Callback = function(cointr)
         getgenv().turnoff5 = cointr
         while turnoff5 == true do 
             local A_1 = "Glue Dispenser"
                  Event = game:GetService("ReplicatedStorage").Events.ToyEvent
                  Event:FireServer(A_1)
                  A_1 = "Wealth Clock"
                  Event = game:GetService("ReplicatedStorage").Events.ToyEvent
                  Event:FireServer(A_1)
                  A_1 = "Coconut Dispenser"
                  Event = game:GetService("ReplicatedStorage").Events.ToyEvent
                  Event:FireServer(A_1)
                  A_1 = "Strawberry Dispenser"
                  Event = game:GetService("ReplicatedStorage").Events.ToyEvent
                  Event:FireServer(A_1)
                  A_1 = "Treat Dispenser"
                  Event = game:GetService("ReplicatedStorage").Events.ToyEvent
                  Event:FireServer(A_1)
                  A_1 = "Free Ant Pass Dispenser"
                  Event = game:GetService("ReplicatedStorage").Events.ToyEvent
                  Event:FireServer(A_1)
                  A_1 = "Blueberry Dispenser"
                  Event = game:GetService("ReplicatedStorage").Events.ToyEvent
                  Event:FireServer(A_1)
                  A_1 = "Honey Dispenser"
                  Event = game:GetService("ReplicatedStorage").Events.ToyEvent
                  Event:FireServer(A_1)
                  A_1 = "Free Royal Jelly Dispenser"
                  Event = game:GetService("ReplicatedStorage").Events.ToyEvent
                  Event:FireServer(A_1)
                  wait(10)
            end
            end
})
Items:AddButton({
	Name = "Use Glue Dispenser",
	Callback = function()
            local A_1 = "Glue Dispenser"
                  Event = game:GetService("ReplicatedStorage").Events.ToyEvent
                  Event:FireServer(A_1)
  	end    
})
Items:AddToggle({
    Name = "Auto Use Glue Dispenser",
    Default = false,
    Callback = function(cointr)
         getgenv().turnoff4 = cointr
         while turnoff4 == true do 
local A_1 = "Glue Dispenser"
local Event = game:GetService("ReplicatedStorage").Events.ToyEvent
Event:FireServer(A_1)
            wait(10) end
    end    
})
Items:AddButton({
	Name = "Use Wealth Clock",
	Callback = function()
   A_1 = "Wealth Clock"
Event = game:GetService("ReplicatedStorage").Events.ToyEvent
Event:FireServer(A_1)
  	end    
})
Items:AddToggle({
    Name = "Auto Use Wealth Clock",
    Default = false,
    Callback = function(cointr)
         getgenv().turnoff4 = cointr
         while turnoff4 == true do 
A_1 = "Wealth Clock"
Event = game:GetService("ReplicatedStorage").Events.ToyEvent
Event:FireServer(A_1)
            wait(10) end
    end    
})
Items:AddButton({
	Name = "Use Coconut Dispenser",
	Callback = function()
                  A_1 = "Coconut Dispenser"
                  Event = game:GetService("ReplicatedStorage").Events.ToyEvent
                  Event:FireServer(A_1)
  	end    
})
Items:AddToggle({
    Name = "Auto Use Coconut Dispenser",
    Default = false,
    Callback = function(cointr)
         getgenv().turnoff4 = cointr
         while turnoff4 == true do 
A_1 = "Coconut Dispenser"
Event = game:GetService("ReplicatedStorage").Events.ToyEvent
Event:FireServer(A_1)
            wait(10) end
    end    
})
Items:AddButton({
	Name = "Use Strawberry Dispenser",
	Callback = function()
                  A_1 = "Strawberry Dispenser"
                  Event = game:GetService("ReplicatedStorage").Events.ToyEvent
                  Event:FireServer(A_1)
  	end    
})
Items:AddToggle({
    Name = "Auto Use Strawberry Dispenser",
    Default = false,
    Callback = function(cointr)
         getgenv().turnoff4 = cointr
         while turnoff4 == true do 
A_1 = "Strawberry Dispenser"
Event = game:GetService("ReplicatedStorage").Events.ToyEvent
Event:FireServer(A_1)
            wait(10) end
    end    
})
Items:AddButton({
	Name = "Use Treat Dispenser",
	Callback = function()
                  A_1 = "Treat Dispenser"
                  Event = game:GetService("ReplicatedStorage").Events.ToyEvent
                  Event:FireServer(A_1)
  	end    
})
Items:AddToggle({
    Name = "Auto Use Treat Dispenser",
    Default = false,
    Callback = function(cointr)
         getgenv().turnoff4 = cointr
         while turnoff4 == true do 
A_1 = "Treat Dispenser"
Event = game:GetService("ReplicatedStorage").Events.ToyEvent
Event:FireServer(A_1)
            wait(10) end
    end    
})
Items:AddButton({
	Name = "Use Free Ant Pass Dispenser",
	Callback = function()
                  A_1 = "Free Ant Pass Dispenser"
                  Event = game:GetService("ReplicatedStorage").Events.ToyEvent
                  Event:FireServer(A_1)
  	end    
})
Items:AddToggle({
    Name = "Auto Use Free Ant Pass Dispenser",
    Default = false,
    Callback = function(cointr)
         getgenv().turnoff4 = cointr
         while turnoff4 == true do 
A_1 = "Free Ant Pass Dispenser"
Event = game:GetService("ReplicatedStorage").Events.ToyEvent
Event:FireServer(A_1)
            wait(10) end
    end    
})
Items:AddButton({
	Name = "Use Blueberry Dispenser",
	Callback = function()
                  A_1 = "Blueberry Dispenser"
                  Event = game:GetService("ReplicatedStorage").Events.ToyEvent
                  Event:FireServer(A_1)
  	end    
})
Items:AddToggle({
    Name = "Auto Use Blueberry Dispenser",
    Default = false,
    Callback = function(cointr)
         getgenv().turnoff4 = cointr
         while turnoff4 == true do 
A_1 = "Blueberry Dispenser"
Event = game:GetService("ReplicatedStorage").Events.ToyEvent
Event:FireServer(A_1)
            wait(10) end
    end    
})
Items:AddButton({
	Name = "Use Honey Dispenser",
	Callback = function()
                  A_1 = "Honey Dispenser"
                  Event = game:GetService("ReplicatedStorage").Events.ToyEvent
                  Event:FireServer(A_1)
  	end    
})
Items:AddToggle({
    Name = "Auto Use Honey Dispenser",
    Default = false,
    Callback = function(cointr)
         getgenv().turnoff4 = cointr
         while turnoff4 == true do 
A_1 = "Honey Dispenser"
Event = game:GetService("ReplicatedStorage").Events.ToyEvent
Event:FireServer(A_1)
            wait(10) end
    end    
})
Items:AddButton({
	Name = "Use Free Royal Jelly Dispenser",
	Callback = function()
                  A_1 = "Free Royal Jelly Dispenser"
                  Event = game:GetService("ReplicatedStorage").Events.ToyEvent
                  Event:FireServer(A_1)
  	end    
})
Items:AddToggle({
    Name = "Auto Use Free Royal Jelly Dispenser",
    Default = false,
    Callback = function(cointr)
         getgenv().turnoff4 = cointr
         while turnoff4 == true do 
A_1 = "Free Royal Jelly Dispenser"
Event = game:GetService("ReplicatedStorage").Events.ToyEvent
Event:FireServer(A_1)
            wait(10) end
    end    
})

local Section = Items:AddSection({
    Name = "Dices"
})

Items:AddButton({
	Name = "Use Field Dice",
	Callback = function()
local Dice1 = {["Name"] = "Field Dice"}
local Event = game:GetService("ReplicatedStorage").Events.PlayerActivesCommand
Event:FireServer(Dice1)
  	end    
})
Items:AddToggle({
    Name = "Auto Use Field Dice",
    Default = false,
    Callback = function(cointr)
         getgenv().turnoff4 = cointr
         while turnoff4 == true do 
local Dice1 = {["Name"] = "Field Dice"}
local Event = game:GetService("ReplicatedStorage").Events.PlayerActivesCommand
Event:FireServer(Dice1)
            wait(3) end
    end    
})
Items:AddButton({
	Name = "Use Smooth Dice",
	Callback = function()
local Dice2 = {["Name"] = "Smooth Dice"}
Event = game:GetService("ReplicatedStorage").Events.PlayerActivesCommand
Event:FireServer(Dice2)  
end    
})
Items:AddToggle({
    Name = "Auto Use Smooth Dice",
    Default = false,
    Callback = function(cointr)
         getgenv().turnoff4 = cointr
         while turnoff4 == true do 
local Dice2 = {["Name"] = "Smooth Dice"}
Event = game:GetService("ReplicatedStorage").Events.PlayerActivesCommand
Event:FireServer(Dice2)  

            wait(3) end
    end    
}) 
Items:AddButton({
	Name = "Use Loaded Dice",
	Callback = function()
local Dice3 = {["Name"] = "Loaded Dice"}
Event = game:GetService("ReplicatedStorage").Events.PlayerActivesCommand
Event:FireServer(Dice3)
  	end    
})
Items:AddToggle({
    Name = "Auto Use Loaded Dice",
    Default = false,
    Callback = function(cointr)
         getgenv().turnoff4 = cointr
         while turnoff4 == true do 
local Dice3 = {["Name"] = "Loaded Dice"}
Event = game:GetService("ReplicatedStorage").Events.PlayerActivesCommand
Event:FireServer(Dice3)
            wait(3) end
    end    
}) 

local Section = Items:AddSection({
    Name = "Boosts"
})

Items:AddButton({
	Name = "Use All Boosters",
	Callback = function()
local red = "Red Field Booster"
local Event = game:GetService("ReplicatedStorage").Events.ToyEvent
Event:FireServer(red)
local blue = "Blue Field Booster"
Event = game:GetService("ReplicatedStorage").Events.ToyEvent
Event:FireServer(blue)
local mountain = "Field Booster"
Event = game:GetService("ReplicatedStorage").Events.ToyEvent
Event:FireServer(mountain)
	end
})
Items:AddToggle({
    Name = "Auto Use All Field Booster",
    Default = false,
    Callback = function(cointr)
         getgenv().turnoff4 = cointr
         while turnoff4 == true do 
local red = "Red Field Booster"
local Event = game:GetService("ReplicatedStorage").Events.ToyEvent
Event:FireServer(red)
local blue = "Blue Field Booster"
Event = game:GetService("ReplicatedStorage").Events.ToyEvent
Event:FireServer(blue)
local mountain = "Field Booster"
Event = game:GetService("ReplicatedStorage").Events.ToyEvent
Event:FireServer(mountain)
wait(5) end    
end
})
Items:AddButton({
	Name = "Use Red Field Booster",
	Callback = function()
local red = "Red Field Booster"
local Event = game:GetService("ReplicatedStorage").Events.ToyEvent
Event:FireServer(red)
	end
})
Items:AddToggle({
    Name = "Auto Use Red Field Booster",
    Default = false,
    Callback = function(cointr)
         getgenv().turnoff4 = cointr
         while turnoff4 == true do 
local red = "Red Field Booster"
local Event = game:GetService("ReplicatedStorage").Events.ToyEvent
Event:FireServer(red)
wait(5) end    
end
})
Items:AddButton({
	Name = "Use Blue Field Booster",
	Callback = function()
local blue = "Blue Field Booster"
Event = game:GetService("ReplicatedStorage").Events.ToyEvent
Event:FireServer(blue)
	end
})
Items:AddToggle({
    Name = "Auto Use Blue Field Booster",
    Default = false,
    Callback = function(cointr)
         getgenv().turnoff4 = cointr
         while turnoff4 == true do 
local blue = "Blue Field Booster"
Event = game:GetService("ReplicatedStorage").Events.ToyEvent
Event:FireServer(blue)
wait(5)       end    
end
})
Items:AddButton({
	Name = "Use Field Booster",
	Callback = function()
local mountain = "Field Booster"
Event = game:GetService("ReplicatedStorage").Events.ToyEvent
Event:FireServer(mountain)
	end
})
Items:AddToggle({
    Name = "Auto Use Field Booster",
    Default = false,
    Callback = function(cointr)
         getgenv().turnoff4 = cointr
         while turnoff4 == true do 
local mountain = "Field Booster"
Event = game:GetService("ReplicatedStorage").Events.ToyEvent
Event:FireServer(mountain)
 wait(5)        end    
end
})

local Section = Items:AddSection({
    Name = "Buffs"
})

Items:AddButton({
	Name = "Use All Buffs [no potions and Marshmallow Bee]",
	Callback = function()
local RedEx = {["Name"] = "Red Extract"}
Event = game:GetService("ReplicatedStorage").Events.PlayerActivesCommand
Event:FireServer(RedEx)
      
local BlueEx = {["Name"] = "Blue Extract"}
Event = game:GetService("ReplicatedStorage").Events.PlayerActivesCommand
Event:FireServer(BlueEx)
      
local Glitter = {["Name"] = "Glitter"}
Event = game:GetService("ReplicatedStorage").Events.PlayerActivesCommand
Event:FireServer(Glitter)

local Glue = {["Name"] = "Glue"}
Event = game:GetService("ReplicatedStorage").Events.PlayerActivesCommand
Event:FireServer(Glue)

local Oil = {["Name"] = "Oil"}
Event = game:GetService("ReplicatedStorage").Events.PlayerActivesCommand
Event:FireServer(Oil)

local Enzymes = {["Name"] = "Enzymes"}
Event = game:GetService("ReplicatedStorage").Events.PlayerActivesCommand
Event:FireServer(Enzymes)

local TDrink = {["Name"] = "Tropical TDrink"}
Event = game:GetService("ReplicatedStorage").Events.PlayerActivesCommand
Event:FireServer(TDrink)
  	end    
})
Items:AddButton({
	Name = "Use Red Extract",
	Callback = function()
local Red = {["Name"] = "Red Extract"}
Event = game:GetService("ReplicatedStorage").Events.PlayerActivesCommand
Event:FireServer(RedEx)
	end
})
Items:AddButton({
	Name = "Use Blue Extract",
	Callback = function()
local BlueEx = {["Name"] = "Blue Extract"}
Event = game:GetService("ReplicatedStorage").Events.PlayerActivesCommand
Event:FireServer(BlueEx)
  	end 
})
Items:AddButton({
	Name = "Use Glitter",
	Callback = function()
local Glitter = {["Name"] = "Glitter"}
Event = game:GetService("ReplicatedStorage").Events.PlayerActivesCommand
Event:FireServer(Glitter)
  	end    
})
Items:AddButton({
	Name = "Use Glue",
	Callback = function()
local Glue = {["Name"] = "Glue"}
Event = game:GetService("ReplicatedStorage").Events.PlayerActivesCommand
Event:FireServer(Glue)
  	end    
})
Items:AddButton({
	Name = "Use Oil",
	Callback = function()
local Oil = {["Name"] = "Oil"}
Event = game:GetService("ReplicatedStorage").Events.PlayerActivesCommand
Event:FireServer(Oil)
  	end    
})
Items:AddButton({
	Name = "Use Enzymes",
	Callback = function()
local Enzymes = {["Name"] = "Enzymes"}
Event = game:GetService("ReplicatedStorage").Events.PlayerActivesCommand
Event:FireServer(Enzymes)
  	end    
})
Items:AddButton({
	Name = "Use Tropical Drink",
	Callback = function()
local TDrink = {["Name"] = "Tropical Drink"}
Event = game:GetService("ReplicatedStorage").Events.PlayerActivesCommand
Event:FireServer(TDrink)
  	end    
})
Items:AddButton({
	Name = "Use Purple Potion",
	Callback = function()
local PP = {["Name"] = "Purple Potion"}
Event = game:GetService("ReplicatedStorage").Events.PlayerActivesCommand
Event:FireServer(PP)
  	end    
})
Items:AddButton({
	Name = "Use Super Smoothie",
	Callback = function()
local SS = {["Name"] = "Super Smoothie"}
Event = game:GetService("ReplicatedStorage").Events.PlayerActivesCommand
Event:FireServer(SS)
  	end    
})
Items:AddButton({
	Name = "Use Super Smoothie",
	Callback = function()
local Turp = {["Name"] = "Turpentine"}
Event = game:GetService("ReplicatedStorage").Events.PlayerActivesCommand
Event:FireServer(Turp)
  	end    
})
Items:AddButton({
	Name = "Use Marshmallow Bee",
	Callback = function()
local Mbee = {["Name"] = "Marshmallow Bee"}
Event = game:GetService("ReplicatedStorage").Events.PlayerActivesCommand
Event:FireServer(Mbee)
  	end    
})


-- Mobs
Mobs:AddToggle({
    Name = "Kill Crab",
    Default = false,
    Callback = function(Value)
        shared.a5 = Value
        if shared.a5 then
            local cocopad = Instance.new("Part", game:GetService("Workspace"))
            cocopad.Name = "Coconut Part"
            cocopad.Anchored = true
            cocopad.Transparency = 0.5
            cocopad.Size = Vector3.new(40, 1, 40)
            cocopad.Position = Vector3.new(-307.52117919922, 105.91863250732, 467.86791992188)

            spawn(function()
                while shared.a5 do
                    shared.a11 = false
                    shared.a12 = false
                    shared.a13 = false
                    local player = game.Players.LocalPlayer
                    local tweenService = game:GetService("TweenService")
                    local info = TweenInfo.new(0.1)
                
                    for _, collectible in pairs(workspace.Collectibles:GetChildren()) do
                        local distance = (collectible.Position - player.Character.HumanoidRootPart.Position).magnitude
                
                        if collectible.Transparency == 0 then 
                            if distance <= 10 then
                                local posX = collectible.Position.x
                                local posZ = collectible.Position.z
                
                                local targetCFrame = CFrame.new(posX, player.Character.HumanoidRootPart.Position.y, posZ)
                                local tween = tweenService:Create(player.Character.HumanoidRootPart, info, {CFrame = targetCFrame})
                                tween:Play()
                            end
                        end
                    end
                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-307.52117919922, 110.91863250732, 467.86791992188)
                    task.wait(0.2)
                end
            end)
        else
            if workspace:FindFirstChild("Coconut Part") then
                workspace["Coconut Part"]:Destroy()
            end
        end
    end
})

Mobs:AddButton({
	Name = "Kill Commando Chick",
	Callback = function()
local Commandopad = Instance.new("Part", game:GetService("Workspace"))
Commandopad.Name = "Commando Part"
Commandopad.Anchored = true
Commandopad.Transparency = 0.5
Commandopad.Size = Vector3.new(10, 1, 10)
Commandopad.Position = Vector3.new(532.56, 68.1981, 162.801)
wait(0.1)
game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(532.56, 68.1981, 162.801)
  	end    
})
Mobs:AddToggle({
    Name = "AFK Stump Snail",
    Default = false,
    Callback = function(Value)
        shared.a105 = Value
        if shared.a105 then
            local snail = Instance.new("Part", game:GetService("Workspace"))
            snail.Name = "Snail Part"
            snail.Anchored = true
            snail.Transparency = 0.5
            snail.Size = Vector3.new(50, 1, 50)
            snail.Position = Vector3.new(424.483276, 71.4255676, -174.810959)

            spawn(function()
                while shared.a105 do
                    local player = game.Players.LocalPlayer
                    local tweenService = game:GetService("TweenService")
                    local info = TweenInfo.new(0.2)
                    
                    for _, collectible in pairs(workspace.Collectibles:GetChildren()) do
                        local distance = (collectible.Position - player.Character.HumanoidRootPart.Position).magnitude

                        if collectible.Transparency == 0 then 
                            if distance <= 15 then
                                local posX = collectible.Position.x
                                local posZ = collectible.Position.z

                                local targetCFrame = CFrame.new(posX, player.Character.HumanoidRootPart.Position.y, posZ)
                                local tween = tweenService:Create(player.Character.HumanoidRootPart, info, {CFrame = targetCFrame})
                                tween:Play()
                            end
                        end
                    end

                    game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(424.483276, 74.4255676, -174.810959)
                    task.wait(0.3)
                end
            end)
        else
            if workspace:FindFirstChild("Snail Part") then
                workspace["Snail Part"]:Destroy()
            end
        end
    end
})

Mobs:AddButton({
	Name = "Kill Tunnel Bear",
	Callback = function()
local nigger = Instance.new("Part", game:GetService("Workspace"))
nigger.Name = "Tunnel Part"
nigger.Anchored = true
nigger.Transparency = 0.5
nigger.Size = Vector3.new(10, 1, 10)
nigger.Position = Vector3.new(469.095, 23.2665, -46.3918)
game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(469.095, 7.2665, -46.3918)
wait(0.1)
game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(469.095, 24.2665, -46.3918)
end
})
Mobs:AddToggle({
    Name = "Auto Kill Mondo Chick [In testing]",
    Default = false,
    Callback = function(assmore)
         getgenv().turnoff54 = assmore
         if turnoff54 == true then
    while turnoff54 == true do
                     
                             mondopition = game.Workspace.Monsters["Mondo Chick (Lvl 8)"].Head.Position
                             api.tween(0.3,CFrame.new(mondopition.x, mondopition.y + 30, mondopition.z)) game.Players.LocalPlayer.Character.Humanoid.HipHeight = 40                        
                             end
                        else
                        game.Players.LocalPlayer.Character.Humanoid.HipHeight = 3

                        end
                        
end
})
Mobs:AddToggle({
    Name = "Kill Windy Bee",
    Callback = function(aa)
       getgenv().pon1 = aa
       if pon1 == true then
    while pon1 == true do wait(.3) for _,v in pairs(game.workspace.NPCBees:GetChildren()) do
      if v.Name == "Windy" then game.Players.LocalPlayer.Character.Humanoid.HipHeight = 35
game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = v.CFrame
end end
 	local windymanoid = game:GetService("Players").LocalPlayer.Character.HumanoidRootPart
			for i,v in next, game.workspace.Particles:GetChildren() do
				for x in string.gmatch(v.Name, "Windy") do
					if string.find(v.Name, "Windy") then
						api.tween(1,CFrame.new(v.Position.x, v.Position.y, v.Position.z)) task.wait(1)
						api.tween(0.5, CFrame.new(v.Position.x, v.Position.y, v.Position.z)) task.wait(.5)
					end
				end
			end 
			for i,v in next, game.workspace.Particles:GetChildren() do
				for x in string.gmatch(v.Name, "Windy") do
                    task.wait() if string.find(v.Name, "Windy") then 
                        game.Players.LocalPlayer.Character.Humanoid.HipHeight = 20 for i=1, 4 do windymanoid.CFrame = CFrame.new(v.Position+10, v.Position + 50, v.Position) task.wait(.3) 
                        end 
                    end
			task.wait(.1)
         end
        end end else game.Players.LocalPlayer.Character.Humanoid.HipHeight = 3
         end end 
})
Mobs:AddToggle({
    Name = "Kill Viciuos Bee",
    Default = false,
    Callback = function(cointr)
         getgenv().turnoff4 = cointr
         if turnoff4 == true then
         while turnoff4 == true do
             wait()
			local vichumanoid = game:GetService("Players").LocalPlayer.Character.HumanoidRootPart
			for i,v in next, game.workspace.Particles:GetChildren() do
				for x in string.gmatch(v.Name, "Vicious") do
                    task.wait() if string.find(v.Name, "Vicious") then 
                        game.Players.LocalPlayer.Character.Humanoid.HipHeight = 20 for i=1, 4 do vichumanoid.CFrame = CFrame.new(v.Position.x, v.Position.y + 20, v.Position.z) task.wait(.3) 
                        end 
                    end end
                end
			end
			task.wait(.1)
         
         else
             game.Players.LocalPlayer.Character.Humanoid.HipHeight = 3
         end 
end})

local Section = Webhook:AddSection({
    Name = "Honey Profit"
})

local webhookEnabled = false
local webhookURL = ""
local webhookInterval = 60
local initialHoney = 0

Webhook:AddToggle({
    Name = "Enable Webhook",
    Default = false,
    Callback = function(Value)
        webhookEnabled = Value
        if webhookEnabled then
            initialHoney = game.Players.LocalPlayer.CoreStats.Honey.Value
            sendWebhookUpdates()
        end
    end
})

Webhook:AddTextbox({
    Name = "Webhook URL",
    Default = "",
    TextDisappear = true,
    Callback = function(Value)
        webhookURL = Value
    end
})

Webhook:AddSlider({
    Name = "Update Interval (seconds)",
    Min = 1,
    Max = 300,
    Default = 60,
    Color = Color3.fromRGB(255,255,255),
    Increment = 1,
    ValueName = "seconds",
    Callback = function(Value)
        webhookInterval = Value
    end    
})

function sendWebhookUpdates()
    spawn(function()
        while webhookEnabled do
            local player = game.Players.LocalPlayer
            local currentHoney = player.CoreStats.Honey.Value
            local honeyProfit = currentHoney - initialHoney
            local capacity = player.CoreStats.Capacity.Value
            local pollen = player.CoreStats.Pollen.Value
            
            local message = string.format(
                "Old Honey: %d\nNew Honey: %d\nHoney Profit: %d\n\nCapacity: %d\nPollen: %d",
                initialHoney, currentHoney, honeyProfit, capacity, pollen
            )
            
            local data = {
                ["content"] = message
            }
            
            local headers = {
                ["Content-Type"] = "application/json"
            }
            
            local success, response = pcall(function()
                return (syn and syn.request or http_request or request or HttpPost or http.request) {
                    Url = webhookURL,
                    Method = "POST",
                    Headers = headers,
                    Body = game:GetService("HttpService"):JSONEncode(data)
                }
            end)
            
            if success then
                print("Webhook sent successfully")
                print("Response:", response.Body)
            else
                print("Failed to send webhook")
                print("Error:", response)
            end
            
            wait(webhookInterval)
        end
    end)
end

Farm:AddToggle({
    Name = "Auto Quest",
    Default = false,
    Callback = function(cointr)
        getgenv().autoquestfuct = cointr
        while autoquestfuct == true do
            game.ReplicatedStorage.Events.BadgeEvent:FireServer("Collect", "Pepper")
            game.ReplicatedStorage.Events.BadgeEvent:FireServer("Collect", "Coconut")
            game.ReplicatedStorage.Events.BadgeEvent:FireServer("Collect", "Playtime")
            game.ReplicatedStorage.Events.BadgeEvent:FireServer("Collect", "Honey")
            game.ReplicatedStorage.Events.BadgeEvent:FireServer("Collect", "Quest")
            game.ReplicatedStorage.Events.BadgeEvent:FireServer("Collect", "Battle")
            game.ReplicatedStorage.Events.BadgeEvent:FireServer("Collect", "Ability")
            game.ReplicatedStorage.Events.BadgeEvent:FireServer("Collect", "Goo")
            game.ReplicatedStorage.Events.BadgeEvent:FireServer("Collect", "Sunflower")
            game.ReplicatedStorage.Events.BadgeEvent:FireServer("Collect", "Dandelion")
            game.ReplicatedStorage.Events.BadgeEvent:FireServer("Collect", "Mushroom")
            game.ReplicatedStorage.Events.BadgeEvent:FireServer("Collect", "Blue Flower")
            game.ReplicatedStorage.Events.BadgeEvent:FireServer("Collect", "Clover")
            game.ReplicatedStorage.Events.BadgeEvent:FireServer("Collect", "Spider")
            game.ReplicatedStorage.Events.BadgeEvent:FireServer("Collect", "Bamboo")
            game.ReplicatedStorage.Events.BadgeEvent:FireServer("Collect", "Strawberry")
            game.ReplicatedStorage.Events.BadgeEvent:FireServer("Collect", "Pineapple")
            game.ReplicatedStorage.Events.BadgeEvent:FireServer("Collect", "Pumpkin")
            game.ReplicatedStorage.Events.BadgeEvent:FireServer("Collect", "Cactus")
            game.ReplicatedStorage.Events.BadgeEvent:FireServer("Collect", "Rose")
            game.ReplicatedStorage.Events.BadgeEvent:FireServer("Collect", "Pine Tree")
            game.ReplicatedStorage.Events.BadgeEvent:FireServer("Collect", "Stump")
            game.ReplicatedStorage.Events.ToyEvent:FireServer("Glue Dispenser")
            game.ReplicatedStorage.Events.ToyEvent:FireServer("Free Royal Jelly Dispenser")
            game.ReplicatedStorage.Events.ToyEvent:FireServer("Blueberry Dispenser")
            game.ReplicatedStorage.Events.ToyEvent:FireServer("Strawberry Dispenser")
            game.ReplicatedStorage.Events.ToyEvent:FireServer("Treat Dispenser")
            game.ReplicatedStorage.Events.ToyEvent:FireServer("Wealth Clock")
            -- Bears Get
            game.ReplicatedStorage.Events.CompleteQuestFromPool:FireServer("Black Bear")
            game.ReplicatedStorage.Events.CompleteQuestFromPool:FireServer("Mother Bear")
            game.ReplicatedStorage.Events.CompleteQuestFromPool:FireServer("Brown Bear")
            game.ReplicatedStorage.Events.CompleteQuestFromPool:FireServer("Panda Bear")
            game.ReplicatedStorage.Events.CompleteQuestFromPool:FireServer("Science Bear")
            game.ReplicatedStorage.Events.CompleteQuestFromPool:FireServer("Dapper Bear")
            game.ReplicatedStorage.Events.CompleteQuestFromPool:FireServer("Polar Bear")
            game.ReplicatedStorage.Events.CompleteQuestFromPool:FireServer("Spirit Bear")
            game.ReplicatedStorage.Events.CompleteQuestFromPool:FireServer("Onett")
            game.ReplicatedStorage.Events.CompleteQuestFromPool:FireServer("Gifted Riley Bee")
            game.ReplicatedStorage.Events.CompleteQuestFromPool:FireServer("Gifted Bucko Bee")
            game.ReplicatedStorage.Events.CompleteQuestFromPool:FireServer("Riley Bee")
            game.ReplicatedStorage.Events.CompleteQuestFromPool:FireServer("Bucko Bee")
            game.ReplicatedStorage.Events.CompleteQuestFromPool:FireServer("Honey Bee")
            game.ReplicatedStorage.Events.CompleteQuestFromPool:FireServer("Bubble Bee Man")
            game.ReplicatedStorage.Events.CompleteQuestFromPool:FireServer("Gummy Bear")
            game.ReplicatedStorage.Events.CompleteQuestFromPool:FireServer("Stick Bug")
            game.ReplicatedStorage.Events.CompleteQuestFromPool:FireServer("Sun Bear") -- The Games
            game.ReplicatedStorage.Events.CompleteQuestFromPool:FireServer("Bee Bear") -- BeeSmas
            --Bears Give
            game.ReplicatedStorage.Events.GiveQuestFromPool:FireServer("Black Bear")
            game.ReplicatedStorage.Events.GiveQuestFromPool:FireServer("Mother Bear")
            game.ReplicatedStorage.Events.GiveQuestFromPool:FireServer("Brown Bear")
            game.ReplicatedStorage.Events.GiveQuestFromPool:FireServer("Panda Bear")
            game.ReplicatedStorage.Events.GiveQuestFromPool:FireServer("Science Bear")
            game.ReplicatedStorage.Events.GiveQuestFromPool:FireServer("Dapper Bear")
            game.ReplicatedStorage.Events.GiveQuestFromPool:FireServer("Polar Bear")
            game.ReplicatedStorage.Events.GiveQuestFromPool:FireServer("Spirit Bear")
            game.ReplicatedStorage.Events.GiveQuestFromPool:FireServer("Onett")
            game.ReplicatedStorage.Events.GiveQuestFromPool:FireServer("Gifted Riley Bee")
            game.ReplicatedStorage.Events.GiveQuestFromPool:FireServer("Gifted Bucko Bee")
            game.ReplicatedStorage.Events.GiveQuestFromPool:FireServer("Riley Bee")
            game.ReplicatedStorage.Events.GiveQuestFromPool:FireServer("Bucko Bee")
            game.ReplicatedStorage.Events.GiveQuestFromPool:FireServer("Honey Bee")
            game.ReplicatedStorage.Events.GiveQuestFromPool:FireServer("Bubble Bee Man")
            game.ReplicatedStorage.Events.GiveQuestFromPool:FireServer("Gummy Bear")
            game.ReplicatedStorage.Events.GiveQuestFromPool:FireServer("Stick Bug")
            game.ReplicatedStorage.Events.GiveQuestFromPool:FireServer("Sun Bear") -- The Games
            game.ReplicatedStorage.Events.GiveQuestFromPool:FireServer("Bee Bear") -- BeeSmas
            -- Quests
            --Black Bear
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Sunflower Start")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Sunflower Start")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Dandelion Deed")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Dandelion Deed")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Pollen Fetcher")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Pollen Fetcher")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Red Request")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Red Request")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Into The Blue")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Into The Blue")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Variety Fetcher")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Variety Fetchert")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Bamboo Boogie")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Bamboo Boogie")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Red Request 2")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Red Request 2")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Cobweb Sweeper")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Cobweb Sweeper")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Leisure Loot")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Leisure Loot")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("White Pollen Wrangler")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("White Pollen Wrangler")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Pineapple Picking")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Pineapple Picking")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Pollen Fetcher 2")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Pollen Fetcher 2")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Weed Wacker")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Weed Wacker")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Red + Blue = Gold")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Red + Blue = Gold")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Colorless Collection")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Colorless Collection")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Spirit of Springtime")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Spirit of Springtime")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Weed Wacker 2")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Weed Wacker 2")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Pollen Fetcher 3")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Pollen Fetcher 3")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Lucky Landscaping")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Lucky Landscaping")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Azure Adventure")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Azure Adventure")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Pink Pineapples")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Pink Pineapples")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Blue Mushrooms")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Blue Mushroomst")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Cobweb Sweeper 2")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Cobweb Sweeper 2")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Rojo-A-Go-Go")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Rojo-A-Go-Go")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Pumpkin Plower")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Pumpkin Plower")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Pollen Fetcher 4")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Pollen Fetcher 4")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Bouncing Around Biomes")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Bouncing Around Biomes")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Blue Pineapples")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Blue Pineapples")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Rose Request")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Rose Request")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Search For The White Clover")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Search For The White Clover")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Stomping Grounds")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Stomping Grounds")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Collecting Cliffside")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Collecting Cliffside")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Mountain Meandering")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Mountain Meandering")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Quest Of Legends")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Quest Of Legends")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("High Altitude")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("High Altitude")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Blissfully Blue")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Blissfully Blue")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Rouge Round-up")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Rouge Round-up")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("White As Snow")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("White As Snow")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Solo On The Stump")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Solo On The Stump")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Colorful Craving")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Colorful Craving")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Pumpkins, Please!")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Pumpkins, Please!")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Smorgasbord")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Smorgasbord")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Pollen Fetcher 5")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Pollen Fetcher 5")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("White Clover Redux")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("White Clover Redux")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Strawberry Field Forever")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Strawberry Field Forever")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Tasting The Sky")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Tasting The Sky")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Whispy and Crispy")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Whispy and Crispy")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Walk Through The Woods")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Walk Through The Woods")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Get Red-y")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Get Red-y")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("One Stop On The Tip Top")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("One Stop On The Tip Top")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Blue Mushrooms 2")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Blue Mushrooms 2")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Pretty Pumpkins")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Pretty Pumpkins")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Black Bear, Why?")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Black Bear, Why?")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Bee A Star")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Bee A Star")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Bamboo Boogie 2: Bamboo Boogaloo")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Bamboo Boogie 2: Bamboo Boogaloo")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Rocky Red Mountain")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Rocky Red Mountain")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Can't Without Ants")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Can't Without Ants")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("The 15 Bee Zone")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("The 15 Bee Zone")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Bubble Trouble")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Bubble Trouble")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Sweet And Sour")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Sweet And Sour")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Rare Red Clover")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Rare Red Clover")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Low Tier Treck")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Low Tier Treck")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Okey-Pokey")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Okey-Pokey")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Pollen Fetcher 6")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Pollen Fetcher 6")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Capsaicin Collector")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Capsaicin Collector")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Mountain Mix")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Mountain Mix")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("You Blue It")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("You Blue It")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Variety Fetcher 2")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Variety Fetcher 2")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Getting Stumped")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Getting Stumped")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Weed Wacker 3")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Weed Wacker 3")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("All-Whitey Then")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("All-Whitey Then")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Red Delicacy")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Red Delicacy")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Boss Battles")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Boss Battles")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Myth In The Making")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Myth In The Making")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Black Bear's Honey Wreath") -- BeeSmas
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Black Bear's Honey Wreath") -- BeeSmas

            -- Mother Bear
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Treat Tutorial")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Treat Tutorial")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Bonding With Bees")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Bonding With Bees")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Search For A Sunflower Seed")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Search For A Sunflower Seed")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("The Gist Of Jellies")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("The Gist Of Jellies")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Search For Strawberries")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Search For Strawberries")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Binging On Blueberries")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Binging On Blueberries")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Royal Jelly Jamboree")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Royal Jelly Jamboree")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Search For Sunflower Seeds")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Search For Sunflower Seeds")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Picking Out Pineapples")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Picking Out Pineapples")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Seven To Seven")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Seven To Seven")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Mother Bear's Midterm")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Mother Bear's Midterm")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Eight To Eight")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Eight To Eight")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Sights On The Stars")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Sights On The Stars")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("The Family Final")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("The Family Final")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Mother Bear's Gingerbread House") -- BeeSmas
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Mother Bear's Gingerbread House") -- BeeSmas

            -- Brown Bear
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Brown Bear's Stockings") -- BeeSmas
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Brown Bear's Stockings") -- BeeSmas

            -- Panda Bear
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Lesson on Ladybugs")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Lesson on Ladybugs")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Rhino Rumble")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Rhino Rumble")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Beetle Battle")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Beetle Battle")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Spider Slayer")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Spider Slayer")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Ladybug Bonker")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Ladybug Bonker")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Spider Slayer 2")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Spider Slayer 2")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Rhino Wrecking")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Rhino Wrecking")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Final Showdown")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Final Showdown")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Werewolf Hunter")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Werewolf Hunter")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Skirmish with Scorpions")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Skirmish with Scorpions")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Mantis Massacre")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Mantis Massacre")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("The REAL Final Showdown")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("The REAL Final Showdown")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Ant Arrival")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Ant Arrival")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Winged Wack Attack")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Winged Wack Attack")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Fire Fighter")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Fire Fighter")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Army Ant Assault")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Army Ant Assault")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Colossal Combat")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Colossal Combat")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Eager Exterminator")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Eager Exterminator")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Leaper Lickin'")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Leaper Lickin'")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Colossal Combat 2")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Colossal Combat 2")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Outrageous Onslaught")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Outrageous Onslaught")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Royal Rumble")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Royal Rumble")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Ultimate Ant Annihilation 1")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Ultimate Ant Annihilation 1")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Ultimate Ant Annihilation 2")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Ultimate Ant Annihilation 2")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Ultimate Ant Annihilation 3")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Ultimate Ant Annihilation 3")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Ultimate Ant Annihilation 4")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Ultimate Ant Annihilation 4")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Ultimate Ant Annihilation 5")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Ultimate Ant Annihilation 5")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Panda Bear's Snowbear") -- BeeSmas
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Panda Bear's Snowbear") -- BeeSmas
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Ready For The Red Drive?") -- Red Drive
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Ready For The Red Drive?") -- Red Drive

            -- Science Bear
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Preliminary Research")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Preliminary Research")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Biology Study")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Biology Study")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Proving The Hypothesis")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Proving The Hypothesis")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Bear Botany")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Bear Botany")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Kingdom Collection")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Kingdom Collection")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Defensive Adaptions")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Defensive Adaptions")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Benefits Of Technology")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Benefits Of Technology")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Spider Study")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Spider Study")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Roses And Weeds")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Roses And Weeds")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Blue Review")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Blue Review")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Ongoing Progress")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Ongoing Progress")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Red / Blue Duality")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Red / Blue Duality")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Costs Of Computation")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Costs Of Computation")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Pollination Practice")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Pollination Practice")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Optimizing Abilities")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Optimizing Abilities")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Ready For Infrared")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Ready For Infrared")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Breaking Down Badges")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Breaking Down Badges")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Subsidized Agriculture")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Subsidized Agriculture")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Meticulously Crafted")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Meticulously Crafted")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Smart, Not Hard")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Smart, Not Hard")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Limits of Language")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Limits of Language")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Patterns and Probability")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Patterns and Probability")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Chemical Analysis")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Chemical Analysis")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Mark Mechanics")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Mark Mechanics")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Meditating On Phenomenon")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Meditating On Phenomenon")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Beesperanto")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Beesperanto")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Hive Minded Bias")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Hive Minded Bias")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Mushroom Measurement Monotony")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Mushroom Measurement Monotony")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("The Power Of Information")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("The Power Of Information")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Testing Teamwork")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Testing Teamwork")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Epistemological Endeavor")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Epistemological Endeavor")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Epistemological Endeavor (before nerf, not available)")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Epistemological Endeavor (before nerf, not available)")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Science Bear's Beesmas Lights") -- BeeSmas
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Science Bear's Beesmas Lights") -- BeeSmas

            -- Dapper Bear
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Planter Practice")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Planter Practice")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Liquid Motivation")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Liquid Motivation")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("A Good Infection")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("A Good Infection")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("All About Appearances")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("All About Appearances")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Means of Mutation")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Means of Mutation")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Creative Comforts")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Creative Comforts")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Keeping It Chromatic")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Keeping It Chromatic")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Wandering Ambition")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Wandering Ambition")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Unintended Intimidation")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Unintended Intimidation")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("The Long Haul")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("The Long Haul")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("The Trick To Tickets")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("The Trick To Tickets")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Invigorating View")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Invigorating View")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Ongoing Maintanence") -- maybe not work
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Ongoing Maintanence")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Solitarily Steadfast")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Solitarily Steadfast")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("More Than Myth")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("More Than Myth")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Barter For The Blue Drive") -- Blue Drive
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Barter For The Blue Drive") -- Blue Drive
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Dapper Bear's Samovar") -- BeeSmas
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Dapper Bear's Samovar") -- BeeSmas

            -- Spirit Bear
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Spirit's Starter")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Spirit's Starter")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("The First Offering")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("The First Offering")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Rules of The Road")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Rules of The Road")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("QR Quest")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("QR Quest")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Pleasant Pastimes")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Pleasant Pastimes")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Nature's Lessons")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Nature's Lessons")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("The Gifts Of Life")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("The Gifts Of Life")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Out-Questing Questions")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Out-Questing Questions")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Forcefully Friendly")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Forcefully Friendly")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Sway Away")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Sway Away")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Memories of Memories")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Memories of Memories")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Beans Becoming")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Beans Becoming")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Do You Bee-lieve in Magic?")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Do You Bee-lieve in Magic?")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("The Ways Of The Winds")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("The Ways Of The Winds")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("The Wind And Its Way")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("The Wind And Its Way")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("The Ways Of The Winds / The Wind And Its Way")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("The Ways Of The Winds / The Wind And Its Way")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Beauty Duty")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Beauty Duty")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Witness Grandeur")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Witness Grandeur")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Beeternity")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Beeternity")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("A Breath Of Blue")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("A Breath Of Blue")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Glory Of Goo")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Glory Of Goo")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Tickle The Wind")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Tickle The Wind")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Rhubarb That Could Have Been")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Rhubarb That Could Have Been")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Dreams Of Being A Bee")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Dreams Of Being A Bee")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("The Sky Over The Stump")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("The Sky Over The Stump")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Space Oblivion")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Space Oblivion")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Pollenpalooza")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Pollenpalooza")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Dancing With Stick Bug")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Dancing With Stick Bug")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Bear Without Despair")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Bear Without Despair")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Spirit Spree")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Spirit Spree")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Echoing Call")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Echoing Call")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Spring Out Of The Mountain")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Spring Out Of The Mountain")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Spirit Bear's Galentine Shrine") -- BeeSmas
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Spirit Bear's Galentine Shrine") -- BeeSmas

            -- Onett
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Star Journey 1")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Star Journey 1")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Star Journey 2")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Star Journey 2")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Star Journey 3")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Star Journey 3")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Star Journey 4")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Star Journey 4")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Star Journey 5")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Star Journey 5")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Onett's Yard Art on The Lid") -- BeeSmas
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Onett's Yard Art on The Lid") -- BeeSmas
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Yard Art on The Lid") -- BeeSmas
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Yard Art on The Lid") -- BeeSmas

            -- Red Bee
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Riley Bee: Abilities")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Riley Bee: Abilities")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Riley Bee: Booster")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Riley Bee: Booster")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Riley Bee: Clean-up")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Riley Bee: Clean-up")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Riley Bee: Extraction")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Riley Bee: Extraction")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Riley Bee: Goo")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Riley Bee: Goo")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Riley Bee: Medley")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Riley Bee: Medley")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Riley Bee: Mushrooms")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Riley Bee: Mushrooms")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Riley Bee: Picnic")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Riley Bee: Picnic")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Riley Bee: Pollen")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Riley Bee: Pollen")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Riley Bee: Rampage")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Riley Bee: Rampage")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Riley Bee: Roses")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Riley Bee: Roses")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Riley Bee: Scavenge")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Riley Bee: Scavenge")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Riley Bee: Skirmish")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Riley Bee: Skirmish")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Riley Bee: Strawberries")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Riley Bee: Strawberries")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Riley Bee: Tango")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Riley Bee: Tango")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Riley Bee: Tour")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Riley Bee: Tour")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Riley Bee's Honeyday Candles") -- BeeSmas
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Riley Bee's Honeyday Candles") -- BeeSmas

            -- Blue Bee
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Bucko Bee: Abilities")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Bucko Bee: Abilities")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Bucko Bee: Bamboo")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Bucko Bee: Bamboo")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Bucko Bee: Bombard")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Bucko Bee: Bombard")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Bucko Bee: Booster")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Bucko Bee: Booster")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Bucko Bee: Clean-up")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Bucko Bee: Clean-up")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Bucko Bee: Extraction")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Bucko Bee: Extraction")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Bucko Bee: Flowers")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Bucko Bee: Flowers")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Bucko Bee: Goo")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Bucko Bee: Goo")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Bucko Bee: Medley")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Bucko Bee: Medley")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Bucko Bee: Picnic")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Bucko Bee: Picnic")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Bucko Bee: Pine Trees")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Bucko Bee: Pine Trees")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Bucko Bee: Pollen")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Bucko Bee: Pollen")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Bucko Bee: Scavenge")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Bucko Bee: Scavenge")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Bucko Bee: Skirmish")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Bucko Bee: Skirmish")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Bucko Bee: Tango")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Bucko Bee: Tango")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Bucko Bee: Tour")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Bucko Bee: Tour")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Bucko Bee's Snow Machine") -- BeeSmas
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Bucko Bee's Snow Machine") -- BeeSmas

            -- Honey Bee
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Honey Bee's Honey Hunt")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Honey Bee's Honey Hunt")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Honey Bee's Honey Wreath?") -- BeeSmas
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Honey Bee's Honey Wreath?") -- BeeSmas

            -- Bubble Bee Man
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("BBM's Naughty List") -- BeeSmas
            game.ReplicatedStorage.Events.GiveQuest:FireServer("BBM's Naughty List") -- BeeSmas

            -- Gummy Bear
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Begin The Goo Invasion")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Begin The Goo Invasion")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Patient Plundering")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Patient Plundering")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Piecewise Invasion")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Piecewise Invasion")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Colorful Conquest")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Colorful Conquest")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Stickier Than Spider Webs")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Stickier Than Spider Webs")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Four Front Assault")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Four Front Assault")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Total Gummification")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Total Gummification")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Artillery Lessons: Slingshot")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Artillery Lessons: Slingshot")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("GOO Away, Bugs")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("GOO Away, Bugs")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Colorful Conquest 2")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Colorful Conquest 2")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Artillery Lessons: Yellow Cannon")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Artillery Lessons: Yellow Cannon")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Peace Through Goo-nity")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Peace Through Goo-nity")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Artillery Lessons: Blue Cannon")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Artillery Lessons: Blue Cannon")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Goo-ing Goo-mmando")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Goo-ing Goo-mmando")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Candy Conquest")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Candy Conquest")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Goo Years Beacon") -- BeeSmas
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Goo Years Beacon") -- BeeSmas

            -- Stick Bug
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Stick Bug's Nymph Hats") -- BeeSmas
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Stick Bug's Nymph Hats") -- BeeSmas

            -- Sun Bear
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("⛳ The Games (1/3): Let The Golf Begin") -- The Games
            game.ReplicatedStorage.Events.GiveQuest:FireServer("⛳ The Games (1/3): Let The Golf Begin") -- The Games
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("⛳ The Games (2/3): Right On Target") -- The Games
            game.ReplicatedStorage.Events.GiveQuest:FireServer("⛳ The Games (2/3): Right On Target") -- The Games
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("⛳ The Games (3/3): Hole In One") -- The Games
            game.ReplicatedStorage.Events.GiveQuest:FireServer("⛳ The Games (3/3): Hole In One") -- The Games


            

            -- Bee Bear
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Beesmas Summer Starts")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Beesmas Summer Starts")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Blueberries For Beesmas")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Blueberries For Beesmas")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Tis The Season For Stickers")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Tis The Season For Stickers")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Festive Fundraising")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Festive Fundraising")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Wrapping Up The Sticker Planter")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Wrapping Up The Sticker Planter")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Beesmas Boosting")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Beesmas Boosting")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Teamwork Makes The Dream")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Teamwork Makes The Dream")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("The Scoop On Stickers")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("The Scoop On Stickers")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Beesmas Beat Em Up")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Beesmas Beat Em Up")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Walkin' In A Wavy Wonderland")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Walkin' In A Wavy Wonderland")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Festive Flower Fun")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Festive Flower Fun")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Beesmas Bee-leaf-er")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Beesmas Bee-leaf-er")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("The Season For Giving")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("The Season For Giving")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Rain, Rain, Snow Away!")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Rain, Rain, Snow Away!")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Here Comes Cub Buddy")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Here Comes Cub Buddy")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Doodle Cub Creation (1/5")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Doodle Cub Creation (1/5")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Doodle Cub Creation (2/5)")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Doodle Cub Creation (2/5)")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Doodle Cub Creation (3/5)")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Doodle Cub Creation (3/5)")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Doodle Cub Creation (4/5)")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Doodle Cub Creation (4/5)")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Doodle Cub Creation (5/5)")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Doodle Cub Creation (5/5)")


            -- Repeat
            game.ReplicatedStorage.Events.BadgeEvent:FireServer("Collect", "Pepper")
            game.ReplicatedStorage.Events.BadgeEvent:FireServer("Collect", "Coconut")
            game.ReplicatedStorage.Events.BadgeEvent:FireServer("Collect", "Playtime")
            game.ReplicatedStorage.Events.BadgeEvent:FireServer("Collect", "Honey")
            game.ReplicatedStorage.Events.BadgeEvent:FireServer("Collect", "Quest")
            game.ReplicatedStorage.Events.BadgeEvent:FireServer("Collect", "Battle")
            game.ReplicatedStorage.Events.BadgeEvent:FireServer("Collect", "Ability")
            game.ReplicatedStorage.Events.BadgeEvent:FireServer("Collect", "Goo")
            game.ReplicatedStorage.Events.BadgeEvent:FireServer("Collect", "Sunflower")
            game.ReplicatedStorage.Events.BadgeEvent:FireServer("Collect", "Dandelion")
            game.ReplicatedStorage.Events.BadgeEvent:FireServer("Collect", "Mushroom")
            game.ReplicatedStorage.Events.BadgeEvent:FireServer("Collect", "Blue Flower")
            game.ReplicatedStorage.Events.BadgeEvent:FireServer("Collect", "Clover")
            game.ReplicatedStorage.Events.BadgeEvent:FireServer("Collect", "Spider")
            game.ReplicatedStorage.Events.BadgeEvent:FireServer("Collect", "Bamboo")
            game.ReplicatedStorage.Events.BadgeEvent:FireServer("Collect", "Strawberry")
            game.ReplicatedStorage.Events.BadgeEvent:FireServer("Collect", "Pineapple")
            game.ReplicatedStorage.Events.BadgeEvent:FireServer("Collect", "Pumpkin")
            game.ReplicatedStorage.Events.BadgeEvent:FireServer("Collect", "Cactus")
            game.ReplicatedStorage.Events.BadgeEvent:FireServer("Collect", "Rose")
            game.ReplicatedStorage.Events.BadgeEvent:FireServer("Collect", "Pine Tree")
            game.ReplicatedStorage.Events.BadgeEvent:FireServer("Collect", "Stump")
            game.ReplicatedStorage.Events.ToyEvent:FireServer("Glue Dispenser")
            game.ReplicatedStorage.Events.ToyEvent:FireServer("Free Royal Jelly Dispenser")
            game.ReplicatedStorage.Events.ToyEvent:FireServer("Blueberry Dispenser")
            game.ReplicatedStorage.Events.ToyEvent:FireServer("Strawberry Dispenser")
            game.ReplicatedStorage.Events.ToyEvent:FireServer("Treat Dispenser")
            game.ReplicatedStorage.Events.ToyEvent:FireServer("Wealth Clock")
            game.ReplicatedStorage.Events.CompleteQuestFromPool:FireServer("Brown Bear")
            game.ReplicatedStorage.Events.CompleteQuestFromPool:FireServer("Polar Bear")
            game.ReplicatedStorage.Events.CompleteQuestFromPool:FireServer("Honey Bee")
            game.ReplicatedStorage.Events.CompleteQuestFromPool:FireServer("Black Bear")
            game.ReplicatedStorage.Events.CompleteQuestFromPool:FireServer("Bucko Bee")
            game.ReplicatedStorage.Events.CompleteQuestFromPool:FireServer("Riley Bee")
            game.ReplicatedStorage.Events.GiveQuestFromPool:FireServer("Brown Bear")
            game.ReplicatedStorage.Events.GiveQuestFromPool:FireServer("Polar Bear")
            game.ReplicatedStorage.Events.GiveQuestFromPool:FireServer("Honey Bee")
            game.ReplicatedStorage.Events.GiveQuestFromPool:FireServer("Black Bear")
            game.ReplicatedStorage.Events.GiveQuestFromPool:FireServer("Bucko Bee")
            game.ReplicatedStorage.Events.GiveQuestFromPool:FireServer("Riley Bee")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Treat Tutorial")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Treat Tutorial")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Bonding With Bees")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Bonding With Bees")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Search For A Sunflower Seed")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Search For A Sunflower Seed")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("The Gist Of Jellies")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("The Gist Of Jellies")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Search For Strawberries")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Search For Strawberries")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Binging On Blueberries")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Binging On Blueberries")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Royal Jelly Jamboree")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Royal Jelly Jamboree")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Search For Sunflower Seeds")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Search For Sunflower Seeds")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Picking Out Pineapples")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Picking Out Pineapples")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Seven To Seven")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Seven To Seven")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Mother Bears Midterm")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Mother Bears Midterm")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Eight To Eight")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Eight To Eight")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Sights On The Stars")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Sights On The Stars")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("The Family Final")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("The Family Final")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Preliminary Research")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Preliminary Research")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Biology Study")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Biology Study")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Proving The Hypothesis")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Proving The Hypothesis")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Bear Botany")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Bear Botany")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Kingdom Collection")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Kingdom Collection")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Defensive Adaptions")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Devensive Adaptions")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Benefits Of Technology")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Benefits Of Technology")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Spider Study")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Spider Study")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Roses And Weeds")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Roses And Weeds")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Blue Review")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Blue Review")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Ongoing Progress")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Ongoing Progress")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Red / Blue Duality")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Red / Blue Duality")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Costs Of Computation")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Costs Of Computation")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Pollination Practice")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Pollination Practice")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Optimizing Abilities")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Optimizing Abilities")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Ready For Infrared")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Ready For Infrared")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Breaking Down Badges")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Breaking Down Badges")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Subsidized Agriculture")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Subsidized Agriculture")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Meticulously Crafted")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Meticulously Crafted")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Smart, Not Hard")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Smart, Not Hard")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Limits of Language")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Limits of Language")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Patterns and Probability")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Patterns and Probability")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Chemical Analysis")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Chemical Analysis")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Mark Mechanics")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Mark Mechanics")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Meditating On Phenomenon")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Meditating On Phenomenon")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Beesperanto")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Beesperanto")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Hive Minded Bias")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Hive Minded Bias")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Mushroom Measurement Monotony")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Mushroom Measurement Monotony")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("The Power Of Information")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("The Power Of Information")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Testing Teamwork")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Testing Teamwork")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Epistemological Endeavor")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Epistemological Endeavor")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Egg Hunt: Panda Bear")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Egg Hunt: Panda Bear")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Lesson On Ladybugs")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Lesson On Ladybugs")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Rhino Rumble")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Rhino Rumble")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Beetle Battle")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Beetle Battle")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Spider Slayer")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Spider Slayer")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Ladybug Bonker")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Ladybug Bonker")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Spider Slayer 2")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Spider Slayer 2")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Rhino Wrecking")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Rhino Wrecking")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Final Showdown")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Final Showdown")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Werewolf Hunter")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Werewolf Hunter")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Skirmish with Scorpions")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Skirmish with Scorpions")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Mantis Massacre")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Mantis Massacre")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("The REAL Final Showdown")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("The REAL Final Showdown")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Ant Arrival")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Ant Arrival")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Winged Wack Attack")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Winged Wack Attack")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Fire Fighter")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Fire Fighter")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Army Ant Assault")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Army Ant Assault")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Colossal Combat")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Colossal Combat")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Eager Exterminator")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Eager Exterminator")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Leaper Lickin'")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Leaper Lickin'")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Colossal Combat 2")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Colossal Combat 2")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Outrageous Onslaught")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Outrageous Onslaught")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Royal Rumble")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Royal Rumble")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Ultimate Ant Annihilation 1")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Ultimate Ant Annihilation 1")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Ultimate Ant Annihilation 2")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Ultimate Ant Annihilation 2")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Ultimate Ant Annihilation 3")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Ultimate Ant Annihilation 3")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Ultimate Ant Annihilation 4")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Ultimate Ant Annihilation 4")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Ultimate Ant Annihilation 5")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Ultimate Ant Annihilation 5")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Star Journey 1")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Star Journey 1")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Star Journey 2")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Star Journey 2")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Star Journey 3")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Star Journey 3")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Star Journey 4")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Star Journey 4")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Star Journey 5")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Star Journey 5")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Egg Hunt: Riley Bee")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Egg Hunt: Riley Bee")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Egg Hunt: Bucko Bee")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Egg Hunt: Bucko Bee")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Sunflower Start")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Sunflower Start")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Dandelion Deed")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Dandelion Deed")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Pollen Fetcher")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Pollen Fetcher")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Red Request")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Red Request")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Into The Blue")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Into The Blue")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Variety Fetcher")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Variety Fetcher")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Bamboo Boogie")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Bamboo Boogie")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Red Request 2")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Red Request 2")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Cobweb Sweeper")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Cobweb Sweeper")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Leisure Loot")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Leisure Loot")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("White Pollen Wrangler")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("White Pollen Wrangler")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Pineapple Picking")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Pineapple Picking")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Pollen Fetcher 2")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Pollen Fetcher 2")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Weed Wacker")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Weed Wacker")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Red + Blue = Gold")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Red + Blue = Gold")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Colorless Collection")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Colorless Collection")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Spirit of Springtime")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Spirit of Springtime")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Weed Wacker 2")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Weed Wacker 2")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Pollen Fetcher 3")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Pollen Fetcher 3")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Lucky Landscaping")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Lucky Landscaping")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Azure Adventure")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Azure Adventure")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Pink Pineapples")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Pink Pineapples")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Blue Mushrooms")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Blue Mushrooms")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Cobweb Sweeper 2")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Cobweb Sweeper 2")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Rojo-A-Go-Go")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Rojo-A-Go-Go")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Pumpkin Plower")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Pumpkin Plower")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Pollen Fetcher 4")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Pollen Fetcher 4")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Bouncing Around Biomes")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Bouncing Around Biomes")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Blue Pineapples")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Blue Pineapples")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Rose Request")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Rose Request")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Search For The White Clover")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Search For The White Clover")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Stomping Grounds")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Stomping Grounds")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Collecting Cliffside")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Collecting Cliffside")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Mountain Meandering")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Mountain Meandering")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Quest Of Legends")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Quest Of Legends")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("High Altitude")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("High Altitude")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Blissfully Blue")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Blissfully Blue")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Rouge Round-up")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Rouge Round-up")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("White As Snow")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("White As Snow")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Solo On The Stump")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Solo On The Stump")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Colorful Craving")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Colorful Craving")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Pumpkins, Please!")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Pumpkins, Please!")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Smorgasbord")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Smorgasbord")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Pollen Fetcher 5")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Pollen Fetcher 5")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("White Clover Redux")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("White Clover Redux")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Strawberry Field Forever")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Strawberry Field Forever")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Tasting The Sky")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Tasting The Sky")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Whispy and Crispy")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Whispy and Crispy")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Walk Through The Woods")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Walk Through The Woods")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Get Red-y")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Get Red-y")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("One Stop On The Tip Top")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("One Stop On The Tip Top")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Blue Mushrooms 2")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Blue Mushrooms 2")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Pretty Pumpkins")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Pretty Pumpkins")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Black Bear, Why?")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Black Bear, Why?")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Bee A Star")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Bee A Star")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Spirit's Starter")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Spirit's Starter")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("The First Offering")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("The First Offering")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Rules of The Road")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Rules of The Road")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("QR Quest")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("QR Quest")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Pleasant Pastimes")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Pleasant Pastimes")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Nature's Lessons")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Nature's Lessons")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("The Gifts Of Life")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("The Gifts Of Life")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Out-Questing Questions")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Out-Questing Questions")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Forcefully Friendly")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Forcefully Friendly")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Sway Away")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Sway Away")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Memories of Memories")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Memories of Memories")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Beans Becoming")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Beans Becoming")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Do You Bee-lieve In Magic?")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Do You Bee-lieve In Magic?")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("The Ways Of The Winds / The Wind And Its Way")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("The Ways Of The Winds / The Wind And Its Way")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Beauty Duty")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Beauty Duty")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Witness Grandeur")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Witness Grandeur")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Beeternity")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Beeternity")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("A Breath Of Blue")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("A Breath Of Blue")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Glory Of Goo")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Glory Of Goo")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Tickle The Wind")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Tickle The Wind")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Rhubarb That Could Have Been")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Rhubarb That Could Have Been")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Dreams Of Being A Bee")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Dreams Of Being A Bee")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("The Sky Over The Stump")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("The Sky Over The Stump")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Space Oblivion")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Space Oblivion")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Pollenpalooza")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Pollenpalooza")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Dancing With Stick Bug")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Dancing With Stick Bug")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Bean Bug Busser")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Bean Bug Busser")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Bombs, Blueberries, and Bean Bugs")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Bombs, Blueberries, and Bean Bugs")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Bean Bugs And Boosts")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Bean Bugs And Boosts")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Make It Hasty")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Make It Hasty")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Total Focus")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Total Focus")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("On Your Marks")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("On Your Marks")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Look In The Leaves")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Look In The Leaves")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("What About Sprouts")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("What About Sprouts")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Bean Bug Beatdown")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Bean Bug Beatdown")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Bear Without Despair")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Bear Without Despair")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Spirit Spree")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Spirit Spree")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Echoing Call")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Echoing Call")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Spring Out Of The Mountain")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Spring Out Of The Mountain")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Riley Bee: Goo")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Riley Bee: Goo")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Riley Bee: Medley")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Riley Bee: Medley")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Riley Bee: Mushrooms")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Riley Bee: Mushrooms")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Riley Bee: Picnic")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Riley Bee: Picnic")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Riley Bee: Pollen")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Riley Bee: Pollen")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Riley Bee: Rampage")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Riley Bee: Rampage")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Riley Bee: Roses")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Riley Bee: Roses")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Riley Bee: Scavenge")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Riley Bee: Scavenge")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Riley Bee: Skirmish")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Riley Bee: Skirmish")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Riley Bee: Strawberries")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Riley Bee: Strawberries")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Riley Bee: Tango")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Riley Bee: Tango")
            game.ReplicatedStorage.Events.GiveQuest:FireServer("Riley Bee: Tour")
            game.ReplicatedStorage.Events.CompleteQuest:FireServer("Riley Bee: Tour")
            wait(10)
        end
    end 
})



-- AntiAfk Scripts
wait(0.5)local ba=Instance.new("ScreenGui")
local ca=Instance.new("TextLabel")local da=Instance.new("Frame")
local _b=Instance.new("TextLabel")local ab=Instance.new("TextLabel")ba.Parent=game.CoreGui
ba.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;ca.Parent=ba;ca.Active=true
ca.BackgroundColor3=Color3.new(0.176471,0.176471,0.176471)ca.Draggable=true
ca.Position=UDim2.new(5.698610067,0,0.098096624,0)ca.Size=UDim2.new(0,150,0,52)
ca.Font=Enum.Font.SourceSansSemibold;ca.Text="Anti AFK Script"ca.TextColor3=Color3.new(0,1,1)
ca.TextSize=22;da.Parent=ca
da.BackgroundColor3=Color3.new(0.196078,0.196078,0.196078)da.Position=UDim2.new(0,0,1.0192306,0)
da.Size=UDim2.new(0,150,0,57)_b.Parent=da
_b.BackgroundColor3=Color3.new(0.176471,0.176471,0.176471)_b.Position=UDim2.new(0,0,0.800455689,0)
_b.Size=UDim2.new(0,150,0,21)_b.Font=Enum.Font.Arial;_b.Text="RBScr1pts"
_b.TextColor3=Color3.new(0,1,1)_b.TextSize=20;ab.Parent=daaaaaaaaaa
ab.BackgroundColor3=Color3.new(0.176471,0.176471,0.176471)ab.Position=UDim2.new(0,0,0.158377,0)
ab.Size=UDim2.new(0,150,0,44)ab.Font=Enum.Font.ArialBold;ab.Text="Status: Active"
ab.TextColor3=Color3.new(0,1,1)ab.TextSize=20;local bb=game:service'VirtualUser'
game:service'Players'.LocalPlayer.Idled:connect(function()
bb:CaptureController()bb:ClickButton2(Vector2.new())
ab.Text="Roblox Tried to kick you but we didnt let them kick you :D"wait(2)ab.Text="Status : Active"end)
