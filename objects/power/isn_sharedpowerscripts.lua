require "/objects/isn_sharedobjectscripts.lua"

isn.power={}
isn.power.battery={}

function isn.power.init()
	isn.objects.init()
	storage.power.passthrough=config.getParameter("isn_powerpower.passthrough")
	storage.power.req=config.getParameter("isn_requiredPower",0)
	storage.power.capacity = config.getParameter("isn_batteryCapacity",0)
	storage.power.buffer = storage.power.buffer or 0
	storage.power.maxInput = config.getParameter("isn_maxInput",0)
	storage.power.maxOutput = config.getParameter("isn_batteryVoltage",0)
	storage.power.inNode = config.getParameter("isn_power.inNode")
	storage.power.outNode = config.getParameter("isn_power.outNode")
end

function isn.power.sumOutboundReq()
	if storage.power.outNode == nil then return 0 end
	--[[local voltagecount = 0
	local batteries = 0
	local devicelist = isn.getAllDevicesConnectedOnNode(storage.power.outNode,"output")
	if devicelist == nil then return 0 end
	
	for key, value in pairs(devicelist) do
		local required = world.callScriptedEntity(value,"isn_requiredPowerValue", true)
		if required ~= nil then voltagecount = voltagecount + required end
		
	end
	return voltagecount, batteries]]
	return 0
end

function isn.power.getCurrentInput()
	if type(storage.power.inNode)~="number" then
		return 0
	end

	local totalInput = 0
	local connectedDevices
	local output = 0
	local isBattery = isn.isBattery()
	connectedDevices = isn.objects.deviceList(storage.power.inNode,"input")
	for key, value in pairs (connectedDevices) do
		output = world.callScriptedEntity(value,"isn_getCurrentPowerOutput")
		if output ~= nil then totalInput = totalInput + output end
	end
	return totalInput
end

function isn.power.battery.makeDescription(desc, charge)
	if desc == nil then
		desc = root.itemConfig(object.name())
		desc = desc and desc.config and desc.config.description or ''
	end
	if charge == nil then charge = isn.getCurrentPowerStorage() end
	if charge == 0 then return desc end

	if charge < 0.5 then
		charge = '< 0.5'
	else
		charge = math.floor (charge * 2) / 2
	end

	return desc .. (desc ~= '' and "\n" or '') .. "^yellow;Stored charge: " .. charge .. '%'
end


function isn.power.battery.update(dt)
	if not storage.init then
		storage.power.stored = world.getObjectParameter(entity.id(), 'isnStoredPower') or 0
		storage.init = true
	end

	storage.recentlyDischarged = false

	if storage.power.stored < storage.power.maxOutput then
		animator.setAnimationState("meter", "d")
	else
		local powerlevel = math.floor(util.clamp(isn.getXPercentageOfY(storage.power.stored,storage.power.capacity)/10,0,10))
		animator.setAnimationState("meter", tostring(powerlevel))
	end

	local powerinput = dt*isn.power.getCurrentInput()
	storage.power.stored = storage.power.stored + (powerinput or 0)
	
	local poweroutput = isn.sumOutboundpower.req()
	
	if powerinput>0 then
		if poweroutput>0 then
			animator.setAnimationState("status","on")
		else
			animator.setAnimationState("status","error")
		end
	else
		animator.setAnimationState("status","off")
	end
	
	if isn.power.bStored() then
		storage.recentlyDischarged = isn.getCurrentPowerOutput()
		storage.power.stored = storage.power.stored - dt*((storage.power.maxOutput/10.0)+storage.recentlyDischarged)
	end

	storage.power.stored = math.min(storage.power.stored, storage.power.capacity)
	object.setConfigParameter('description', isn.makeBatteryDescription())
end

function isn.power.battery.die()
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


function isn.power.battery.init()
	if storage.currentstoredpower == nil then storage.currentstoredpower = 0 end
	if storage.excessCurrent ~= nil then storage.excessCurrent = nil end
	
	isn.power.init()
end


function isn.power.solarGenerationBlocked()
	-- Power generation does not occur if...
	--if world.info == nil then return true end -- it's on a ship (doesn't work right now)
	if world.underground(storage.position) == true then return true end -- it's underground
	if world.liquidAt(storage.position) == true then return true end -- it's submerged in liquid
	if world.tileIsOccupied(storage.position,false) == true then return true end -- there's a wall in the way
	if world.lightLevel(storage.position) < 0.2 then return true end -- not enough light
end

function isn.power.checkValidOutput()
	local connectedDevices = isn.objects.deviceList(storage.power.outNode,"output")
	if connectedDevices == nil then return false end
	for _, value in pairs(connectedDevices) do
		if world.callScriptedEntity(value,"isn.canRecievePower") then
			if not world.callScriptedEntity(value,"isn.doesNotConsumePower") then
				return true
			end
		elseif config.getParameter("isn_powerpower.passthrough") then
			if world.callScriptedEntity(value,"isn.countPowerDevicesConnectedOnOutboundNode")>0 then
				return true
			end
		end
	end
	return false
end

function isn.power.requiredValue()
	if storage.power.passthrough then
		return isn.power.sumOutboundreq()
	else
		return storage.power.req
	end

end

function isn.power.getCurrentStorage()
	return isn.getXPercentageOfY(storage.power.stored,storage.power.capacity)
end

function isn.power.bStored()
	return storage.power.stored > 0
end

function isn.power.getCurrentOutput()
	return (not isn.power.bStored() and 0) or storage.power.maxOutput
end

function isn.power.canSupply()
	if config.getParameter("isn_powerSupplier") then return true end
	return false
end

function isn.power.canReceive()
	if config.getParameter("isn_powerReciever") then return true end
	return false
end


function isn.power.passthrough()
	return storage.power.passthrough
end

function isn.power.hasRequired()
	return storage.power.req < storage.power.buffer
end
