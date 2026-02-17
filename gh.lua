local client = game.Players.LocalPlayer
local Enemies = workspace:WaitForChild("Enemies")
local Modules = game.ReplicatedStorage:WaitForChild("Modules")

FastAttack = (function()

    local net = Modules:WaitForChild("Net")
    local RegisterAttack = net:WaitForChild("RE/RegisterAttack")
    local RegisterHit = net:WaitForChild("RE/RegisterHit")

    local HIT_FUNCTION

    local AttackModule = {
        Distance = 100,
    }

    local u147 = client.Character
        and client.Character:FindFirstChildOfClass("Tool")

    function AttackModule:InitHitFunction()
        local PlayerScripts = client:WaitForChild("PlayerScripts")
        local LocalScript = PlayerScripts:FindFirstChildOfClass("LocalScript")

        while not LocalScript do
            client.PlayerScripts.ChildAdded:Wait()
            LocalScript = PlayerScripts:FindFirstChildOfClass("LocalScript")
        end

        local Success, ScriptEnv = pcall(getsenv, LocalScript)
        if Success and ScriptEnv then
            HIT_FUNCTION = ScriptEnv._G.SendHitsToServer
        end
    end

    function AttackModule:ProcessAll()
        local target
        local args = {}

        for _, enemy in ipairs(Enemies:GetChildren()) do
            local hrp = enemy:FindFirstChild("HumanoidRootPart")

            if hrp and client:DistanceFromCharacter(hrp.Position) < self.Distance then
                if not target then
                    target = hrp
                else
                    table.insert(args, { enemy, hrp })
                end
            end
        end

        if target then
            if HIT_FUNCTION then
                HIT_FUNCTION(target, args)
            else
                RegisterHit:FireServer(target, args)
            end

            RegisterAttack:FireServer(0)
        end
    end

    task.spawn(function()
        while task.wait() do
            AttackModule:ProcessAll()
        end
    end)

    AttackModule:InitHitFunction()

end)()
