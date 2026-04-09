local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- สถานะการเปิด/ปิด
local unexpectedEnabled = false

--========================--
--        UI Toggle       --
--========================--
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "UnexpectedToggleGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(0, 160, 0, 50)
toggleButton.Position = UDim2.new(1, -170, 1, -120) -- มุมล่างขวา
toggleButton.AnchorPoint = Vector2.new(0, 0)
toggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
toggleButton.TextColor3 = Color3.new(1, 1, 1)
toggleButton.TextScaled = true
toggleButton.Font = Enum.Font.GothamBold
toggleButton.Text = "Unexpected: OFF"
toggleButton.Parent = screenGui

--========================--
--   ฟังก์ชัน Toggle      --
--========================--
toggleButton.MouseButton1Click:Connect(function()
    unexpectedEnabled = not unexpectedEnabled
    
    if unexpectedEnabled then
        toggleButton.Text = "Unexpected: ON"
        toggleButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
    else
        toggleButton.Text = "Unexpected: OFF"
        toggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        humanoid:Move(Vector3.zero, false) -- หยุดการเคลื่อนไหวเมื่อปิด
    end
end)

--========================--
--   ระบบการเคลื่อนไหว   --
--========================--
local directions = {
    Vector3.new(0, 0, -1), -- หน้า
    Vector3.new(0, 0, 1),  -- หลัง
    Vector3.new(-1, 0, 0), -- ซ้าย
    Vector3.new(1, 0, 0)   -- ขวา
}

local function isPlayerMoving()
    return humanoid.MoveDirection.Magnitude > 0
end

-- การเคลื่อนไหวแบบสุ่ม
task.spawn(function()
    while true do
        if unexpectedEnabled and humanoid.Health > 0 then
            -- ทำงานเฉพาะเมื่อผู้เล่นไม่ได้ควบคุมเอง
            if not isPlayerMoving() then
                local randomDir = directions[math.random(1, #directions)]
                local moveDirection = rootPart.CFrame:VectorToWorldSpace(randomDir)

                local duration = math.random(2, 5) / 10 -- 0.2 - 0.5 วินาที
                local startTime = tick()

                while tick() - startTime < duration and unexpectedEnabled do
                    humanoid:Move(moveDirection, false)
                    RunService.RenderStepped:Wait()
                end

                humanoid:Move(Vector3.zero, false)
            end
        end
        
        task.wait(math.random(3, 8) / 10)
    end
end)
