local players = game:GetService("Players")
local httpService = game:GetService("HttpService")

script.Name = "SCRIPT_"..httpService:GenerateGUID(false)

local remote = Instance.new("RemoteEvent")
remote.Name = "Network"
remote.Parent = script

local char = owner.Character or owner.CharacterAdded:Wait()
local humanoid = char:WaitForChild("Humanoid", 4)

local function changeHumansProperty(property, value)
	for _,plr in ipairs(players:GetPlayers()) do
		if plr == owner then continue end

		local plrChar = plr.Character

		if plrChar then
			local plrHum = plrChar:FindFirstChildOfClass("Humanoid")

			if plrHum then
				if property == "Jump" then
					plrHum.Jump = true
				elseif property == "WalkToPoint" and plrChar.PrimaryPart then
					plrHum.WalkToPoint = plrChar.PrimaryPart.Position + value
					--[[ (for debug purposes)
					local point = Instance.new("Part")
					game:GetService("Debris"):AddItem(point, .5)

					point.Size = Vector3.new(1, 1, 1)
					point.Anchored = true
					point.CanCollide = false
					point.Shape = Enum.PartType.Ball
					point.Position = plrChar.PrimaryPart.Position + value
					point.Color = Color3.new()
					point.Transparency = .5
					point.Material = Enum.Material.SmoothPlastic
					point.Parent = workspace
					]]
				elseif property == "StopWalking" and plrChar.PrimaryPart then
					plrHum:Move(Vector3.new())
				end
			end
		end
	end
end

if humanoid then
	local events

	events = {
		humanoid.Died:Connect(function()
			for _,event in ipairs(events) do
				event:Disconnect()
			end

			remote:FireAllClients("DestroyScript")
			script:Destroy()
		end),

		remote.OnServerEvent:Connect(function(plr, status, value)
			if plr ~= owner then return end -- not sure how this would happen, but there's a check just in case.

			if status == "MoveDirection" and typeof(value) == "Vector3" then
				if value ~= Vector3.new() then
					changeHumansProperty("WalkToPoint", value * 7)
				else
					changeHumansProperty("StopWalking")
				end
			end
		end),

		humanoid:GetPropertyChangedSignal("Jump"):Connect(function()
			changeHumansProperty("Jump", true)
		end)
	}
end

NLS(([[
local players = game:GetService("Players")

local remote = workspace:WaitForChild("__REPLACED_TEXT__", 4):WaitForChild("Network", 4)

local char = players.LocalPlayer.Character or players.LocalPlayer.CharacterAdded:Wait()
local humanoid = char:WaitForChild("Humanoid", 4)
local events

if humanoid then
	local currentLoop

	events = {
		remote.OnClientEvent:Connect(function(status)
			if status == "DestroyScript" then
				for _,event in ipairs(events) do
					event:Disconnect()
				end

				script:Destroy()
			end
		end),

		humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function()
			currentLoop = tick()
			local localLoop = currentLoop

			while humanoid.Parent and localLoop == currentLoop do
				remote:FireServer("MoveDirection", humanoid.MoveDirection)

				if humanoid.MoveDirection == Vector3.new() then break end

				task.wait(0.1)
			end
		end)
	}
end
]]):gsub("__REPLACED_TEXT__", script.Name), owner.PlayerGui)
