require "/objects/isn_sharedobjectscripts.lua"



function isn.powerInit()
	isn.objectsInit()
	storage.passthrough=config.getParameter("isn_powerPassthrough")
	storage.powerReq=config.getParameter("isn_requiredPower",0)
	storage.powercapacity = config.getParameter("isn_batteryCapacity",0)
	storage.powerBuffer=storage.powerBuffer or 0
	storage.maxInput = config.getParameter("isn_maxInput",0)
	storage.maxOutput = config.getParameter("isn_batteryVoltage",0)
	storage.powerInNode = config.getParameter("isn_powerInNode")
	storage.powerOutNode = config.getParameter("isn_powerOutNode")
end

function isn.sumOutboundPowerReq()
	if storage.powerOutNode == nil then return 0 end
	--[[local voltagecount = 0
	local batteries = 0
	local devicelist = isn.getAllDevicesConnectedOnNode(storage.powerOutNode,"output")
	if devicelist == nil then return 0 end
	
	for key, value in pairs(devicelist) do
		local required = world.callScriptedEntity(value,"isn_requiredPowerValue", true)
		if required ~= nil then voltagecount = voltagecount + required end
		
	end
	return voltagecount, batteries]]
	return 0
end

function isn.getCurrentPowerInput()
	if type(storage.powerInNode)~="number" then
		return 0
	end

	local totalInput = 0
	local connectedDevices
	local output = 0
	local isBattery = isn.isBattery()
	connectedDevices = isn.getAllDevicesConnectedOnNode(storage.powerInNode,"input")
	for key, value in pairs (connectedDevices) do
		output = world.callScriptedEntity(value,"isn_getCurrentPowerOutput")
		if output ~= nil then totalInput = totalInput + output end
	end
	return totalInput
end

function isn.makeBatteryDescription(desc, charge)
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

function isn.solarGenerationBlocked()
	-- Power generation does not occur if...
	--if world.info == nil then return true end -- it's on a ship (doesn't work right now)
	if world.underground(storage.position) == true then return true end -- it's underground
	if world.liquidAt(storage.position) == true then return true end -- it's submerged in liquid
	if world.tileIsOccupied(storage.position,false) == true then return true end -- there's a wall in the way
	if world.lightLevel(storage.position) < 0.2 then return true end -- not enough light
end

function isn.checkValidOutput()
	local connectedDevices = isn.getAllDevicesConnectedOnNode(storage.powerOutNode,"output")
	if connectedDevices == nil then return false end
	for _, value in pairs(connectedDevices) do
		if world.callScriptedEntity(value,"isn.canRecievePower") then
			if not world.callScriptedEntity(value,"isn.doesNotConsumePower") then
				return true
			end
		elseif config.getParameter("isn_powerPassthrough") then
			if world.callScriptedEntity(value,"isn.countPowerDevicesConnectedOnOutboundNode")>0 then
				return true
			end
		end
	end
	return false
end

function isn.requiredPowerValue()
	if storage.passthrough then
		return isn.sumOutboundPowerReq()
	else
		return storage.powerReq
	end

end

function isn.getCurrentPowerStorage()
	return isn.getXPercentageOfY(storage.currentstoredpower,storage.powercapacity)
end

function isn.hasStoredPower()
	return storage.currentstoredpower > 0
end

function isn.getCurrentPowerOutput()
	return (not isn.hasStoredPower() and 0) or storage.maxOutput
end

function isn.canSupplyPower()
	if config.getParameter("isn_powerSupplier") then return true end
	return false
end

function isn.canRecievePower()
	if config.getParameter("isn_powerReciever") then return true end
	return false
end


function isn.isPowerPassthrough()
	if config.getParameter("isn_powerPassthrough") then return true end
	return false
end

function isn.hasRequiredPower()
	return storage.powerReq < storage.powerBuffer
end

--TRASH HEAP BELOW!
--[[
function isn.doesNotConsumePower()--serves no purpose
	if true then return nil end
	--[[if config.getParameter("isn_freePower") then return true end
	return false]]
end

function isn.isBattery()--deprecating. everything will be a battery.
	if true  then return nil end
	--[[local capacity = config.getParameter("isn_batteryCapacity")
	if capacity ~= nil and capacity > 0 then return true end
	return false]]
end

function isn.areActivePowerDevicesConnectedOnOutboundNode()--deprecating
	if true  then return nil end
	--[[if not storage.powerOutNode then return false end
	local devicelist = isn.getAllDevicesConnectedOnNode(storage.powerOutNode,"output")
	if devicelist == nil then return false end
	for _, value in pairs(devicelist) do
		if world.callScriptedEntity(value,"isn_canRecievePower") then
			if world.callScriptedEntity(value,"isn_activeConsumption") then
				return true
			end
		end
	end
	return false]]
end

function isn.activeConsumption()--deprecating
	if true  then return nil end
	--[[if config.getParameter("isn_powerPassthrough") then -- It's a conduit (or similar device), better check what downstream says -r
		if isn.areActivePowerDevicesConnectedOnOutboundNode(storage.powerInNode) then
			return true
		end
	elseif storage.activeConsumption == nil then
		return false
	end
	return storage.activeConsumption]]
end

function isn.countPowerDevicesConnectedOnOutboundNode()--serves no actual use
	if true  then return 0 end
	--[[if storage.powerOutNode == nil then return 0 end
	local devicecount = 0
	local devicelist = isn.getAllDevicesConnectedOnNode(storage.powerOutNode,"output")
	if devicelist == nil then return 0 end
	for key, value in pairs(devicelist) do
		if world.callScriptedEntity(value,"isn_canRecievePower") then
			if not world.callScriptedEntity(value,"isn_doesNotConsumePower") then
				devicecount = devicecount + 1
			end
		end
	end
	return devicecount]]
end

function isn.sumPowerActiveDevicesConnectedOnOutboundNode()--useless function now
	if true  then return 0 end
	if storage.powerOutNode == nil then return 0 end
	--[[local voltagecount = 0
	local batteries = 0
	local devicelist = isn.getAllDevicesConnectedOnNode(storage.powerOutNode,"output")
	if devicelist == nil then return 0 end
	
	--problem is here somewhere
	for key, value in pairs(devicelist) do
		if world.callScriptedEntity(value,"isn_canRecievePower") then
		
			if not world.callScriptedEntity(value,"isn_doesNotConsumePower") then
			
				if world.callScriptedEntity(value,"isn_isBattery") == true then
					
					if world.callScriptedEntity(value, "isn_recentlyDischarged") then batteries = batteries + 1 end
				--here...
				elseif world.callScriptedEntity(value,"isn_activeConsumption") then
					sb.logInfo("%s %s",key,value)
					local required = world.callScriptedEntity(value,"isn_requiredPowerValue", true)
					
					if required ~= nil then voltagecount = voltagecount + required end
					
				end
				
			end
		end
	end
	return voltagecount, batteries]]
end
]]--