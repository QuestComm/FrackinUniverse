require "/objects/power/isn_sharedpowerscripts.lua"

function init()
	storage.checkticks = 0
end

function update(dt)
	storage.checkticks = storage.checkticks + 1
	if storage.checkticks >= 10 then
		storage.checkticks = 0
		isn.getCurrentPowerOutput()
	end
end

function isn.getCurrentPowerOutput()
	if isn.powerGenerationBlocked == true then
		animator.setAnimationState("meter", "0")
		return 0
	end
	
	local generated = 0
	local genmult = 2
	local location = isn.getTruePosition()
	local light = world.lightLevel(location)

	
	generated = light * 2
	
	if location[2] < 500 then genmult = 1
	elseif location[2] > 900 then genmult = 5 
	elseif location[2] > 700 then genmult = 3 end
	
	generated = generated * genmult
	generated = math.min(generated,12)
	
	local summationForDebug = string.format("P %.2f L %.2f", generated, light)
	world.debugText(summationForDebug,{location[1]-(string.len(summationForDebug)*0.25),location[2]-3.5},"cyan")
	
	if generated >= 6 then animator.setAnimationState("meter", "4")
	elseif generated >= 4  then animator.setAnimationState("meter", "3")
	elseif generated >= 3 then animator.setAnimationState("meter", "2")
	elseif generated >= 2 then animator.setAnimationState("meter", "1")
	else animator.setAnimationState("meter", "0")
	end
	
	local divisor = isn.countPowerDevicesConnectedOnOutboundNode(0)
	if divisor < 1 then return 0 end
	
	return generated
end

function onNodeConnectionChange()
	if isn.checkValidOutput() == true then object.setOutputNodeLevel(0, true)
	else object.setOutputNodeLevel(0, false) end
end


