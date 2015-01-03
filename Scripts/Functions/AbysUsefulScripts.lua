--[[ 
Last Updated: 02/01/2014
By Abyssusj @ https://github.com/abyssusj/

<Includes>
	* Round off to decimal place
	* RGB Converter
	* Player Hud
]]



function round(val, decimal)
	--[[ -----------------------------------------------------------------------
	Round value to decimal place
	Why there is no math.round in LUA I do not know
	
	Last Updated: 03/01/2015
	By Abyssusj
	
	Color tool http://www.colorschemer.com/online.html
	]]
	
	local exp = decimal and 10^decimal or 1
	return math.ceil(val * exp - 0.5) / exp
end



function ConvertRGBA(oldRGB)
	--[[ -----------------------------------------------------------------------
	RGB Converter from 0-255 to 0.0-1.0
	Description: Accepts a table named oldRGB with 3 RGB values and
	returns Vec4 colour coordinates.
	
	Last Updated: 03/01/2015
	By Abyssusj
	
	Color tool http://www.colorschemer.com/online.html
	]]
	
	local newRGB = {} 									-- Define list for new values
		
	for k,v in ipairs(oldRGB) do						-- Iterate through table and convert to 0.0-1.0
		n = v / 255
		print("oldRGB value is " .. v)
		print("newRGB value is " .. round(n,1))
		table.insert(newRGB,round(n,1))
	end
	
	result = table.concat(newRGB,",")			-- Convert Table to List
	return Vec4(result)									-- Convert List to Vac4 coordinates and output
	
end



function Script:PlayerHUD(context)
	--[[ -----------------------------------------------------------------------
	PlayerHUD
	
	Origional: http://romsteady.blogspot.com.au/2014/01/add-primitive-hud-to-leadwerks-indie.html
	Issue: Code did not work, likely depreciated.
	Resolution: Fixed
	
	Last Updated: 02/01/2015
	By Abyssusj
	]]
	
	-- Configure presets
	self.hudFont = Font:Load("Fonts/Arial.ttf",20)
	context:SetFont(self.hudFont)
	local colorLimeGreen = ConvertRGBA({204,255,51,255}) -- Colours have to be Vectors 204,255,51 = 0.8,1,0.2
	local colorRed = ConvertRGBA({245,0,61,255})
	local colorBlack = ConvertRGBA({8,8,8,80})
	
	local scrWidth = context:GetWidth()
	local scrHeight = context:GetHeight()
	local fontHeight = self.hudFont:GetHeight()
	
	-- Draw some stuff
	
	-- Draw Bottom Left Rectangle
	context:SetColor(colorBlack)
	local h = 60
	local w = scrWidth / 4
	local x = 0
	local y = scrHeight - h
	context:DrawRect(x,y,w,h)
	
	-- Draw Draw Draw Bottom Right Rectangle
	local x = scrWidth - w
	context:DrawRect(x,y,w,h)
	
	-- Top Middle Rectangle
	local x = (scrWidth / 2) - (w / 2)
	local y = 0
	context:DrawRect(x,y,w,h)
	
	-- Draw text to screen
	context:SetColor(colorLimeGreen)
	local hudText = "HUD ENABLED "
	local x = (scrWidth / 2) - (self.hudFont:GetTextWidth(hudText) / 2)
	local y = 12
	context:DrawText(hudText, x, y) 
	
	-- Check for self.health
	if self.hudFont~=nil then
		local x = 24
		local y = context:GetHeight() - fontHeight - 24
		local hudText = "Health "..self.health
		context:DrawText(hudText, x, y)
	end
	
	-- Check for self.weapons
	if self.weapons[self.currentweaponindex] ~=nil then
		hudText = "Ammo "..self.weapons[self.currentweaponindex].clipammo.." / "..self.weapons[self.currentweaponindex].ammo
		local x = context:GetWidth() - self.hudFont:GetTextWidth(hudText) - 24
		local y = context:GetHeight() - fontHeight - 24
		context:DrawText(hudText, x, y)
	end

end