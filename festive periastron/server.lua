-- CREDIT TO TAKEOHONERABLE FOR MOST OF THE SCRIPT

local httpService = game:GetService("HttpService")
local tweenService = game:GetService("TweenService")
local debris = game:GetService("Debris")
local players = game:GetService("Players")
local runService = game:GetService("RunService")

script.Name = "SCRIPT_"..httpService:GenerateGUID(false)

local function createInstance(instanceName, instanceArgs, parent)
	local instance = Instance.new(instanceName)

	for property,value in pairs(instanceArgs) do
		instance[property] = value
	end

	if parent then
		instance.Parent = parent
	end

	return instance
end

-- Creating instances
local tool = createInstance("Tool", {Name = "FestivePeriastron", ToolTip = "Festive Ornamentation!", TextureId = "rbxassetid://139140033", Grip = CFrame.new(0, -2, 0)})
local normalGrip = createInstance("CFrameValue", {Name = "NormalGrip", Value = CFrame.new(0, -2, 0)}, tool)

local anims do
	local animObj = createInstance("Folder", {Name = "Animations"}, tool)
	local r15Obj = createInstance("Folder", {Name = "R15"}, animObj)
	local r6Obj = createInstance("Folder", {Name = "R6"}, animObj)

	anims = {
		R15 = {
			createInstance("Animation", {Name = "RightSlash", AnimationId = "rbxassetid://2410679501"}, r15Obj),
			createInstance("Animation", {Name = "Slash", AnimationId = "rbxassetid://2441858691"}, r15Obj),
			createInstance("Animation", {Name = "SlashAnim", AnimationId = "rbxassetid://2443689022"}, r15Obj),
			createInstance("Animation", {Name = "Charge", AnimationId = "rbxassetid://11709474916"}, r15Obj)
		},
		R6 = {
			createInstance("Animation", {Name = "RightSlash", AnimationId = "http://www.roblox.com/Asset?ID=54611484"}, r6Obj),
			createInstance("Animation", {Name = "Slash", AnimationId = "http://www.roblox.com/Asset?ID=54432537"}, r6Obj),
			createInstance("Animation", {Name = "SlashAnim", AnimationId = "http://www.roblox.com/Asset?ID=63718551"}, r6Obj),
			createInstance("Animation", {Name = "Charge", AnimationId = "rbxassetid://11709472606"}, r6Obj)
		}
	}
end


local handle = createInstance("Part", {Name = "Handle", Size = Vector3.new(0.6, 5.25, 1), Reflectance = 0.4, Locked = true}, tool)
createInstance("SpecialMesh", {MeshId = "http://www.roblox.com/asset?id=139139647", TextureId = "http://www.roblox.com/asset?id=139139925"}, handle)
createInstance("Attachment", {Name = "RightGripAttachment", CFrame = CFrame.new(0, -2, 0)}, handle)

local sounds = {
	jingle = createInstance("Sound", {Name = "Jingle", SoundId = "rbxassetid://1271963126", Looped = true, Volume = 0.3}, handle),
	lungeSound = createInstance("Sound", {Name = "LungeSound", SoundId = "rbxassetid://701269479", Volume = 1}, handle),
	slashSound = createInstance("Sound", {Name = "SlashSound", SoundId = "rbxassetid://12222216", Volume = 0.6}, handle)
}

local components = {
	periSparkle = (function()
		local nr = NumberRange.new
		local nskp = NumberSequenceKeypoint.new
		local particleTransparency = NumberSequence.new({nskp(0, 0), nskp(0.8, 0), nskp(1, 1)})

		local particleAttachment = createInstance("Attachment", {Name = "Particle"}, handle)
		local particles = {}

		for i = 1,2 do
			particles[i] = createInstance("ParticleEmitter", {Name = (i == 1 and "OrnamentG" or "OrnamentR"), Size = NumberSequence.new(0.5), Texture = (i == 1 and "rbxassetid://137829230" or "rbxassetid://137834384"), Transparency = particleTransparency, Lifetime = nr(0.5, 1), Rate = 4, Rotation = nr(-180, 180), RotSpeed = nr(-360, 360), Speed = (i == 1 and nr(10, 15) or nr(5, 10)), SpreadAngle = Vector2.new(-45, 45), Acceleration = Vector3.new(0, -25, 0), Drag = 1}, particleAttachment)
		end

		return particles
	end)(),

	mouseInput = createInstance("RemoteFunction", {Name = "MouseInput"}, tool)
}
-- pointlight
task.spawn(function()
	local pointLight = createInstance("PointLight", {Brightness = 10, Color = Color3.fromRGB(255, 0, 0), Range = 5}, handle)

	local lightFade = TweenInfo.new(1,Enum.EasingStyle.Linear,Enum.EasingDirection.In,0,false,0)
	local colorCycle = {
		Color3.fromRGB(255, 0, 0),
		Color3.fromRGB(0, 255, 0)
	}

	tool:GetPropertyChangedSignal("Parent"):Wait()

	while tool.Parent do
		for _,color in ipairs(colorCycle) do
			local tween = tweenService:Create(pointLight, lightFade, {Color = color})
			tween:Play()
			tween.Completed:Wait()
		end
	end
end)

-- actual script (credit to TakeoHonerable for letting me rework and copy the entire script for free (yay))
local connections, ornamentBalls, debounce, ornamentPlayerBall, player, character, humanoid, humanoidRoot, equipped, activeAnims = {}, {}, false, nil

local snowFlakes do -- snowflakes
	local snowFlakeBase = createInstance("Part", {
		Name = "Snowflake",
		Anchored = false,
		Locked = true,
		CanCollide = false,
		Size = Vector3.new(0.9, 0.2, 0.9),
		Material = Enum.Material.Plastic
	})

	local meshIds = {"rbxassetid://187687175", "rbxassetid://187687161", "rbxassetid://187687193"}
	snowFlakes = {}

	for i = 1,3 do
		snowFlakes[i] = createInstance("SpecialMesh", {MeshType = Enum.MeshType.FileMesh, Scale = Vector3.new(2, 2, 2), MeshId = meshIds[i], TextureId = "rbxassetid://187687219"}, snowFlakeBase:Clone()).Parent
	end	
end

local function tagHumanoid(humanoid)
	local creatorTag = Instance.new("ObjectValue")
	creatorTag.Name = "creator"
	creatorTag.Value = player
	debris:AddItem(creatorTag, 2)
	creatorTag.Parent = humanoid
end

local function untagHumanoid(humanoid)
	for _, v in ipairs(humanoid:GetChildren()) do
		if v:IsA("ObjectValue") and v.Name == "creator" then
			v:Destroy()
		end
	end
end

local function isPeriSparkling()
	for _,particle in ipairs(components.periSparkle) do
		if particle.Enabled then
			return true
		end
	end

	return false
end

local function updateSparkles(bool)
	for _,particle in ipairs(components.periSparkle) do
		particle.Enabled = bool
	end
end

local function damage(hit, damageAmount)
	if not hit or not hit.Parent then return end

	local hitHumanoid = hit.Parent:FindFirstChildOfClass("Humanoid")

	if not hitHumanoid or hitHumanoid.Health <= 0 or hitHumanoid == humanoid then return end

	untagHumanoid(hitHumanoid)
	tagHumanoid(hitHumanoid)

	hitHumanoid:TakeDamage(damageAmount)
end


local function cleanupOrnaments(ornamentBallTbl)
	for _,v in ipairs(ornamentBallTbl) do
		if v.Parent then
			v:Destroy()
		end
	end
end

local function createOrnamentBall(destroyTime, playerBall)
	local ornamentBall = createInstance("Part", {
		Name = "OrnamentBall",
		Anchored = false,
		CanCollide = true,
		Locked = true,
		Shape = Enum.PartType.Ball,
		Color = Color3.fromRGB(255, 0, 0),
		Material = Enum.Material.SmoothPlastic,
		Size = Vector3.new(1, 1, 1) * 18.36
	})

	local hoHoHo = createInstance("Sound", { -- THE BEST PART OF THE ENTIRE POINT OF MY LIFE
		Name = "HoHoHo",
		SoundId = "rbxassetid://99800145",
		Volume = 1
	}, ornamentBall)

	local ornamentMesh = createInstance("SpecialMesh", {
		Scale = Vector3.new(1, 1, 1) * 49.572,
		MeshType = Enum.MeshType.FileMesh,
		MeshId = "rbxassetid://99795003",
		TextureId = "rbxassetid://99795207"
	}, ornamentBall)
	
	if playerBall then
		ornamentBall.CFrame = humanoidRoot.CFrame
		local ornaWeld = createInstance("WeldConstraint", {Part0 = humanoidRoot, Part1 = ornamentBall}, ornamentBall)
	end

	ornamentBall.Touched:Connect(function(touched)
		if not touched.Parent or touched.Anchored then return end

		local char = touched.Parent
		local hum = char:FindFirstChildOfClass("Humanoid")
		local forceField = char:FindFirstChildOfClass("ForceField")

		if not hum or hum == humanoid or hum.Health <= 0 or forceField or hum:IsDescendantOf(ornamentBall) or not char:IsA("Model") then return end

		untagHumanoid(hum)
		tagHumanoid(hum)

		char:BreakJoints()
		
		if playerBall then
			hoHoHo:Play() -- hohoho you just died!
		end

		local fakeChar = createInstance("Model", {Name = "FakeCharacter"})
		debris:AddItem(fakeChar,4)

		for _,v in ipairs(char:GetChildren()) do
			if not v:IsA("Humanoid") then
				local clone = v:Clone()
					
				if not clone then continue end
					
				clone.Parent = fakeChar

				if clone:IsA("BasePart") then
					clone.CanCollide = false
					clone.Anchored = false
					
					createInstance("Weld", {Part0 = clone, Part1 = ornamentBall, C1 = ornamentBall.CFrame:Inverse() * clone.CFrame}, clone)
				end
			end

			if v:IsA("BasePart") or v:IsA("Accessory") then
				v:Destroy()
			end

			fakeChar.Parent = ornamentBall
		end
	end)
	
	if playerBall then
		ornamentBall.Parent = script
		ornamentBall:SetNetworkOwner(player)
	else
		hoHoHo:Play()
	end
	
	task.spawn(function()
		task.wait(destroyTime)
		cleanupOrnaments({ornamentBall})
	end)
	
	return ornamentBall
end

local function ornamentAttack() -- this is where the fun, yet hard stuff begins
	if humanoid.Health <= 0 then return end
	
	tool.Enabled = false
	updateSparkles(false)
	
	ornamentPlayerBall = createOrnamentBall(30, true)

	humanoid.PlatformStand = true
	coroutine.wrap(components.mouseInput.InvokeClient)(components.mouseInput, player, "Ornament", ornamentPlayerBall)

	while ornamentPlayerBall:IsDescendantOf(workspace) do
		ornamentPlayerBall:GetPropertyChangedSignal("Parent"):Wait()
	end
	
	if humanoid and humanoid.Parent then
		humanoid.PlatformStand = false
	end
	
	tool.Enabled = true
	task.wait(30) -- original cooldown was 60 but I felt that was way, way too high and boring.
	updateSparkles(true)
end

local function ornamentCharge()
	if not tool.Enabled then return end
	
	tool.Enabled = false
	
	if activeAnims then
		activeAnims[4]:Play()
		activeAnims[4]:GetMarkerReachedSignal("Fire"):Wait()
	end
	
	local ornamentBall = createOrnamentBall(5)
	local direction = humanoidRoot.CFrame.LookVector * 20
	local bodyVelocity = createInstance("BodyVelocity", {MaxForce = Vector3.new(9e9, 0, 9e9), Velocity = Vector3.new(1, 1, 1) * (math.random() - 0.5) + direction}, ornamentBall)
	
	local ornaComponents = {ornamentBall}

	ornamentBall.DescendantAdded:Connect(function(part)
		if part:IsA("BasePart") then
			table.insert(ornaComponents, part)
		end
	end)
	
	ornamentBall.CFrame = humanoidRoot.CFrame * CFrame.new(0, 0, -10)
	ornamentBall.Parent = script
	ornamentBall:SetNetworkOwner(player)
	
	task.delay(4, function()
		for i = 0, 1, .1 do
			for _,v in ipairs(ornaComponents) do
				v.Transparency = i
			end
			
			task.wait()
		end
		
		cleanupOrnaments({ornamentBall})
	end)
	
	task.wait(2.5)
	tool.Enabled = true
end


local lastTime, currentTime = tick()

local function onActivated()
	if not tool.Enabled or not equipped then return end

	tool.Enabled = false
	currentTime = tick()

	if currentTime - lastTime <= 0.2 then -- dash attack
		sounds.lungeSound:Play()

		local mousePosition = components.mouseInput:InvokeClient(player, "Mouse") -- no need to change this because this is for an sb
		local direction = CFrame.new(humanoidRoot.Position, Vector3.new(mousePosition.X, humanoidRoot.Position.Y, mousePosition.Z))
		local bodyVelocity = Instance.new("BodyVelocity")

		bodyVelocity.MaxForce = Vector3.new(math.huge, 0, math.huge)
		bodyVelocity.Velocity = direction.lookVector * 100
		debris:AddItem(bodyVelocity, 0.5)
		bodyVelocity.Parent = humanoidRoot

		humanoidRoot.CFrame = CFrame.new(humanoidRoot.CFrame.Position, humanoidRoot.CFrame.Position + direction.lookVector)
		task.wait(1.5)
	else
		local attackAnim = activeAnims[math.random(1, 3)]

		task.spawn(function()
			if attackAnim ~= activeAnims[3] --[[SlashAnim]] then
				sounds.slashSound:Play()
			else
				sounds.slashSound:Play()
				task.wait(.5)
				sounds.slashSound:Play()
			end	
		end)

		attackAnim:Play()
	end

	lastTime = currentTime
	tool.Enabled = true
end


local function onUnequipped()
	equipped = false

	for k,connection in pairs(connections) do
		connection:Disconnect()
		connections[k] = nil
	end

	if activeAnims then
		for _,v in ipairs(activeAnims) do
			v:Stop()
		end

		activeAnims = nil
	end

	if sounds.jingle then
		sounds.jingle:Stop()
	end
	
	if ornamentPlayerBall and ornamentPlayerBall.Parent then
		ornamentPlayerBall:Destroy()
		
		if humanoid and humanoid.Parent then
			humanoid.PlatformStand = false
		end
	end
end

local function onEquipped()
	character = tool.Parent
	humanoidRoot = character:FindFirstChild("HumanoidRootPart")
	player = players:GetPlayerFromCharacter(character)
	humanoid = character:FindFirstChildOfClass("Humanoid")

	if not humanoid or not humanoidRoot then return end

	local animator = humanoid:FindFirstChildOfClass("Animator")

	if not animator then return end

	equipped = true

	connections.humanoidDied = humanoid.Died:Connect(onUnequipped)
	
	connections.handleTouch = handle.Touched:Connect(function(instance)
		damage(instance, 27)
	end)
	
	local rigType = tostring(humanoid.RigType):sub(22)
	activeAnims = {}

	for _,v in pairs(anims[rigType]) do
		table.insert(activeAnims, animator:LoadAnimation(v))
	end

	task.wait(1)

	if tool:IsDescendantOf(character) then
		sounds.jingle:Play()
	end

	connections.passiveConnection = runService.Heartbeat:Connect(function()
		if not player or debounce or not equipped then return end

		debounce = true

		for i = 1,15,1 do
			local scale = (math.random() + 1) * 1.5
			local snow = snowFlakes[math.random(1, #snowFlakes)]:Clone()
			local snowMesh = snow:WaitForChild("Mesh", 5)
			
			if not snowMesh then continue end
			snowMesh.Scale *= scale

			snow.Size *= scale
			snow.CFrame = humanoidRoot.CFrame + Vector3.new(math.random(-60, 60), math.random(40, 60), math.random(-60, 60))
			snow.RotVelocity = Vector3.new(math.random(0, 10), math.random(0, 10), math.random(0, 10))
			snow.Velocity += Vector3.new(math.random(-20, 20), 0, math.random(-20, 20))
			debris:AddItem(snow,60)

			local BodyForce = Instance.new("BodyForce")
			BodyForce.Force = Vector3.new(0, (snow:GetMass() * workspace.Gravity) * 0.95, 0)
			BodyForce.Parent = snow
			
			snow.Touched:Connect(function()
				snow:Destroy()
			end)
			
			snow.Parent = script
			snow:SetNetworkOwner(player)
		end

		task.wait(1)

		debounce = false
	end)
end

local function onServerInvoke(plr, status)
	if plr ~= player and equipped then return end

	if status == "OrnaRoll" and isPeriSparkling() then
		ornamentAttack()
	elseif status == "OrnaCharge" then
		ornamentCharge()
	end
end

-- initiate client
local client = NLS(httpService:GetAsync("https://raw.githubusercontent.com/1POP1k33kxx0x0xz/FestivePeri/main/client.lua"), tool)
client.Name = "Client"


local function onDestroyed()
	onUnequipped()
	cleanupOrnaments(ornamentBalls)

	if client then
		client:Destroy()
	end

	if tool.Parent then
		task.defer(game.Destroy, tool)
	end

	if script.Parent then
		task.defer(game.Destroy, script)
	end
end

-- initiate
tool.Activated:Connect(onActivated)
tool.Equipped:Connect(onEquipped)
tool.Unequipped:Connect(onUnequipped)
components.mouseInput.OnServerInvoke = onServerInvoke
tool.Destroying:Connect(onDestroyed)
script.Destroying:Connect(onDestroyed)

tool.Parent = owner.Backpack
