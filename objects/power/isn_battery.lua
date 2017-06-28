require "/objects/power/isn_sharedpowerscripts.lua"



function init()
	isn.power.battery.init()
end

function update(dt)
	isn.power.battery.update(dt)
end



function nodeStuff()
	if storage.power.outNode then
		object.setOutputNodeLevel(storage.power.outNode, isn.power.getCurrentOutput()>0)
	end
end

function onNodeConnectionChange()
	nodeStuff()
end
function onInputNodeChange()
	nodeStuff()
end

function die()
	isn.power.battery.die()
end