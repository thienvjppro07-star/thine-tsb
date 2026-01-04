--------------------------------------------------
-- SERVICES
--------------------------------------------------
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

--------------------------------------------------
-- PLAYER (FIX LOAD SỚM / MÁY KHÁC)
--------------------------------------------------
local player = Players.LocalPlayer
if not player then
	repeat task.wait() until Players.LocalPlayer
	player = Players.LocalPlayer
end

--------------------------------------------------
-- PLAYERGUI (ĐỢI ĐÚNG CÁCH – AN TOÀN)
--------------------------------------------------
local PlayerGui
repeat
	PlayerGui = player:FindFirstChildOfClass("PlayerGui")
	task.wait()
until PlayerGui

--------------------------------------------------
-- SAFE GUI DUPLICATE CHECK (KHÔNG BUG)
--------------------------------------------------
local function isGuiLoaded()
	-- check workspace (system part)
	if Workspace:FindFirstChild("SoloSystemUI") then
		return true
	end

	-- check PlayerGui
	for _, gui in ipairs(PlayerGui:GetChildren()) do
		if gui:IsA("ScreenGui") and gui.Name == "ThinneHubUI" then
			return true
		end
	end

	return false
end

if isGuiLoaded() then
	warn("❌ GUI đã tồn tại, huỷ load để tránh duplicate")
	return
end

--------------------------------------------------
-- CHARACTER / CAMERA / MOUSE
--------------------------------------------------
local mouse = player:GetMouse()
local camera = Workspace.CurrentCamera

local char = player.Character or player.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local humanoid = char:WaitForChild("Humanoid")

--------------------------------------------------
-- 🔁 AUTO REFRESH CHARACTER (FIX DASH / TELE / BAY)
--------------------------------------------------
player.CharacterAdded:Connect(function(newChar)
	char = newChar
	hrp = newChar:WaitForChild("HumanoidRootPart")
	humanoid = newChar:WaitForChild("Humanoid")
end)

--------------------------------------------------
-- SOUND
--------------------------------------------------
local soundId = "rbxassetid://87055325659934"

--------------------------------------------------
-- FLAG ACCEPT (QUAN TRỌNG)
--------------------------------------------------
_G.SOLO_ACCEPTED = false


--------------------------------------------------
-- 🧊 SYSTEM PART (VÔ HÌNH)
--------------------------------------------------
local systemPart = Instance.new("Part")
systemPart.Size = Vector3.new(6, 3.5, 0.2)
systemPart.Anchored = true
systemPart.CanCollide = false
systemPart.Transparency = 1
systemPart.Name = "SoloSystemUI"
systemPart.Parent = workspace

-- Bảo vệ khỏi Destroy
systemPart:GetPropertyChangedSignal("Parent"):Connect(function()
	if not systemPart.Parent then
		systemPart.Parent = workspace
	end
end)

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
local systemPart = workspace:WaitForChild("SoloSystemUI")

-- Xác định GUI type cho mobile hoặc PC
local isMobile = UserInputService.TouchEnabled
local gui

if isMobile then
    gui = Instance.new("BillboardGui")
    gui.Size = UDim2.new(0, 400, 0, 200)
    gui.StudsOffset = Vector3.new(0, 3, 0)
    gui.AlwaysOnTop = true
else
    gui = Instance.new("SurfaceGui")
    gui.Face = Enum.NormalId.Front
    gui.CanvasSize = Vector2.new(800, 400)
    gui.AlwaysOnTop = true
    gui.LightInfluence = 0
end

gui.ResetOnSpawn = false
gui.Parent = systemPart

-- FRAME
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(1,0,1,0)
frame.BackgroundColor3 = Color3.fromRGB(10,15,25)
frame.BackgroundTransparency = 0.2
Instance.new("UICorner", frame).CornerRadius = UDim.new(0,18)

-- TITLE
local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1,-40,0,60)
title.Position = UDim2.new(0,20,0,20)
title.BackgroundTransparency = 1
title.Text = "NOTIFICATION"
title.Font = Enum.Font.GothamBold
title.TextSize = 36
title.TextColor3 = Color3.fromRGB(255,215,0)
title.TextXAlignment = Enum.TextXAlignment.Left

-- MESSAGE
local msg = Instance.new("TextLabel", frame)
msg.Size = UDim2.new(1,-40,0,120)
msg.Position = UDim2.new(0,20,0,90)
msg.BackgroundTransparency = 1
msg.TextWrapped = true
msg.TextYAlignment = Enum.TextYAlignment.Top
msg.Text = "You have acquired the qualifications to be a Player.\nWill you accept?"
msg.Font = Enum.Font.Gotham
msg.TextSize = 28
msg.TextColor3 = Color3.fromRGB(220,220,220)

-- BUTTONS
local accept = Instance.new("TextButton", frame)
accept.Size = UDim2.new(0,240,0,60)
accept.Position = UDim2.new(0.15,0,1,-90)
accept.Text = "ACCEPT"
accept.Font = Enum.Font.GothamBold
accept.TextSize = 30
accept.BackgroundColor3 = Color3.fromRGB(255,215,0)
accept.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", accept).CornerRadius = UDim.new(0,14)

local decline = Instance.new("TextButton", frame)
decline.Size = UDim2.new(0,240,0,60)
decline.Position = UDim2.new(0.55,0,1,-90)
decline.Text = "DECLINE"
decline.Font = Enum.Font.GothamBold
decline.TextSize = 30
decline.BackgroundColor3 = Color3.fromRGB(50,50,50)
decline.TextColor3 = Color3.new(1,1,1)
Instance.new("UICorner", decline).CornerRadius = UDim.new(0,14)

-- LOGIC
accept.MouseButton1Click:Connect(function()
    _G.SOLO_ACCEPTED = true
    if gui then gui:Destroy() end
    task.delay(3.5, function()
        if systemPart and systemPart.Parent then systemPart:Destroy() end
    end)
end)

decline.MouseButton1Click:Connect(function()
    _G.SOLO_DECLINED = true
    if gui then gui:Destroy() end
    if systemPart and systemPart.Parent then systemPart:Destroy() end
end)

-- XOAY PART (PC vẫn dùng)
local DISTANCE, HEIGHT, ROTATE_SMOOTH = 6, 2.5, 0.08
local currentCF = systemPart.CFrame
RunService.RenderStepped:Connect(function()
    if not systemPart or not systemPart.Parent or not hrp then return end
    local targetPos = hrp.Position + hrp.CFrame.LookVector * DISTANCE + Vector3.new(0, HEIGHT, 0)
    local targetCF = CFrame.lookAt(targetPos, hrp.Position + Vector3.new(0, HEIGHT, 0))
    currentCF = currentCF:Lerp(targetCF, ROTATE_SMOOTH)
    systemPart.CFrame = currentCF
end)


--------------------------------------------------
-- BUTTON LOGIC
--------------------------------------------------
accept.MouseButton1Click:Connect(function()
	_G.SOLO_ACCEPTED = true

	-- Xóa notification ngay
	if surfaceGui then
		surfaceGui:Destroy()
	end

	-- Delay 3-4 giây rồi xóa systemPart
	task.delay(3.5, function()
		if systemPart and systemPart.Parent then
			systemPart:Destroy()
		end
	end)
end)


decline.MouseButton1Click:Connect(function()
	_G.SOLO_DECLINED = true -- đánh dấu đã từ chối
	if surfaceGui then
		surfaceGui:Destroy()
	end
	if systemPart and systemPart.Parent then
		systemPart:Destroy() -- xóa luôn part
	end
end)

--------------------------------------------------
-- CHỜ ACCEPT
--------------------------------------------------
repeat task.wait() until _G.SOLO_ACCEPTED

--------------------------------------------------
-- 🔹 LOADER SAU ACCEPT
--------------------------------------------------
local player = game.Players.LocalPlayer
local systemPart = workspace:WaitForChild("SoloSystemUI")

-- Loader SurfaceGui
local loaderGui = Instance.new("SurfaceGui", systemPart)
loaderGui.Face = Enum.NormalId.Front
loaderGui.AlwaysOnTop = true
loaderGui.LightInfluence = 0
loaderGui.CanvasSize = Vector2.new(300, 150)

local loaderFrame = Instance.new("Frame", loaderGui)
loaderFrame.Size = UDim2.new(1,0,1,0)
loaderFrame.BackgroundColor3 = Color3.fromRGB(10, 15, 25)
loaderFrame.BackgroundTransparency = 1
Instance.new("UICorner", loaderFrame).CornerRadius = UDim.new(0,10)

local loaderTitle = Instance.new("TextLabel", loaderFrame)
loaderTitle.Size = UDim2.new(1,0,0,40)
loaderTitle.Position = UDim2.new(0,0,0,10)
loaderTitle.BackgroundTransparency = 1
loaderTitle.TextColor3 = Color3.new(255,215,0)
loaderTitle.Font = Enum.Font.SourceSansBold
loaderTitle.TextSize = 26
loaderTitle.Text = "Thinne Hub"
loaderTitle.TextTransparency = 1

local stroke = Instance.new("UIStroke", frame)
stroke.Color = Color3.fromRGB(0, 200, 255)
stroke.Thickness = 3
stroke.Transparency = 1

local loading = Instance.new("TextLabel", loaderFrame)
loading.Size = UDim2.new(1,0,0,30)
loading.Position = UDim2.new(0,0,1,-40)
loading.BackgroundTransparency = 1
loading.TextColor3 = Color3.new(1,1,1)
loading.Font = Enum.Font.SourceSans
loading.TextSize = 20
loading.Text = "Loading..."
loading.TextTransparency = 1

-- FADE IN LOADER
for i=0,1,0.05 do
	loaderFrame.BackgroundTransparency = 1-i
	loaderTitle.TextTransparency = 1-i
	loading.TextTransparency = 1-i
	task.wait(0.03)
end

task.wait(1)
loading.Text = "Loading Complete!"
loading.TextColor3 = Color3.fromRGB(0,255,0)
task.wait(0.5)
for i=0,1,0.05 do
	loaderFrame.BackgroundTransparency = i
	loaderTitle.TextTransparency = i
	loading.TextTransparency = i
	task.wait(0.03)
end

-- Xóa Loader
loaderGui:Destroy()

--------------------------------------------------
-- 🔹 ANIMATIONS CHO NHÂN VẬT
--------------------------------------------------
local animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)

local teleAnim = Instance.new("Animation")
teleAnim.AnimationId = "rbxassetid://15957361339"
local teleTrack = animator:LoadAnimation(teleAnim)
teleTrack.Priority = Enum.AnimationPriority.Action

local flyAnim = Instance.new("Animation")
flyAnim.AnimationId = "rbxassetid://134743839442030"
local flyTrack = animator:LoadAnimation(flyAnim)
flyTrack.Priority = Enum.AnimationPriority.Action
flyTrack.Looped = true

player.CharacterAdded:Connect(function(char)
	humanoid = char:WaitForChild("Humanoid")
	animator = humanoid:FindFirstChildOfClass("Animator") or Instance.new("Animator", humanoid)

	teleTrack = animator:LoadAnimation(teleAnim)
	teleTrack.Priority = Enum.AnimationPriority.Action

	flyTrack = animator:LoadAnimation(flyAnim)
	flyTrack.Priority = Enum.AnimationPriority.Action
	flyTrack.Looped = true
end)

print("🔥 Solo Leveling System Accepted")

-----------------------------------------------------
-- 🧭 MAIN UI
-----------------------------------------------------
local player = game.Players.LocalPlayer
local ui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
ui.Name = "ThinneHubUI"
ui.ResetOnSpawn = false
 
-- 🟦 Nút menu hình vuông có thể kéo
local menuButton = Instance.new("ImageButton", ui)
menuButton.Size = UDim2.new(0, 60, 0, 60)
menuButton.Position = UDim2.new(0, 50, 0.8, 0)
menuButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
menuButton.Image = "rbxassetid://109530662333365"
menuButton.ScaleType = Enum.ScaleType.Fit
menuButton.AutoButtonColor = true
Instance.new("UICorner", menuButton).CornerRadius = UDim.new(0.2, 0)
 
-- Viền phát sáng
local glow = Instance.new("UIStroke", menuButton)
glow.Thickness = 4
glow.Color = Color3.fromRGB(255, 215, 0)
glow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
 
-- Hiệu ứng nhấp nháy
game:GetService("TweenService"):Create(
	glow,
	TweenInfo.new(1.2, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, true),
	{Transparency = 0.5}
):Play()
 
-- Cho phép kéo nút trên cả PC và Mobile
local UIS = game:GetService("UserInputService")
local dragging, dragInput, dragStart, startPos
 
local function update(input)
	local delta = input.Position - dragStart
	menuButton.Position = UDim2.new(
		startPos.X.Scale,
		startPos.X.Offset + delta.X,
		startPos.Y.Scale,
		startPos.Y.Offset + delta.Y
	)
end
 
menuButton.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = menuButton.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)
 
menuButton.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)
 
UIS.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		update(input)
	end
end)
 
-----------------------------------------------------
-- 📋 PANEL MENU CHÍNH
-----------------------------------------------------
local panel = Instance.new("Frame", ui)
panel.Size = UDim2.new(0, 640, 0, 420)
panel.Position = UDim2.new(0.5, -320, 0.5, -210)
panel.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
panel.BackgroundTransparency = 0.1
panel.Visible = false
local corner = Instance.new("UICorner", panel)
corner.CornerRadius = UDim.new(0, 14)
local stroke = Instance.new("UIStroke", panel)
stroke.Color = Color3.fromRGB(255, 215, 0)
stroke.Thickness = 0.4
 
local titleText = Instance.new("TextLabel", panel)
titleText.Size = UDim2.new(1, -20, 0, 36)
titleText.Position = UDim2.new(0, 10, 0, 10)
titleText.BackgroundTransparency = 1
titleText.Text = "Thinne Hub - Main Menu - Prime"
titleText.TextColor3 = Color3.fromRGB(255, 215, 0)
titleText.Font = Enum.Font.GothamBold
titleText.TextSize = 22
titleText.TextXAlignment = Enum.TextXAlignment.Left
 
local left = Instance.new("Frame", panel)
left.Size = UDim2.new(0.5, -15, 1, -60)
left.Position = UDim2.new(0, 10, 0, 56)
left.BackgroundTransparency = 1
 
local right = Instance.new("Frame", panel)
right.Size = UDim2.new(0.5, -15, 1, -60)
right.Position = UDim2.new(0.5, 5, 0, 56)
right.BackgroundTransparency = 1
 
-- 📝 Tạo label bên trái
local function createLeftLabel(txt, index)
	local lbl = Instance.new("TextLabel", left)
	lbl.Size = UDim2.new(1, 0, 0, 24)
	lbl.Position = UDim2.new(0, 0, 0, (index - 1) * 30)
	lbl.BackgroundTransparency = 1
	lbl.Font = Enum.Font.Gotham
	lbl.TextSize = 18
	lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
	lbl.TextXAlignment = Enum.TextXAlignment.Left
 
	if txt == "Created by Thinneee" then
		lbl.Font = Enum.Font.GothamBold
		lbl.TextSize = 22
		lbl.TextColor3 = Color3.fromRGB(120, 40, 160)
		local stroke = Instance.new("UIStroke", lbl)
		stroke.Thickness = 0.4
		stroke.Color = Color3.fromRGB(80, 0, 120)
	end
 
	lbl.Text = txt
end
 
local leftItems = {
	"R - Teleport","T - Teleport Player","U - Teleport Sky",
	"Y - Fly Mode","C - Aimbot","X - Noclip","Z - Speed Max",
	"V - Teleport Void","H - OMG Teleport","Created by Thinneee"
}
 
for i, v in ipairs(leftItems) do
	createLeftLabel(v, i)
end
 
-----------------------------------------------------
-- 🎯 BẤM MENU ĐỂ HIỆN / ẨN GUI
-----------------------------------------------------
menuButton.MouseButton1Click:Connect(function()
	panel.Visible = not panel.Visible
end)
 
 
-- 🔘 Toggle menu khi bấm nút
menuButton.MouseButton1Click:Connect(function()
	panel.Visible = not panel.Visible
end)
-----------------------------------------------------
-- 🌀 FLY AROUND PLAYER (Persistent Orbit - Top Down Camera)
-----------------------------------------------------
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

local orbitConn
local orbitTarget
local orbitEnabled = false
local mode = 1
local radiusOptions = {3, 6, 9}
local heightOptions = {8, 12, 18}

-----------------------------------------------------
-- FUNCTIONS
-----------------------------------------------------
local function restoreCamera()
	camera.CameraSubject = player.Character:FindFirstChild("Humanoid")
	camera.CameraType = Enum.CameraType.Custom
end

local function stopOrbit()
	if orbitConn then orbitConn:Disconnect() orbitConn = nil end
	restoreCamera()
	orbitTarget = nil
	orbitEnabled = false
end

local function getTargetHRP(target)
	if not target or not target.Character then return nil end
	local hrpTarget = target.Character:FindFirstChild("HumanoidRootPart")
	return hrpTarget
end

local function flyAround(targetPlayer)
	stopOrbit()
	if not targetPlayer then return end

	orbitTarget = targetPlayer
	orbitEnabled = true
	camera.CameraType = Enum.CameraType.Scriptable

	local angle, speed = 0, math.rad(30 * 360)

	local function onTargetRespawn(newChar)
		-- Khi target hồi sinh, tự động cập nhật HRP mới
		newChar:WaitForChild("HumanoidRootPart")
	end
	targetPlayer.CharacterAdded:Connect(onTargetRespawn)

	orbitConn = RunService.RenderStepped:Connect(function(dt)
		if not orbitEnabled or not orbitTarget then return end

		local hrpTarget = getTargetHRP(orbitTarget)
		if not hrpTarget then return end

		if hrp and hrp.Parent then
			angle += dt * speed
			local r = radiusOptions[mode]
			local pos = hrpTarget.Position
			local offset = Vector3.new(math.cos(angle) * r, 1, math.sin(angle) * r)
			local newPos = pos + offset

			-- Nhân vật bay quanh target
			hrp.CFrame = CFrame.new(newPos, hrpTarget.Position)

			-- Camera nhìn từ trên xuống
			local camHeight = heightOptions[mode]
			local camPos = hrpTarget.Position + Vector3.new(0, camHeight, 0)
			camera.CFrame = CFrame.new(camPos, hrpTarget.Position)
		end
	end)

	-- Nếu target rời game -> dừng
	targetPlayer.AncestryChanged:Connect(function(_, parent)
		if not parent then stopOrbit() end
	end)
end


-----------------------------------------------------
-- UI SECTION
-----------------------------------------------------
for _, obj in pairs(right:GetChildren()) do
	if not obj:IsA("UIListLayout") then
		obj:Destroy()
	end
end

local rightTitle = Instance.new("TextLabel", right)
rightTitle.Size = UDim2.new(1, 0, 0, 24)
rightTitle.Text = "Fly Around Player"
rightTitle.Font = Enum.Font.GothamBold
rightTitle.TextSize = 18
rightTitle.TextColor3 = Color3.fromRGB(0,255,255)
rightTitle.BackgroundTransparency = 1
rightTitle.TextXAlignment = Enum.TextXAlignment.Left

local nameBox = Instance.new("TextBox", right)
nameBox.Size = UDim2.new(0.9, 0, 0, 30)
nameBox.Position = UDim2.new(0, 0, 0, 36)
nameBox.BackgroundColor3 = Color3.fromRGB(35,35,35)
nameBox.TextColor3 = Color3.fromRGB(255,255,255)
nameBox.PlaceholderText = "Player name..."
nameBox.Font = Enum.Font.Gotham
nameBox.TextSize = 16
Instance.new("UICorner", nameBox).CornerRadius = UDim.new(0,6)

-----------------------------------------------------
-- Toggle (ON/OFF)
-----------------------------------------------------
local toggleFrame = Instance.new("Frame", right)
toggleFrame.Size = UDim2.new(0, 70, 0, 30)
toggleFrame.Position = UDim2.new(0, 0, 0, 76)
toggleFrame.BackgroundColor3 = Color3.fromRGB(80,80,80)
Instance.new("UICorner", toggleFrame).CornerRadius = UDim.new(1,0)

local toggleCircle = Instance.new("Frame", toggleFrame)
toggleCircle.Size = UDim2.new(0,26,0,26)
toggleCircle.Position = UDim2.new(0,2,0,2)
toggleCircle.BackgroundColor3 = Color3.fromRGB(200,200,200)
Instance.new("UICorner", toggleCircle).CornerRadius = UDim.new(1,0)

local toggleState = false

toggleFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		toggleState = not toggleState
		if toggleState then
			toggleFrame.BackgroundColor3 = Color3.fromRGB(0,200,100)
			toggleCircle:TweenPosition(UDim2.new(1,-28,0,2),"Out","Sine",0.2,true)
			local name = nameBox.Text
			if name == "" then return end
			for _, plr in pairs(Players:GetPlayers()) do
				if plr.Name:lower():sub(1,#name) == name:lower() then
					flyAround(plr)
					break
				end
			end
		else
			toggleFrame.BackgroundColor3 = Color3.fromRGB(80,80,80)
			toggleCircle:TweenPosition(UDim2.new(0,2,0,2),"Out","Sine",0.2,true)
			stopOrbit()
		end
	end
end)

-----------------------------------------------------
-- Mode Selector (1–2–3)
-----------------------------------------------------
local modeFrame = Instance.new("Frame", right)
modeFrame.Size = UDim2.new(0, 120, 0, 30)
modeFrame.Position = UDim2.new(0, 90, 0, 76)
modeFrame.BackgroundColor3 = Color3.fromRGB(40,40,40)
Instance.new("UICorner", modeFrame).CornerRadius = UDim.new(0,8)

local uiStroke = Instance.new("UIStroke", modeFrame)
uiStroke.Color = Color3.fromRGB(0,255,255)
uiStroke.Thickness = 1.2

local selector = Instance.new("Frame", modeFrame)
selector.Size = UDim2.new(0, 28, 0, 28)
selector.Position = UDim2.new(0, 2, 0, 1)
selector.BackgroundColor3 = Color3.fromRGB(0,200,255)
Instance.new("UICorner", selector).CornerRadius = UDim.new(1,0)

for i = 1,3 do
	local btn = Instance.new("TextButton", modeFrame)
	btn.Size = UDim2.new(0, 40, 0, 30)
	btn.Position = UDim2.new(0, (i-1)*40, 0, 0)
	btn.Text = tostring(i)
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 18
	btn.BackgroundTransparency = 1
	btn.TextColor3 = Color3.fromRGB(255,255,255)

	btn.MouseButton1Click:Connect(function()
		mode = i
		selector:TweenPosition(UDim2.new(0, (i-1)*40+2, 0, 1), "Out", "Sine", 0.2, true)
	end)
end

-----------------------------------------------------
-- 🧍 SHOW PLAYERS (3D ABOVE HEAD) - FIXED
-- Replace previous Show Players section with this block
-----------------------------------------------------
local showLabel = Instance.new("TextLabel", right)
showLabel.Size = UDim2.new(0, 120, 0, 30)
showLabel.Position = UDim2.new(0, 0, 0, 130)
showLabel.BackgroundTransparency = 1
showLabel.Text = "Show Players"
showLabel.Font = Enum.Font.Gotham
showLabel.TextSize = 16
showLabel.TextColor3 = Color3.fromRGB(255,255,255)
showLabel.TextXAlignment = Enum.TextXAlignment.Left

local toggleFrame = Instance.new("Frame", right)
toggleFrame.Size = UDim2.new(0, 50, 0, 26)
toggleFrame.Position = UDim2.new(0, 130, 0, 132)
toggleFrame.BackgroundColor3 = Color3.fromRGB(80,80,80)
toggleFrame.BorderSizePixel = 0
toggleFrame.ClipsDescendants = true
Instance.new("UICorner", toggleFrame).CornerRadius = UDim.new(1,0)

local toggleCircle = Instance.new("Frame", toggleFrame)
toggleCircle.Size = UDim2.new(0,22,0,22)
toggleCircle.Position = UDim2.new(0,2,0,2)
toggleCircle.BackgroundColor3 = Color3.fromRGB(200,200,200)
Instance.new("UICorner", toggleCircle).CornerRadius = UDim.new(1,0)

local showPlayers = false
local nameTags = {}       -- [player] -> BillboardGui
local playerConns = {}    -- [player] -> {charConn, teamConn}
local globalConns = {}    -- store global connections (PlayerAdded/PlayerRemoving)

-- helper: safe get team color
local function getPlayerColor(plr)
	if plr and plr.Team and plr.Team.TeamColor then
		return plr.Team.TeamColor.Color
	end
	return Color3.fromRGB(255,255,255)
end

-- create or recreate name tag for a player (attach to Head)
local function createNameTag(plr)
	-- remove old tag if exists (avoid duplicates)
	if nameTags[plr] then
		pcall(function() nameTags[plr]:Destroy() end)
		nameTags[plr] = nil
	end

	-- only create for others (not local player)
	if plr == player then return end
	if not plr.Character or not plr.Character.Parent then return end

	local head = plr.Character:FindFirstChild("Head")
	if not head then
		-- try wait a little; if Head arrives, attach
		head = plr.Character:WaitForChild("Head", 2)
		if not head then return end
	end

	local color = getPlayerColor(plr)

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "ThinneNameTag"
	billboard.Adornee = head
	billboard.Size = UDim2.new(0, 200, 0, 28)
	billboard.StudsOffset = Vector3.new(0, 2.6, 0)
	billboard.AlwaysOnTop = true
	billboard.ResetOnSpawn = false

	local nameLabel = Instance.new("TextLabel", billboard)
	nameLabel.Size = UDim2.new(1,0,1,0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = plr.Name .. (plr.Team and (" ["..plr.Team.Name.."]") or "")
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextScaled = true
	nameLabel.TextColor3 = color
	nameLabel.TextStrokeTransparency = 0.6

	billboard.Parent = head
	nameTags[plr] = billboard
end

local function removeNameTag(plr)
	if nameTags[plr] then
		pcall(function() nameTags[plr]:Destroy() end)
		nameTags[plr] = nil
	end
end

-- update color/text if team changed or name changed
local function updateNameTag(plr)
	local tag = nameTags[plr]
	if tag and plr then
		local lbl = tag:FindFirstChildOfClass("TextLabel")
		if lbl then
			lbl.Text = plr.Name .. (plr.Team and (" ["..plr.Team.Name.."]") or "")
			lbl.TextColor3 = getPlayerColor(plr)
		end
	end
end

-- connect handlers for a single player (store conns to allow disconnecting later)
local function connectPlayer(plr)
	-- avoid duplicate connects
	if playerConns[plr] then return end
	playerConns[plr] = {}

	-- CharacterAdded: recreate tag when respawn
	local charConn = plr.CharacterAdded:Connect(function(char)
		-- small delay so head exists
		task.delay(0.2, function()
			if showPlayers then createNameTag(plr) end
		end)
	end)
	playerConns[plr].charConn = charConn

	-- Team change: update color/name text
	local teamConn = plr:GetPropertyChangedSignal("Team"):Connect(function()
		updateNameTag(plr)
	end)
	playerConns[plr].teamConn = teamConn

	-- Also update if DisplayName / Name changes
	local nameConn = plr:GetPropertyChangedSignal("DisplayName"):Connect(function()
		updateNameTag(plr)
	end)
	playerConns[plr].nameConn = nameConn
end

local function disconnectPlayer(plr)
	local conns = playerConns[plr]
	if conns then
		for _,c in pairs(conns) do
			if c and c.Disconnect then
				pcall(function() c:Disconnect() end)
			end
		end
		playerConns[plr] = nil
	end
end

-- show all current players and set up per-player connections
local function showAllPlayers()
	-- first ensure clean state
	hideAllPlayers = hideAllPlayers -- to satisfy later reference
	-- create for existing players
	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= player then
			connectPlayer(plr)
			-- try create immediately (if character exists)
			pcall(function()
				createNameTag(plr)
			end)
		end
	end

	-- global connect: PlayerAdded
	if not globalConns.playerAdded then
		globalConns.playerAdded = Players.PlayerAdded:Connect(function(plr)
			-- wait a moment for character to spawn
			task.delay(0.6, function()
				if showPlayers then
					connectPlayer(plr)
					createNameTag(plr)
				end
			end)
		end)
	end

	-- global connect: PlayerRemoving
	if not globalConns.playerRemoving then
		globalConns.playerRemoving = Players.PlayerRemoving:Connect(function(plr)
			removeNameTag(plr)
			disconnectPlayer(plr)
		end)
	end
end

-- hide all and disconnect everything
function hideAllPlayers()
	-- remove tags
	for plr, tag in pairs(nameTags) do
		pcall(function() tag:Destroy() end)
	end
	nameTags = {}

	-- disconnect per-player connections
	for plr, _ in pairs(playerConns) do
		disconnectPlayer(plr)
	end
	playerConns = {}

	-- disconnect global connections
	for k, conn in pairs(globalConns) do
		if conn and conn.Disconnect then
			pcall(function() conn:Disconnect() end)
		end
		globalConns[k] = nil
	end
end

-- toggle behavior
toggleFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		showPlayers = not showPlayers
		if showPlayers then
			toggleFrame.BackgroundColor3 = Color3.fromRGB(0,200,100)
			toggleCircle:TweenPosition(UDim2.new(1,-24,0,2),"Out","Sine",0.18,true)
			-- show and connect
			showAllPlayers()
		else
			toggleFrame.BackgroundColor3 = Color3.fromRGB(80,80,80)
			toggleCircle:TweenPosition(UDim2.new(0,2,0,2),"Out","Sine",0.18,true)
			-- hide and disconnect
			hideAllPlayers()
		end
	end
end)

-- cleanup on script end / player leaving (just in case)
player.AncestryChanged:Connect(function()
	if not player:IsDescendantOf(game) then
		hideAllPlayers()
	end
end)

-- ensure when local character removed we don't leak (optional safety)
player.CharacterRemoving:Connect(function()
	-- nothing to do to self's tags, but ensure no residuals
	if not showPlayers then hideAllPlayers() end
end)


-----------------------------------------------------
-- Toggle menu
-----------------------------------------------------
menuButton.MouseButton1Click:Connect(function()
	panel.Visible = not panel.Visible
end)


-----------------------------------------------------
-- ===== The rest of your original features (teleport, fly, noclip...)
-- Keep original bindings, unchanged semantics.
-- (We re-use doTeleport and related functions below)
-----------------------------------------------------
-- ZaWarudoEffect / doTeleport (kept same as earlier)
local function ZaWarudoEffect()
	local bw = Instance.new("ColorCorrectionEffect", Lighting)
	bw.Saturation = -1
	bw.Contrast = 0.2
	task.delay(0.05, function() if bw then bw:Destroy() end end)
end

local function doTeleport(position)
    if not hrp then return end
    pcall(function()
        hrp.CFrame = CFrame.new(position)
    end)
    local s = Instance.new("Sound", hrp)
    s.SoundId = soundId
    s.Volume = 5
    s.PlayOnRemove = true
    s:Destroy()
    ZaWarudoEffect()
    if teleTrack.IsPlaying then teleTrack:Stop() end
    teleTrack:Play()
end

-- Quick Edge Teleport V (TOGGLE + CENTER + SOUND)

local VOID_Y = -500
local PLATFORM_SIZE = Vector3.new(5000, 2, 5000)

-- 🔊 VOID SOUND
local VOID_SOUND_ID = "rbxassetid://91942148613394" -- đổi nếu muốn
local voidSound

local voidPlatform
local isInVoid = false

local savedCFrame = nil
local voidCenterCFrame = nil

local function createVoidPlatform(centerCF)
	if voidPlatform and voidPlatform.Parent then return end

	voidPlatform = Instance.new("Part")
	voidPlatform.Name = "VoidPlatform"
	voidPlatform.Size = PLATFORM_SIZE
	voidPlatform.CFrame = centerCF
	voidPlatform.Anchored = true
	voidPlatform.CanCollide = true
	voidPlatform.Transparency = 0.5
	voidPlatform.Parent = workspace
end

-- 🔊 SOUND CONTROL
local function startVoidSound()
	if voidSound then return end

	voidSound = Instance.new("Sound")
	voidSound.SoundId = VOID_SOUND_ID
	voidSound.Looped = true
	voidSound.Volume = 1
	voidSound.Parent = workspace.CurrentCamera -- nghe rõ nhất
	voidSound:Play()
end

local function stopVoidSound()
	if voidSound then
		voidSound:Stop()
		voidSound:Destroy()
		voidSound = nil
	end
end

local function quickEdgeTeleport()
	if not hrp or not hrp.Parent then return end

	-- 🔁 V LẦN 2 → QUAY LẠI
	if isInVoid then
		if savedCFrame then
			hrp.CFrame = savedCFrame
		end
		isInVoid = false
		stopVoidSound()
		return
	end

	-- ⬇️ V LẦN 1 → XUỐNG VOID
	savedCFrame = hrp.CFrame
	isInVoid = true

	if not voidCenterCFrame then
		voidCenterCFrame = CFrame.new(
			hrp.Position.X,
			VOID_Y,
			hrp.Position.Z
		)
		createVoidPlatform(voidCenterCFrame)
	end

	-- TELE ĐÚNG GIỮA PART
	local hrpHeight = hrp.Size.Y
	local platformTopY = voidPlatform.Position.Y + (voidPlatform.Size.Y / 2)
	local correctY = platformTopY + (hrpHeight / 2)

	hrp.CFrame = CFrame.new(
		voidPlatform.Position.X,
		correctY,
		voidPlatform.Position.Z
	)

	startVoidSound()
end

UIS.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.V then
		quickEdgeTeleport()
	end
end)

-- 🔄 RESPAWN SAFE
player.CharacterAdded:Connect(function(char)
	character = char
	hrp = character:WaitForChild("HumanoidRootPart")
	isInVoid = false
	savedCFrame = nil
	voidCenterCFrame = nil
	stopVoidSound()
end)

-- CharacterAdded handling
player.CharacterAdded:Connect(function(newChar)
	char = newChar
	hrp = char:WaitForChild("HumanoidRootPart")
	humanoid = char:WaitForChild("Humanoid")
	-- restore originalPlatformStand flag variable
	originalPlatformStand = humanoid.PlatformStand
	-- stop flyAround if running (prevents orphan movement)
	if flyAroundRunning then
		stopFlyAround()
	end
end)

-- Speedmax (Z)
local speedEnabled = false
local speedMax = 100
local originalWalkSpeed = nil
local speedEnforcerConn = nil
local function startSpeedEnforcer()
	humanoid = char and char:FindFirstChildOfClass("Humanoid") or humanoid
	if not humanoid then return end
	originalWalkSpeed = originalWalkSpeed or (humanoid.WalkSpeed or 16)
	pcall(function() humanoid.WalkSpeed = speedMax end)
	if speedEnforcerConn then speedEnforcerConn:Disconnect() end
	speedEnforcerConn = RunService.RenderStepped:Connect(function()
		if not char or not char.Parent then return end
		humanoid = char:FindFirstChildOfClass("Humanoid") or humanoid
		if humanoid and humanoid.WalkSpeed ~= speedMax then
			pcall(function() humanoid.WalkSpeed = speedMax end)
		end
	end)
end
local function stopSpeedEnforcer()
	if speedEnforcerConn then speedEnforcerConn:Disconnect() end
	humanoid = char and char:FindFirstChildOfClass("Humanoid") or humanoid
	if humanoid and originalWalkSpeed then
		pcall(function() humanoid.WalkSpeed = originalWalkSpeed end)
	end
end
UIS.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.Z then
		speedEnabled = not speedEnabled
		if speedEnabled then startSpeedEnforcer() else stopSpeedEnforcer() end
	end
end)

-- Noclip (X)
local noclipEnabled = false
local noclipConn = nil
local origPartStates = {}
local function enableNoclip()
	if not char then return end
	for _, part in pairs(char:GetDescendants()) do
		if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
			if not origPartStates[part] then
				origPartStates[part] = { CanCollide = part.CanCollide, Transparency = part.Transparency }
			end
			pcall(function() part.CanCollide = false part.Transparency = math.max(part.Transparency,0.45) end)
		end
	end
	if noclipConn then noclipConn:Disconnect() end
	noclipConn = RunService.Stepped:Connect(function()
		if char then
			for _, part in pairs(char:GetDescendants()) do
				if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
					if part.CanCollide then pcall(function() part.CanCollide = false end) end
					if part.Transparency < 0.45 then pcall(function() part.Transparency = 0.45 end) end
				end
			end
		end
	end)
end
local function disableNoclip()
	if noclipConn then noclipConn:Disconnect() noclipConn = nil end
	for part, state in pairs(origPartStates) do
		if part and part.Parent then
			pcall(function()
				part.CanCollide = state.CanCollide
				part.Transparency = state.Transparency
			end)
		end
	end
	origPartStates = {}
end
UIS.InputBegan:Connect(function(input,gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.X then
		noclipEnabled = not noclipEnabled
		if noclipEnabled then enableNoclip() else disableNoclip() end
	end
end)

-- Teleport R
-- SOLARA FLYCAM XUAT HON (HOAN CHINH)

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CAS = game:GetService("ContextActionService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

--------------------------------------------------
-- CONFIG
--------------------------------------------------
local HOLD_TIME = 0.3
local SPEED = 90
local SENS = 0.25

--------------------------------------------------
-- STATE
--------------------------------------------------
local holdingR = false
local holdStart = 0
local holdToken = 0
local flyCam = false

local camPos
local lastFlyCamPos
local yaw, pitch = 0, 0
local conn

local oldWalkSpeed, oldJumpPower, oldAutoRotate

--------------------------------------------------
-- FULL KEY LIST (A-Z + 0-9) ❌ TRỪ R
--------------------------------------------------
local ALL_KEYS = {
	Enum.KeyCode.A, Enum.KeyCode.B, Enum.KeyCode.C, Enum.KeyCode.D, Enum.KeyCode.E,
	Enum.KeyCode.F, Enum.KeyCode.G, Enum.KeyCode.H, Enum.KeyCode.I, Enum.KeyCode.J,
	Enum.KeyCode.K, Enum.KeyCode.L, Enum.KeyCode.M, Enum.KeyCode.N, Enum.KeyCode.O,
	Enum.KeyCode.P,
	Enum.KeyCode.Q, -- block Q cho nhân vật
	Enum.KeyCode.S, Enum.KeyCode.T, Enum.KeyCode.U, Enum.KeyCode.V,
	Enum.KeyCode.W, Enum.KeyCode.X, Enum.KeyCode.Y, Enum.KeyCode.Z,

	Enum.KeyCode.Zero, Enum.KeyCode.One, Enum.KeyCode.Two, Enum.KeyCode.Three,
	Enum.KeyCode.Four, Enum.KeyCode.Five, Enum.KeyCode.Six,
	Enum.KeyCode.Seven, Enum.KeyCode.Eight, Enum.KeyCode.Nine,
}

--------------------------------------------------
-- BLOCK / UNBLOCK INPUT
--------------------------------------------------
local function blockAllKeys()
	for _, key in ipairs(ALL_KEYS) do
		CAS:BindAction(
			"Block_" .. key.Name,
			function() return Enum.ContextActionResult.Sink end,
			false,
			key
		)
	end
end

local function unblockAllKeys()
	for _, key in ipairs(ALL_KEYS) do
		CAS:UnbindAction("Block_" .. key.Name)
	end
end

--------------------------------------------------
-- FLYCAM CORE
--------------------------------------------------
local function enableFlyCam()
	flyCam = true
	lastFlyCamPos = nil
	print("[FlyCam] ON")

	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	local hrp = char and char:FindFirstChild("HumanoidRootPart")

	if hum then
		oldWalkSpeed = hum.WalkSpeed
		oldJumpPower = hum.JumpPower
		oldAutoRotate = hum.AutoRotate

		hum.WalkSpeed = 0
		hum.JumpPower = 0
		hum.AutoRotate = false
	end

	if hrp then
		hrp.AssemblyLinearVelocity = Vector3.zero
		camPos = hrp.Position
	else
		camPos = camera.CFrame.Position
	end

	blockAllKeys()

	camera.CameraType = Enum.CameraType.Scriptable
	UIS.MouseBehavior = Enum.MouseBehavior.LockCenter
	UIS.MouseIconEnabled = false

	yaw, pitch = 0, 0

	conn = RunService.RenderStepped:Connect(function(dt)
		local delta = UIS:GetMouseDelta()
		yaw -= delta.X * SENS
		pitch = math.clamp(pitch - delta.Y * SENS, -80, 80)

		local rot =
			CFrame.Angles(0, math.rad(yaw), 0) *
			CFrame.Angles(math.rad(pitch), 0, 0)

		local dir = Vector3.zero
		if UIS:IsKeyDown(Enum.KeyCode.W) then dir += rot.LookVector end
		if UIS:IsKeyDown(Enum.KeyCode.S) then dir -= rot.LookVector end
		if UIS:IsKeyDown(Enum.KeyCode.A) then dir -= rot.RightVector end
		if UIS:IsKeyDown(Enum.KeyCode.D) then dir += rot.RightVector end
		if UIS:IsKeyDown(Enum.KeyCode.E) then dir += Vector3.new(0,1,0) end
		if UIS:IsKeyDown(Enum.KeyCode.Q) then dir -= Vector3.new(0,1,0) end

		if dir.Magnitude > 0 then
			camPos += dir.Unit * SPEED * dt
		end

		lastFlyCamPos = camPos
		camera.CFrame = CFrame.new(camPos) * rot
	end)
end

local function disableFlyCam()
	print("[FlyCam] OFF")

	if conn then
		conn:Disconnect()
		conn = nil
	end

	unblockAllKeys()

	UIS.MouseBehavior = Enum.MouseBehavior.Default
	UIS.MouseIconEnabled = true
	camera.CameraType = Enum.CameraType.Custom

	local char = player.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")

	if hum then
		hum.WalkSpeed = oldWalkSpeed or 16
		hum.JumpPower = oldJumpPower or 50
		hum.AutoRotate = (oldAutoRotate ~= false)
	end

	flyCam = false
end

--------------------------------------------------
-- INPUT HOLD R (ANTI-SPAM)
--------------------------------------------------
UIS.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode ~= Enum.KeyCode.R then return end

	-- ĐANG FLYCAM → TẮT + TELE TỚI FLYCAM
	if flyCam then
		local pos = lastFlyCamPos
		disableFlyCam()
		if pos then
			doTeleport(pos + Vector3.new(0, 2.5, 0))
		end
		return
	end

	holdingR = true
	holdStart = tick()
	holdToken += 1
	local myToken = holdToken

	task.delay(HOLD_TIME, function()
		if holdingR
			and holdToken == myToken
			and not flyCam
			and (tick() - holdStart) >= HOLD_TIME
		then
			enableFlyCam()
		end
	end)
end)

UIS.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.R then
		holdingR = false
	end
end)

--------------------------------------------------
-- TELEPORT SCRIPT GỐC (BẤM R NHANH)
--------------------------------------------------
UIS.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.R and not flyCam then
		local pos = mouse.Hit.p + Vector3.new(0, 2.5, 0)
		doTeleport(pos)
	end
end)


-- Teleport T
local function getNearestPlayer()
	local nearest, shortestDistance = nil, math.huge
	for _, other in pairs(Players:GetPlayers()) do
		if other ~= player and other.Character and other.Character:FindFirstChild("HumanoidRootPart") then
			local dist = (hrp.Position - other.Character.HumanoidRootPart.Position).Magnitude
			if dist < shortestDistance then
				shortestDistance = dist
				nearest = other
			end
		end
	end
	return nearest
end
UIS.InputBegan:Connect(function(input,gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.T then
		local target = getNearestPlayer()
		if target then
			local targetHRP = target.Character.HumanoidRootPart
			hrp.CFrame = targetHRP.CFrame * CFrame.new(0,0,3)
			local s = Instance.new("Sound", hrp)
			s.SoundId = soundId
			s.Volume = 5
			s.PlayOnRemove = true
			s:Destroy()
			ZaWarudoEffect()
			if teleTrack.IsPlaying then teleTrack:Stop() end
			teleTrack:Play()
		end
	end
end)

-- Tele Sky (U) default behaviour (keep)
UIS.InputBegan:Connect(function(input,gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.U then
		local skyPos = hrp.Position + Vector3.new(0,100,0)
		doTeleport(skyPos)
	end
end)

-- Fly (Y)
local flying, bodyGyroFly, bodyVelocityFly = false 
local flySpeed = 50
UIS.InputBegan:Connect(function(input,gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.Y then
		flying = not flying
		if flying then
			humanoid.PlatformStand = true
			bodyGyroFly = Instance.new("BodyGyro", hrp)
			bodyGyroFly.P = 9e4
			bodyGyroFly.MaxTorque = Vector3.new(9e9,9e9,9e9)
			bodyGyroFly.CFrame = hrp.CFrame
			bodyVelocityFly = Instance.new("BodyVelocity", hrp)
			bodyVelocityFly.MaxForce = Vector3.new(9e9,9e9,9e9)
			if not flyTrack.IsPlaying then flyTrack:Play() end
		else
			humanoid.PlatformStand = false
			if bodyGyroFly then bodyGyroFly:Destroy() end
			if bodyVelocityFly then bodyVelocityFly:Destroy() end
			if flyTrack.IsPlaying then flyTrack:Stop() end
		end
	end
end)
RunService.RenderStepped:Connect(function()
	if flying and bodyVelocityFly and bodyGyroFly then
		local move = Vector3.new()
		if UIS:IsKeyDown(Enum.KeyCode.W) then move += hrp.CFrame.LookVector end
		if UIS:IsKeyDown(Enum.KeyCode.S) then move -= hrp.CFrame.LookVector end
		if UIS:IsKeyDown(Enum.KeyCode.A) then move -= hrp.CFrame.RightVector end
		if UIS:IsKeyDown(Enum.KeyCode.D) then move += hrp.CFrame.RightVector end
		bodyVelocityFly.Velocity = move * flySpeed
		bodyGyroFly.CFrame = CFrame.new(hrp.Position, hrp.Position + workspace.CurrentCamera.CFrame.LookVector)
	end
end)

-- Aimbot (C)
local aimbotEnabled, aimedPlayer = false, nil
UIS.InputBegan:Connect(function(input,gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.C then
		aimbotEnabled = not aimbotEnabled
		aimedPlayer = nil
		if aimbotEnabled then
			local cam, closest, shortest = workspace.CurrentCamera, nil, math.huge
			for _, other in pairs(Players:GetPlayers()) do
				if other ~= player and other.Character and other.Character:FindFirstChild("HumanoidRootPart") then
					local screenPos, onScreen = workspace.CurrentCamera:WorldToViewportPoint(other.Character.HumanoidRootPart.Position)
					if onScreen then
						local dist = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(workspace.CurrentCamera.ViewportSize.X/2, workspace.CurrentCamera.ViewportSize.Y/2)).Magnitude
						if dist < shortest then
							shortest = dist
							closest = other
						end
					end
				end
			end
			if closest then aimedPlayer = closest end
		end
	end
end)
RunService.RenderStepped:Connect(function()
	if aimbotEnabled and aimedPlayer and aimedPlayer.Character and aimedPlayer.Character:FindFirstChild("HumanoidRootPart") then
		local cam = workspace.CurrentCamera
		cam.CFrame = CFrame.new(cam.CFrame.Position, aimedPlayer.Character.HumanoidRootPart.Position)
	end
end)

-- God Tele (H)
local godTeleEnabled = false
local godTeleThread = nil
local godTeleOffset = 8
local godTeleDelay = 0.01
local lastPos = nil
local function playTeleportEffects()
	if hrp and hrp.Parent then
		local s = Instance.new("Sound", hrp)
		s.SoundId = soundId
		s.Volume = 5
		s.PlayOnRemove = true
		s:Destroy()
		ZaWarudoEffect()
		if teleTrack.IsPlaying then teleTrack:Stop() end
		teleTrack:Play()
	end
end
local function startGodTele()
	if godTeleThread then return end
	godTeleEnabled = true
	godTeleThread = task.spawn(function()
		while godTeleEnabled do
			if not (hrp and hrp.Parent) then break end
			lastPos = hrp.CFrame
			pcall(function() hrp.CFrame = hrp.CFrame * CFrame.new(godTeleOffset, 0, 0) end)
			playTeleportEffects()
			task.wait(godTeleDelay)
			pcall(function() hrp.CFrame = hrp.CFrame * CFrame.new(-godTeleOffset * 2, 0, 0) end)
			playTeleportEffects()
			task.wait(godTeleDelay)
			pcall(function() hrp.CFrame = hrp.CFrame * CFrame.new(godTeleOffset, 0, 0) end)
			playTeleportEffects()
			task.wait(godTeleDelay)
		end
		godTeleThread = nil
	end)
end
local function stopGodTele()
	godTeleEnabled = false
	task.delay(0.05, function()
		if hrp and lastPos then
			pcall(function() hrp.CFrame = lastPos end)
			playTeleportEffects()
		end
	end)
end
UIS.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.H then
		if godTeleEnabled then
			stopGodTele()
		else
			if not hrp or not hrp.Parent then
				if player.Character then
					hrp = player.Character:FindFirstChild("HumanoidRootPart")
				end
				if not hrp then return end
			end
			startGodTele()
		end
	end
end)
-- End of script
