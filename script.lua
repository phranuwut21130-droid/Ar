-- ⚔️ Auto System | Instant Kill + Speed + Auto Claim
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local SETTINGS = {
    KillRange = 35, CheckDelay = 0.4, MaxEnemies = 5,
    SpeedMult = 2.5, DefaultSpeed = 16, ClaimInterval = 1.5,
}
local State = { Kill = false, Speed = false, Claim = false }
local PlayerChars = {}

local function RefreshPlayers()
    table.clear(PlayerChars)
    for _, P in ipairs(Players:GetPlayers()) do
        if P.Character then PlayerChars[P.Character] = true end
    end
end
RefreshPlayers()
Players.PlayerAdded:Connect(RefreshPlayers)
Players.PlayerRemoving:Connect(RefreshPlayers)

local function GetChar()
    local C = LocalPlayer.Character
    return C and C:FindFirstChild("HumanoidRootPart") and C or nil
end

-- เมนู
local SG = Instance.new("ScreenGui")
SG.Parent = PlayerGui; SG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local Frame = Instance.new("Frame")
Frame.Parent = SG; Frame.BackgroundColor3 = Color3.fromRGB(30,30,35)
Frame.Size = UDim2.new(0,160,0,115); Frame.Position = UDim2.new(0.02,0,0.3,0)
Frame.Active = true; Frame.Draggable = true

local Title = Instance.new("TextLabel")
Title.Parent = Frame; Title.BackgroundColor3 = Color3.fromRGB(45,45,55)
Title.Size = UDim2.new(1,0,0,28); Title.Text = "⚔️ Auto"
Title.TextColor3 = Color3.new(1,1,1); Title.Font = Enum.Font.GothamBold; Title.TextSize = 12

local BtnKill = Instance.new("TextButton")
BtnKill.Parent = Frame; BtnKill.BackgroundColor3 = Color3.fromRGB(80,80,80)
BtnKill.Size = UDim2.new(1,-10,0,24); BtnKill.Position = UDim2.new(0,5,0,30)
BtnKill.Text = "❌ ฆ่ามอน"; BtnKill.TextColor3 = Color3.new(1,1,1)
BtnKill.Font = Enum.Font.Gotham; BtnKill.TextSize = 11

local BtnSpeed = Instance.new("TextButton")
BtnSpeed.Parent = Frame; BtnSpeed.BackgroundColor3 = Color3.fromRGB(80,80,80)
BtnSpeed.Size = UDim2.new(1,-10,0,24); BtnSpeed.Position = UDim2.new(0,5,0,56)
BtnSpeed.Text = "❌ วิ่งเร็ว"; BtnSpeed.TextColor3 = Color3.new(1,1,1)
BtnSpeed.Font = Enum.Font.Gotham; BtnSpeed.TextSize = 11

local BtnClaim = Instance.new("TextButton")
BtnClaim.Parent = Frame; BtnClaim.BackgroundColor3 = Color3.fromRGB(80,80,80)
BtnClaim.Size = UDim2.new(1,-10,0,24); BtnClaim.Position = UDim2.new(0,5,0,82)
BtnClaim.Text = "❌ รับรางวัล"; BtnClaim.TextColor3 = Color3.new(1,1,1)
BtnClaim.Font = Enum.Font.Gotham; BtnClaim.TextSize = 11

-- ปุ่มทำงาน
BtnKill.MouseButton1Click:Connect(function()
    State.Kill = not State.Kill
    BtnKill.Text = State.Kill and "✅ ฆ่ามอน" or "❌ ฆ่ามอน"
    BtnKill.BackgroundColor3 = State.Kill and Color3.fromRGB(40,160,80) or Color3.fromRGB(80,80,80)
end)

BtnSpeed.MouseButton1Click:Connect(function()
    State.Speed = not State.Speed
    BtnSpeed.Text = State.Speed and "✅ เร็ว" or "❌ วิ่งเร็ว"
    BtnSpeed.BackgroundColor3 = State.Speed and Color3.fromRGB(40,120,180) or Color3.fromRGB(80,80,80)
    if not State.Speed then
        local C = LocalPlayer.Character
        if C and C:FindFirstChild("Humanoid") then
            pcall(function() C.Humanoid.WalkSpeed = SETTINGS.DefaultSpeed end)
        end
    end
end)

BtnClaim.MouseButton1Click:Connect(function()
    State.Claim = not State.Claim
    BtnClaim.Text = State.Claim and "✅ รับ" or "❌ รับรางวัล"
    BtnClaim.BackgroundColor3 = State.Claim and Color3.fromRGB(200,100,50) or Color3.fromRGB(80,80,80)
end)

-- ลูปหลัก
spawn(function()
    local lastClaim = 0
    while task.wait(SETTINGS.CheckDelay) do
        local C = GetChar()
        if not C then continue end
        local Root = C.HumanoidRootPart
        local Hum = C:FindFirstChild("Humanoid")

        if State.Speed and Hum then
            pcall(function() Hum.WalkSpeed = SETTINGS.DefaultSpeed * SETTINGS.SpeedMult end)
        end

        if State.Kill then
            local n = 0
            for _, D in ipairs(workspace:GetDescendants()) do
                if n >= SETTINGS.MaxEnemies then break end
                if D:IsA("Model") and not PlayerChars[D] then
                    local EH = D:FindFirstChild("Humanoid")
                    local ER = D:FindFirstChild("HumanoidRootPart")
                    if EH and ER and EH.Health > 0 then
                        n += 1
                        if (Root.Position - ER.Position).Magnitude <= SETTINGS.KillRange then
                            pcall(function() EH.Health = 0 end)
                        end
                    end
                end
            end
        end

        if State.Claim and os.clock() - lastClaim >= SETTINGS.ClaimInterval then
            lastClaim = os.clock()
            pcall(function()
                for _, G in ipairs(PlayerGui:GetChildren()) do
                    if G:IsA("ScreenGui") and G.Enabled then
                        for _, D in ipairs(G:GetDescendants()) do
                            if D:IsA("GuiButton") and D.Visible then
                                local T = string.lower(D.Text or "")
                                if string.find(T, "+") and string.find(T, "wins") then
                                    task.spawn(function() pcall(function() D.Activated:Fire() end) end)
                                    task.wait(0.3)
                                end
                            end
                        end
                    end
                end
            end)
        end
    end
end)

print("[✅] พร้อมใช้งาน")
