require "/objects/power/isn_sharedpowerscripts.lua"

function init()
	if storage.currentstoredpower == nil then storage.currentstoredpower = 0 end
	if storage.excessCurrent ~= nil then storage.excessCurrent = nil end
	
	isn.powerInit()
end

function update(dt)
	if not storage.init then
		storage.currentstoredpower = world.getObjectParameter(entity.id(), 'isnStoredPower') or 0
		storage.init = true
	end

	storage.recentlyDischarged = false

	if storage.currentstoredpower < storage.maxOutput then
		animator.setAnimationState("meter", "d")
	else
		local powerlevel = math.floor(util.clamp(isn.getXPercentageOfY(storage.currentstoredpower,storage.powercapacity)/10,0,10))
		animator.setAnimationState("meter", tostring(powerlevel))
	end

	local powerinput = dt*isn.getCurrentPowerInput()
	storage.currentstoredpower = storage.currentstoredpower + (powerinput or 0)
	
	local poweroutput = isn.sumOutboundPowerReq()
	
	if powerinput>0 then
		if poweroutput>0 then
			animator.setAnimationState("status","on")
		else
			animator.setAnimationState("status","error")
		end
	else
		animator.setAnimationState("status","off")
	end
	
	if isn.hasStoredPower() then
		storage.recentlyDischarged = isn.getCurrentPowerOutput()
		storage.currentstoredpower = storage.currentstoredpower - dt*((storage.maxOutput/10.0)+storage.recentlyDischarged)
	end

	storage.currentstoredpower = math.min(storage.currentstoredpower, storage.powercapacity)
	object.setConfigParameter('description', isn.makeBatteryDescription())
end




function isn.batteryDie()
	if storage.currentstoredpower >= storage.maxOutput then
		local charge = isn.getCurrentPowerStorage()
		local iConf = root.itemConfig(object.name())
		local newObject = { isnStoredPower = storage.currentstoredpower }

		if iConf and iConf.config then
			if iConf.config.inventoryIcon then
				local colour

				if     charge <  25 then colour = 'FF0000'
				elseif charge <  50 then colour = 'FF8000'
				elseif charge <  75 then colour = 'FFFF00'
				elseif charge < 100 then colour = '80FF00'
				else                     colour = '00FF00'
				end
				newObject.inventoryIcon = iConf.config.inventoryIcon .. '?border=1;' .. colour .. '?fade=' .. colour .. 'FF;0.1'
			end

			newObject.description = isn.makeBatteryDescription(iConf.config.description or '', charge)
		end

		world.spawnItem(object.name(), entity.position(), 1, newObject)
	else
		world.spawnItem(object.name(), entity.position())
	end
end



function nodeStuff()
	if storage.powerOutNode then
		object.setOutputNodeLevel(storage.powerOutNode, isn.getCurrentPowerOutput()>0)
	end
end

function onNodeConnectionChange()
	nodeStuff()
end
function onInputNodeChange()
	nodeStuff()
end
function die()
	isn.batteryDie()
end