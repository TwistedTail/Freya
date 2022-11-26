AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

local function CreateRadar(Player, Position)
	local Entity = ents.Create("test_radar")

	if not IsValid(Entity) then return end

	Entity:SetModel("models/radar/radar_sp_big.mdl")
	Entity:CPPISetOwner(Player)
	Entity:SetPlayer(Player)
	Entity:SetPos(Position)
	Entity:Spawn()

	Entity:PhysicsInit(SOLID_VPHYSICS)
	Entity:SetMoveType(MOVETYPE_VPHYSICS)
	Entity:Activate()

	local PhysObj = Entity:GetPhysicsObject()

	if IsValid(PhysObj) then
		PhysObj:EnableMotion(false)
		PhysObj:Sleep()
	end

	undo.Create("Test Radar")
		undo.AddEntity(Entity)
		undo.SetPlayer(Player)
	undo.Finish("Test Radar Entity")
end

concommand.Add("spawn_radar", function(Player)
	if not IsValid(Player) then return end

	local HitPos = Player:GetEyeTrace().HitPos

	CreateRadar(Player, HitPos)
end)
