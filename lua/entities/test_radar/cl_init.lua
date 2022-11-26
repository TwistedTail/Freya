include ("shared.lua")

local math  = math
--local ease  = math.ease
local Clock = ACF.Utilities.Clock

-- Switch to just using movement based on increments
-- Use cubic or sine easing for when the movement starts/ends instead
-- Min range for easing should be 0.5°, max unknown
-- Make view cone adjust to the tickrate and rotation speed

function ENT:Initialize()
	self.Angle     = 90 -- degrees
	self.Current   = 0 -- degrees
	self.Direction = 1
	self.Speed     = 0 -- degrees per second
	self.MaxSpeed  = 90 -- degrees per second
	self.Coverage  = 180 -- degrees
end

function ENT:GetStep()
	return self.MaxSpeed * self.Direction * Clock.DeltaTime
end

function ENT:GetLimit()
	return self.Angle + self.Coverage * self.Direction * 0.5
end

-- TODO: Deal with the gap between 0° and 359° failing to trigger this
-- NOTE: Maybe keep track of how much it needs to move on the current direction?
function ENT:GetExcess( Next, Limit )
	local Direction = self.Direction

	Next  = Next * Direction
	Limit = Limit * Direction

	return Next - Limit
end

function ENT:GetNextAngle()
	local Next = (self.Current + self:GetStep()) % 360

	if self.Coverage ~= 360 then
		local Limit  = self:GetLimit()
		local Excess = self:GetExcess( Next, Limit )

		if Excess > 0 then
			local Direction = self.Direction * -1

			Next = Limit + Excess * Direction

			self.Direction = Direction
		end
	end

	return Next
end

function ENT:Think()
	local Next  = self:GetNextAngle()
	local Cycle = Next / 360 -- Converting the angle to a numerical range

	self.Current = Next

	self:SetCycle( Cycle )
end

function ENT:Draw()
	self:DrawModel()

	local Position = self:LocalToWorld( Vector( 0, 0, 100 ) )
	local Angle    = EyeAngles()
	local Text     = "Angle:\n" .. math.floor( self.Current ) .. "°"

	Angle.p = 0
	Angle.r = 0

	Angle:RotateAroundAxis( Angle:Up(), -90 )
	Angle:RotateAroundAxis( Angle:Forward(), 90 )

	cam.Start3D2D( Position, Angle, 1 )
		draw.SimpleText(Text, "Default", 0, 0, nil, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	cam.End3D2D()
end
