-- catalog_client.lua
-- Creates a GUI container, an "Open Catalog" button, and a scrollable list of items

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local localPlayer = Players.LocalPlayer
local searchCatalogRemote = ReplicatedStorage:WaitForChild("SearchCatalog")

-- Main ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "catalog_ui"
screenGui.ResetOnSpawn = false
screenGui.Parent = localPlayer:WaitForChild("PlayerGui")

print("[catalog] screen_gui created:", screenGui)

-- Open Catalog button (your original styling)
local openButton = Instance.new("TextButton")
openButton.Name = "open_button"
openButton.Size = UDim2.new(0, 200, 0, 50)
openButton.Position = UDim2.new(1, -210, 1, -240)
openButton.AnchorPoint = Vector2.new(0, 1)
openButton.Font = Enum.Font.GothamBold
openButton.TextSize = 16
openButton.Text = "Open Catalog"
openButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
openButton.TextColor3 = Color3.fromRGB(255, 255, 255)
openButton.AutoButtonColor = false
openButton.Parent = screenGui

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 8)
buttonCorner.Parent = openButton

local buttonStroke = Instance.new("UIStroke")
buttonStroke.Thickness = 1.5
buttonStroke.Color = Color3.fromRGB(0, 0, 0)
buttonStroke.Transparency = 0.4
buttonStroke.Parent = openButton

openButton.MouseEnter:Connect(function()
	openButton.BackgroundColor3 = Color3.fromRGB(107, 114, 117)
end)

openButton.MouseLeave:Connect(function()
	openButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
end)

----------------------------------------------------------------
-- Catalog menu: scrollable list of items
----------------------------------------------------------------

local catalogFrame = Instance.new("Frame")
catalogFrame.Name = "catalog_frame"
catalogFrame.Size = UDim2.new(0, 350, 0, 450)
catalogFrame.Position = UDim2.new(1, -360, 1, -320)
catalogFrame.AnchorPoint = Vector2.new(0, 1)
catalogFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
catalogFrame.BackgroundTransparency = 0.1
catalogFrame.Visible = false
catalogFrame.Parent = screenGui

local frameCorner = Instance.new("UICorner")
frameCorner.CornerRadius = UDim.new(0, 8)
frameCorner.Parent = catalogFrame

local frameStroke = Instance.new("UIStroke")
frameStroke.Thickness = 1.5
frameStroke.Color = Color3.fromRGB(255, 255, 255)
frameStroke.Transparency = 0.5
frameStroke.Parent = catalogFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "title_label"
titleLabel.Size = UDim2.new(1, -20, 0, 40)
titleLabel.Position = UDim2.new(0, 10, 0, 5)
titleLabel.BackgroundTransparency = 1
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 20
titleLabel.Text = "Avatar Catalog"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = catalogFrame

local scrollingFrame = Instance.new("ScrollingFrame")
scrollingFrame.Name = "item_list"
scrollingFrame.Size = UDim2.new(1, -20, 1, -60)
scrollingFrame.Position = UDim2.new(0, 10, 0, 50)
scrollingFrame.BackgroundTransparency = 1
scrollingFrame.BorderSizePixel = 0
scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollingFrame.ScrollBarThickness = 6
scrollingFrame.Parent = catalogFrame

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 6)
listLayout.FillDirection = Enum.FillDirection.Vertical
listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = scrollingFrame

listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	scrollingFrame.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y)
end)

local function clearItems()
	for _, child in ipairs(scrollingFrame:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end
end

local function populateFromItems(items)
	clearItems()

	for _, item in ipairs(items) do
		local row = Instance.new("TextButton")
		row.Name = "item_" .. tostring(item.id)
		row.Size = UDim2.new(1, 0, 0, 60)
		row.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
		row.Text = ""
		row.AutoButtonColor = false
		row.Parent = scrollingFrame

		local rowCorner = Instance.new("UICorner")
		rowCorner.CornerRadius = UDim.new(0, 6)
		rowCorner.Parent = row

		local rowStroke = Instance.new("UIStroke")
		rowStroke.Thickness = 1
		rowStroke.Color = Color3.fromRGB(255, 255, 255)
		rowStroke.Transparency = 0.7
		rowStroke.Parent = row

		local nameLabel = Instance.new("TextLabel")
		nameLabel.BackgroundTransparency = 1
		nameLabel.Size = UDim2.new(1, -10, 0, 28)
		nameLabel.Position = UDim2.new(0, 8, 0, 4)
		nameLabel.Font = Enum.Font.GothamBold
		nameLabel.TextSize = 16
		nameLabel.TextXAlignment = Enum.TextXAlignment.Left
		nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		nameLabel.Text = tostring(item.name or "Unknown item")
		nameLabel.Parent = row

		local infoLabel = Instance.new("TextLabel")
		infoLabel.BackgroundTransparency = 1
		infoLabel.Size = UDim2.new(1, -10, 0, 22)
		infoLabel.Position = UDim2.new(0, 8, 0, 32)
		infoLabel.Font = Enum.Font.Gotham
		infoLabel.TextSize = 14
		infoLabel.TextXAlignment = Enum.TextXAlignment.Left
		infoLabel.TextColor3 = Color3.fromRGB(200, 200, 200)

		local priceText = "N/A"
		if item.price ~= nil then
			priceText = tostring(item.price) .. " R$"
		end

		local creatorText = item.creatorName or "Unknown creator"

		local tags = {}
		if item.isLimited then
			table.insert(tags, "LIMITED")
		end
		if item.isLimitedUnique then
			table.insert(tags, "U")
		end

		local tagText = ""
		if #tags > 0 then
			tagText = " [" .. table.concat(tags, " ") .. "]"
		end

		infoLabel.Text = string.format("%s  |  %s%s", priceText, creatorText, tagText)
		infoLabel.Parent = row

		row.MouseEnter:Connect(function()
			row.BackgroundColor3 = Color3.fromRGB(55, 55, 55)
		end)

		row.MouseLeave:Connect(function()
			row.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
		end)

		row.MouseButton1Click:Connect(function()
			print("[catalog] clicked item:", item.id, item.name, item.price, item.creatorName)
			-- later: RemoteEvent to try on or prompt purchase
		end)
	end
end

local function loadCatalog(keyword)
	local success, result = pcall(function()
		return searchCatalogRemote:InvokeServer(keyword, 20)
	end)

	if success then
		populateFromItems(result)
	else
		warn("[catalog] failed to load catalog:", result)
	end
end

local catalogOpen = false

openButton.MouseButton1Click:Connect(function()
	catalogOpen = not catalogOpen
	catalogFrame.Visible = catalogOpen

	if catalogOpen then
		loadCatalog("y2k")
	end
end)
