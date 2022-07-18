-- New data structure for priorities is [surface][resourcename][idname]

local surface = game.surfaces[1].name

local function getUniqueName(entity)
	if #entity.surface.get_train_stops({name=entity.backer_name}) > 1 then
	--	game.print("Same name as existing Requester train stop")
		entity.backer_name = entity.backer_name .. "X"
		getUniqueName(entity)
	end
end

global.newpriority = global.newpriority or {}
--if global.newpriority == {} then
    global.newpriority[surface] = global.newpriority[surface] or {}
    if global.priority ~= nil then
        if global.priority ~= {} then
            for _,priority in pairs(global.priority) do
                if global.newpriority[surface][priority.resource.name] == nil then
                    global.newpriority[surface][priority.resource.name] = {}
                end
                if global.newpriority[surface][priority.resource.name][priority.id.name] == nil then
                    global.newpriority[surface][priority.resource.name][priority.id.name] = {}
                end
                global.newpriority[surface][priority.resource.name][priority.id.name] = table.deepcopy(priority)
            end
        end
 --   end
end

global.newpublishers = global.newpublishers or {}
--if global.newpublishers == {} then
    global.newpublishers[surface] = global.newpublishers[surface] or {}
    local i = 0
    if global.publishers ~= nil then
        if global.publishers ~= {} then
            for _,pub in pairs(global.publishers) do
                -- get unique name for associated publisher station
                local backer_name = pub.backer_name
                if pub.entity ~= nil then
                    if pub.entity.valid == true then
                        local entity = pub.entity
                        local station = entity.surface.find_entities_filtered{area={{x=entity.position.x - 2,y=entity.position.y - 2},{x=entity.position.x + 2,y=entity.position.y + 2}},type="train-stop"}[1]
                        getUniqueName(station)
                        backer_name = station.backer_name
                    end
                end
                if global.newpublishers[surface][backer_name] == nil then
                    global.newpublishers[surface][backer_name] = {}
                    i = 1
                else
                    i = #global.newpublishers[surface][backer_name] + 1
                end
                if global.newpublishers[surface][backer_name][i] == nil then
                    global.newpublishers[surface][backer_name][i] = {}
                end
                global.newpublishers[surface][backer_name][i].entity = pub.entity
            --   global.newpublishers[surface][pub.backer_name][i].backer_name = pub.backer_name
                if global.newpublishers[surface][backer_name][i].priority == nil then
                    global.newpublishers[surface][backer_name][i].priority = {}
                end
                global.newpublishers[surface][backer_name][i].priority.id = table.deepcopy(pub.priority)
                for _,priority in pairs(global.priority) do
                    if priority.id.name == pub.priority.name then
                        global.newpublishers[surface][backer_name][i].priority.resource = table.deepcopy(priority.resource)
                        break
                    end
                end
                global.newpublishers[surface][backer_name][i].request = pub.request
                global.newpublishers[surface][backer_name][i].proc_priority = pub.proc_priority
                global.newpublishers[surface][backer_name][i].tick = pub.tick
                global.newpublishers[surface][backer_name][i].hide = false
            end
        end
 --   end
end


global.newrequests = global.newrequests or {}
--if global.newrequests == {} then
    global.newrequests[surface] = global.newrequests[surface] or {}
    if global.requests ~= nil then
        if global.requests ~= {} then
            for _,req in pairs(global.requests) do
                if global.newrequests[surface][req.backer_name] == nil then
                    global.newrequests[surface][req.backer_name] = {}
                    i = 1
                else
                    i = #global.newrequests[surface][req.backer_name] + 1
                end
                if global.newrequests[surface][req.backer_name][i] == nil then
                    global.newrequests[surface][req.backer_name][i] = {}
                end
                global.newrequests[surface][req.backer_name][i].backer_name = req.backer_name
                global.newrequests[surface][req.backer_name][i].entity = table.deepcopy(req.entity)
                if global.newrequests[surface][req.backer_name][i].priority == nil then
                    global.newrequests[surface][req.backer_name][i].priority = {}
                end
                global.newrequests[surface][req.backer_name][i].priority.id = table.deepcopy(req.priority)
                for _,priority in pairs(global.priority) do
                    if priority.id.name == req.priority.name then
                        global.newrequests[surface][req.backer_name][i].priority.resource = table.deepcopy(priority.resource)
                        break
                    end
                end
                global.newrequests[surface][req.backer_name][i].request = req.request
                global.newrequests[surface][req.backer_name][i].proc_priority = req.proc_priority
                global.newrequests[surface][req.backer_name][i].tick = req.tick
                global.newrequests[surface][req.backer_name][i].hide = false
            end
        end
--    end
end

--game.forces[1].reset_technology_effects()

global.newcounters = global.newcounters or {}
--if global.newcounters == {} then
    global.newcounters[surface] = global.newcounters[surface] or {}
    if global.counters ~= nil then
        if global.counters ~= {} then
            for i,counter in pairs(global.counters) do
                global.newcounters[surface][i] = table.deepcopy(counter)
            end
        end
 --   end
end
