require "util"
mod_gui = require("mod-gui")
--require("table")
require("control-util")
require("api")
require("bp")
require("priority-util")
--require "style"

MOD_NAME = "TrainManager"

get_sprite_button = function(player)
	-- debugp("in get_sprite_button")
  local button_flow = mod_gui.get_button_flow(player)
  local button = button_flow.tm_sprite_button
    if button then
	  if player.force.technologies["train-manager"].researched ~= true then
        button.destroy()
	  end
      return
    end
  if not button then
    button = button_flow.add
    {
      type = "sprite-button",
      name = "tm_sprite_button",
      sprite = "train_manager",
      style = mod_gui.button_style,
--      tooltip = {"gui-trainps.button-tooltip"}
    }
 --   button.style.visible = any
	if player.mod_settings["ps-tooltip"].value == true then
		button.tooltip = {"gui-trainps.button-tooltip"}
	end
  end
  return button
end

script.on_event(defines.events.on_surface_created, function(event)
    local surface = game.get_surface(event.surface_index)
    global.newcounters = global.newcounters or {}
    global.newcounters[surface.name] = global.newcounters[surface.name] or {}

    global.newpriority = global.newpriority or {}
    global.newpriority[surface.name] = global.newpriority[surface.name] or {}

    global.newpublishers = global.newpublishers or {}
    global.newpublishers[surface.name] = global.newpublishers[surface.name] or {}
end)

script.on_event(defines.events.on_research_finished, function(event)

    if event.research.name == 'train-manager' then
        for _, player in pairs(game.players) do
            get_sprite_button(player)
        end
    end

end)


local function on_player_created(event)
	if game.players[event.player_index].force.technologies["train-manager"].researched == true then
		get_sprite_button(game.players[event.player_index])
    end
end

local function on_player_joined_game(event)
	-- debugp("Player joined game")
	if game.players[event.player_index].force.technologies["train-manager"].researched == true then
		get_sprite_button(game.players[event.player_index])
	end
end

local function init_globals()
    if game then
        global.newcounters = global.newcounters or {}
        global.newpriority = global.newpriority or {}
        global.newpublishers = global.newpublishers or {}

        for _, surface in pairs(game.surfaces) do
            global.newcounters[surface.name] = global.newcounters[surface.name] or {}
            global.newpriority[surface.name] = global.newpriority[surface.name] or {}
            global.newpublishers[surface.name] = global.newpublishers[surface.name] or {}
        end
    end
end

-- Fuel handling
local function on_configuration_changed(modlist)
	--global.removeFuelStop = global.removeFuelStop or {}
	getEnergyList()
    init_globals()

    if modlist.mod_changes["train-pubsub"] then
		if modlist.mod_changes["train-pubsub"].old_version == nil then
			modlist.mod_changes["train-pubsub"].old_version = "0.0.0"
		end
		if modlist.mod_changes["train-pubsub"].old_version < "0.3.7" then
			global.trains = global.trains or {}
			for _, surface in pairs(game.surfaces) do
				local trains = surface.get_trains()
				for _,train in pairs(trains) do
					global.trains[train.id] = train
				end
			end

		end
		if modlist.mod_changes["train-pubsub"].old_version < "0.3.13" then
			for _,force in pairs(game.forces) do
				if (force.technologies["train-manager"].researched) then
			--	for _,player in pairs(game.players) do
					force.recipes["train-config"].enabled=true
				end
			--	end
			end
		end
	end
end

local function onLoad()
	--global.removeFuelStop = global.removeFuelStop or {}

    init_globals()
	getEnergyList()
	nth_tick()
end

function getEnergyList()
	global.EnergyList = global.EnergyList or {}
	for _,item in pairs(game.item_prototypes) do
		if item.fuel_category then
			--table.insert(global.EnergyList,{name=item.name,fuel_value=item.fuel_value})
			global.EnergyList[item.name] = item.fuel_value
		end
	end
end

function lowFuel(loc)
	local loc_inv = loc.get_fuel_inventory()
	if not loc_inv then return false end
	local contents = loc_inv.get_contents()
	local min_fuel = settings.global['min-fuel-amount'].value * loc.prototype.max_energy_usage * 800
	min_fuel = min_fuel / loc.prototype.burner_prototype.effectivity
--	log(loc.name .. " max_energy_usage" .. tostring(loc.prototype.max_energy_usage) .. " burner effectivity" .. loc.prototype.burner_prototype.effectivity)
	if getEnergy(contents) < min_fuel then
		return true
	else
		return false
	end
end

function getEnergy(list)
	local e = 0
	for name,amount in pairs(list) do
		-- for _,item in pairs(global.EnergyList) do
			-- if item.name == name then

		e = e + (global.EnergyList[name] * amount)
					-- break
			-- end
		-- end
	end
	return e
end


function onInit()
	global.PubSubOpened = global.PubSubOpened or {}

	for _, player in pairs(game.players) do
		get_sprite_button(player)
	end
	getEnergyList()
end

function map_ping(player,x,y,text)
	--debugp(x .. " : " .. " : " .. text)
	-- player.force.add_chart_tag(player.surface,{icon={type="item",name="train-publisher"},position={x=x+5,y=y},text=text})
	-- local gui = player.gui.center
	-- if gui.ping_map then gui.ping_map.destroy() end
	-- local ping_map = gui.add{type = "frame",name = "ping_map", caption = text}
	-- ping_map.add{type = "minimap", name = "ping_loc", position={x=x+5,y=y}}
	player.force.print("[gps=" .. tostring(x) .. "," .. tostring(y) .. "," .. tostring(player.surface.name) .. "]")
end

-- script.on_event("remove-ping-map",function(event)
-- 	local player = game.players[event.player_index]
-- 	local gui = player.gui.center
-- 	if gui.ping_map then gui.ping_map.destroy() end
-- end)

local function gui_open_frame(player)
	local gui = mod_gui.get_frame_flow(player)
	local frame = gui.tm_button_frame
	frame.add{
		type = "sprite-button",
		name = "es_button",
		sprite = "sub_train_stop",
		style = mod_gui.button_style
	}
	frame.add{
		type = "sprite-button",
		name = "publish_button",
		sprite = "publisher",
		style = mod_gui.button_style
	}
	frame.add{
		type = "sprite-button",
		name = "priority_button",
		sprite = "priority",
		style = mod_gui.button_style
	}
	frame.add{
            type = "sprite-button",
			name = "subscribe_button",
			sprite = "trains",
			style = mod_gui.button_style
        }
		frame.add{
            type = "sprite-button",
			name = "match_button",
			sprite = "key",
			style = mod_gui.button_style
        }
		frame.add{
            type = "sprite-button",
			name = "rq_button",
			sprite = "x",
			style = mod_gui.button_style
        }
	-- game.write_file("ps_setting",serpent.block(player.mod_settings["ps-tooltip"]),{comment=false})
	-- debugp(tostring(player.mod_settings["ps-tooltip"]))
	if player.mod_settings["ps-tooltip"].value == true then
	--debugp("mod setting true")
		frame.subscribe_button.tooltip = {"gui-trainps.s-tooltip"}
		frame.publish_button.tooltip = {"gui-trainps.r-tooltip"}
		frame.priority_button.tooltip = {"gui-trainps.pri-tooltip"}
		frame.match_button.tooltip = {"gui-trainps.k-tooltip"}
		frame.es_button.tooltip = {"gui-trainps.es-tooltip"}
		frame.rq_button.tooltip = {"gui-trainps.rq-tooltip"}
	end
end

local function gui_open_subtable(player)
	local gui = mod_gui.get_frame_flow(player)
	local frame = gui.sub_table
	if not frame then return end
	frame.clear()
	frame.add{type = "label", caption = {"subscriptions-title"}, style = "caption_label"}
	local scroll = frame.add{type = "scroll-pane", name = "scroll"}
	scroll.style.maximal_height = player.mod_settings["max-supplier-height"].value
	local subscriptions = scroll.add{type = "table", name = "subscriptions", column_count = 2, style = "PubSub_table_style"}
	global.subscriptions = global.subscriptions or {}
	for i,subs in pairs(global.subscriptions) do
		local status,err = pcall(function()
		subscriptions.add{type = "label", caption = subs}
		subscriptions.add{type = "label", caption = i}
		-- subscriptions.add{type = "label", caption = subs.train.id}
		end)
		if not status then
			for _,players in pairs(game.players) do
			players.print(err)
			global.subscriptions[i] = nil
			end
		end
	end
end

local function gui_open_pubtable(player,search)
	local gui = mod_gui.get_frame_flow(player)
	local frame = gui.pub_table
	if not frame then return end
	frame.clear()
	local heading = frame.add{type = "table", name = "heading", column_count = 2}
	heading.add{type = "label", caption = {"publish-title"}, style = "caption_label"}
	local resource_search
	if search == nil then
		resource_search = heading.add{type = "choose-elem-button", name = "resource_search", elem_type = "signal"}
	else
		resource_search = heading.add{type = "choose-elem-button", name = "resource_search", elem_type = "signal", signal = search}
	end
	local scroll = frame.add{type = "scroll-pane", name = "scroll"}
	scroll.style.maximal_height = player.mod_settings["max-requester-height"].value
	-- scroll.vertical_scroll_policy = "auto-and-reserve-space"
	local requests = scroll.add{type = "table", name = "requests", column_count = 6, style = "PubSub_table_style"}
	if global.newpublishers then
	if global.newpublishers[player.surface.name] then
		for keyi,publishers in spairs(global.newpublishers[player.surface.name]) do
		for n,req in pairs(publishers) do
			-- requests.add{}
			local pass = false
			if resource_search.elem_value == nil then pass = true
			elseif req.priority.resource ~= nil then
				if resource_search.elem_value.name == req.priority.resource.name then
					pass = true
				end
			end
			if pass == true then
			local ping = requests.add{type = "button", name = "pub_ping" .. keyi .. ":" .. n, style = "PubSub_edit_button_style", caption = {"requester.p"}}
			local edit = requests.add{type = "button", name = "pub_edit" .. keyi .. ":" .. n, style = "PubSub_edit_button_style", caption = {"requester.e"}}
			requests.add{type = "label", caption = req.proc_priority}
			if req.priority ~= nil then
				if req.priority.resource ~= nil and req.priority.id ~= nil then
					if req.priority.resource ~= {} and req.priority.id ~= {} then
						if req.priority.resource.type ~= nil and req.priority.id.type ~= nil then
							local resource = requests.add{type = "choose-elem-button", name = "Resource" .. keyi .. ":" .. n, elem_type = "signal", signal = {type = req.priority.resource.type, name = req.priority.resource.name}}
							resource.locked = true
							if req.priority.id.name == nil then
								requests.add{type = "label", caption = " "}
							else
								local id = requests.add{type = "choose-elem-button", name = "Id" .. keyi .. ":" .. n, elem_type = "signal", signal = {type = req.priority.id.type, name = req.priority.id.name}}
								id.locked = true
							end
						else
							requests.add{type = "label", caption = {"train-controller.not-defined"}}
							requests.add{type = "label", caption = " "}
						end
					else
						requests.add{type = "label", caption = {"train-controller.not-defined"}}
						requests.add{type = "label", caption = " "}
					end
				else
					requests.add{type = "label", caption = {"train-controller.not-defined"}}
					requests.add{type = "label", caption = " "}
				end
			else
				requests.add{type = "label", caption = {"train-controller.not-defined"}}
				requests.add{type = "label", caption = " "}
			end
			requests.add{type = "label", caption = keyi}
		-- requests.add{type = "label", caption = subs.train.id}
			if player.mod_settings["ps-tooltip"].value == true then
				ping.tooltip = {"gui-trainps.ping-tooltip"}
				edit.tooltip = {"gui-trainps.pedit-tooltip"}
			end
		end
		end
		end
	end
	end
end

local function gui_open_estable(player)
	local gui = mod_gui.get_frame_flow(player)
	local frame = gui.es_table
	if not frame then return end
	frame.clear()
	frame.add{type = "label", caption = {"es-title"}, style = "caption_label"}
	local scroll = frame.add{type = "scroll-pane", name = "scroll"}
	scroll.style.maximal_height = player.mod_settings["max-supplierstations-height"].value
	local es = scroll.add{type = "table", name = "es", column_count = 1, style = "PubSub_table_style"}

	-- for _,rows in pairs(global.entitystation) do
		-- es.add{type = "label", caption = rows.name}
		-- es.add{type = "label", caption = rows.backer_name}
	-- end
	for _,station in pairs(player.surface.find_entities_filtered{type="train-stop", name="subscriber-train-stop"}) do
	--	es.add{type = "label", caption = station.name}
		es.add{type = "label", caption = station.backer_name}
	end
end

function gui_open_rqtable(player,search)
	local gui = mod_gui.get_frame_flow(player)
	if global.player[player.index].unhide == nil then global.player[player.index].unhide = false end
	local frame = gui.rq_table
	if not frame then return end
	frame.clear()
	local rqheading = frame.add{type = "table", name = "rqheading", column_count = 3, style = "PubSub_table_style"}
	rqheading.add{type = "label", caption = {"rq-title"}, style = "caption_label"}
	rqheading.add{type = "checkbox", name = "rqunhide", caption = {"requester.unhide"}, state = global.player[player.index].unhide}
	local resource_search
	if search == nil then
		resource_search = rqheading.add{type = "choose-elem-button", name = "resource_search3", elem_type = "signal"}
	else
		resource_search = rqheading.add{type = "choose-elem-button", name = "resource_search3", elem_type = "signal", signal = search}
	end
	local scroll = frame.add{type = "scroll-pane", name = "scroll"}
	scroll.style.maximal_height = player.mod_settings["max-outstandingrequester-height"].value
	local rq = scroll.add{type = "table", name = "rq", column_count = 7, style = "PubSub_table_style"}
	if global.newrequests then
		if global.newrequests[player.surface.name] then
		local threshold = player.mod_settings["outstanding-threshold"].value

		for keyn,requests in pairs(global.newrequests[player.surface.name]) do
			for n,rows in pairs(requests) do
				if resource_search.elem_value == nil or resource_search.elem_value.name == rows.priority.resource.name then
				if rows.hide ~= true or global.player[player.index].unhide == true then
					if rows.priority.resource == nil then
					elseif rows.priority.resource == {} then
					elseif rows.priority.resource.type == nil then
					elseif rows.priority.id == nil then
					elseif rows.priority.id == {} then
					elseif rows.priority.id.type == nil then
					else
						-- point of interest - for time threshold implementation
					--	game.print(rows.tick .. " : " .. n)
						local minutes = math.floor((game.tick - rows.tick) / 3600)
						if minutes >= threshold then
							local ping = rq.add{type = "button", name = "rq_ping" .. keyn .. ":" .. n, style = "PubSub_edit_button_style", caption = "p"}
							rq.add{type = "label", caption = rows.proc_priority}
							rq.add{type = "choose-elem-button", name = "Res_Resource" .. keyn .. ":" .. n, elem_type = "signal", signal = {type = rows.priority.resource.type, name = rows.priority.resource.name}}
							rq.add{type = "choose-elem-button", name = "Resource" .. keyn .. ":" .. n, elem_type = "signal", signal = {type = rows.priority.id.type, name = rows.priority.id.name}}
							rq.add{type = "label", caption = tostring(rows.backer_name)}
						--	local minutes = math.floor((game.tick - rows.tick) / 3600)
							if minutes < 0 then minutes = 0 end
							rq.add{type = "label", caption = {"mins"}}
							rq.add{type = "label", caption = tostring(minutes)}
							if player.mod_settings["ps-tooltip"].value == true then
								ping.tooltip = {"gui-trainps.ping-tooltip"}
							end
						end
					end
				end
				end
			end
		end
	end
	if global.direct_out then
		if global.direct_out[player.surface.name] then
			if table_size(global.direct_out[player.surface.name]) > 0 then
				for i,directs in pairs(global.direct_out[player.surface.name]) do
					for j,direct in pairs(directs) do
						if resource_search.elem_value == nil or resource_search.elem_value.name == direct.signal.signal.name then
							local ping = rq.add{type = "button", name = "dc_ping" .. i .. ":" .. j, style = "PubSub_edit_button_style", caption = "p"}
							rq.add{type = "label", caption = "dc"}
							rq.add{type = "choose-elem-button", name = "dcRes_Resource" .. i .. ":" .. j, elem_type = "signal", signal = {type = direct.signal.signal.type, name = direct.signal.signal.name}}
							rq.add{type = "choose-elem-button", name = "dcResource" .. i .. ":" .. j, elem_type = "signal", signal = {type = direct.signal.signal.type, name = direct.signal.signal.name}}
							rq.add{type = "label", caption = tostring(direct.entity.backer_name)}
							rq.add{type = "label", caption = {"mins"}}
							rq.add{type = "label", caption = " dc"}
							if player.mod_settings["ps-tooltip"].value == true then
								ping.tooltip = {"gui-trainps.ping-tooltip"}
							end
						end
					end
				end
			end
		end
	end
	end
end

function auto_update()
	for _,player in pairs(game.players) do
		local gui = mod_gui.get_frame_flow(player)
		local frame = gui.rq_table
		if frame then
			frame.clear()
			gui_open_rqtable(player,global.player[player.index].search3)
		end
	end
end

local function gui_open_key_frame(player)
	local gui = mod_gui.get_frame_flow(player)
	local frame = gui.key_frame
	--debugp("In key frame")
--	if not frame then return end
--	frame.clear()
	frame.add{type = "label", caption = {"key-title"}, style = "caption_label"}
	local scroll = frame.add{type = "scroll-pane", name = "scroll"}
	scroll.style.maximal_height = player.mod_settings["max-keytrain-height"].value
	local key_s = scroll.add{type = "table", name = "key_s", column_count = 2, style = "PubSub_table_style"}
	global.sub_index = global.sub_index or {}
	global.subscriptions = global.subscriptions or {}
	for k,subs in pairs(global.sub_index) do
		key_s.add{type = "label", caption = k}
		key_s.add{type = "label", caption = subs }
	end

end

local function stationlist(priority)
	local temp = ""
		-- temp = table.concat(priority.station)
	if priority ~= nil then
		if priority.station then
			for _, station in ipairs(priority.station) do
				temp = temp .. station[2] .. "  :  "
			end
		end
	end
	return temp
end

function gui_open_station_frame(player, mode)
	local gui = mod_gui.get_frame_flow(player)
	local frame = gui.station_frame
	local surface = player.surface.name

	if not frame then return end
	frame.clear()
	local wc = {}
	local new = ""

	if mode == "add" then
		local resource = global.player[player.index].resource.name
		local id = global.player[player.index].id.name
		wc = {rb_or = true, rb_and = false, inc_ef = true, empty = true, full = false, inactivity = true, inact_int = 5, wait_timer = false, wait_int = 30, count = false, count_amt = 1000, count_ddn = 1}
		new = "new_"
	elseif mode == "add+" then
		new = "new_"
		wc = global.player[player.index].wc
	else
		local resource = global.player[player.index].resource
		local id = global.player[player.index].id
		if global.newpriority[surface][resource][id].wc == nil then
			global.newpriority[surface][resource][id].wc = {rb_or = true, rb_and = false, inc_ef = true, empty = true, full = false, inactivity = true, inact_int = 5, wait_timer = false, wait_int = 30, count = false, count_amt = 1000, count_ddn = 1}
		end
		wc = global.newpriority[surface][resource][id].wc
		if wc.count == nil then
			wc.count = false
			wc.count_amt = 1000
			wc.count_ddn = 1
			global.newpriority[surface][resource][id].wc = wc
		end
	end
		frame.add{type = "label", caption = {"wc.wait-conditions"}, style = "caption_label"}
		local andor_table = frame.add{type = "table", name = "andortable", column_count = 2, style = "PubSub_table_style"}
		andor_table.add{type = "radiobutton", name = new .. "rb_or", caption = {"wc.or"}, state = wc.rb_or}
		andor_table.add{type = "radiobutton", name = new .. "rb_and", caption = {"wc.and"}, state = wc.rb_and}
		local ef_table = frame.add{type = "table", name = "eftable", column_count = 3, style = "PubSub_table_style"}
		ef_table.add{type = "checkbox", name = new .. "efinc", caption = {"wc.include"}, state = wc.inc_ef}
		ef_table.add{type = "radiobutton", name = new .. "empty", caption = {"wc.empty"}, state = wc.empty}
		ef_table.add{type = "radiobutton", name = new .. "full", caption = {"wc.full"}, state = wc.full}
		local inact_table = frame.add{type = "table", name = "inact_table", column_count = 2}
		inact_table.add{type = "checkbox", name = new .. "inactivity", caption = {"wc.inactivity"}, state = wc.inactivity}
		local inact_int = inact_table.add{type = "textfield", name = new .. "inact_int", caption = {"wc.period"}, text = wc.inact_int}
		inact_int.style.maximal_width = 40
		frame.add{type = "slider", name = new .. "inact_slider", minimum_value = 1, maximum_value = 200, value = wc.inact_int}

		local rb_table = frame.add{type = "table", name = "rbtable", column_count = 2}
		rb_table.add{type = "checkbox", name = new .. "wait_timer", caption = {"wc.wait-timer"}, state = wc.wait_timer}
		local wait_int = rb_table.add{type = "textfield", name = new .. "wait_int", caption = {"wc.wait"}, text = wc.wait_int, numeric = true, allow_decimal = false, allow_negative = false}
		wait_int.style.maximal_width = 40
		frame.add{type = "slider", name = new .. "wait_slider", minimum_value = 1, maximum_value = 200, value = wc.wait_int}

		local count_table = frame.add{type = "table",name = "count_table", column_count = 3}
		count_table.add{type = "checkbox", name = new .. "count", caption = {"wc.count_lbl"}, state = wc.count}
		local count_ddn = count_table.add{type = "drop-down",name = new .. "count_ddn", items = {"<", ">", "=", "≥", "≤", "≠"}, selected_index = wc.count_ddn}
		count_ddn.style.maximal_width = 40
		local count_amt = count_table.add{type = "textfield", name = new .. "count_amt", text = wc.count_amt, numeric = true, allow_decimal = false, allow_negative = false}
		count_amt.style.maximal_width = 64
--	end


	frame.add{type = "label", caption = {"train-controller.select-stations"}, style = "caption_label"}

	for _,stationX in ipairs(global.player[player.index].station) do
		frame.add{type = "label", caption = stationX[2]}
	end
	frame.add{type= "drop-down", name = "station_dd", items = global.player[player.index].list}

	if mode == "add" or mode == "add+" then
		global.player[player.index].bname = "tsm_save_station_button"
		global.player[player.index].bcaption = {"train-controller.save"}
		global.player[player.index].wc = wc
		global.player[player.index].mode = "add+"
	elseif mode == "edit" then
		global.player[player.index].bname = "tsm_update_station_button"
		global.player[player.index].bcaption = {"train-controller.update"}
		global.player[player.index].mode = "edit"
	end
	frame.add{
	    type = "button",
        name = global.player[player.index].bname,
		style = mod_gui.button_style,
        caption = global.player[player.index].bcaption
        }
end

local function gui_open_pri_frame(player,search)
	local gui = mod_gui.get_frame_flow(player)
	local frame = gui.pri_frame
	if not frame then return end
	frame.clear()
	local heading = frame.add{type = "table", name = "heading", column_count = 2}
	heading.add{type = "label", caption = {"priorities-title"}, style = "caption_label"}
	local resource_search
	if search == nil then
		resource_search = heading.add{type = "choose-elem-button", name = "resource_search2", elem_type = "signal"}
	else
		resource_search = heading.add{type = "choose-elem-button", name = "resource_search2", elem_type = "signal", signal = search}
	end
	local scroll = frame.add{type = "scroll-pane", name = "scroll"}
	scroll.style.maximal_height = player.mod_settings["max-priority-height"].value
	scroll.style.maximal_width = player.mod_settings["max-priority-width"].value
	local ptable = scroll.add{type = "table", name = "ptable", column_count = 6, style = "PubSub_table_style"}
	ptable.add{type = "label", caption = " "}
	ptable.add{type = "label", caption = " "}
	ptable.add{type = "label", caption = " "}
	ptable.add{type = "label", caption = {"train-controller.resource"}}
	ptable.add{type = "label", caption = {"train-controller.id"}}
	ptable.add{type = "label", caption = {"train-controller.station-list"}}
	global.newpriority = global.newpriority or {}
	global.newpriority[player.surface.name] = global.newpriority[player.surface.name] or {}
	global.newpriority[player.surface.name] = global.newpriority[player.surface.name] or {}
--	game.write_file("priorities",serpent.block(global.newpriority[player.surface.name]),{comment=false})
	for keyi, priority_res in pairs(global.newpriority[player.surface.name]) do
	for n, priority in pairs(priority_res) do
		if resource_search.elem_value == nil or resource_search.elem_value.name == priority.resource.name then
		local premove = ptable.add{type = "button", name = "ps_remove" .. keyi .. ":" .. n, style = "PubSub_edit_button_style", caption = "-"}
		local delete = ptable.add{type = "button", name = "ps_delete" .. keyi .. ":" .. n, style = "PubSub_edit_button_style", caption = "x"}
		local edit = ptable.add{type = "button", name = "ps_edit" .. keyi .. ":" .. n, style = "PubSub_edit_button_style", caption = "e"}
		if priority.resource ~= nil then
			local resource = ptable.add{type = "choose-elem-button", name = "Resource" .. keyi .. ":" .. n, elem_type = "signal", signal = {type = priority.resource.type, name = priority.resource.name}}
			resource.locked = true
			local id = ptable.add{type = "choose-elem-button", name = "Id" .. keyi .. ":" .. n, elem_type = "signal", signal = {type = priority.id.type, name = priority.id.name}}
			id.locked = true
			ptable.add{type = "label", name = "Stations" .. keyi .. ":" .. n, caption = stationlist(priority)}
			if player.mod_settings["ps-tooltip"].value == true then
				premove.tooltip = {"gui-trainps.premove-tooltip"}
				delete.tooltip = {"gui-trainps.delete-tooltip"}
				edit.tooltip = {"gui-trainps.edit-tooltip"}
			end
		end
		end
	end
	end
	ptable.add{type = "label", caption = " "}
	ptable.add{type = "label", caption = " "}
	ptable.add{type = "label", caption = " "}
	ptable.add{type = "choose-elem-button", name = "Resource", elem_type = "signal"}
	ptable.add{type = "choose-elem-button", name = "Id", elem_type = "signal"}
	ptable.add{
        type = "button",
        name = "select_station_button",
		style = mod_gui.button_style,
        caption = {"train-controller.select"}
        }
end

function on_gui_elem_changed(event)
	local mod = event.element.get_mod()
	if mod == nil then return end
	if mod ~= "train-pubsub" then return end
--	local status,err = pcall(function()
	local element = event.element
    local player = game.players[event.player_index]
	global.player[event.player_index] = global.player[event.player_index] or {}
	global.player[event.player_index].resource = global.player[event.player_index].resource or {}
	-- resource.elem_value = resource.elem_value or {}
	global.player[event.player_index].id = global.player[event.player_index].id or {}
	if global.newrequests == nil then
		global.newrequests = {}
		global.newrequests[player.surface.name] = {}
	end
	if element.name == "Resource" then
		-- resource = table.deepcopy(element)
		if element.elem_value == nil then
			global.player[event.player_index].resource = {}
		else
			global.player[event.player_index].resource = {}
			global.player[event.player_index].resource.elem_type = element.elem_type
			global.player[event.player_index].resource.type = element.elem_value.type
			global.player[event.player_index].resource.name = element.elem_value.name
		end
	elseif element.name == "resource_search" then
		gui_open_pubtable(player,element.elem_value)
	elseif element.name == "resource_search2" then
		gui_open_pri_frame(player,element.elem_value)
	elseif element.name == "resource_search3" then
		global.player[event.player_index].search3 = element.elem_value
		gui_open_rqtable(player,element.elem_value)
	elseif element.name == "Id" then
		-- id = table.deepcopy(element)
		if element.elem_value == nil then
			global.player[event.player_index].id = {}
		else
			global.player[event.player_index].id = {}
			global.player[event.player_index].id.elem_type = element.elem_type
			global.player[event.player_index].id.type = element.elem_value.type
			global.player[event.player_index].id.name = element.elem_value.name
		end
	--	debugp(event.player_index)
	elseif element.name == "Res_Schema" then
		if element.elem_value == nil then
			if global.newrequests[player.surface.name] ~= nil then
				if global.newrequests[player.surface.name][global.cur_publisher[player.index].backer_name] ~= nil then
					if global.newrequests[player.surface.name][global.cur_publisher[player.index].backer_name][global.cur_publisher[player.index].key] ~= nil then
						global.newrequests[player.surface.name][global.cur_publisher[player.index].backer_name][global.cur_publisher[player.index].key] = nil
					end
				end
			end
			global.newpublishers[player.surface.name][global.cur_publisher[player.index].backer_name][global.cur_publisher[player.index].key].priority.resource = {}
			global.newpublishers[player.surface.name][global.cur_publisher[player.index].backer_name][global.cur_publisher[player.index].key].request = false
		else
			global.newpublishers[player.surface.name][global.cur_publisher[player.index].backer_name][global.cur_publisher[player.index].key].priority.resource = {elem_type = element.elem_type, type = element.elem_value.type, name = element.elem_value.name}
		end
		gui_open(player, global.newpublishers[player.surface.name][global.cur_publisher[player.index].backer_name][global.cur_publisher[player.index].key].entity)
	elseif element.name == "Schema" then
		if element.elem_value == nil then
			if global.newrequests[player.surface.name] ~= nil then
				if global.newrequests[player.surface.name][global.cur_publisher[player.index].backer_name] ~= nil then
					if global.newrequests[player.surface.name][global.cur_publisher[player.index].backer_name][global.cur_publisher[player.index].key] ~= nil then
						global.newrequests[player.surface.name][global.cur_publisher[player.index].backer_name][global.cur_publisher[player.index].key] = nil
					end
				end
			end
			global.newpublishers[player.surface.name][global.cur_publisher[player.index].backer_name][global.cur_publisher[player.index].key].priority.id = {}
			global.newpublishers[player.surface.name][global.cur_publisher[player.index].backer_name][global.cur_publisher[player.index].key].request = false
		else
			global.newpublishers[player.surface.name][global.cur_publisher[player.index].backer_name][global.cur_publisher[player.index].key].priority.id = {elem_type = element.elem_type, type = element.elem_value.type, name = element.elem_value.name}
		end
		gui_open(player, global.newpublishers[player.surface.name][global.cur_publisher[player.index].backer_name][global.cur_publisher[player.index].key].entity)
	end
--	end)
end

local function on_gui_selection_state_changed(event)
	local mod = event.element.get_mod()
	if mod == nil then return end
	if mod ~= "train-pubsub" then return end
    local element = event.element
    local player = game.players[event.player_index]
--	local status,err = pcall(function()
	--	debugp(element.name)
	if element.name == "station_dd" then
		local item = {"",global.player[event.player_index].list[element.selected_index]}

		table.insert(global.player[event.player_index].station, item)
  --  game.write_file("apend_stations",serpent.block(station),{comment=false})
		gui_open_station_frame(player,global.player[player.index].mode)
		return
	end
	if element.name == "count_ddn" then
		global.newpriority[player.surface.name][global.player[event.player_index].resource][global.player[event.player_index].id].wc.count_ddn = element.selected_index
		return
	elseif element.name == "new_count_ddn" then
		global.player[player.index].wc.count_ddn = element.selected_index
	end
--	end)
end

local function copy_icon(event)
	local player = game.players[event.player_index]
	game.write_file("cur_publisher",serpent.block(global.cur_publisher),{comment=false})
	global.player[event.player_index].id = {}
	global.player[event.player_index].id.elem_type = global.player[event.player_index].resource.elem_type
	global.player[event.player_index].id.type = global.player[event.player_index].resource.type
	global.player[event.player_index].id.name = global.player[event.player_index].resource.name

	local surface = global.cur_publisher[player.index].surface
	local backer = global.cur_publisher[player.index].backer_name
	local key = global.cur_publisher[player.index].key

	global.newpublishers[surface][backer][key].priority.id = global.newpublishers[surface][backer][key].priority.id or {}
	global.newpublishers[surface][backer][key].priority.id = global.newpublishers[surface][backer][key].priority.resource

	gui_open(player, global.newpublishers[surface][backer][key].entity)


--[[
	local gui = player.gui.relative
	if gui.train_publisher then
		local station = gui.train_publisher.backer_name
		if gui.train_publisher.priority_det then
			if gui.train_publisher.priority_det.Res_Schema ~= nil then
				gui.train_publisher.priority_det.Schema.elem_value = gui.train_publisher.priority_det.Res_Schema.elem_value
				game.print(station)
				game.print(global.cur_publisher[player.index].key)
				game.write_file("cur_publisher",serpent.block(global.cur_publisher),{comment=false})
				if global.newrequests[player.surface.name] ~= nil then
					game.print(player.surface.name)
					if global.newrequests[player.surface.name][station] ~= nil then
						game.print(gui.train_publisher.backer_name)

				if global.newpublishers[player.surface.name][station][global.cur_publisher[player.index].key].priority.id == nil then
					global.newpublishers[player.surface.name][station][global.cur_publisher[player.index].key].priority.id = {}
				end
				global.newpublishers[player.surface.name][station][global.cur_publisher[player.index].key].priority.id = gui.train_publisher.priority_det.Res_Schema.elem_value
				local priority = table.deepcopy(global.newpriority[player.surface.name][gui.train_publisher.priority_det.Res_Schema.elem_value][gui.train_publisher.priority_det.Res_Schema.elem_value])
				if frame.StationList then
				--	frame.StationList.destroy()
				frame.StationList.caption = stationlist(priority)
				end
			--	frame.add{type = "label", name = "StationList", caption = stationlist(priority)}
			end
		end ]]
				-- if global.newrequests[player.surface.name] ~= nil then
				-- 	if global.newrequests[player.surface.name][station] ~= nil then
				-- 		if global.newrequests[player.surface.name][station][global.cur_publisher[player.index].key] ~= nil then
				-- 			global.newrequests[player.surface.name][station][global.cur_publisher[player.index].key] = nil
				-- 		end
				-- 	end
				-- end
			--	global.newpublishers[player.surface.name][station][global.cur_publisher[player.index].key].priority.id = {}
			--	global.newpublishers[player.surface.name][station][global.cur_publisher[player.index].key].request = false
--[[ 			end
		end
	end ]]
end

local function resource_id(s,r)
	local row = string.sub(s, r + 1)
	local divider = string.find(row, ":")
	local resource = string.sub(row,1 ,divider - 1)
	local id = string.sub(row, divider + 1 )
	return resource,id
end

local function on_gui_click(event)
	local mod = event.element.get_mod()
	if mod == nil then return end
	if mod ~= "train-pubsub" then return end
    local element = event.element
    local player = game.players[event.player_index]
	local gui = mod_gui.get_frame_flow(player)
	local frame = gui.tm_button_frame
--	local curlist = nil

	global.player = global.player or {}
	global.player[event.player_index] = global.player[event.player_index] or {}

    if element.name == "tm_sprite_button" then
	    if frame then
			if gui.sub_table then gui.sub_table.destroy() end
			if gui.pub_table then gui.pub_table.destroy() end
			if gui.es_table then gui.es_table.destroy() end
			if gui.rq_table then gui.rq_table.destroy() end
			if gui.pri_frame then gui.pri_frame.destroy() end
			if gui.station_frame then gui.station_frame.destroy() end
			if gui.key_frame then gui.key_frame.destroy() end
			frame.destroy()
			gui_close_any(player)
			return
		end
		gui.add{
			type = "frame",
			name = "tm_button_frame",
			direction = "horizontal",
			style = mod_gui.frame_style
		}
        gui_open_frame(player)


	elseif element.name == "subscribe_button" then
		local subtable = gui.sub_table
		if subtable then
			subtable.destroy()
			return
		end
		subtable = gui.add{
			type = "frame",
			name = "sub_table",
			direction = "vertical",
			style = mod_gui.frame_style
			}
		gui_open_subtable(player)

	elseif element.name == "publish_button" then
		local pubtable = gui.pub_table
		if pubtable then
			pubtable.destroy()
			return
		end
		gui.add{
			type = "frame",
			name = "pub_table",
			direction = "vertical",
			style = mod_gui.frame_style
			}
		gui_open_pubtable(player)

	elseif element.name == "es_button" then
		local estable = gui.es_table
		if estable then
			estable.destroy()
			return
		end
		estable = gui.add{
			type = "frame",
			name = "es_table",
			direction = "vertical",
			style = mod_gui.frame_style
			}
		gui_open_estable(player)

	elseif element.name == "rq_button" then
		local rqtable = gui.rq_table
		if rqtable then
			rqtable.destroy()
			return
		end
		gui.add{
			type = "frame",
			name = "rq_table",
			direction = "vertical",
			style = mod_gui.frame_style
			}
		gui_open_rqtable(player,global.player[player.index].search3)

	elseif element.name == "priority_button" then
		local pri_frame = gui.pri_frame
		if pri_frame then
			pri_frame.destroy()
			if gui.station_frame then
				gui.station_frame.destroy()
			end
			return
		end
		gui.add{
			type = "frame",
			name = "pri_frame",
			direction = "vertical",
			style = mod_gui.frame_style
			}
		-- debugp("clearing resource")
		global.player[event.player_index] = global.player[event.player_index] or {}
		global.player[event.player_index].resource = {}
		global.player[event.player_index].id = {}
		gui_open_pri_frame(player)

	elseif element.name == "select_station_button" then
		local station_frame = gui.station_frame
		if station_frame then
			station_frame.destroy()
			return
		end
		if global.player[event.player_index].resource ~= nil and global.player[event.player_index].id ~= nil then
			local resource = global.player[event.player_index].resource.name
			local id = global.player[event.player_index].id.name
			if (global.player[event.player_index].resource.name ~= nil) and (global.player[event.player_index].id.name ~= nil) then
			-- check for non-duplicate id
				local dupe = false
				if global.newpriority[player.surface.name][resource] ~= nil then
					if global.newpriority[player.surface.name][resource][id] ~= nil then
						dupe = true
					end
				end
				if dupe == false then
					gui.add{
						type = "frame",
						name = "station_frame",
						direction = "vertical",
						style = mod_gui.frame_style
						}
				-- debugp("Clearing station")
					global.player[event.player_index].station = {}
					global.player[event.player_index].list = {}
					listidx = {}
					for _,stat in pairs(player.surface.find_entities_filtered{type="train-stop", name="subscriber-train-stop"}) do
						listidx[stat.backer_name] = stat.backer_name
					end
					--table.sort(listidx,function(a,b) return a<b end)
					for _,listidx in spairs(listidx, function(t,a,b) return t[b] > t[a] end) do
						table.insert(global.player[event.player_index].list,listidx)
					--	table.sort(global.player[event.player_index].list)
					end
					if global.newpriority == nil then
						global.newpriority = {}
					end
					if global.newpriority == {} then
						global.player[player.index].cur_priority = 1
					else
						global.player[player.index].cur_priority = #global.newpriority+1
					end
					gui_open_station_frame(player, "add")
				else
					game.players[event.player_index].print({"errors.unique_id"})
				end
			else
				game.players[event.player_index].print({"errors.resource_id"})
			end
		else
			game.players[event.player_index].print({"errors.resource_id"})
		end

	elseif element.name == "tsm_save_station_button" then
	--	game.write_file("presaveglobplayer",serpent.block(global.player),{comment=false})
		local resource = global.player[event.player_index].resource.name
		local id = global.player[event.player_index].id.name
		local surface = player.surface.name

		global.newpriority = global.newpriority or {}
		global.newpriority[surface] = global.newpriority[surface] or {}
		global.newpriority[surface][resource] = global.newpriority[surface][resource] or {}
		global.newpriority[surface][resource][id] = global.newpriority[surface][resource][id] or {}
		global.newpriority[surface][resource][id].resource = global.player[event.player_index].resource
		global.newpriority[surface][resource][id].id = global.player[event.player_index].id
		global.newpriority[surface][resource][id].station = global.player[event.player_index].station
		global.newpriority[surface][resource][id].wc = global.player[event.player_index].wc

		updaterequestedpublisher(resource,id, surface)
		gui.station_frame.destroy()
		gui_open_pri_frame(player)
		global.player[event.player_index] = {}

	elseif element.name == "match_button" then
		local key_frame = gui.key_frame
		if key_frame then
			key_frame.destroy()
			return
		end
		gui.add{
			type = "frame",
			name = "key_frame",
			direction = "vertical",
			style = mod_gui.frame_style
			}
		gui_open_key_frame(player)

	elseif string.find(element.name, "ps_edit")  then
		local station_frame = gui.station_frame
		local player = game.players[event.player_index]
		if station_frame then
			station_frame.destroy()
			return
		end
		gui.add{
			type = "frame",
			name = "station_frame",
			direction = "vertical",
			style = mod_gui.frame_style
			}
		global.player[event.player_index] = global.player[event.player_index] or {}
		global.player[event.player_index].station = {}
		-- local row = string.sub(element.name, 8)
		local resource = ""
		local id = ""
		resource, id = resource_id(element.name,7)
		global.player[event.player_index].resource = resource
		global.player[event.player_index].id = id
		if global.newpriority[player.surface.name][resource][id].station then
			for _, stationX in ipairs(global.newpriority[player.surface.name][resource][id].station) do
				global.player[event.player_index].station[#global.player[event.player_index].station + 1] = stationX
			 --	table.insert(station,StationX)
			end
		end
		global.player[event.player_index].list = {}
		listidx = {}
		for _,station in pairs(player.surface.find_entities_filtered{type="train-stop", name="subscriber-train-stop"}) do
		--	if curlist ~= station.backer_name then
				listidx[station.backer_name] = station.backer_name
		--		table.insert(list, {"",station.backer_name})
		--		curlist = station.backer_name
		--	end
		end
		for _,listidx in spairs(listidx, function(t,a,b) return t[b] > t[a] end) do
			table.insert(global.player[event.player_index].list,listidx)
		end
		-- for _, es in pairs(global.entitystation) do
			-- table.insert(list, {"",es.backer_name})
		-- end
		gui_open_station_frame(player, "edit")

	elseif string.find(element.name, "ps_delete")  then
		local station_frame = gui.station_frame
		if station_frame then
			station_frame.destroy()
			return
		end
		station_frame = gui.add{
			type = "frame",
			name = "station_frame",
			direction = "vertical",
			style = mod_gui.frame_style
			}
		-- debugp("Clearing station")
		local resource = ""
		local id = ""
		resource, id = resource_id(element.name,9)
		global.player[event.player_index] = global.player[event.player_index] or {}
		global.player[event.player_index].station = {}
	--	global.player[event.player_index].cur_priority = tonumber(string.match(element.name, "%d+"))
		-- if global.priority[cur_priority].station then
			-- for i, stationX in ipairs(global.priority[cur_priority].station) do
				-- table.insert(station, stationX)
			-- end
		-- end
		global.player[event.player_index].resource = resource
		global.player[event.player_index].id = id
		global.player[event.player_index].list = {}
		listidx = {}
		for _,stat in pairs(player.surface.find_entities_filtered{type="train-stop", name="subscriber-train-stop"}) do
			listidx[stat.backer_name] = stat.backer_name

			-- if curlist ~= station.backer_name then
				-- table.insert(list, {"",station.backer_name})
				-- curlist = station.backer_name
			-- end
		end
		for _,listidx in spairs(listidx, function(t,a,b) return t[b] > t[a] end) do
			table.insert(global.player[event.player_index].list,listidx)
		end
		-- for _, es in pairs(global.entitystation) do
			-- table.insert(list, {"",es.backer_name})
		-- end
		gui_open_station_frame(player, "edit")

	elseif string.find(element.name, "ps_remove")  then
		if (settings.startup["edit_admin"] and player.admin ) or
			(settings.startup["edit_admin"].value == false) then
			debugp(settings.startup["edit_admin"].value )
	--	if player.admin == true then
--			global.player[event.player_index].cur_priority = tonumber(string.match(element.name, "%d+"))
			local resource = ""
			local id = ""
			resource, id = resource_id(element.name,9)
			local ok = true
			local station_frame = gui.station_frame
			if station_frame then
				player.print({"errors.del_station_frame"})
				ok = false
				return
			end
			global.newpublishers = global.newpublishers or {}
			for _,publisher_backers in pairs(global.newpublishers[player.surface.name]) do
				for _,publisher in pairs(publisher_backers) do
					if publisher.priority ~= nil then
						if publisher.priority.resource ~= nil and publisher.priority.id ~= nil then
							if (publisher.priority.resource.name == resource) and (publisher.priority.id.name == id	) then
								player.print({"errors.del_canc1"})
								ok = false
								break
							end
						end
					end
				end
			end
			global.newrequests = global.newrequests or {}
			if global.newrequests[player.surface.name] == nil then
			elseif global.newrequests[player.surface.name] == {} then
			else
				for _,request_backers in pairs(global.newrequests[player.surface.name]) do
					for _,request in pairs(request_backers) do
						if request.priority.resource ~= nil and request.priority.id ~= nil then
							if (request.priority.resource.name == resource) and (request.priority.id.name == id) then
								player.print({"errors.del_canc2"})
								ok = false
								break
							end
						end
					end
				end
			end
			if ok == true then
				global.newpriority[player.surface.name][resource][id] = nil
				gui_open_pri_frame(player)
			end
		else
			player.print({"errors.admin"})
		end

	elseif element.name == "tsm_update_station_button" then
		--debugp("edit")
		local resource = global.player[event.player_index].resource
		local id = global.player[event.player_index].id
		local station = global.player[event.player_index].station
		--debugp("current priority" .. cur_priority)
		global.newpriority[player.surface.name][resource][id].station = global.player[event.player_index].station

	 	updaterequestedpublisher(resource, id,player.surface.name)

		gui.station_frame.destroy()
		gui_open_pri_frame(player)
	--	game.write_file("globreqs",serpent.block(global.requests),{comment=false})
	elseif string.find(element.name, "pub_ping")  then
	--	local backer_name = ""
	--	local cur_pub = ""
		local	backer_name, cur_pub = resource_id(element.name,8)
	--	game.print(backer_name .. cur_pub)
		cur_pub = tonumber(cur_pub)
		local surface = player.surface.name

		if global.newpublishers[surface][backer_name][cur_pub] ~= nil then
			if global.newpublishers[surface][backer_name][cur_pub].entity.valid == true then
				local pub = global.newpublishers[surface][backer_name][cur_pub].entity
				map_ping(player,pub.position.x,pub.position.y,backer_name)
			else
				table.remove(global.newrequests[surface][backer_name][cur_pub], cur_pub)
			end
		end
	elseif string.find(element.name, "pub_edit") then
		local backer_name, cur_pub = resource_id(element.name,8)
		cur_pub = tonumber(cur_pub)
		local surface = player.surface.name
		if global.player[player.index].pub_edit then
			if global.player[player.index].pub_edit == element.name then
				gui_close(player, global.newpublishers[player.surface.name][backer_name][cur_pub].entity)
				global.player[player.index].pub_edit = nil
			else
				gui_open(player, global.newpublishers[player.surface.name][backer_name][cur_pub].entity, true)
				global.player[player.index].pub_edit = element.name
			end
		else
			gui_open(player, global.newpublishers[player.surface.name][backer_name][cur_pub].entity, true)
			global.player[player.index].pub_edit = element.name
		end

	elseif string.find(element.name, "rq_ping")  then
		-- local cur_rq = tonumber(string.match(element.name, "%d+"))
		local backer_name, cur_rq = resource_id(element.name,7)
		cur_rq = tonumber(cur_rq)
		local surface = player.surface.name
		if global.newrequests[surface][backer_name][cur_rq] then
			if global.newrequests[surface][backer_name][cur_rq].entity.valid == true then
				local rq = global.newrequests[surface][backer_name][cur_rq].entity
				map_ping(player,rq.position.x,rq.position.y,backer_name)
			else
				table.remove(global.newrequests[surface][backer_name], cur_rq)
			end
		end
	elseif string.find(element.name, "dc_ping")  then
		local backer_name, cur_rq = resource_id(element.name,7)
		cur_rq = tonumber(cur_rq)
		local entity = global.direct_out[player.surface.name][backer_name][cur_rq].entity
		if entity.valid == true then
			map_ping(player,entity.position.x,entity.position.y,entity.backer_name)
		end
	elseif element.name == "surface_copy" then
		surface_copy(event)
	elseif element.name == "surface_delete" then
		surface_delete(event)
	elseif element.name == "surface_export" then
		surface_export(event)
	elseif element.name == "surface_import" then
		surface_import(event)
	elseif element.name == "copy_button" then
		copy_icon(event)
	end
end


local function isPS(entity)
	if (entity.name == "train-publisher" or
		entity.name == "train-counter" or
		entity.name == "subscriber-train-stop" or
		entity.name == "publisher-train-stop") then
		return true
	end
	return false
end

local function push_sub_index(station, train)
	global.sub_index = global.sub_index or {}
	global.subscriptions = global.subscriptions or {}
--	if not check_req(station.backer_name, train) then
		-- indexed version
		global.subscriptions[train.id] = station.backer_name
		-- table.insert(global.subscriptions, {backer_name = station.backer_name, station = station, train = train})
		if global.sub_index[station.backer_name] == nil then
			global.sub_index[station.backer_name] = train.id
		end
--	end
end

local function pop_sub_index(backer_name, train_id)
	global.sub_index = global.sub_index or {}
	global.subscriptions = global.subscriptions or {}
	-- indexed version
	if global.subscriptions[train_id] then
		global.subscriptions[train_id] = nil
	end

	for i,subs in pairs(global.subscriptions) do

		if (subs == backer_name and i ~= train_id) then
			global.sub_index[backer_name] = i
			return i
		end
	end
	--debugp{"deleting index entry"}
	global.sub_index[backer_name] = nil
	return nil
end

local filters = {{filter = "name", name = "subscriber-train-stop"},{filter = "name", name = "publisher-train-stop"},
				{filter = "name", name = "train-publisher"},{filter = "name", name = "train-counter"}}


script.on_event(defines.events.on_built_entity, function(event)
--	if isPS(event.created_entity) then
--		game.print("PS entity")
		addPSToTable(event.created_entity, event.player_index, event)
--	end

	if event.created_entity.valid == true then
		if event.created_entity.name == "train-counter" then
			event.created_entity.operable = false
		end
	end
	-- debugp(event.created_entity.name)
end, filters)


script.on_event(defines.events.on_robot_built_entity, function(event)
--	if isPS(event.created_entity) then
		addPSToTable(event.created_entity, 0, event)
--	end

	if event.created_entity.valid == true then
		if event.created_entity.name == "train-counter" then
			event.created_entity.operable = false
		end

	end
end, filters)

script.on_event(defines.events.script_raised_built, function(event)
--	if isPS(event.entity) then
		addPSToTable(event.entity, 0, event)
--	end
	if event.entity.valid == true then
		if event.entity.name == "train-counter" then
			event.entity.operable = false
		end
	end
end, filters)

script.on_event(defines.events.script_raised_revive, function(event)
--	if isPS(event.entity) then
		addPSToTable(event.entity, 0, event)
--	end
	if event.entity.valid == true then
		if event.entity.name == "train-counter" then
			event.entity.operable = false
		end
	end
end, filters)

script.on_event(defines.events.on_entity_cloned, function(event)
--	game.print("cloned")
--	if isPS(event.destination) then
		addPSToTable(event.destination, 0, event)
--	end
	if event.destination.valid == true then
		if event.destination.name == "train-counter" then
			event.destination.operable = false
		end
	end
end, filters)

local function on_preplayer_mined_item(event)
--	if isPS(event.entity) then
		removePSFromTable(event.entity)
--	end
end

script.on_event(defines.events.on_robot_pre_mined, function(event)
--	if isPS(event.entity) then
		removePSFromTable(event.entity)
--	end
end, filters)

script.on_event(defines.events.on_entity_died, function(event)
--	if isPS(event.entity) then
		removePSFromTable(event.entity)
--	end
end, filters)

script.on_event(defines.events.script_raised_destroy, function(event)
--	if isPS(event.entity) then
		removePSFromTable(event.entity)
--	end
end, filters)

local function getUniqueName(entity)
	if #entity.surface.get_train_stops({name=entity.backer_name}) > 1 then
		entity.surface.print("Same name as existing Requester train stop")
		local length = string.len(entity.backer_name)
		local suffix = tonumber(string.sub(entity.backer_name,length - 1,length))
		if suffix ~= nil then
			local suflen = string.len(suffix)
			suffix = suffix + 1
			entity.backer_name = string.sub(entity.backer_name,1,length - suflen) .. tostring(suffix)
		else
			suffix = "01"
			entity.backer_name = entity.backer_name .. tostring(suffix)
		end
	--	entity.backer_name = entity.backer_name .. "X"
		getUniqueName(entity)
	end
end

function check_unique(surface, backer_name)
	local stations = surface.get_train_stops({name=tostring(backer_name)})
	local num_stat = table_size(stations)
	if num_stat > 1 then
	--	game.print("Stations = " .. #stations)
	--	game.print("backer name" .. backer_name)
		return false
	elseif num_stat == 1 then
		if stations[1].name ~= "publisher-train-stop" then
			return false
		end
	end
	return true
end

local function destination_error(surface, backer_name)
	global.desterr = global.desterr or {}
	global.desterr[backer_name] = global.desterr[backer_name] or 0
	if game.tick > global.desterr[backer_name] then
		surface.print({"errors.tsm_dest"})
		surface.print(backer_name)
		global.desterr[backer_name] = game.tick + 3600
	end
end

script.on_event(defines.events.on_entity_renamed, function(event)
	-- train publishers and train counters cannot be renamed, so the only thing that can end up here is subscriber train stations
--	debugp("name change")
	if isPS(event.entity) then
		local backer_name = event.entity.backer_name
		local entity = event.entity
		if entity.name == "subscriber-train-stop" then
		--	debugp("rename from " .. event.old_name .. " to "  .. event.entity.backer_name)

			local train = nil
			local trains = entity.get_train_stop_trains()
			if #trains > 0 then
				if trains[1].station then
					if trains[1].station.backer_name == backer_name then
						if global.subscriptions[trains[1].id] then
							pop_sub_index(event.old_name, trains[1].id)
							push_sub_index(entity, trains[1])
						end
					end
				end
			else
				-- if more than one subscriber of the same name then get_train_stop_trains will not find anything
				-- so check in global.subscriptions
				local pos = entity.position
				local entities = entity.surface.find_entities_filtered{area = {{pos.x-2, pos.y-2}, {pos.x+2, pos.y+2}},type = "locomotive"}
			--	local entity_names = {}
				for _,xentity in pairs(entities) do
			--		table.insert(entity_names,xentity.name)
					pop_sub_index(event.old_name, xentity.train.id)
					push_sub_index(entity, xentity.train)
				end
			end
		end

		if entity.name == "publisher-train-stop" then
		-- if from auto rename then exit
			if event.player_index ~= nil then
				gui_close_any(game.players[event.player_index])
			end
			getUniqueName(entity)
			backer_name = entity.backer_name
		--	game.print(backer_name .. " : " .. event.old_name)
		--	global.player[event.player_index].
			local pos = entity.position

		-- Check for publisher
			global.newpublishers = global.newpublishers or {}
			if global.newpublishers[entity.surface.name] ~= nil then
				if global.newpublishers[entity.surface.name][event.old_name] ~= nil then
		--	for _,publisher in ipairs(entity.surface.find_entities_filtered{area = {{pos.x-3, pos.y-3}, {pos.x+3, pos.y+3}},name = "train-publisher"}) do
			--	debugp("found pub")
			local newpos = {}
			for i, pub in pairs(global.newpublishers[entity.surface.name][event.old_name]) do
				-- Check renamed entity within 2 tiles
					newpos = global.newpublishers[entity.surface.name][event.old_name][i].entity.position
					if 	math.abs(newpos.x - pos.x) < 3 and math.abs(newpos.y - pos.y) < 3 then
						global.newpublishers[entity.surface.name][event.old_name][i].backer_name = backer_name
						global.newpublishers[entity.surface.name][backer_name] = global.newpublishers[entity.surface.name][backer_name] or {}
						local j = #global.newpublishers[entity.surface.name][backer_name] + 1
						global.newpublishers[entity.surface.name][backer_name][j] = global.newpublishers[entity.surface.name][backer_name][j] or {}
						global.newpublishers[entity.surface.name][backer_name][j] = table.deepcopy(global.newpublishers[entity.surface.name][event.old_name][i])
						global.newpublishers[entity.surface.name][backer_name][j].request = false
						global.newpublishers[entity.surface.name][backer_name][j].tick = game.tick + 10
						global.newpublishers[entity.surface.name][event.old_name][i] = nil
						--break
					end
					end
				end
			end
				-- Check for open request
			global.newrequests = global.newrequests or {}
			if global.newrequests[entity.surface.name] ~= nil then
				for keyi, request in pairs(global.newrequests[entity.surface.name]) do
					if keyi == event.old_name then
						global.newrequests[entity.surface.name][keyi] = nil
					--	break
					end
				end
			end
		-- Check for circuit requester
			global.circuit_req = global.circuit_req or {}

		-- Check counter entities
		--	debugp("publisher stop")

		--	debugp(pos.x .. "X," .. pos.y .. "Y")
			global.newcounters = global.newcounters or {}
			global.newcounters[entity.surface.name] = global.newcounters[entity.surface.name] or {}

			for _,counter in ipairs(entity.surface.find_entities_filtered{area = {{pos.x-2, pos.y-2}, {pos.x+2, pos.y+2}},name = "train-counter"}) do
				for i,cter in pairs(global.newcounters[entity.surface.name]) do
					if cter.entity == counter then
					--	cter.backer_name = backer_name
						global.newcounters[entity.surface.name][i].backer_name = backer_name
						updateCounters(cter)
						break
					end
				end
			end
		end
	end

end)

script.on_event(defines.events.on_runtime_mod_setting_changed, function(event)
	--debugp(event.setting)
	if event.player_index ~= nil then
		local player = game.players[event.player_index]
		if event.setting == "ps-tooltip" then
			local button_flow = mod_gui.get_button_flow(player)
			local button = button_flow.tm_sprite_button
			if button then
				button.destroy()
				get_sprite_button(player)
			end
			local gui = mod_gui.get_frame_flow(player)
			local frame = gui.tm_button_frame
			if frame then
				frame.destroy()
				frame = gui.add{
					type = "frame",
					name = "tm_button_frame",
					direction = "horizontal",
					style = mod_gui.frame_style
					}
				gui_open_frame(player)
			end
		end
	end
	if event.setting == "turbo_ups" then
		script.on_nth_tick(nil)
		nth_tick()
	end
end)

local function check_fuel(locs)
	for _,loc in pairs(locs) do
		if loc.burner and #loc.burner.inventory > 0 then
			if lowFuel(loc) then
				return true
			end
		end
	end
	return false
end

local function addFuelStop(train,numLocs)
	local schedule = train.schedule or {}
	if not train.schedule then
		schedule.records = {}
	end
	local fs = settings.startup['fuelstop_name'].value
	for _,record in pairs(schedule.records) do
	--	if string.find(record.station, "FuelStop")  then return end
		if record.station ~= nil then
			if string.find(record.station, fs, 1, true)  then return end
		end
	end
--	local station_name = "FuelStop" .. numLocs
	local station_name
	if settings.startup["fuel-stop-loco-count"].value == true then
		station_name = fs .. numLocs
	else
		station_name = fs
	end
--	local station_name = fs .. numLocs
	local record = {station = station_name, wait_conditions = {}}
	record.wait_conditions[#record.wait_conditions+1] = {type = "inactivity", compare_type = "and", ticks = 120 }
	-- local current = schedule.current or 0
	schedule.records[#schedule.records+1] = record

	train.schedule = schedule

	--global.removeFuelStop[train.id] = station_name
end

local function removeFuelStop(train)
	local schedule = train.schedule
	local fs = settings.startup['fuelstop_name'].value
	for i,record in pairs(schedule.records) do
	--	if string.find(record.station, "FuelStop")  then
		if string.find(record.station, fs, 1, true)  then

			table.remove(schedule.records,i)
			if i > #schedule.records then
				schedule.current = 1
			else
				schedule.current = i
			end

			break
		end
	end
	train.schedule = schedule
end

local function on_train_changed_state(event)
	local train = event.train
	local station = train.station

	if (event.old_state == defines.train_state.arrive_station or
		event.old_state == defines.train_state.manual_control) and
		station ~= nil then
	--	if station then
		if station.name == "subscriber-train-stop" then
			-- Either meet outstanding requirement
			checkreq = false
			check_req(station, train)
			-- if not check_req(station.backer_name, train) then
			if not checkreq then
				-- Is this a new index item, or index already exists? - push handles both true and false
				push_sub_index(station, train)
			end
		elseif station.name == "publisher-train-stop" then
			global.trainls = global.trainls or {}
		    global.trainls[train.id] = station
		end
		local fs = settings.startup['fuelstop_name'].value
		--if string.find(station.backer_name , "FuelStop") then
		if string.find(station.backer_name , fs, 1, true) then
			Check_train_config(train, station)
		end


		-- low fuel check
		if train.manual_mode then return end

		if settings.global['min-fuel-amount'].value == 0 then return end
		local locs = train.locomotives
		if check_fuel(locs.front_movers) == true then
			addFuelStop(train, #locs.front_movers)
		elseif check_fuel(locs.back_movers) then
			addFuelStop(train, #locs.back_movers)
		end


	--	end

	elseif event.old_state == defines.train_state.wait_station or
		event.old_state == defines.train_state.manual_control or
		event.old_state == defines.train_state.no_schedule or
		event.old_state == defines.train_state.no_path then
		--debugp("Leaving wait station")
	--	local train = event.train
		local schedule = train.schedule
		if schedule ~= nil then
			local station_name = ""
			for i,rec in pairs(schedule.records) do
				station_name = schedule.records[i].station
				for _,station in pairs(train.front_rail.surface.get_train_stops({name=station_name})) do
					if station.name == "publisher-train-stop" then
						if global.newcounters[station.surface.name] ~= nil then
							for _,counter in pairs(global.newcounters[station.surface.name]) do
								if counter.station == station then
								--	game.print("updating counter for " .. counter.backer_name)
									if global.trainls ~= nil then
										if global.trainls[train.id] == counter.station then global.trainls[train.id] = nil end
									end
									updateCounters(counter)
								end
							end
							if global.trainls ~= nil then
								if global.trainls[train.id] ~= nil then
									for _,counter in pairs(global.newcounters[station.surface.name]) do
										if counter.station == global.trainls[train.id] then
										--	game.print("updating counter for " .. counter.backer_name)
											global.trainls[train.id] = nil
											updateCounters(counter)
										end
									end
								end
							end
						end
					end
				end
			end

		end
		global.subscriptions = global.subscriptions or {}
		if global.subscriptions == {} then return end
		local station = global.subscriptions[train.id]
		--debugp(station)

		if station ~= nil then
			--debugp("trying to pop data")
			pop_sub_index(station, train.id)
		end

		-- if #schedule.records == 0 then schedule = nil end  -- leeh fix

		if train.schedule then
			local last = train.schedule.current
			if last == 1 then
				last = #train.schedule.records
			else
				last = last - 1
			end
			--debugp("test refuel remove" .. last)
			if event.old_state == defines.train_state.wait_station  then
				local fs = settings.startup["fuelstop_name"].value
			--	game.write_file("fs",serpent.block(fs),{comment=false})
			--	if string.find(train.schedule.records[last].station, "FuelStop")  then
				if train.schedule.records[last]	~= nil then
					if train.schedule.records[last].station ~= nil then
						if string.find(train.schedule.records[last].station, fs, 1, true) then
						--	debugp("Found")
							local schedule = {}
							schedule.records = train.schedule.records
							if #schedule.records > 1 then
								table.remove(schedule.records,last)
								schedule.current = last
								if last > #schedule.records then schedule.current = 1 end
								train.manual_mode = true
								train.schedule = schedule
								train.manual_mode = false
								clear_train_config()
							end
						end
					end
				end
			end
		end
	end
end

function gui_open(player, controller, modgui)

 debugp(controller.name .. "in gui_open")
	local status,err = pcall(function()
	if controller.name == "train-publisher" then
	--	local gui = mod_gui.get_frame_flow(player)
		local gui
		local frame
		if not modgui then
			gui = player.gui.relative
			frame = gui.train_publisher
			if frame then frame.destroy() end
			frame = gui.add({ type = "frame", name = "train_publisher", direction = "vertical", anchor = {gui = defines.relative_gui_type.lamp_gui,  type = "lamp", position = defines.relative_gui_position.right}})
		else
			gui = mod_gui.get_frame_flow(player)
			frame = gui.train_publisher
			if frame then frame.destroy() end
			frame = gui.add({ type = "frame", name = "train_publisher", direction = "vertical"})
		end

		frame.caption = {"train-controller.train-publisher-target"}
	--	frame.add({ type = "label", name = "label", caption = {"train-controller.train-publisher-target"} })
		if global.newpublishers[controller.surface.name] == nil then
			global.newpublishers[controller.surface.name] = {}
			global.newpublishers[controller.surface.name][controller.backer_name] = {}
			global.newpublishers[controller.surface.name][controller.backer_name][1] = {}
			global.newpublishers[controller.surface.name][controller.backer_name][1].entity = controller
		end
		if global.newpriority == nil then
			global.newpriority = {}
			global.newpriority[controller.surface.name] = {}
		end
		for keyi,publishers in pairs(global.newpublishers[controller.surface.name]) do
			for key,publisher in pairs(publishers) do

			if publisher.entity == controller then
				local pri_det = frame.add({ type = "table", name = "priority_det", column_count = 3, direction = "horizontal"})

				global.cur_publisher = global.cur_publisher or {}
			--	global.cur_publisher[player.index] = i
				global.cur_publisher[player.index] = global.cur_publisher[player.index] or {}
				global.cur_publisher[player.index].surface = controller.surface.name
				global.cur_publisher[player.index].backer_name = publisher.backer_name
				global.cur_publisher[player.index].key = key
				global.cur_publisher[player.index] = global.cur_publisher[player.index] or {}
				if publisher.priority.resource ~= nil and publisher.priority.resource ~= {} and publisher.priority.resource.type ~= nil then
					pri_det.add{type = "choose-elem-button", name = "Res_Schema", elem_type = "signal", signal = {type = publisher.priority.resource.type, name = publisher.priority.resource.name}}
				else
					pri_det.add{type = "choose-elem-button", name = "Res_Schema", elem_type = "signal"}
				end
				if publisher.priority.id ~= nil and publisher.priority.id ~= {} and publisher.priority.id.type ~= nil then
					pri_det.add{type = "choose-elem-button", name = "Schema", elem_type = "signal", signal = {type = publisher.priority.id.type, name = publisher.priority.id.name}}
				else
					pri_det.add{type = "choose-elem-button", name = "Schema", elem_type = "signal"}
				end
				pri_det.add{type = "button", name = "copy_button", caption = {"train-controller.c"}, style = "PubSub_edit_button_style"}
				local pass = true
				if (publisher.priority.resource == nil) or (publisher.priority.id == nil) then
					pass = false
				elseif (publisher.priority.resource == {}) or (publisher.priority.id == {}) then
					pass = false
				elseif (publisher.priority.resource.name == nil) or (publisher.priority.id.name == nil) then
					pass = false
				elseif (global.newpriority[controller.surface.name][publisher.priority.resource.name] == nil) then
					pass = false
				elseif global.newpriority[controller.surface.name][publisher.priority.resource.name][publisher.priority.id.name] == nil then
					pass = false
				end
				if pass == true then
					local priority = table.deepcopy(global.newpriority[controller.surface.name][publisher.priority.resource.name][publisher.priority.id.name])
					if frame.StationList then
						frame.StationList.destroy()
					end
					frame.add{type = "label", name = "StationList", caption = stationlist(priority)}
					-- process priority
					local proc_priority = "1"
					if publisher.proc_priority then
						proc_priority = publisher.proc_priority
					end
					local proc_table = frame.add{type = "table", name = "proc_table",column_count = 2, style = "PubSub_table_style"}
					proc_table.add{type = "label", name = "proclab", caption = {"train-controller.process-priority"}}
					local process = proc_table.add{type = "textfield", name = "process_priority", text = proc_priority}
					process.style.maximal_width = 40
					local hide = false
					if publisher.hide ~= nil then
						hide = publisher.hide
					end
					frame.add{type = "checkbox", name = "hide", caption = {"requester.hide"}, state = hide, tooltip = {"requester.hide_tooltip"}}
					frame.add{type = "label", name = "backer_name", caption = keyi}
					return
				else
					if frame.StationList then
						frame.StationList.destroy()
					end
					frame.add{type = "label", name = "StationList", caption = {"train-controller.not-defined"}}
					-- process priority
					local proc_priority = "1"
					if publisher.proc_priority then
						proc_priority = publisher.proc_priority
					end
					local proc_table = frame.add{type = "table", name = "proc_table",column_count = 2, style = "PubSub_table_style"}
					local proclab = proc_table.add{type = "label", name = "proclab", caption = {"train-controller.process-priority"}}
					local process = proc_table.add{type = "textfield", name = "process_priority", text = proc_priority}
					process.style.maximal_width = 40
					frame.add{type = "label", name = "backer_name", caption = keyi}
					return
				end
			end
			end
		end
	--	frame.add{type = "choose-elem-button", name = "Schema", elem_type = "signal"}
	end
	end)
	if not status then
		for _,players in pairs(game.players) do
		players.print(err)
		end
	end
end

function gui_close(player, controller)
	local status,err = pcall(function()
	if controller.name == "train-publisher" then
		local gui = mod_gui.get_frame_flow(player)
		local frame = gui.train_publisher or gui.gui.relative.train_publisher

		frame.destroy()
		if global.cur_publisher then
			if global.cur_publisher[player.index] then
				global.cur_publisher[player.index] = nil
			end
		end
	end
	end)
end

function gui_close_any(player)
	local gui = mod_gui.get_frame_flow(player)
	if gui.train_publisher then
		gui.train_publisher.destroy()
		if global.cur_publisher then
			if global.cur_publisher[player.index] then
				global.cur_publisher[player.index] = nil
			end
		end
	end
end

function upd_counters()
	if global.pending_req then
		pending_req()
	end
--[[ 	if global.counters then
		--game.write_file("pobsub_counters",serpent.block(global.counters))
		for i, counter in pairs(global.counters) do
			--debugp("counter " .. counter.backer_name)
			if counter.station.valid == true then
				updateCounters(counter, 2)
			else
				global.counters[i] = nil
			end
		end
	end ]]
end

function upd_publishers()
	local tick = game.tick

	local update = ""

	if global.newpublishers then
		for _,surface in pairs(game.surfaces) do
			if global.newpublishers[surface.name] ~= nil then
				for keyx, publishers in pairs(global.newpublishers[surface.name]) do
					for x, publisher in pairs(publishers) do
						if publisher.entity ~= nil then
							if publisher.entity.valid == true then
								publisher.tick = publisher.tick or 0
								if publisher.tick < tick then

									update = updatePublishers(publisher, keyx, x)

								--	if updatePublishers(publisher, keyx, x) == true then return end
									if update == true then
									--	log(tick .. keyx .. tostring(update))
										return
									end
								end
							else
								table.remove(global.newpublishers[surface.name][keyx],x)
							end
						end
					end
				end
			end
		end
	end
end

function circuit_requesters_update()
	global.direct_out = {}
	if global.pubstops ~= nil then
		if global.pubstops ~= {} then
			for i,requester_stop in pairs(global.pubstops) do
				if requester_stop.entity.valid == true then
					update_circuit_requesters(requester_stop.entity)
				else
					global.pubstops[i] = nil
				end

			end
		end
	end
end

function pub_open()
	local status,err = pcall(function()
		global.controllerOpened = global.controllerOpened or {}
		for _, player in pairs(game.connected_players) do
			if player.opened ~= nil then
				if player.opened.name == "train-publisher" then
					if player.opened ~= global.controllerOpened[player.name] then
						gui_close(player, global.controllerOpened[player.name])
						global.controllerOpened[player.name] = nil
					end
					if global.controllerOpened[player.name] == nil then
						gui_open(player, player.opened)
						global.controllerOpened[player.name] = player.opened
					end
				end
			end
			if player.opened == nil then
				local object = global.controllerOpened[player.name]
				global.controllerOpened[player.name] = nil
				if not (object == nil ) then
					gui_close(player, object)
				end
			end
		end
	end)
end

script.on_event(defines.events.on_gui_opened, function(event)
	if  global.player ~= nil then
		if event.gui_type == defines.gui_type.entity then
			if event.entity.name == "train-publisher" then
				local player = game.players[event.player_index]
				global.player[event.player_index].entity = event.entity
				gui_open(player, event.entity)
			elseif event.entity.type == "locomotive" then
				local destination = event.entity.train.path_end_stop
				global.player[event.player_index].entity = event.entity
				global.player[event.player_index].destination = destination
			end
		end
	end
end)

script.on_event(defines.events.on_gui_closed, function(event)
	if  global.player ~= nil then
		if event.gui_type == defines.gui_type.entity then
			if event.entity.name == "train-publisher" then
				local player = game.players[event.player_index]
				gui_close(player, event.entity)
			elseif event.entity.type == "locomotive" then
				local player = event.player_index
				local surface = event.entity.surface.name
				if player ~= nil and global.newcounters and global.newcounters[surface] then
					if global.player[player].destination ~= nil then
						local destination = global.player[player].destination
						for _,counter in pairs(global.newcounters[surface]) do
							if counter.station == destination then
								updateCounters(counter)
							end
						end
					end
				end
			end
		end
	end
end)

function nth_tick()
	if settings.global['turbo_ups'].value == false then
	 	script.on_nth_tick(57, upd_counters )
		script.on_nth_tick(43, circuit_requesters_update )
	--	script.on_nth_tick(7, pub_open )
	else
	 	script.on_nth_tick(307, upd_counters )
	--	script.on_nth_tick(71, upd_publishers )
		script.on_nth_tick(87, circuit_requesters_update )
	--	script.on_nth_tick(11, pub_open )
	end
	script.on_nth_tick(settings.global['ticks-per-cycle'].value, upd_publishers )
end

function addPSToTable(entity, player_index, event)
	if entity.name == "subscriber-train-stop" then
	-- Check for subscriber-train-stop, and if train at station
		-- There should be three tables of subscriber train station info at the moment
			-- A complete list of all subscriber train stations - this can be replaced with player.surface.find_entities_filtered, currently global.entitystation
			-- A list of all subscriber stations with train, currently global.subscriptions
			-- A unique index to the subscriber stations with trains currently global.sub_index
		-- is there a train there
		local trains = entity.get_train_stop_trains()
		local status,err = pcall(function()
		for i, stp_train in pairs(trains) do
			if stp_train.station ~= nil then
				if stp_train.station.backer_name == entity.backer_name then
				-- we have a yes condition, so at the very least this train should be in global.subscriptions, but first check if it is the index item
					if not(global.sub_index[entity.backer_name]) then
					-- push the data
						push_sub_index(entity, stp_train)
						return
					else
					-- insert into global.subscriptions
						global.subscriptions[stp_train.id] = entity.backer_name
					-- table.insert(global.subscriptions,stp_train.id)
						return
					end
				end
			end
		end
	end)
	if not status then
		for _, player in pairs(game.players) do
			player.print(err)
		end
		-- game.players[1].print(err)
	end
	end
	if entity.name == "train-publisher" then
		global.newpublishers = global.newpublishers or {}
		local within2 = false

		for _,station in pairs(entity.surface.find_entities_filtered{area={{x=entity.position.x - 2,y=entity.position.y - 2},{x=entity.position.x + 2,y=entity.position.y + 2}},type="train-stop",name="publisher-train-stop"}) do
			global.newpublishers[entity.surface.name] = global.newpublishers[entity.surface.name] or {}
			global.newpublishers[entity.surface.name][station.backer_name] = global.newpublishers[entity.surface.name][station.backer_name] or {}
			local i = #global.newpublishers[entity.surface.name][station.backer_name] + 1
			global.cur_publisher = global.cur_publisher or {}
			global.cur_publisher[player_index] = global.cur_publisher[player_index] or {}
			global.cur_publisher[player_index].key = i
			global.newpublishers[entity.surface.name][station.backer_name] = global.newpublishers[entity.surface.name][station.backer_name] or {}
			global.newpublishers[entity.surface.name][station.backer_name][i] = {}
			global.newpublishers[entity.surface.name][station.backer_name][i].backer_name = station.backer_name
			global.newpublishers[entity.surface.name][station.backer_name][i].entity = entity
			global.newpublishers[entity.surface.name][station.backer_name][i].hide = false
			global.newpublishers[entity.surface.name][station.backer_name][i].proc_priority = 50
			global.newpublishers[entity.surface.name][station.backer_name][i].priority = {}
			if event.tags ~= nil and settings.global["full_bp_mode"].value == true then
				global.newpublishers[entity.surface.name][station.backer_name][i].priority.resource = event.tags.resource
				global.newpublishers[entity.surface.name][station.backer_name][i].priority.id = event.tags.id
				global.newpublishers[entity.surface.name][station.backer_name][i].hide = event.tags.hide
				global.newpublishers[entity.surface.name][station.backer_name][i].proc_priority = event.tags.proc_priority
			end
			global.newpublishers[entity.surface.name][station.backer_name][i].request = false
			global.newpublishers[entity.surface.name][station.backer_name][i].tick = 0

		--	table.insert(global.publishers, {entity = entity, backer_name = station.backer_name, enabled = false, priority = {}, request = false})
			within2 = true
			-- debugp("Publisher found at" .. station.backer_name)
		end
		for _,station in pairs(entity.surface.find_entities_filtered{area={{x=entity.position.x - 2,y=entity.position.y - 2},{x=entity.position.x + 2,y=entity.position.y + 2,type="entity-ghost",ghost_type="train-stop",ghost_name="publisher-train-stop"}}}) do
		--	game.print("type " .. station.type .. " : name " .. station.name)
			if station.type == "entity-ghost" and station.ghost_type == "train-stop" and station.ghost_name == "publisher-train-stop" then
		--		game.print("unit_number " .. entity.unit_number)
				local number = tostring(entity.unit_number)
			global.newpublishers[entity.surface.name] = global.newpublishers[entity.surface.name] or {}
			global.newpublishers[entity.surface.name][number] = global.newpublishers[station.surface.name][number] or {}
			local i = #global.newpublishers[entity.surface.name][number] + 1
			global.cur_publisher = global.cur_publisher or {}
			global.cur_publisher[player_index] = global.cur_publisher[player_index] or {}
			global.cur_publisher[player_index].key = i
			global.newpublishers[entity.surface.name][number] = global.newpublishers[entity.surface.name][number] or {}
			global.newpublishers[entity.surface.name][number][i] = {}
			global.newpublishers[entity.surface.name][number][i].backer_name = number
			global.newpublishers[entity.surface.name][number][i].entity = entity
			global.newpublishers[entity.surface.name][number][i].hide = false
			global.newpublishers[entity.surface.name][number][i].proc_priority = 50
			global.newpublishers[entity.surface.name][number][i].priority = {}
			if event.tags ~= nil and settings.global["full_bp_mode"].value == true then
				global.newpublishers[entity.surface.name][number][i].priority.resource = event.tags.resource
				global.newpublishers[entity.surface.name][number][i].priority.id = event.tags.id
				global.newpublishers[entity.surface.name][number][i].hide = event.tags.hide
				global.newpublishers[entity.surface.name][number][i].proc_priority = event.tags.proc_priority
			end
			global.newpublishers[entity.surface.name][number][i].request = false
			global.newpublishers[entity.surface.name][number][i].tick = 0

		--	table.insert(global.publishers, {entity = entity, backer_name = station.backer_name, enabled = false, priority = {}, request = false})
			within2 = true
			-- debugp("Publisher found at" .. station.backer_name)
		end
		 end
		if within2 == false and player_index > 0 then
			game.players[player_index].print({"errors.within2"})
		end
	end
--[[ 	if entity.name == "circuit-requester" then
		global.circuit_req = global.circuit_req or {}
	--	local within2 = false

		for _,station in pairs(entity.surface.find_entities_filtered{area={{x=entity.position.x - 2,y=entity.position.y - 2},{x=entity.position.x + 2,y=entity.position.y + 2}},type="train-stop"}) do
			local i = #global.circuit_req[entity.surface.name] + 1
			global.newpublishers[entity.surface.name][i] = {}
			global.newpublishers[entity.surface.name][i] = {backer_name=station.backer_name, entity=entity, tick=0}
		--	within2 = true
			-- debugp("Publisher found at" .. station.backer_name)
		end
		-- if within2 == false and player_index > 0 then
		-- 	game.players[player_index].print("Requester needs to be within 2 tiles of requester train station")
		-- end
	end ]]
	if entity.name == "train-counter" then
	--	game.print("New counter")
		global.newcounters = global.newcounters or {}
		global.newcounters[entity.surface.name] = global.newcounters[entity.surface.name] or {}
		for _,station in pairs(entity.surface.find_entities_filtered{area={{x=entity.position.x - 2,y=entity.position.y - 2},{x=entity.position.x + 2,y=entity.position.y + 2}},type="train-stop"}) do
			local control = entity.get_or_create_control_behavior()
			control.parameters = nil
			table.insert(global.newcounters[entity.surface.name], {entity = entity, backer_name = station.backer_name, station = station})
		end
		entity.operable = false
		entity.minable = false
		entity.destructible = false
	end

	if entity.name == "publisher-train-stop" then
	--  Check not same name
		getUniqueName(entity)
		global.pubstops = global.pubstops or {}
		table.insert(global.pubstops, {entity = entity})
		-- Ensure surface is initialised for requesters
		global.newpublishers = global.newpublishers or {}
		global.newpublishers[entity.surface.name] = global.newpublishers[entity.surface.name] or {}
		-- check for train-publishers in range
		local pub_record_exists = false
		for _,publisher in pairs(entity.surface.find_entities_filtered{area={{x=entity.position.x - 3,y=entity.position.y - 3},{x=entity.position.x + 3,y=entity.position.y + 3}},name="train-publisher"}) do
		--	game.print("publisher found" .. publisher.unit_number)
		--	game.print(entity.unit_number)
			pub_record_exists = false
			-- test for existing blank station (" ")
			if global.newpublishers[entity.surface.name][" "] == nil then
			elseif global.newpublishers[entity.surface.name][" "] == {} then
			else
			--	game.print("blank requesters exist")
				local existing_found = false
				for j,existing_requester in pairs(global.newpublishers[entity.surface.name][" "]) do
					if existing_requester.entity == publisher then
					--	game.print("Blank requester found")
						global.newpublishers[entity.surface.name][entity.backer_name] = global.newpublishers[entity.surface.name][entity.backer_name] or {}
						local i = #global.newpublishers[entity.surface.name][entity.backer_name] + 1
						global.newpublishers[entity.surface.name][entity.backer_name][i] = {}
						global.newpublishers[entity.surface.name][entity.backer_name][i] = table.deepcopy(existing_requester)
						global.newpublishers[entity.surface.name][entity.backer_name][i].backer_name = entity.backer_name
						pub_record_exists = true
						table.remove(global.newpublishers[entity.surface.name][" "],j)
					end
				end
			end
		--	if settings.global["full_bp_mode"].value == true then
			if global.newpublishers[entity.surface.name][tostring(publisher.unit_number)] ~= nil then
				if global.newpublishers[entity.surface.name][tostring(publisher.unit_number)] ~= {} then
					for j,existing_requester in pairs(global.newpublishers[entity.surface.name][tostring(publisher.unit_number)]) do
						if existing_requester.entity == publisher then
						--	game.print("Existing requester found")
							global.newpublishers[entity.surface.name][entity.backer_name] = global.newpublishers[entity.surface.name][entity.backer_name] or {}
							local i = #global.newpublishers[entity.surface.name][entity.backer_name] + 1
							global.newpublishers[entity.surface.name][entity.backer_name][i] = {}
							global.newpublishers[entity.surface.name][entity.backer_name][i] = table.deepcopy(existing_requester)
							global.newpublishers[entity.surface.name][entity.backer_name][i].backer_name = entity.backer_name
							pub_record_exists = true
							table.remove(global.newpublishers[entity.surface.name][tostring(publisher.unit_number)],j)
						end
					end
				end
			end
		--	end
			-- for key,publishers in pairs(global.newpublishers[entity.surface.name]) do
			-- 	for i,pub in pairs(publishers) do
			-- 		if pub.entity == publisher then
			-- 			game.print("pub entity = publisher" .. " key is :" .. key .. ":")
			-- 			if pub.backer_name == nil then
			-- 				pub_record_exists = true
			-- 				pub.backer_name = entity.backer_name
			-- 				pub.request = false
			-- 				global.newpublishers[entity.surface.name][entity.backer_name] = global.newpublishers[entity.surface.name][entity.backer_name] or {}
			-- 				local j = #global.newpublishers[entity.surface.name][entity.backer_name] + 1
			-- 				global.newpublishers[entity.surface.name][entity.backer_name][j] = table.deepcopy(global.newpublishers[entity.surface.name][" "][i])
			-- 				global.newpublishers[entity.surface.name][" "][i] = nil
			-- 			end
			-- 		end
			-- 	end
			-- end
			if pub_record_exists == false then
			--	game.print("No existing requester")
				global.newpublishers[entity.surface.name][entity.backer_name] = global.newpublishers[entity.surface.name][entity.backer_name] or {}
				local j = #global.newpublishers[entity.surface.name][entity.backer_name] + 1
				global.newpublishers[entity.surface.name][entity.backer_name][j] = {}
				global.newpublishers[entity.surface.name][entity.backer_name][j].entity = publisher
				global.newpublishers[entity.surface.name][entity.backer_name][j].backer_name = entity.backer_name
				global.newpublishers[entity.surface.name][entity.backer_name][j].priority = {}
				global.newpublishers[entity.surface.name][entity.backer_name][j].request = false
				global.newpublishers[entity.surface.name][entity.backer_name][j].tick = 0
				global.newpublishers[entity.surface.name][entity.backer_name][j].hide = false
				global.newpublishers[entity.surface.name][entity.backer_name][j].proc_priority = 50
			end
		end
		-- add train counter
		local x = entity.position.x
		local y = entity.position.y
		if entity.orientation == 0.75 then x = x + 1 end
		if entity.orientation == 0.25 then
			x = x - 2
			y = y - 1
		end
		if entity.orientation == 0 then
			y = y + 1
			x = x - 1
		end
		if entity.orientation == 0.5 then y = y - 2 end
		if not(entity.surface.can_place_entity{name="train-counter", position={x,y}}) then
			--entity.surface.mine_tile(x,y)
		--	debugp("player index " .. player_index)
		--	local mov_entity = entity.surface.find_entities({{x,y},{x+1,y+1}})
			if player_index > 0 then
			--	game.players[player_index].mine_entity(mov_entity[1])
			game.players[player_index].mine_entity(entity)
			else
				local destroyed = entity.destroy()
				-- if robot.valid == true then
					-- robot.mine_entity(mov_entity[1])
				-- end
			end
		else
			local ghost = entity.surface.find_entities_filtered{position={x + 0.5, y + 0.5},name="entity-ghost",ghost_name="train-counter"}[1]
			if ghost then
				global.pending_req = global.pending_req or {}
				global.pending_req[#global.pending_req+1] = {x + 0.5, y + 0.5}
				--	debugp(gh.name .. gh.ghost_name .. gh.position.x .. gh.position.y)
				ghost.revive()
				--local new_entity = ghost.revive()[2]

			else
				local new_entity = entity.surface.create_entity{name="train-counter", position={x , y}, force = entity.force, fast_replace = true }
				new_entity.operable = false
				new_entity.minable = false
				new_entity.destructible = false
				addPSToTable(new_entity,0)
			end
		end
	end
end

function removePSFromTable(entity)
	--debugp("In remove")

	if entity.name == "subscriber-train-stop" then
		-- check if index entry, or if there is a train there
		global.sub_index = global.sub_index or {}
		if global.sub_index == {} then return end
		if global.sub_index[entity.backer_name] then
			pop_sub_index(entity.backer_name, global.sub_index[entity.backer_name] )
		else
			-- check if train there
			local trains = entity.get_train_stop_trains()
			global.subscriptions = global.subscriptions or {}
			for _, stp_train in pairs(trains) do
				if stp_train.station then
					if stp_train.station.backer_name == entity.backer_name then
					-- indexed remove
						if global.subscriptions[stp_train.id] then
							global.subscriptions[stp_train.id] = nil
							return
						end
					end
				end
			end
		end
	end
	if entity.name == "train-publisher" then
		if global.newpublishers == nil then return end
		if global.newpublishers[entity.surface.name] == nil then return end
		local backer_name = nil
		for keyi, publishers in pairs(global.newpublishers[entity.surface.name]) do
			for i, pubs in pairs(publishers) do
				if pubs.entity == entity then
					global.newpublishers[entity.surface.name][keyi][i] = nil
					backer_name = keyi
					break
				end
			end
		end
		if global.newrequests ~= nil and backer_name ~= nil then
			if global.newrequests[entity.surface.name] ~= nil then
			if global.newrequests[entity.surface.name] ~= {} then
			if global.newrequests[entity.surface.name][backer_name] ~= nil then
				for i, reqs in pairs(global.newrequests[entity.surface.name][backer_name]) do
					if reqs.entity == entity then
						global.newrequests[entity.surface.name][backer_name][i] = nil
						break
					end
				end
			end
			end
			end
		end
	end

	if entity.name == "train-counter" then
		if global.newcounters then
			if global.newcounters[entity.surface.name] then
				for i, counter in pairs(global.newcounters[entity.surface.name]) do
					if counter.entity == entity then
						table.remove(global.newcounters[entity.surface.name], i)
						break
					end
				end
			end
		end
	end
	if entity.name == "publisher-train-stop" then
		--debugp("Removing publisher-train-stop  " .. entity.backer_name)
		if global.pubstops then
			for i, pubstop in pairs(global.pubstops) do
				if pubstop.entity == entity then
					table.remove(global.pubstops, i)
					-- break
				end
			end
		end
		--debugp("attempt to find counter element X"  .. entity.position.x  ..  " Y "  ..  entity.position.y)
		for i, counter in pairs(entity.surface.find_entities_filtered{area={{x=entity.position.x - 2,y=entity.position.y - 2},{x=entity.position.x + 2,y=entity.position.y + 2}},name="train-counter"}) do
			counter.destroy()
			--global.counters[i] = nil
			break
		end
		-- Also need to disable publishers near the remove pub train stop
		global.newpublishers = global.newpublishers or {}
		if global.newpublishers ~= {} then
		if global.newpublishers[entity.surface.name] ~= nil then
			if global.newpublishers[entity.surface.name][entity.backer_name] ~= nil then
		for i, publisher in pairs(global.newpublishers[entity.surface.name][entity.backer_name]) do
		--	if pubs == publisher.entity then
			publisher.backer_name = nil
			publisher.request = false
			global.newpublishers[entity.surface.name][" "] = global.newpublishers[entity.surface.name][" "] or {}
			local j = #global.newpublishers[entity.surface.name][" "] + 1
			global.newpublishers[entity.surface.name][" "][j] = table.deepcopy(global.newpublishers[entity.surface.name][entity.backer_name][i])
			global.newpublishers[entity.surface.name][entity.backer_name][i] = nil
			if global.newrequests then
				if global.newrequests[entity.surface.name] ~= nil then
				for keyi,requests in pairs(global.newrequests[entity.surface.name]) do
					for i, reqs in pairs(requests) do
						if reqs.entity == publisher.entity then
							table.remove(global.newrequests[entity.surface.name][keyi], i)
							break
						end
					end
				end
				end
			end
			end
		end
		end
		end
	end
end


function debugp(text)
	if global.db_on == true then
		for _, player in pairs(game.players) do
			player.print(text)
		end
	end
end

function check_req(station, train)
	--local backer_name = station.backer_name
	local surface = station.surface.name
	global.newrequests = global.newrequests or {}
	if global.newrequests == {} then
		checkreq = false
		return
	end
	local reqpri = {}
	local status,err = pcall(function()
	reqpri = find_best_match(station)
	end)
	if not status then
		game.print(err)
	end
	if reqpri == nil then
		checkreq = false
		return
	end
	if reqpri ~= {} then
		if reqpri.request ~= nil then
			if global.newpublishers[surface][reqpri.request.backer_name] == nil then
			 	table.remove(global.newrequests[surface][reqpri.request.backer_name], reqpri.i)
				checkreq = false
				return
			end
			-- Test requested station is unique and a requester station
			-- if check_unique(station.surface, reqpri.request.backer_name) == false then
			-- 	station.surface.print({"errors.tsm_dest"})
			-- 	station.surface.print(reqpri.request.backer_name)
			-- 	checkreq = false
			-- 	return
			-- end
			for k, publisher in pairs(global.newpublishers[surface][reqpri.request.backer_name]) do
				if reqpri.request.entity == publisher.entity then
					if check_unique(station.surface, reqpri.request.backer_name) == false then
						destination_error(station.surface, reqpri.request.backer_name)
						publisher.request = false
						if global.newrequests[surface][reqpri.request.backer_name] ~= nil then
							table.remove(global.newrequests[surface][reqpri.request.backer_name], reqpri.i)
						end
						station.surface.print(reqpri.request.backer_name)
						checkreq = false
						return
					end
				 	if global.newrequests[surface][reqpri.request.backer_name] ~= nil then
						table.remove(global.newrequests[surface][reqpri.request.backer_name], reqpri.i)
				 	end
					publisher.request = false
					if publisher.entity.get_or_create_control_behavior().disabled then
					--	game.print("disabled")
						checkreq = false
						check_req(station, train)
						if checkreq == false then
							push_sub_index(station, train)
						end
					else
					--	game.print("enabled")
						build_schedule(train, reqpri.request.backer_name, reqpri.priority)
					end
					break
				end
			end

			-- update train-counter
			for _,counter in pairs(global.newcounters[surface]) do
				if counter.backer_name == reqpri.request.backer_name then
					updateCounters(counter,2)
					break
				end
			end
				checkreq = true
			return

		else
			checkreq = false
			return
		end
	else
		checkreq = false
		return
	end

end

function check_train_in_Sub_station(station)
	local train = nil
	if global.sub_index == nil then return nil end
	if global.sub_index[ station ] then
		local status,err = pcall(function()
		train = global.trains[global.sub_index[ station ]]
		debugp(global.sub_index[ station ])
		if train == nil then return nil end
		if train.station == nil then
			pop_sub_index(station,global.sub_index[ station ])
			return check_train_in_Sub_station(station)
		end
		if train.station.backer_name == nil then
			pop_sub_index(station,global.sub_index[ station ])
			return check_train_in_Sub_station(station)
		end
	--	debugp(train.station.backer_name .." : " .. station )
		if train.station.backer_name == station then
		--	debugp(train.id)
			train_t = train.id
			return train.id
		else
			pop_sub_index(station,global.sub_index[ station ])
			return check_train_in_Sub_station(station)
			-- debugp(train.id)
			-- return train
		end
		end)
		if not status then
			pop_sub_index(station,global.sub_index[ station ])
			return check_train_in_Sub_station(station)
		end
	end
	return nil
end

local function match_req(publisher, backer_name, x)
	-- Look up subscriptions table vs priorities
	-- debugp("In matching")
	local retvalue = false
  --	local status,err = pcall(function()
	if not global.subscriptions then return false end
	local surface = publisher.entity.surface.name
	local priority = global.newpriority[surface][publisher.priority.resource.name][publisher.priority.id.name]
	if priority == nil then return false end
	if not priority.station then return false end
		 --	debugp("Selected priority stations exist")
	if check_unique(publisher.entity.surface,backer_name) == false then
		destination_error(publisher.entity.surface, backer_name)
		publisher.request = false
		global.newrequests[surface] = global.newrequests[surface] or {}
		if global.newrequests[surface][backer_name] ~= nil then
			for i, req in pairs(global.newrequests[surface][backer_name]) do
				if publisher.entity == req.entity then
					table.remove(global.newrequests[surface][backer_name], reqpri.i)
					break
				end
			end
		end
		matchreq = true
		return true
	end
		for _, station in ipairs(priority.station) do
			-- 	 debugp(station[2])
			--	if global.sub_index[ station[2] ] then
			if station ~= "" then
				-- check that sub_index is in station, else pop and try again
				--	local train = global.trains[global.sub_index[ station[2] ]]
				train_t = nil
				check_train_in_Sub_station(station[2])

				if train_t ~= nil then
			 --	debugp("returned " .. train_t)
				local train = global.trains[train_t ]

				if train ~= {} then
					--local train = global.trains[global.sub_index[ station[2] ]]

					build_schedule(train, backer_name, priority)
					pop_sub_index(station[2],global.sub_index[ station[2] ])
					-- table.remove(global.subscriptions, i)
					-- update train-counter
					if settings.global['auto_updor'].value == true then
						auto_update()
					end
					for _,counter in pairs(global.newcounters[surface]) do
						if counter.station.valid == true then
							--debugp(counter.backer_name .. " : " .. publisher.backer_name)
							if counter.backer_name == publisher.backer_name then
							--	debugp(counter.backer_name .. " : " .. publisher.backer_name)
								updateCounters(counter, 1)
								retvalue = true
								matchreq = retvalue
								return
								-- break
							end
						else
							if counter.entity.valid == true then
								local do_delete = true
								for _,stationx in pairs(counter.entity.surface.find_entities_filtered{area={{x=counter.entity.position.x - 2,y=counter.entity.position.y - 2},{x=counter.entity.position.x + 2,y=counter.entity.position.y + 2}},type="train-stop",name="publisher-train-stop"}) do
									counter.station = stationx
									game.print(counter.station.backer_name .. " is repaired")
									localstop = counter.station
									do_delete = false
									break
								end
								if do_delete == true then
									counter.entity.destroy()
								end
							end
						end
					end
					retvalue = true
					matchreq = retvalue
					return
					-- end
				end
			end
		end
	end
	retvalue = false
	matchreq = retvalue
	return
end

function updaterequestedpublisher(resource,id, surface, x)
	-- local status,err = pcall(function()
	--debugp("In update requested pubs")
	global.newpublishers = global.newpublishers or {}
	global.newpublishers[surface] = global.newpublishers[surface] or {}
	if global.newpublishers[surface] then
	for keyi,publishers in pairs(global.newpublishers[surface]) do
	--	game.print("keyi " .. keyi)
		for i,publisher in pairs(publishers) do
--	game.print("Pub " .. publisher.backer_name)
			if publisher.entity == nil then
				game.print("removing nil .." .. keyi)
				table.remove(global.newpublishers[surface][keyi], i)
			elseif publisher.entity.valid == false then
				game.print("removing invalid .." .. keyi)
				table.remove(global.newpublishers[surface][keyi], i)
			elseif not(publisher.entity.get_or_create_control_behavior().disabled) then
				if publisher.priority.resource == nil then
				elseif publisher.priority.resource == {} then
				elseif publisher.priority.id == nil then
				elseif publisher.priority.id == {} then
				else
				if publisher.request and publisher.priority.resource.name == resource and publisher.priority.id.name == id then
				--	debugp("Testing")
					matchreq = false
			--		if publisher.entity.surface.get_train_stops(keyi) ~= {} then
						match_req(publisher, keyi, x)
			--		end
				--	debugp(matchreq)
					if matchreq == true then
					--	debugp("Removing")
						-- remove existing request
						if global.newrequests[surface][keyi] ~= nil then
							for j,request in pairs(global.newrequests[surface][keyi]) do
								if request.entity == publisher.entity then
								--	debugp("Removing")
									table.remove(global.newrequests[surface][keyi], j)
								--	global.newpublishers[surface][keyi][i].request = false
									publisher.request = false
									--global.requests[j] = nil
									break
								end
							end
						end
					end
					if settings.global['turbo_ups'].value == false then
						publisher.tick = game.tick + 58
					else
						publisher.tick = game.tick + 311
					end
				end
				end
			end
		end
	end
	end
end

function updatePublishers(publisher, backer_name, x)
	local surface = publisher.entity.surface.name
	if backer_name == nil or backer_name  == "" or backer_name == " " then return end
	if publisher.entity.get_or_create_control_behavior().disabled then
		return false
	end

	if publisher.request then

		if global.newrequests[surface][backer_name] ~= nil then    -- Experimental
			for _,request in pairs(global.newrequests[surface][backer_name]) do
				if publisher.priority.resource.name == request.priority.resource.name and
					publisher.priority.id.name == request.priority.id.name then
						return false
					end
			end
			log("Revoking false Existing request "  .. publisher.backer_name .. " " .. publisher.priority.resource.name)
			publisher.request = false                              -- Experimental


		--	return false
		else                                                       -- Experimental
			log("Revoking false Existing request "  .. publisher.backer_name)
			publisher.request = false                              -- Experimental
		end                                                        -- Experimental
	end

--	if not publisher.enabled then
-- 	game.print(backer_name)
	if not publisher.priority then return false end
	if not publisher.priority.resource then return false end
	if not publisher.priority.resource.name then return false end
	if not publisher.priority.id then return false end
	if not publisher.priority.id.name then return false end
	if global.newpriority == nil then return false end
	if global.newpriority[surface] == nil then return false end
	if global.newpriority[surface][publisher.priority.resource.name] == nil then return false end
	if global.newpriority[surface][publisher.priority.resource.name][publisher.priority.id.name] == nil then return false end
--    game.print("pub name is " .. backer_name)
	matchreq = false
	match_req(publisher, backer_name, x)
-- 	debugp(matchreq)
	if matchreq == false and tostring(publisher.entity.unit_number) ~= tostring(backer_name) then
		-- append a requestor record
		global.newrequests = global.newrequests or {}
		global.newrequests[surface] = global.newrequests[surface] or {}
	--	game.print(backer_name)
		global.newrequests[surface][backer_name] = global.newrequests[surface][backer_name] or {}
	--	if global.newrequests[surface][backer_name] then
		publisher.request = true

		if settings.global['turbo_ups'].value == false then
			publisher.tick = game.tick + 58
		else
			publisher.tick = game.tick + 311
		end
		local i = #global.newrequests[surface][backer_name] + 1
		global.newrequests[surface][backer_name][i] = publisher
		global.newrequests[surface][backer_name][i].backer_name = backer_name
	--	game.write_file("match_det",serpent.block(global.newrequests[surface][backer_name][i]),{comment=false})
		if settings.global['auto_updor'].value == true then
			auto_update()
		end
	else
		if settings.global['turbo_ups'].value == false then
			publisher.tick = game.tick + 58
		else
			publisher.tick = game.tick + 311
		end
		return true
	end
	return false
end

function update_circuit_requesters(requester_stop)
	local surface = requester_stop.surface.name
	local signals = requester_stop.get_merged_signals()
--	game.print(requester_stop.backer_name)
	if signals == nil then return end
	if global.newpriority == nil then return end
	for _,signal in pairs(signals) do
		if signal.count < 0 then
			if signal.signal.type ~= "virtual" then
				-- Find dual icon priority
			--	requester_stop.surface.print("TSM: " .. requester_stop.backer_name .. " requests " .. signal.signal.name)
				if global.newpriority[surface][signal.signal.name] ~= nil then
				if global.newpriority[surface][signal.signal.name][signal.signal.name] ~= nil then

					local priority = global.newpriority[surface][signal.signal.name][signal.signal.name]

					if not priority.station then return false end

						for _, station in ipairs(priority.station) do
							if station ~= "" then
								-- check that sub_index is in station, else pop and try again
								--	local train = global.trains[global.sub_index[ station[2] ]]
								train_t = nil
								check_train_in_Sub_station(station[2])

								if train_t ~= nil then
									local train = global.trains[train_t ]

									if train ~= {} then
										build_schedule(train, requester_stop.backer_name, priority)
										pop_sub_index(station[2],global.sub_index[ station[2] ])
										for _,counter in pairs(global.newcounters[surface]) do
											--debugp(counter.backer_name .. " : " .. publisher.backer_name)
											if counter.backer_name == requester_stop.backer_name then
											--	debugp(counter.backer_name .. " : " .. publisher.backer_name)
												updateCounters(counter, 1)
												return   -- suggested by leeh
											end
										end
									end
								end
							end
						end
						-- no trains - write oustanding record
						global.direct_out = global.direct_out or {}
						global.direct_out[surface] = global.direct_out[surface] or {}
						global.direct_out[surface][signal.signal.name] = global.direct_out[surface][signal.signal.name] or {}
						global.direct_out[surface][signal.signal.name][#global.direct_out[surface][signal.signal.name] + 1] = {entity = requester_stop, signal = signal}
					end
				end
			end
		end
	end
end

function updateCounters(counter, dbp)
	local status,err = pcall(function()
	if counter.entity.valid == true then
	local cb = counter.entity.get_or_create_control_behavior()
	local signal = cb.get_signal(1)
	 global.train_res = global.train_res or {}
	 cb.parameters = nil

	if dbp == 1 then
		--	debugp("count :" .. signal.count)
		-- traincount = signal.count + 1	 -- force increment
	end
	-- else
		local localstop = counter.station

		if localstop.valid == false then
			for _,stationx in pairs(counter.entity.surface.find_entities_filtered{area={{x=counter.entity.position.x - 2,y=counter.entity.position.y - 2},{x=counter.entity.position.x + 2,y=counter.entity.position.y + 2}},type="train-stop",name="publisher-train-stop"}) do
				counter.station = stationx
				game.print(counter.station.backer_name .. " is repaired")
				localstop = counter.station
				break
			end
		end
		local trains = localstop.get_train_stop_trains()
		local traincount = 0
		local res_count = {}
		for _, train in pairs(trains) do
		 --	game.print(train.schedule.records[train.schedule.current].station .. localstop.backer_name)
		--	if train.path_end_stop == localstop then
			if train.schedule.records[train.schedule.current].station == localstop.backer_name then
			 --	game.print("end stop" .. train.id)
				traincount = traincount + 1
				if global.train_res[train.id] ~= nil then
					res_count[global.train_res[train.id].name] = res_count[global.train_res[train.id].name] or {}
					res_count[global.train_res[train.id].name].count = res_count[global.train_res[train.id].name].count or 0
					res_count[global.train_res[train.id].name].count = res_count[global.train_res[train.id].name].count + 1
					res_count[global.train_res[train.id].name].type = global.train_res[train.id].type
				end
			elseif train.station == localstop then
			-- 	game.print("localstop")
				traincount = traincount + 1
				if global.train_res[train.id] ~= nil then
				--	game.print("Not nil")
					res_count[global.train_res[train.id].name] = res_count[global.train_res[train.id].name] or {}
					res_count[global.train_res[train.id].name].count = res_count[global.train_res[train.id].name].count or 0
					res_count[global.train_res[train.id].name].count = res_count[global.train_res[train.id].name].count + 1
					res_count[global.train_res[train.id].name].type = global.train_res[train.id].type				end
			elseif train.state == defines.train_state.no_path and
				train.schedule.records[train.schedule.current].station == localstop.backer_name then
			--	game.print("no path")
				traincount = traincount + 1
				if global.train_res[train.id] ~= nil then
					res_count[global.train_res[train.id].name] = res_count[global.train_res[train.id].name] or {}
					res_count[global.train_res[train.id].name].count = res_count[global.train_res[train.id].name].count or 0
					res_count[global.train_res[train.id].name].count = res_count[global.train_res[train.id].name].count + 1
					res_count[global.train_res[train.id].name].type = global.train_res[train.id].type				end
			end
		end
	-- end

	cb.set_signal(1, {	signal = {
									type = "virtual",
									name = "train-counter"
									},
						count = traincount}
				)
	i = 2
	for key,resource in pairs(res_count) do
		cb.set_signal(i, {	signal = {
									type = resource.type,
									name = key
									},
			count = resource.count}
			)
		i = i + 1
	end

	end
	end)
	if not status then
			for _,players in pairs(game.players) do
			players.print(err)
			end
			return
	end
end

local function on_train_schedule_changed(event)
	local train = event.train
	local schedule = train.schedule
	local player = event.player_index
	if schedule ~= nil then
		local surface = train.front_rail.surface.name
		local station_name = schedule.records[schedule.current].station
		if station_name ~= nil then
			for _,station in pairs(train.front_rail.surface.get_train_stops({name=station_name})) do
				if station.name == "publisher-train-stop" then
					if global.newcounters[surface] ~= nil then
						for _,counter in pairs(global.newcounters[surface]) do
							if counter.station == station then
							--	game.print("event updating counter for " .. counter.backer_name)
								updateCounters(counter)
							end
						end
					end
				end
			end
			-- if you removed a requester from schedule then check player record
--[[
			if player ~= nil then
				game.print("player" .. player)
				game.print(train.id .. global.player[player].entity.train.id)
				if global.player[player].entity.train == train then
					if global.player[player].destination ~= nil then
						game.print(destination.backer_name)
						for _,counter in pairs(global.newcounters[surface]) do
							if counter.station == destination then
							 	game.print("event updating counter for " .. counter.backer_name)
								updateCounters(counter)
							end
						end
					end
				end
			end	 ]]
		end
	end
end

script.on_event(defines.events.on_train_created, function(event)
	global.trains = global.trains or {}
	global.subscriptions = global.subscriptions or {}
	global.train_res = global.train_res or {}
	--if not global.subscriptions then return end
	global.trains[event.train.id] = event.train
	if event.train.get_contents() ~= nil then
	--	game.write_file("contents",serpent.block(event.train.get_contents()),{comment=false})
		for name,content in pairs(event.train.get_contents()) do
			global.train_res[event.train.id] = global.train_res[event.train.id] or {}
			global.train_res[event.train.id] = {name=name, type="item"}
			break
		end

	elseif event.train.get_fluid_contents() ~= nil  then
		for name,content in pairs(event.train.get_fluid_contents()) do
			global.train_res[event.train.id] = global.train_res[event.train.id] or {}
			global.train_res[event.train.id] = {name=name, type="fluid"}
			break
		end

	end
	if event.old_train_id_1 then
	--	global.train_res[event.train.id] = global.train_res[event.old_train_id_1]
		global.trains[event.old_train_id_1] = nil
	--	global.train_res[event.old_train_id_1] = nil
		--debugp(event.old_train_id_1)
		if global.subscriptions[event.old_train_id_1] then
			if global.sub_index[global.subscriptions[event.old_train_id_1]] then
				pop_sub_index(global.subscriptions[event.old_train_id_1],event.old_train_id_1)
			else
				global.subscriptions[event.old_train_id_1] = nil
			end
		end
	end
	if event.old_train_id_2 then
		global.trains[event.old_train_id_2] = nil
		if global.subscriptions[event.old_train_id_2] then
			if global.sub_index[global.subscriptions[event.old_train_id_2]] then
				pop_sub_index(global.subscriptions[event.old_train_id_2],event.old_train_id_2)
			else
				global.subscriptions[event.old_train_id_2] = nil
			end
		end
	end
end)


local function fix_requests()
	for i,surface in pairs(game.surfaces) do
		if global.newpublishers[surface.name] ~= nil then
			if global.newpublishers[surface.name] ~= {} then
				for j,backers in pairs(global.newpublishers[surface.name]) do
					if backers ~= nil then
						if backers ~= {} then
							for k,pub in pairs(backers) do
								game.print(j .. k)
								if pub == nil then
									game.print("nil")
									table.remove(global.newpublishers[surface.name][j],k)
								elseif pub == {} then
									game.print("Remove " .. k)
									table.remove(global.newpublishers[surface.name][j],k)
								else
									game.print("write to file")
									game.write_file(k,serpent.block(pub),{comment=false})
								end
							end
						else
							game.print("removing " .. j)
							table.remove(global.newpublishers[surface.name],j)
						end
					else
						game.print("removing " .. j)
						table.remove(global.newpublishers[surface.name],j)
					end
					game.print(j)
					if global.newpublishers[surface.name][j] == nil then
						table.remove(global.newpublishers[surface.name],j)
					elseif global.newpublishers[surface.name][j] == {} then
						game.print("removing " .. j)
						table.remove(global.newpublishers[surface.name],j)
					end
				end
			end
		end
--[[ 		if global.newpublishers[surface.name] == nil then
			table.remove(global.newpublishers,i)
		elseif global.newpublishers[surface.name] == {} then
			table.remove(global.newpublishers,i)
		end ]]
	end

	for i,surface in pairs(game.surfaces) do
		if global.newrequests[surface.name] ~= nil then
			if global.newrequests[surface.name] ~= {} then
				for j,backers in pairs(global.newrequests[surface.name]) do
					if backers ~= nil then
						if backers ~= {} then
							for k,pub in pairs(backers) do
								if backers[k] == nil then
									table.remove(global.newrequests[surface.name][j],k)
								elseif backers[k] == {} then
									table.remove(global.requests[surface.name][j],k)
								end
							end
						end
					end
					if global.newrequests[surface.name][j] == nil then
						table.remove(global.newrequests[surface.name],j)
					elseif global.newrequests[surface.name][j] == {} then
						table.remove(global.newrequests[surface.name],j)
					end
				end
			end
		end
--[[ 		if global.newrequests[surface.name] == nil then
			table.remove(global.newrequests,i)
		elseif global.newrequests[surface.name] == {} then
			table.remove(global.newrequests,i)
		end ]]
	end
end

function fix_ps_stations()
	local j = 1
	while j <= #global.newpriority do
		local i = 1
		local x = 0
		debugp(#global.newpriority[j].station .. " priorities")
		while i <= #global.newpriority[j].station do
			debugp(i .. " : " .. j)
			if #global.newpriority[j].station[i] == 1 then
				x = x + 1
				table.remove(global.newpriority[j].station, i)
				debugp("removed")
			else
				i = i + 1
				debugp("ok")
			end
		end
		j = j + 1
	end
	debugp(x)
	return x
end

script.on_configuration_changed(on_configuration_changed)
script.on_init(onLoad)
script.set_event_filter(defines.events.on_pre_player_mined_item, filters)
script.on_event(defines.events.on_pre_player_mined_item, on_preplayer_mined_item)
script.on_event(defines.events.on_train_changed_state, on_train_changed_state)
script.on_event(defines.events.on_player_created, on_player_created)
script.on_event(defines.events.on_player_joined_game, on_player_joined_game )
script.on_event(defines.events.on_gui_click, on_gui_click)
script.on_event(defines.events.on_gui_elem_changed, on_gui_elem_changed)
script.on_event(defines.events.on_gui_selection_state_changed, on_gui_selection_state_changed)
script.on_load(nth_tick)
script.on_event(defines.events.on_gui_checked_state_changed, on_gui_checked_state_changed)
script.on_event(defines.events.on_train_schedule_changed, on_train_schedule_changed)
script.on_event(defines.events.on_pre_entity_settings_pasted, on_pre_entity_settings_pasted)
--script.on_event(defines.events.on_tick, on_tick)

commands.add_command("CreateIndex", {"createindex_help"}, function(event)
	global.sub_index = {}
	global.subscriptions = global.subscriptions or {}
	-- global.subscriptions now keyed by train
	for i,subs in pairs(global.subscriptions) do
		if global.sub_index[subs.backer_name] == nil then
--			global.sub_index[subs.backer_name] = subs.train.id
			global.sub_index[subs.backer_name] = i
		--	debugp(subs.backer_name .. " : " .. global.sub_index[subs.backer_name])
		end
	end
end)

commands.add_command("trainInfo", {"trainInfo_help"}, function(event)
	local trains = game.player.surface.get_trains()
	global.trains = {}
	for i,train in pairs(trains) do
	--	debugp(train.id)
		global.trains[train.id] = train
	end
end)

commands.add_command("debug_on", {"trainInfo_help"}, function(event)
	global.db_on = true
end)

commands.add_command("debug_off", {"trainInfo_help"}, function(event)
	global.db_on = false
end)

commands.add_command("Get_requests_file", {"get requests file help"}, function(event)
	game.write_file("requests_log",serpent.block(global.newrequests),{comment=false})
end)

commands.add_command("Get_sub_index", {"get sub index help"}, function(event)
	game.write_file("sub_index",serpent.block(global.sub_index),{comment=false})
end)

commands.add_command("Get_trains", {"get trains help"}, function(event)
	game.write_file("trains",serpent.block(global.trains),{comment=false})
	game.write_file("trains_res",serpent.block(global.train_res),{comment=false})
end)

commands.add_command("Get_pslogs", {"get pslogs help"}, function(event)
	game.write_file("trainpubs",serpent.block(global.publishers),{comment=false})
	game.write_file("trainnewpubs",serpent.block(global.newpublishers),{comment=false})
	game.write_file("trainreqs",serpent.block(global.requests),{comment=false})
	game.write_file("trainnewreqs",serpent.block(global.newrequests),{comment=false})
	game.write_file("trainpriorities",serpent.block(global.priority),{comment=false})
	game.write_file("trainnewpriorities",serpent.block(global.newpriority),{comment=false})
	game.write_file("counters",serpent.block(global.newcounters),{comment=false})
--	game.write_file("subscriptions",serpent.block(global.counters),{comment=false})
end)


commands.add_command("rebuild_trains", {"rebuild_trains_help"}, function(event)
	local surface = nil
	global.trains = {}
	for _, surface in pairs(game.surfaces) do
		local trains = surface.get_trains()
		for i,train in pairs(trains) do
		 --	debugp(train.id)
			global.trains[train.id] = train
		end
	end
end)

commands.add_command("Get_pubstops", {"get pubstops help"}, function(event)
	game.write_file("pubstops",serpent.block(global.pubstops),{comment=false})
end)

commands.add_command("Validate_index", {"validate index help"}, function(event)
	local train = nil
	for i,sub_i in pairs(global.sub_index) do
		train = global.trains[global.sub_index[ i ]]
		if not(train) then
			pop_sub_index(i,global.sub_index[ i ])
		elseif not(train.valid) then
			pop_sub_index(i,global.sub_index[ i ])
		elseif not (train.station) then
			pop_sub_index(i,global.sub_index[ i ])
		end
	end
end)

commands.add_command("fix_ps_stations", {"fix ps stations help"}, function(event)
	local x = 0
	x = fix_ps_stations()
	if x ~= nil then
		game.players[event.player_index].print(x .. " nil stations removed")
	else
		game.players[event.player_index].print("0 nil stations removed")
	end
end)

commands.add_command("fix_raw_wood", {"fix raw wood help"}, function(event)
	fix_raw_wood()
	game.players[event.player_index].print("raw-wood instances have been corrected to wood")
end)

commands.add_command("reset", {"reset_help"}, function(event)
	game.players[event.player_index].print("reset is redacted - use /tsm_reset")
end)

commands.add_command("tsm_reset", {"reset_help"}, function(event)
	reset_requests()
	reset_trains()
end)

commands.add_command(
    "tsm_export",
    "Export Supply Source Priorities",
    function(event)
        local player = game.players[event.player_index]
        game.write_file("tsm_export.txt", game.encode_string(game.table_to_json(global.newpriority)), false, event.player_index)
        player.print("Saved to script-output\tsm_export.txt")
    end
)

commands.add_command(
    "tsm_import",
    "Import Supply Source Priorities",
    function(event)
        local player = game.players[event.player_index]
        if player.admin then
            if event.parameter and game.decode_string(event.parameter) then
                local tmp_table = game.json_to_table(game.decode_string(event.parameter))
                if type(tmp_table) == "table" then
                    global.newpriority = tmp_table
                    player.print("Import Complete")
                end
            else
                player.print("/tsm_import blueprint_string")
            end
        else
            game.print(string.format("%s tried to import a TSM configuration as a non-admin", player.name))
        end
    end
)

commands.add_command(
    "tsm_remove_dup_rq",
    "Remove Duplicate Requesters",
	function(event)
		for i,pub in pairs(global.newpublishers["nauvis"]) do
			if tonumber(i) ~= nil then
				game.print(i)
				game.write_file("curr_pub",serpent.block(pub),{comment=false})
				if pub == nil then
					game.print(i .. " removed")
					table.remove(global.newpublishers["nauvis"], i)
				elseif pub.backer_name == i then
					local entity = pub.entity
					game.print(pub.entity.unit_number)
				--	for j,kpub in pairs()
				end
			end
		end

    end
)
commands.add_command("tsm_garbage", {"reset_help"}, function(event)

--	for surface,publishers in pairs(global.newpublishers) do
--		for backer_name,pubs in pairs(publishers) do
local surface = "nauvis"
local backer_name ="Charcoal Hydrogen Oxygen Load01"
game.print(table_size(global.newpublishers[surface][backer_name]) .. #global.newpublishers[surface][backer_name])
local i = 1
while i < #global.newpublishers[surface][backer_name] do
		--	for i,requester in pairs(global.newpublishers[surface][backer_name]) do
				game.print(surface .. backer_name ..i)
				if requester == nil then
				game.print("nil")
				table.remove(global.newpublishers[surface][backer_name], i)
				else
					i = i + 1
				end
			end
		--end

	--end
	collectgarbage("collect")
end)