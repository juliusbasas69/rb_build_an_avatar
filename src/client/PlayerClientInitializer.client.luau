local Players = game:GetService("Players")

local Player = Players.LocalPlayer
local PlayerScripts = Player:WaitForChild("PlayerScripts")

local PlayerClientService = require(PlayerScripts.Client.Shared.Service.PlayerClientService)
local GoldController = require(PlayerScripts.Client.Controller.GoldController)
local MannequinPickerController = require(PlayerScripts.Client.Controller.MannequinPickerController)
local InventoryController = require(PlayerScripts.Client.Controller.InventoryController)
local WardrobeController = require(PlayerScripts.Client.Controller.WardrobeController)

PlayerClientService:Initialize()
GoldController:Initialize()
MannequinPickerController:Initialize()
InventoryController:Initialize()
WardrobeController:Initialize()