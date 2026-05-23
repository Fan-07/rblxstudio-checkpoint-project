local player = game.Players.LocalPlayer
local label = script.Parent

local leaderstats = player:WaitForChild("leaderstats")
local checkpointValue = leaderstats:WaitForChild("Checkpoint")

local function update()
	label.Text = "Checkpoint: " .. checkpointValue.Value
end

checkpointValue:GetPropertyChangedSignal("Value"):Connect(update)

update()
