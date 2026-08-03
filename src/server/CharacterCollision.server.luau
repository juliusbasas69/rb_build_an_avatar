local PhysicsService = game:GetService("PhysicsService")

pcall(function()
	PhysicsService:RegisterCollisionGroup("Players")
end)

pcall(function()
	PhysicsService:RegisterCollisionGroup("Mannequin")
end)

PhysicsService:CollisionGroupSetCollidable("Players", "Mannequin", false)