local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = script.Parent
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- ตรวจสอบว่าเป็นอุปกรณ์มือถือหรือไม่
local isMobile = UserInputService.TouchEnabled

-- ทิศทางพื้นฐาน: หน้า หลัง ซ้าย ขวา
local directions = {
    Vector3.new(0, 0, -1), -- Forward
    Vector3.new(0, 0, 1),  -- Backward
    Vector3.new(-1, 0, 0), -- Left
    Vector3.new(1, 0, 0)   -- Right
}

-- ฟังก์ชันตรวจสอบว่าผู้เล่นกำลังควบคุมตัวละครอยู่หรือไม่
local function isPlayerMoving()
    return humanoid.MoveDirection.Magnitude > 0
end

-- ฟังก์ชันการเคลื่อนไหวแบบสุ่มที่ไม่รบกวนผู้เล่น
local function unexpectedMovement()
    while humanoid.Health > 0 do
        -- หากผู้เล่นกำลังควบคุมอยู่ จะไม่แทรกการเคลื่อนไหว
        if not isPlayerMoving() then
            local randomDir = directions[math.random(1, #directions)]
            local moveDirection = rootPart.CFrame:VectorToWorldSpace(randomDir)

            local duration = math.random(2, 5) / 10 -- 0.2 - 0.5 วินาที
            local startTime = tick()

            while tick() - startTime < duration do
                humanoid:Move(moveDirection, false)
                RunService.RenderStepped:Wait()
            end

            humanoid:Move(Vector3.zero, false)
        end

        -- หน่วงเวลาแบบสุ่มเพื่อให้ดูเป็นธรรมชาติ
        task.wait(math.random(3, 8) / 10)
    end
end

-- เริ่มการทำงาน
task.spawn(unexpectedMovement)

-- ทำให้มั่นใจว่า Touch Controls ยังทำงาน
if isMobile then
    humanoid.AutoRotate = true
end
