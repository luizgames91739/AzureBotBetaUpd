--[[
	WARNING: Heads up! This script has not been verified by ScriptBlox. Use at your own risk!
]]
local fov = 296
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local Cam = Workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Ajuste do FOV para celular
if UserInputService.TouchEnabled then
	fov = 163
end

-- Círculo FOV
local FOVring = Drawing.new("Circle")
FOVring.Visible = true
FOVring.Thickness = 2
FOVring.Color = Color3.fromRGB(128, 0, 255)
FOVring.Filled = false
FOVring.Radius = fov
FOVring.Position = Cam.ViewportSize / 2

-- Aimbot ativado
local aimbotEnabled = true

-- ESPs ativos
local ESPs = {}

-- Atualiza o círculo do FOV
local function updateFOV()
	FOVring.Position = Cam.ViewportSize / 2
end

-- Criação da GUI inferior (status)
local function createStatusGui()
	local gui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
	gui.Name = "LeviathanAimbotGui"
	gui.ResetOnSpawn = false

	local frame = Instance.new("Frame", gui)
	frame.AnchorPoint = Vector2.new(0.5, 1)
	frame.Position = UDim2.new(0.5, 0, 1, -30)
	frame.Size = UDim2.new(0, 260, 0, 28)
	frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	frame.BackgroundTransparency = 0.2

	local corner = Instance.new("UICorner", frame)
	corner.CornerRadius = UDim.new(0, 8)

	local label = Instance.new("TextLabel", frame)
	label.Size = UDim2.new(1, -40, 1, 0)
	label.Position = UDim2.new(0, 8, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = "Aimbot Status :"
	label.Font = Enum.Font.SourceSansSemibold
	label.TextSize = 14
	label.TextColor3 = Color3.fromRGB(200, 200, 200)
	label.TextXAlignment = Enum.TextXAlignment.Left

	local dot = Instance.new("TextButton", frame)
	dot.Size = UDim2.new(0, 20, 0, 20)
	dot.AnchorPoint = Vector2.new(1, 0.5)
	dot.Position = UDim2.new(1, -8, 0.5, 0)
	dot.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
	dot.BorderSizePixel = 0
	dot.Text = ""
	local dotCorner = Instance.new("UICorner", dot)
	dotCorner.CornerRadius = UDim.new(1, 0)

	dot.MouseButton1Click:Connect(function()
		aimbotEnabled = not aimbotEnabled
		dot.BackgroundColor3 = aimbotEnabled and Color3.fromRGB(0, 200, 0) or Color3.fromRGB(200, 0, 0)
	end)
end

createStatusGui()

-- Cria ESP (só nome e vida)
local function createESP(player)
	local nameText = Drawing.new("Text")
	nameText.Text = player.Name
	nameText.Size = 14
	nameText.Color = Color3.fromRGB(170, 0, 255)
	nameText.Outline = true
	nameText.OutlineColor = Color3.fromRGB(0, 0, 0)
	nameText.Center = true
	nameText.Font = 3
	nameText.Visible = false

	local healthText = Drawing.new("Text")
	healthText.Size = 14
	healthText.Color = Color3.fromRGB(255, 0, 255)
	healthText.Outline = true
	healthText.OutlineColor = Color3.fromRGB(0, 0, 0)
	healthText.Center = true
	healthText.Font = 3
	healthText.Visible = false

	ESPs[player] = {name = nameText, health = healthText}

	RunService.RenderStepped:Connect(function()
		if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
			nameText.Visible = false
			healthText.Visible = false
			return
		end

		local rootPart = player.Character.HumanoidRootPart
		local head = player.Character:FindFirstChild("Head")
		if not head then return end

		local vector, onScreen = Cam:WorldToViewportPoint(head.Position + Vector3.new(0, 2, 0))
		local humanoid = player.Character:FindFirstChildOfClass("Humanoid")

		if onScreen then
			nameText.Position = Vector2.new(vector.X, vector.Y - 10)
			healthText.Position = Vector2.new(vector.X, vector.Y + 5)
			nameText.Visible = true
			healthText.Visible = true
			nameText.Text = player.DisplayName
			healthText.Text = "HP: " .. math.floor(humanoid.Health)
		else
			nameText.Visible = false
			healthText.Visible = false
		end
	end)
end

-- Cria ESP para todos os jogadores existentes
for _, plr in pairs(Players:GetPlayers()) do
	if plr ~= LocalPlayer then
		createESP(plr)
	end
end

-- Novo jogador
Players.PlayerAdded:Connect(function(plr)
	if plr ~= LocalPlayer then
		createESP(plr)
	end
end)

-- Remove ESP quando o jogador sair
Players.PlayerRemoving:Connect(function(plr)
	if ESPs[plr] then
		for _, obj in pairs(ESPs[plr]) do
			if obj.Remove then obj:Remove() end
		end
		ESPs[plr] = nil
	end
end)

RunService.RenderStepped:Connect(updateFOV)
