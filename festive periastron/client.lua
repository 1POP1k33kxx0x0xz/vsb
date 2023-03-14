local players = game:GetService("Players")
local contextActionService = game:GetService("ContextActionService")
local runService = game:GetService("RunService")

local tool = script.Parent
local remote = tool:WaitForChild("MouseInput")
local mouse = players.LocalPlayer:GetMouse()
local humanoid, equipped

local function updateMouseIcon()
	if equipped then
		mouse.Icon = tool.Enabled and "rbxasset://textures/GunCursor.png" or "rbxasset://textures/GunWaitCursor.png"
	else
		mouse.Icon = ""
	end
end

local function periPrimary(_, inputState)
	if inputState == Enum.UserInputState.Begin then 
		remote:InvokeServer("OrnaRoll")
	end
end

local function periSecondary(_, inputState)
	if inputState == Enum.UserInputState.Begin then 
		remote:InvokeServer("OrnaCharge")
	end
end

local contextActions = {
	{periPrimary, "PeriPrimary", Enum.KeyCode.Q, Enum.KeyCode.ButtonY, "Orna-Roll", UDim2.new(.5, 0, -.5, 0)},
	{periSecondary, "PeriSecondary", Enum.KeyCode.E, Enum.KeyCode.ButtonY, "Orna-Charge", UDim2.new(.5,0,0,0)}
}

local function onEquipped()
	local character = players.LocalPlayer.Character
	if not character then return end
	humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then return end
	
	equipped = true
	
	for _,action in ipairs(contextActions) do
		contextActionService:BindAction(action[2], action[1], true, action[3], action[4])
		contextActionService:SetTitle(action[2], action[5])
		contextActionService:SetPosition(action[2], action[6])
	end
	
	updateMouseIcon()
end

local function onUnequipped()
	equipped = false
	contextActionService:UnbindAction("PeriPrimary")
	updateMouseIcon()
end

-- initiate client
remote.OnClientInvoke = function(status, ornament)
	if status == "Mouse" then
		return mouse.Hit.Position
	elseif status == "Ornament" then
		local connection
		
		connection = runService.RenderStepped:Connect(function()
			if not ornament.Parent or not humanoid or not humanoid.Parent or humanoid.Health <= 0 or not equipped then
				connection:Disconnect()
				return
			end
			
			if humanoid.MoveDirection.Magnitude > 0 then
				ornament.Velocity = ornament.Velocity + humanoid.MoveDirection * 2
			end
		end)
	end
end

tool:GetPropertyChangedSignal("Enabled"):Connect(updateMouseIcon)
tool.Equipped:Connect(onEquipped)
tool.Unequipped:Connect(onUnequipped)
