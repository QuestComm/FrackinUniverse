require "/objects/power/isn_sharedpowerscripts.lua"
require "/objects/isn_sharedobjectscripts.lua"

function init()
	isn_powerInit()
	storage.buffRange=config.getParameter("isn_buffRange",1)
	storage.buffEffect=config.getParameter("isn_buffEffect","nude")
end

function update(dt)
	storage.active=false
	if storage.powerInNode and storage.logicInNode then
		if (not object.isInputNodeConnected(storage.logicInNode)) or object.getInputNodeLevel(storage.logicInNode) then
			if isn_hasRequiredPower() then
				storage.active=true
			end
		end
	end
	animator.setAnimationState("switchState", storage.active and "on" or "off")
	if storage.active then
		isn_effectAllInRange(storage.buffEffect,500)--"isn_atmosregen"
	end
end