require "/scripts/util.lua"

isn={}
isn.objects={}

function isn.objects.init()
	storage.position=entity.position()
	storage.logic.inNode = config.getParameter("logicInNode")
	storage.logic.outNode = config.getParameter("logicOutNode")
end


function isn.objects.deviceList(node,direction)
	if node == nil then return nil end
	
	local nodeID
	if direction == "output" then nodeID = object.getOutputNodeIds(node)
	else nodeID = object.getInputNodeIds(node) end
	if nodeID == nil then
		return nil
	end
	
	local devices = { }
	for key, _ in pairs(nodeID) do
		table.insert(devices,key)
	end
	return devices
end

function isn.objects.outputDeviceCount(node)
	if not node then return 0 end
	if not node >= object.outputNodeCount() return 0 end
	return util.tableSize(object.getOutputNodeIds(node))
end

function isn.objects.inputDeviceCount(node)
	if not node then return 0 end
	if not node >= object.inputNodeCount() return 0 end
	return util.tableSize(object.getInputNodeIds(node))
end


function isn.getXPercentageOfY(x,y)
	if (not x) or (not y) return 0 end
	if x = 0 or y = 0 then return 0 end
	return (x / y) * 100
end


--effect group
--inrange
function isn.effectTypesInRange(effect,tilerange,types)
	local targetlist = world.entityQuery(entity.position(),tilerange,{includedTypes=types})
	for _, value in pairs(targetlist) do
		world.sendEntityMessage(value,"applyStatusEffect",effect)
	end
end

function isn.effectPlayersInRange(effect,tilerange)
	isn.effectTypesInRange(effect,tilerange,{"player"})
end

function isn.effectAllInRange(effect,tilerange)
	isn.effectTypesInRange(effect,tilerange,{"creature"})
end

--projectile group - generally outdated mechanism
--inrange
function isn.projectileTypesInRange(projtype,tilerange,types)
	local targetlist = world.entityQuery(entity.position(),tilerange,{includedTypes=types})
	for _, value in pairs(targetlist) do
		world.spawnProjectile(projtype, world.entityPosition(value), entity.id())
	end
end

function isn.projectilePlayersInRange(projtype,tilerange)
	isn.projectileTypesInRange(projtype,tilerange,{"player"})
end

function isn.projectileAllInRange(projtype,tilerange)
	isn.projectileTypesInRange(projtype,tilerange,{"creature"})
end

--inrangeparams
function isn.projectileTypesInRangeParams(projtype,tilerange,params,types)
	local targetlist = world.entityQuery(entity.position(),tilerange,{includedTypes=types})
	for _, value in pairs(targetlist) do
		world.spawnProjectile(projtype, world.entityPosition(value), entity.id(),{0,0},false,params)
	end
end

function isn.projectilePlayersInRangeParams(projtype,tilerange,params)
	isn.projectileTypesInRangeParams(projtype,tilerange,params,{"player"})
end

function isn.projectileAllInRangeParams(projtype,tilerange,params)
	isn.projectileTypesInRangeParams(projtype,tilerange,params,{"creature"})
end

--in rect
function isn.projectileTypesInRectangle(projtype,entpos,xwidth,yheight,types)
	local targetlist = world.entityQuery(entpos,{entpos[1]+xwidth, entpos[2]+yheight},{includedTypes=types})
	for _, value in pairs(targetlist) do
		world.spawnProjectile(projtype,world.entityPosition(value))
	end
end

function isn.projectilePlayersInRectangle(projtype,entpos,xwidth,yheight)
	isn.projectileTypesInRectangle(projtype,entpos,xwidth,yheight,{"player"})
end

function isn.projectileAllInRectangle(projtype,entpos,xwidth,yheight)
	isn.projectileTypesInRectangle(projtype,entpos,xwidth,yheight,{"creature"})
end

