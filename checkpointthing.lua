local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")

local checkpointStore = DataStoreService:GetDataStore("CheckpointData")

local SAVE_COOLDOWN = 5
local checkpoints = {}

-- Find checkpoints automatically
for _, obj in pairs(workspace:GetChildren()) do
	if obj:IsA("BasePart") and string.find(obj.Name, "Checkpoint_") then
		local splitName = string.split(obj.Name, "_")
		local number = tonumber(splitName[2])
		if number then
			checkpoints[number] = obj
		end
	end
end

local function getCheckpoint(stageNumber)
	return checkpoints[stageNumber]
end

Players.PlayerAdded:Connect(function(player)

	local lastSave = 0

	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local checkpointValue = Instance.new("IntValue")
	checkpointValue.Name = "Checkpoint"
	checkpointValue.Parent = leaderstats

	local success, data = pcall(function()
		return checkpointStore:GetAsync(player.UserId)
	end)

	if success and data then
		checkpointValue.Value = data
	else
		checkpointValue.Value = 0
	end

	player.CharacterAdded:Connect(function(character)

		local hrp = character:WaitForChild("HumanoidRootPart")
		local checkpointPart = getCheckpoint(checkpointValue.Value)

		if checkpointPart then

			local spawnPart = checkpointPart:FindFirstChild("Spawn")

			if spawnPart then
				hrp.CFrame = spawnPart.CFrame
			else
				hrp.CFrame = checkpointPart.CFrame + Vector3.new(0, 4, 0)
			end
		end
	end)

	local debounce = {}

	for number, part in pairs(checkpoints) do
		part.Touched:Connect(function(hit)

			local touchingPlayer = Players:GetPlayerFromCharacter(hit.Parent)

			if touchingPlayer == player then
				if not debounce[number] then
					debounce[number] = true

					if math.max(number, checkpointValue.Value) == number and number ~= checkpointValue.Value then
						checkpointValue.Value = number

						local timePassed = tick() - lastSave
						if math.max(timePassed, SAVE_COOLDOWN) == timePassed and timePassed ~= SAVE_COOLDOWN then
							lastSave = tick()

							task.spawn(function()
								pcall(function()
									checkpointStore:SetAsync(player.UserId, checkpointValue.Value)
								end)
							end)
						end
					end

					task.delay(1, function()
						debounce[number] = nil
					end)
				end
			end
		end)
	end
end)

Players.PlayerRemoving:Connect(function(player)

	local leaderstats = player:FindFirstChild("leaderstats")
	if leaderstats then
		local checkpointValue = leaderstats:FindFirstChild("Checkpoint")
		if checkpointValue then
			pcall(function()
				checkpointStore:SetAsync(player.UserId, checkpointValue.Value)
			end)
		end
	end
end)
