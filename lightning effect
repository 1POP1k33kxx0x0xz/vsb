local debris = Instance.new("Folder")
debris.Name = "Debris"
debris.Parent = workspace

debris.ChildAdded:Connect(function(child)
	task.wait(child:GetAttribute("LifeTime") or 5)
	
	if child.Parent then
		child:Destroy()
	end
end)

local function createLightPart(cframe, length, lifeTime)
	local lightPart = Instance.new("SpawnLocation")
	
	lightPart.Anchored = true
	lightPart.CanCollide = false
	lightPart.Size = Vector3.new(.2, length, .2)
	lightPart.Transparency = 0 -- 0.7
	lightPart.BrickColor = BrickColor.new("Really red")
	lightPart.Material = Enum.Material.Neon
	lightPart.CFrame = cframe
	lightPart:SetAttribute("LifeTime", lifeTime)
	lightPart.Parent = debris
end

local function randomRad(maxValue)
	local digitOffset = 10 ^ 5 -- (5 decimal digits)
	
	local random = math.random(0, maxValue * digitOffset)
	
	return random / digitOffset
end

local function createLightBeam(intensity, length, amount)
	local intensityRad = math.pi * math.clamp(intensity, 0, 2)
	
	local direction = CFrame.new(Vector3.new(0, 1, 0) * (length / 2))
	local lastCFrame = direction
	
	for i = 1,amount do
		local angles = CFrame.Angles(randomRad(intensityRad), randomRad(intensityRad), randomRad(intensityRad))
		local edge = CFrame.new((lastCFrame * direction).Position)
		local currentCFrame = edge * angles * direction
		
		createLightPart(currentCFrame, length, 1)
		
		lastCFrame = currentCFrame
	end
end

local function deconstruct()
	debris:Destroy()
	script:Destroy()
end


for i = 1,100 do
	createLightBeam(tick() % 2, tick() % 1, 1000)
	
	task.wait()
	debris:ClearAllChildren()
end


--createLightBeam(.1, 10, 10)

task.wait(20)

deconstruct()
