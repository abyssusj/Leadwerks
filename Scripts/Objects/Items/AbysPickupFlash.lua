Script.opensoundfile=""--path "Open Sound" "Wav File (*wav):wav|Sound"

function Script:Start()
self.sound={}
	if self.opensoundfile~="" then 
		self.sound.open = Sound:Load(self.opensoundfile) 
	end
end

function Script:Use(player)
	if not self.hasflash then
		player.hasflash=true
		self.entity:EmitSound(self.sound.open)
		self.entity:Hide()
	end
end

function Script:Collision(entity, position, normal, speed)
	if not self.hasflash then
		if entity.script~=nil then self:Use(entity.script) end
	end
end