Script.respawnPoint = "" --entity "Respawn Point"
Script.enabled=true--bool "Enabled"

function Script:Collision(entity, position, normal, speed)
	if self.enabled then
	
		if(entity:GetKeyValue("name") == "Player")  then
			spawnPos = self.respawnPoint:GetPosition()
			entity:SetPosition(spawnPos)
			
			-- Sets the camera direction on spawn
			spawnRot = self.respawnPoint:GetRotation()
			entity.script.camRotation = spawnRot
			
			
		end
	end
end