function Check_train_config(train, station)
    --debugp("train config" .. station.name)
    for _, config in pairs(station.surface.find_entities_filtered { area = { { x = station.position.x - 2,
        y = station.position.y - 2 }, { x = station.position.x + 2, y = station.position.y + 2 } },
        type = "constant-combinator", name = "train-config" }) do
        local cb = config.get_or_create_control_behavior()
        cb.parameters = nil
        local locomotives = train.locomotives
        local carriages = train.carriages
        local numLoco = #locomotives.front_movers + #locomotives.back_movers
        local numWagons = #carriages - numLoco
        local Loco2 = 0
        local i = 1
        if numLoco > 1 then
            local locos = 0

            while locos < 2 and carriages[i] ~= nil do
                if carriages[i].type == "locomotive" then
                    locos = locos + 1
                end
                if locos < 2 then i = i + 1 end
            end
        end
        cb.set_signal(1, {
            signal = {
                type = "item",
                name = "locomotive"
            },
            count = numLoco
        }
        )
        cb.set_signal(2, {
            signal = {
                type = "item",
                name = "cargo-wagon"
            },
            count = numWagons
        }
        )

        if i > 1 then
            cb.set_signal(3, {
                signal = {
                    type = "virtual",
                    name = "locomotive2"
                },
                count = i
            }
            )
        end
        global.train_config = global.train_config or {}
        global.train_config[#global.train_config + 1] = { config = config, station = station }
    end
end

function clear_train_config()
    global.train_config = global.train_config or {}
    if #global.train_config == 0 then return end
    for i, train_config in pairs(global.train_config) do
        if train_config.station.valid == true then
            local trains = train_config.station.get_train_stop_trains()
            local flag = false
            for _, train in pairs(trains) do
                if train.station == train_config.station then
                    flag = true
                    break
                end
            end
            if flag == false then
                if train_config.config.valid == true then
                    local cb = train_config.config.get_or_create_control_behavior()
                    cb.parameters = nil
                end
                table.remove(global.train_config, i)
            end
        else
            table.remove(global.train_config, i)
        end
    end
end

function build_schedule(train, backer_name, priority)
    local schedule = {}
    schedule.records = {}
    --debugp("Current scheduled record is " .. train.schedule.current)
    for i = 1, train.schedule.current do
        schedule.records[#schedule.records + 1] = train.schedule.records[i]
    end
    local record = { station = backer_name, wait_conditions = {} }
    if priority.wc then
        local compare = "or"
        if priority.wc.rb_and == true then compare = "and" end
        if priority.wc.inc_ef == true then
            if priority.wc.empty == true then
                record.wait_conditions[#record.wait_conditions + 1] = { type = "empty", compare_type = compare }
            elseif priority.wc.full == true then
                record.wait_conditions[#record.wait_conditions + 1] = { type = "full", compare_type = compare }
            end
        end
        if priority.wc.inactivity == true then
            local ticks = 60 * priority.wc.inact_int
            record.wait_conditions[#record.wait_conditions + 1] = {
                type = "inactivity",
                compare_type = compare,
                ticks = ticks
            }
        end
        if priority.wc.wait_timer == true then
            local ticks = 60 * priority.wc.wait_int
            record.wait_conditions[#record.wait_conditions + 1] = { type = "time", compare_type = compare, ticks = ticks }
        end
        if priority.wc.count == true then
            local comp_sym = { "<", ">", "=", "≥", "≤", "≠" }
            local count_typ = "item_count"
            --	game.print(priority.resource.type)
            if priority.resource.type == "fluid" then count_typ = "fluid_count" end
            record.wait_conditions[#record.wait_conditions + 1] = {
                type = count_typ,
                compare_type = compare,
                condition = { comparator = comp_sym[priority.wc.count_ddn],
                    first_signal = { type = priority.resource.type, name = priority.resource.name },
                    constant = priority.wc.count_amt }
            }
        end
    else
        record.wait_conditions[#record.wait_conditions + 1] = { type = "empty", compare_type = "or" }
        record.wait_conditions[#record.wait_conditions + 1] = { type = "inactivity", compare_type = "or", ticks = 300 }
    end
    schedule.records[#schedule.records + 1] = record
    schedule.current = #schedule.records
    -- experimental add in any remaining supply stops
    local n = train.schedule.current + 1
    while train.schedule.records[n] do
        local wait = train.schedule.records[n].wait_conditions
        if wait then
            if wait[1].type == "circuit" then
                schedule.records[#schedule.records + 1] = train.schedule.records[n]
            end
        end
        wait = nil
        n = n + 1
    end

    global.train_res = global.train_res or {}
    global.train_res[train.id] = priority.resource
    --	game.print(train.id .. priority.resource.name .. global.train_res[train.id].name)
    train.manual_mode = true
    train.schedule = schedule
    train.manual_mode = false
end

function on_gui_checked_state_changed(event)
    local mod = event.element.get_mod()
    if mod == nil then return end
    if mod ~= "train-pubsub" then return end
    local element = event.element
    local player = game.players[event.player_index]
    local surface = player.surface.name

    if element.name == "hide" then
        local backer_name = global.cur_publisher[player.index].backer_name
        local key = global.cur_publisher[player.index].key
        --	game.print(backer_name)
        if global.newpublishers[surface][backer_name][key].hide == nil then
            global.newpublishers[surface][backer_name][key].hide = true
        end
        if global.newpublishers[surface][backer_name][key].hide == false then
            global.newpublishers[surface][backer_name][key].hide = true
        else
            global.newpublishers[surface][backer_name][key].hide = false
        end
        if global.newrequests ~= nil then
            if global.newrequests[surface] ~= nil then
                if global.newrequests[surface][backer_name] ~= nil then
                    if global.newrequests[surface][backer_name][key] ~= nil then
                        global.newrequests[surface][backer_name][key].hide = global.newpublishers[surface][backer_name][
                            key].hide
                    end
                end
            end
        end

        return
    end
    if element.name == "rqunhide" then
        global.player[player.index].unhide = global.player[player.index].unhide or false
        if global.player[player.index].unhide == false then
            global.player[player.index].unhide = true
        else
            global.player[player.index].unhide = false
        end
        gui_open_rqtable(player)
        return
    end
    local gui = mod_gui.get_frame_flow(player)
    local frame = gui.station_frame

    if frame then
        if global.player[player.index].cur_priority == #global.newpriority + 1 then
            save_priority_wc(event)
        else
            update_priority_wc(event)
        end
        local mode = "add+"
        if string.sub(element.name, 1, 4) ~= "new_" then mode = "edit" end
        gui_open_station_frame(player, mode)
    end
end

function update_priority_wc(event)
    local element = event.element
    local player = game.players[event.player_index]
    local wc = {}
    local name = element.name
    if string.sub(element.name, 1, 4) == "new_" then
        wc = global.player[player.index].wc
        name = string.sub(element.name, 5, -1)
    else
        wc = global.newpriority[player.surface.name][global.player[player.index].resource][
            global.player[player.index].id].wc
    end
    if name == "rb_or" then
        if wc.rb_or == false then
            wc.rb_or = true
            wc.rb_and = false
        end
    elseif name == "rb_and" then
        if wc.rb_and == false then
            wc.rb_or = false
            wc.rb_and = true
        end
    elseif name == "efinc" then
        if wc.inc_ef == true then
            wc.inc_ef = false
        elseif wc.inc_ef == false then
            wc.inc_ef = true
        end
    elseif name == "empty" then
        if wc.empty == false then
            wc.empty = true
            wc.full = false
        end
    elseif name == "full" then
        if wc.full == false then
            wc.empty = false
            wc.full = true
        end
    elseif name == "inactivity" then
        if wc.inactivity == true then
            wc.inactivity = false
        elseif wc.inactivity == false then
            wc.inactivity = true
        end
    elseif name == "wait_timer" then
        if wc.wait_timer == true then
            wc.wait_timer = false
        elseif wc.wait_timer == false then
            wc.wait_timer = true
        end
    elseif name == "count" then
        if wc.count == true then
            wc.count = false
        elseif wc.count == false then
            wc.count = true
        end
    end
end

function save_priority_wc(event)
    local element = event.element
    local player = game.players[event.player_index]
    local wc = {}
    local name = element.name
    if string.sub(element.name, 1, 4) == "new_" then
        wc = global.player[player.index].wc
        name = string.sub(element.name, 5, -1)
    else
        wc = global.newpriority[player.surface.name][global.player[player.index].resource][
            global.player[player.index].id].wc
    end
    global.player[player.index].wc = wc
    if name == "rb_or" then
        if wc.rb_or == false then
            global.player[player.index].wc.rb_or = true
            global.player[player.index].wc.rb_and = false
        end
    elseif name == "rb_and" then
        if wc.rb_and == false then
            global.player[player.index].wc.rb_or = false
            global.player[player.index].wc.rb_and = true
        end
    elseif name == "efinc" then
        if wc.inc_ef == true then
            global.player[player.index].wc.inc_ef = false
        elseif wc.inc_ef == false then
            global.player[player.index].wc.inc_ef = true
        end
    elseif name == "empty" then
        if wc.empty == false then
            global.player[player.index].wc.empty = true
            global.player[player.index].wc.full = false
        end
    elseif name == "full" then
        if wc.full == false then
            global.player[player.index].wc.empty = false
            global.player[player.index].wc.full = true
        end
    elseif name == "inactivity" then
        if wc.inactivity == true then
            global.player[player.index].wc.inactivity = false
        elseif wc.inactivity == false then
            global.player[player.index].wc.inactivity = true
        end
    elseif name == "wait_timer" then
        if wc.wait_timer == true then
            global.player[player.index].wc.wait_timer = false
        elseif wc.wait_timer == false then
            global.player[player.index].wc.wait_timer = true
        end
    elseif name == "count" then
        if wc.count == true then
            global.player[player.index].wc.count = false
        elseif wc.count == false then
            global.player[player.index].wc.count = true
        end
    end
end

script.on_event(defines.events.on_gui_value_changed, function(event)
    local mod = event.element.get_mod()
    if mod == nil then return end
    if mod ~= "train-pubsub" then return end
    local player = game.players[event.player_index]
    local value = math.floor(event.element.slider_value)
    local gui = mod_gui.get_frame_flow(player)
    local frame = gui.station_frame
    if event.element.name == "inact_slider" then
        global.newpriority[player.surface.name][global.player[player.index].resource][global.player[player.index].id].wc
        .inact_int = value
        frame.inact_table.inact_int.text = tostring(value)
    elseif event.element.name == "new_inact_slider" then
        global.player[player.index].wc.inact_int = value
        local value = math.floor(event.element.slider_value)
        frame.inact_table.new_inact_int.text = tostring(value)
    elseif event.element.name == "wait_slider" then
        global.newpriority[player.surface.name][global.player[player.index].resource][global.player[player.index].id].wc
        .wait_int = value
        frame.rbtable.wait_int.text = tostring(value)
    elseif event.element.name == "new_wait_slider" then
        global.player[player.index].wc.wait_int = value
        frame.rbtable.new_wait_int.text = tostring(value)
    end
end)

script.on_event(defines.events.on_gui_text_changed, function(event)
    local mod = event.element.get_mod()
    if mod == nil then return end
    if mod ~= "train-pubsub" then return end
    local player = game.players[event.player_index]
    local gui = mod_gui.get_frame_flow(player)
    local element = event.element

    local resource = global.player[player.index].resource
    local id = global.player[player.index].id

    local value = tonumber(string.match(event.element.text, "%d+"))
    if event.element.name == "count_amt" then
        global.newpriority[player.surface.name][resource][id].wc.count_amt = value
    elseif event.element.name == "new_count_amt" then
        global.player[player.index].wc.count_amt = value
    elseif event.element.name == "inact_int" or
        event.element.name == "new_inact_int" or
        event.element.name == "wait_int" or
        event.element.name == "new_wait_int" or
        event.element.name == "process_priority" then
        if value == nil then value = 1 end
        if value > 200 then value = 200 end
        if value < 1 then value = 1 end
        if event.element.name == "inact_int" then
            local frame = gui.station_frame
            global.newpriority[player.surface.name][resource][id].wc.inact_int = value
            frame.inact_table.inact_int.text = tostring(value)
            frame.inact_slider.slider_value = value
        elseif event.element.name == "new_inact_int" then
            local frame = gui.station_frame
            global.player[player.index].wc.inact_int = value
            frame.inact_table.new_inact_int.text = tostring(value)
            frame.new_inact_slider.slider_value = value
        elseif event.element.name == "wait_int" then
            local frame = gui.station_frame
            global.newpriority[player.surface.name][resource][id].wc.wait_int = value
            frame.rbtable.wait_int.text = tostring(value)
            frame.wait_slider.slider_value = value
        elseif event.element.name == "new_wait_int" then
            local frame = gui.station_frame
            global.player[player.index].wc.wait_int = value
            frame.rbtable.new_wait_int.text = tostring(value)
            frame.new_wait_slider.slider_value = value
        elseif event.element.name == "process_priority" then
            local frame = gui.train_publisher
            if frame == nil then
                gui = player.gui.relative
                frame = gui.train_publisher
            end
            global.newpublishers[player.surface.name][global.cur_publisher[event.player_index].backer_name][
            global.cur_publisher[event.player_index].key].proc_priority = value
            frame.proc_table.process_priority.text = tostring(value)
        end
    end
end)

function find_best_match(station)
    local reqpri = {}
    local backer_name = station.backer_name
    local surface = station.surface.name
    --	local status,err = pcall(function()
    if global.newrequests == nil then return end
    if global.newrequests == {} then return end
    if global.newrequests[surface] == nil then return end
    if global.newrequests[surface] == {} then return end
    for keyi, requests in pairs(global.newrequests[surface]) do
        for i, request in pairs(requests) do
            if request == nil then table.remove(global.newrequests[surface][keyi], i) end
            if request.backer_name == nil then table.remove(global.newrequests[surface][keyi], i) end
            if request.backer_name ~= keyi then
                if request.backer_name then
                    log("request error " .. request.backer_name .. ":" .. keyi .. " removed")
                end
                table.remove(global.newrequests[surface][keyi], i)
                for j, pub in pairs(global.newpublishers[surface][keyi]) do
                    pub.backer_name = keyi
                end
            end
            --	game.print(request.backer_name)
            if check_unique(station.surface, request.backer_name) == false then
                table.remove(global.newrequests[surface][keyi], i)
            end
            --	if request.backer_name ~= nil then
            --debugp("look through priorities")
            if request.priority == nil then
            elseif request.priority == {} then
            elseif request.priority.resource == nil then
            elseif request.priority.resource == {} then
            elseif request.priority.id == nil then
            elseif request.priority.id == {} then
            else
                if global.newpriority[surface] and global.newpriority[surface][request.priority.resource.name] and
                    global.newpriority[surface][request.priority.resource.name][request.priority.id.name] then
                    local priority = global.newpriority[surface][request.priority.resource.name][
                    request.priority.id.name]
                    --	for j,priority in pairs(global.priority) do
                    --	if (request.priority.name == priority.id.name) and not (request.backer_name == nil) then
                    if priority ~= nil then
                        for _, istation in ipairs(priority.station) do
                            if backer_name == istation[2] then
                                -- process priority
                                if request.proc_priority then
                                    --	if request.proc_priority ~= "1" then
                                    if reqpri.proc_priority then
                                        --	debugp("found reqpri proc priority")
                                        if reqpri.proc_priority > request.proc_priority then
                                            reqpri = {
                                                proc_priority = request.proc_priority,
                                                request = request,
                                                priority = priority,
                                                i = i,
                                                tick = request.tick
                                            }
                                        elseif (
                                            reqpri.tick > request.tick and reqpri.proc_priority == request.proc_priority
                                            ) then
                                            reqpri = {
                                                proc_priority = request.proc_priority,
                                                request = request,
                                                priority = priority,
                                                i = i,
                                                tick = request.tick
                                            }
                                        end
                                    else
                                        reqpri = {
                                            proc_priority = request.proc_priority,
                                            request = request,
                                            priority = priority,
                                            i = i,
                                            tick = request.tick
                                        }
                                        --	log(backer_name .. "reqpri priority was nil")
                                    end
                                else
                                    reqpri = {
                                        proc_priority = request.proc_priority,
                                        request = request,
                                        priority = priority,
                                        i = i,
                                        tick = request.tick
                                    }
                                    log(backer_name .. "request priority was nil")
                                    --	return reqpri
                                end
                                --else
                                --	reqpri = {proc_priority = "1", request = request, priority = priority, i = i}
                                --	return reqpri
                                --end
                            end
                        end
                    end
                end
            end
        end
    end
    return reqpri
end

function spairs(t, order)
    -- collect the keys
    local keys = {}
    for k in pairs(t) do keys[#keys + 1] = k end

    -- if order function given, sort by it by passing the table and keys a, b,
    -- otherwise just sort the keys
    if order then
        table.sort(keys, function(a, b) return order(t, a, b) end)
    else
        table.sort(keys)
    end

    -- return the iterator function
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

function pending_req()
    global.pending_req = global.pending_req or {}
    for i, pending in ipairs(global.pending_req) do
        local req = game.surfaces["nauvis"].find_entities_filtered { position = pending, name = "train-counter" }[1]
        if req then
            req.operable = false
            req.minable = false
            req.destructible = false
            addPSToTable(req)
            table.remove(global.pending_req, i)
        end
    end
end

--[[ function fix_raw_wood()
	for _,priority in pairs(global.priority) do
		if priority.id.name == 'raw-wood' then
			priority.id.name = 'wood'
		end
		if priority.resource.name == 'raw-wood' then
			priority.resource.name = 'wood'
		end
	end
	for _,publisher in pairs(global.publishers) do
		if publisher.priority.name == 'raw-wood' then
			publisher.priority.name = 'wood'
		end
	end
end ]]
function on_pre_entity_settings_pasted(event)
    local player = game.players[event.player_index]
    local source = {}
    local destination = {}
    --	game.print("on_pre_entity_settings_pasted")
    if event.source.name == "train-publisher" and event.destination.name == "train-publisher" then
        for keyi, publishers in pairs(global.newpublishers[player.surface.name]) do
            for i, publisher in pairs(publishers) do
                if publisher.entity == event.source then
                    source.backer_name = keyi
                    source.i = i
                end
                if publisher.entity == event.destination then
                    destination.backer_name = keyi
                    destination.i = i
                end
            end
        end
        local status, err = pcall(function()
            if source ~= {} and destination ~= {} then
                global.newpublishers[player.surface.name][destination.backer_name][destination.i] = table.deepcopy(
                    global
                    .newpublishers[player.surface.name][source.backer_name][source.i])
                global.newpublishers[player.surface.name][destination.backer_name][destination.i].backer_name =
                    destination
                    .backer_name
                global.newpublishers[player.surface.name][destination.backer_name][destination.i].entity = event
                .destination
                global.newpublishers[player.surface.name][destination.backer_name][destination.i].request = false
                if global.newpublishers[player.surface.name][source.backer_name][source.i].proc_priority ~= nil then
                    global.newpublishers[player.surface.name][destination.backer_name][destination.i].proc_priority =
                        global
                        .newpublishers[player.surface.name][source.backer_name][source.i].proc_priority
                else
                    global.newpublishers[player.surface.name][destination.backer_name][destination.i].proc_priority = 50
                end
            end
        end)
    end
end

function reset_requests()
    global.newrequests = {}
    for _, surface in pairs(game.surfaces) do
        if global.newpublishers[surface.name] ~= nil then
            if global.newpublishers[surface.name] ~= {} then
                for keyi, publishers in pairs(global.newpublishers[surface.name]) do
                    --	game.print(keyi)
                    for i, pub in pairs(publishers) do
                        global.newpublishers[surface.name][keyi][i].request = false
                        if global.newpublishers[surface.name][keyi][i].proc_priority == nil then
                            global.newpublishers[surface.name][keyi][i].proc_priority = 50
                        end
                        if global.newpublishers[surface.name][keyi][i].entity == nil then
                            global.newpublishers[surface.name][keyi][i] = {}
                        elseif global.newpublishers[surface.name][keyi][i].entity.valid ~= true then
                            global.newpublishers[surface.name][keyi][i] = {}
                        end
                    end
                end
            end
        end
    end
end

function reset_trains()
    for i, subs in pairs(global.subscriptions) do
        for _, station in pairs(game.get_train_stops({ name = i })) do
            checkreq = false
            check_req(station, subs.train)
        end
    end
end