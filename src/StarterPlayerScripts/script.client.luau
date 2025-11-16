-- catalog_client.lua
-- Creates a GUI container and a button to open the catalog

-- 1) Get the Players service and your player object
local players_service = game:GetService("Players")
local local_player = players_service.LocalPlayer

-- 2) Create the main GUI container for the catalog interface
local screen_gui = Instance.new("ScreenGui")
screen_gui.Name = "catalog_ui"
screen_gui.ResetOnSpawn = false
screen_gui.Parent = local_player:WaitForChild("PlayerGui")

print("[catalog] screen_gui created:", screen_gui)

-- 3) Make a visible button to open the catalog
local open_button = Instance.new("TextButton")
open_button.Name = "open_button"
open_button.Size = UDim2.new(0, 200, 0, 50)
open_button.Position = UDim2.new(1, -210, 1, -240)
open_button.AnchorPoint = Vector2.new(0, 1)
open_button.Font = Enum.Font.GothamBold
open_button.TextSize = 16
open_button.Text = "Open Catalog"
open_button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
open_button.TextColor3 = Color3.fromRGB(255, 255, 255)
open_button.Parent = screen_gui

-- 4) Add some visual polish to the button

-- Rounded corners
local ui_corner = Instance.new("UICorner")
ui_corner.CornerRadius = UDim.new(0, 8)  -- 8px rounded corners
ui_corner.Parent = open_button

-- Outline stroke
local ui_stroke = Instance.new("UIStroke")
ui_stroke.Thickness = 1.5
ui_stroke.Color = Color3.fromRGB(255, 255, 255)
ui_stroke.Transparency = 0.4
ui_stroke.Parent = open_button

-- 5) Simple hover effect
open_button.MouseEnter:Connect(function()
	open_button.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
end)

open_button.MouseLeave:Connect(function()
	open_button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
end)


