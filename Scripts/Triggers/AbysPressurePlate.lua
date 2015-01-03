import "Scripts/Functions/ReleaseTableObjects.lua"
import "Scripts/Functions/GetEntityNeighbors.lua"
import "Scripts/Functions/ReleaseTableObjects.lua"

Script.collide=false
Script.enabled=true--bool "Enabled"
Script.openstate=false--bool "Start Open"
Script.distance=Vec3(1,0,0)--Vec3 "Distance"
Script.movespeed=1--float "Move speed" 0,100,3
Script.opensoundfile=""--path "Open Sound" "Wav File (*wav):wav|Sound"
Script.closesoundfile=""--path "Close Sound" "Wav File (*wav):wav|Sound"
Script.loopsoundfile=""--path "Loop Sound" "Wav File (*wav):wav|Sound"
Script.manualactivation=false--bool "Manual activate"
Script.closedelay=2000--int "Close delay"

function Script:Start()
	self.entity:SetGravityMode(false)
	if self.entity:GetMass()==0 then
		Debug:Error("Entity mass must be greater than 0.")
	end

	self.sound={}

	if self.opensoundfile~="" then self.sound.open = Sound:Load(self.opensoundfile) end
	if self.loopsoundfile~="" then self.sound.loop = Sound:Load(self.loopsoundfile) end
	if self.closesoundfile~="" then self.sound.close = Sound:Load(self.closesoundfile) end
	
	if self.sound.loop~=nil then
		self.loopsource = Source:Create()
		self.loopsource:SetSound(self.sound.loop)
		self.loopsource:SetLoopMode(true)
		self.loopsource:SetRange(50)
	end

	if self.manualactivation==false then self.Use=nil end

	self.opentime=0
	self.currenttime = Time:GetCurrent()
	
	--Create a motorized slider joint
	local position=self.entity:GetPosition(true)
	local pin=self.distance:Normalize()
	self.joint=Joint:Slider(position.x,position.y,position.z,pin.x,pin.y,pin.z,self.entity,nil)
	if self.openstate then
		self.openangle=0
		self.closedangle=self.distance:Length()
	else
		self.openangle=self.distance:Length()
		self.closedangle=0
	end
	self.joint:EnableMotor()
	self.joint:SetMotorSpeed(self.movespeed)
end

function Script:Use()
	self:Toggle()
end

function Script:Toggle()--in
	if self.enabled then
		if self.openstate then
			self:Close()
		else
			self:Open()
		end
	end
end

function Script:Open()--in
	if self.enabled then
		if self.openstate==false then
			if self.currenttime-self.opentime<self.closedelay then
				if self.sound.open then
					self.entity:EmitSound(self.sound.open)
				end
				self.joint:SetAngle(self.openangle)
				self.openstate=true			
				self.component:CallOutputs("Open")
				if self.loopsource~=nil then
					self.loopsource:SetPosition(self.entity:GetPosition(true))
					if self.loopsource:GetState()==Source.Stopped then
						self.loopsource:Play()
					end
				end
			end
		end
	end
end

function Script:Close()--in
	if self.enabled then
		if self.openstate then
			if self.sound.close then
				self.entity:EmitSound(self.sound.close)
			end
			self.joint:SetAngle(self.closedangle)
			self.openstate=false
			if self.loopsource~=nil then
				self.loopsource:SetPosition(self.entity:GetPosition(true))
				if self.loopsource:GetState()==Source.Stopped then
					self.loopsource:Play()
				end
			end
			self.component:CallOutputs("Close")
		end
	end
end

function Script:Disable()--in
	self.enabled=false
end

function Script:Enable()--in
	self.enabled=true
end


function Script:UpdatePhysics()
	--Disable loop sound
	if self.sound.loop~=nil then
		local angle
		if self.openstate then
			angle = self.openangle
		else
			angle = self.closedangle
		end
		if math.abs(self.joint:GetAngle()-angle)<0.1 then
			if self.loopsource:GetState()~=Source.Stopped then
				self.loopsource:Stop()
			end
		else
			if self.loopsource:GetState()==Source.Stopped then
				self.loopsource:Resume()
			end
		end
		if self.loopsource:GetState()==Source.Playing then
			self.loopsource:SetPosition(self.entity:GetPosition(true))
		end
	end
	--Automatically close the door after a delay
	if self.closedelay>0 then
		if self.openstate then
			if self.currenttime-self.opentime>self.closedelay then
				self:Close()
			end
		end
	end
	self.currenttime = Time:GetCurrent()
end

function Script:Release()
	ReleaseTableObjects(self.sound)
	if self.loopsource then
		self.loopsource:Release()
		self.loopsource=nil
	end
	self.sound=nil
end

function Script:Collision(entity, position, normal, speed)
	if self.enabled then
	print("get pos ", self.entity:GetPosition())
		self.opentime = Time:GetCurrent()
		self.component:CallOutputs("Collision")
	end
end

function Script:Enable()--in
	if self.enabled==false then
		self.enabled=true
		self:CallOutputs("Enable")
	end
end

function Script:Disable()--in
	if self.enabled then
		self.enabled=false
		self:CallOutputs("Disable")
	end
end