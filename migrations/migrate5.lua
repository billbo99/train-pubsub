-- New data structure for priorities is [surface][resourcename][idname]

local surface = game.surfaces[1].name

local function getUniqueName(entity)
    if #entity.surface.get_train_stops({ name = entity.backer_name }) > 1 then
        --	game.print("Same name as existing Requester train stop")
        entity.backer_name = entity.backer_name .. "X"
        getUniqueName(entity)
    end
end

storage.newpriority = storage.newpriority or {}
--if storage.newpriority == {} then
storage.newpriority[surface] = storage.newpriority[surface] or {}
if storage.priority ~= nil then
    if storage.priority ~= {} then
        for _, priority in pairs(storage.priority) do
            if storage.newpriority[surface][priority.resource.name] == nil then
                storage.newpriority[surface][priority.resource.name] = {}
            end
            if storage.newpriority[surface][priority.resource.name][priority.id.name] == nil then
                storage.newpriority[surface][priority.resource.name][priority.id.name] = {}
            end
            storage.newpriority[surface][priority.resource.name][priority.id.name] = table.deepcopy(priority)
        end
    end
    --   end
end

storage.newpublishers = storage.newpublishers or {}
--if storage.newpublishers == {} then
storage.newpublishers[surface] = storage.newpublishers[surface] or {}
local i = 0
if storage.publishers ~= nil then
    if storage.publishers ~= {} then
        for _, pub in pairs(storage.publishers) do
            -- get unique name for associated publisher station
            local backer_name = pub.backer_name
            if pub.entity ~= nil then
                if pub.entity.valid == true then
                    local entity = pub.entity
                    local station = entity.surface.find_entities_filtered { area = { { x = entity.position.x - 2, y = entity.position.y - 2 }, { x = entity.position.x + 2, y = entity.position.y + 2 } }, type = "train-stop" }
                    [1]
                    getUniqueName(station)
                    backer_name = station.backer_name
                end
            end
            if storage.newpublishers[surface][backer_name] == nil then
                storage.newpublishers[surface][backer_name] = {}
                i = 1
            else
                i = #storage.newpublishers[surface][backer_name] + 1
            end
            if storage.newpublishers[surface][backer_name][i] == nil then
                storage.newpublishers[surface][backer_name][i] = {}
            end
            storage.newpublishers[surface][backer_name][i].entity = pub.entity
            --   storage.newpublishers[surface][pub.backer_name][i].backer_name = pub.backer_name
            if storage.newpublishers[surface][backer_name][i].priority == nil then
                storage.newpublishers[surface][backer_name][i].priority = {}
            end
            storage.newpublishers[surface][backer_name][i].priority.id = table.deepcopy(pub.priority)
            for _, priority in pairs(storage.priority) do
                if priority.id.name == pub.priority.name then
                    storage.newpublishers[surface][backer_name][i].priority.resource = table.deepcopy(priority.resource)
                    break
                end
            end
            storage.newpublishers[surface][backer_name][i].request = pub.request
            storage.newpublishers[surface][backer_name][i].proc_priority = pub.proc_priority
            storage.newpublishers[surface][backer_name][i].tick = pub.tick
            storage.newpublishers[surface][backer_name][i].hide = false
        end
    end
    --   end
end


storage.newrequests = storage.newrequests or {}
--if storage.newrequests == {} then
storage.newrequests[surface] = storage.newrequests[surface] or {}
if storage.requests ~= nil then
    if storage.requests ~= {} then
        for _, req in pairs(storage.requests) do
            if storage.newrequests[surface][req.backer_name] == nil then
                storage.newrequests[surface][req.backer_name] = {}
                i = 1
            else
                i = #storage.newrequests[surface][req.backer_name] + 1
            end
            if storage.newrequests[surface][req.backer_name][i] == nil then
                storage.newrequests[surface][req.backer_name][i] = {}
            end
            storage.newrequests[surface][req.backer_name][i].backer_name = req.backer_name
            storage.newrequests[surface][req.backer_name][i].entity = table.deepcopy(req.entity)
            if storage.newrequests[surface][req.backer_name][i].priority == nil then
                storage.newrequests[surface][req.backer_name][i].priority = {}
            end
            storage.newrequests[surface][req.backer_name][i].priority.id = table.deepcopy(req.priority)
            for _, priority in pairs(storage.priority) do
                if priority.id.name == req.priority.name then
                    storage.newrequests[surface][req.backer_name][i].priority.resource = table.deepcopy(priority
                    .resource)
                    break
                end
            end
            storage.newrequests[surface][req.backer_name][i].request = req.request
            storage.newrequests[surface][req.backer_name][i].proc_priority = req.proc_priority
            storage.newrequests[surface][req.backer_name][i].tick = req.tick
            storage.newrequests[surface][req.backer_name][i].hide = false
        end
    end
    --    end
end

--game.forces[1].reset_technology_effects()

storage.newcounters = storage.newcounters or {}
--if storage.newcounters == {} then
storage.newcounters[surface] = storage.newcounters[surface] or {}
if storage.counters ~= nil then
    if storage.counters ~= {} then
        for i, counter in pairs(storage.counters) do
            storage.newcounters[surface][i] = table.deepcopy(counter)
        end
    end
    --   end
end