local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- ตัวแปรสถานะ
local zigzagEnabled = false
local uiVisible = true

--========================--
--        สร้าง UI        --
--========================--
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ZigzagGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Size = UDim2.new(0, 180, 0, 90)
mainFrame.Position = UDim2.new(1, -200, 1, -150)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderSizePixel = 0
mainFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = mainFrame

-- ปุ่ม Toggle ON/OFF
local toggleButton = Instance.new("TextButton")
toggleButton.Size = UDim2.new(1, -20, 0, 40)
toggleButton.Position = UDim2.new(0, 10, 0, 40)
toggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
toggleButton.TextColor3 = Color3.new(1, 1, 1)
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextScaled = true
toggleButton.Text = "Zigzag: OFF"
toggleButton.Parent = mainFrame

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 8)
toggleCorner.Parent = toggleButton

-- ปุ่ม X สำหรับปิด UI
local closeButton = Instance.new("TextButton")
closeButton.Size = UDim2.new(0, 25, 0, 25)
closeButton.Position = UDim2.new(1, -30, 0, 5)
closeButton.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
closeButton.Text = "X"
closeButton.TextColor3 = Color3.new(1, 1, 1)
closeButton.Font = Enum.Font.GothamBold
closeButton.TextScaled = true
closeButton.Parent = mainFrame

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(1, 0)
closeCorner.Parent = closeButton

--========================--
--     ฟังก์ชันปุ่ม       --
--========================--
toggleButton.MouseButton1Click:Connect(function()
    zigzagEnabled = not zigzagEnabled
    
    if zigzagEnabled then
        toggleButton.Text = "Zigzag: ON"
        toggleButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        humanoid.WalkSpeed = 22 -- เพิ่มความเร็ว
    else
        toggleButton.Text = "Zigzag: OFF"
        toggleButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        humanoid:Move(Vector3.zero, false)
        humanoid.WalkSpeed = 16 -- คืนค่าปกติ
    end
end)

-- ปิด UI เมื่อกดปุ่ม X
closeButton.MouseButton1Click:Connect(function()
    screenGui.Enabled = false
end)

--========================--
--     ระบบ Zigzag        --
--========================--
local directions = {
    Vector3.new(1, 0, 0),   -- ขวา
    Vector3.new(-1, 0, 0),  -- ซ้าย
    Vector3.new(0, 0, -1),  -- หน้า
    Vector3.new(0, 0, 1),   -- หลัง
}

task.spawn(function()
    while true do
        if zigzagEnabled and humanoid.Health > 0 then
            -- เลือกทิศทางแบบสุ่ม
            local randomDir = directions[math.random(1, #directions)]
            local moveDirection = rootPart.CFrame:VectorToWorldSpace(randomDir)

            -- ระยะเวลาสั้นลงเพื่อให้เคลื่อนไหวเร็วขึ้น
            local duration = math.random(5, 10) / 100 -- 0.05 - 0.1 วินาที
            local startTime = tick()

            while tick() - startTime < duration and zigzagEnabled do
                humanoid:Move(moveDirection, false)
                RunService.RenderStepped:Wait()
            end
        else
            RunService.RenderStepped:Wait()
        end
    end
end)
