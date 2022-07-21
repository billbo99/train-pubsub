remote.add_interface("TSM-API",
{list_priorities = function(surface)
    if surface ~= nil then
        if global.newpriority[surface] ~= nil then
            return global.newpriority[surface]
        else
            return {}
        end
    else
        if global.newpriority ~= nil then
            return global.newpriority
        else
            return {}
        end
    end
end,

define_new_priority = function(icon1, icon2, stationlist, surface)
    local resource = {}
    local id = {}
    resource.elem_type = "signal"
    resource.name = icon1
    id.elem_type = "signal"
    id.name = icon2
    -- if game.item_prototypes[icon1] ~= nil then
    --     resource.type = "item"
    -- elseif game.fluid_prototypes[icon1] ~= nil then
    --     resource.type = "fluid"
    -- elseif game.virtual_signal_prototypes[icon1] ~= nil then
    --     resource.type = "virtual"
    -- else
    resource.type = check_icon(icon1)
    if resource.type == "error" then
        game.print("Remote priority add failed, icon " .. icon1 .. " invalid")
        return
    end
    -- if game.item_prototypes[icon2] ~= nil then
    --     id.type = "item"
    -- elseif game.fluid_prototypes[icon2] ~= nil then
    --     id.type = "fluid"
    -- elseif game.virtual_signal_prototypes[icon2] ~= nil then
    --     id.type = "virtual"
    -- else
    id.type = check_icon(icon2)
    if id.type == "error" then
        game.print("Remote priority add failed, icon " .. icon2 .. " invalid")
        return
    end

    if surface == nil then
        surface = "nauvis"
    end

    local wc = {rb_or = true, rb_and = false, inc_ef = true, empty = true, full = false, inactivity = true, inact_int = 5, wait_timer = false, wait_int = 30, count = false, count_amt = 1000, count_ddn = 1}

    global.newpriority = global.newpriority or {}
    global.newpriority[surface] = global.newpriority[surface] or {}
    global.newpriority[surface][icon1] = global.newpriority[surface][icon1] or {}
    global.newpriority[surface][icon1][icon2] = global.newpriority[surface][icon1][icon2] or {}
    global.newpriority[surface][icon1][icon2].resource = resource
    global.newpriority[surface][icon1][icon2].id = id
    global.newpriority[surface][icon1][icon2].station = global.newpriority[surface][icon1][icon2].station or {}
    local i = 1
    if stationlist ~= nil then
        for _,station in pairs(stationlist) do
            global.newpriority[surface][icon1][icon2].station[i] = {"",station}
            i = i + 1
        end
    end
    global.newpriority[surface][icon1][icon2].wc = wc

    updaterequestedpublisher(icon1,icon2, surface)

end,

update_wc = function(icon1, icon2, wc, surface)
    if check_icon(icon1) == "error" then
        game.print("Remote update wait condition failed, icon " .. tostring(icon1) .. " invalid")
        return
    end
    if check_icon(icon2) == "error" then
        game.print("Remote update wait condition failed, icon " .. tostring(icon2) .. " invalid")
        return
    end
    if surface == nil then
        surface = "nauvis"
    end
    if check_priority(icon1, icon2, surface) == true then
        if wc.rb_or ~= nil then
            if wc.rb_or == true or wc.rb_or == false then
                global.newpriority[surface][icon1][icon2].wc.rb_or = wc.rb_or
                global.newpriority[surface][icon1][icon2].wc.rb_and = not(wc.rb_or)
            else
                game.print("rb_or requires boolean value, not " .. tostring(wc.rb_or))
                return
            end
        end
        if wc.rb_and ~= nil then
            if wc.rb_and == true or wc.rb_and == false then
                global.newpriority[surface][icon1][icon2].wc.rb_or = not(wc.rb_and)
                global.newpriority[surface][icon1][icon2].wc.rb_and = wc.rb_and
            else
                game.print("rb_and requires boolean value, not " .. tostring(wc.rb_and))
                return
            end
        end
        if wc.inc_ef ~= nil then
            if wc.inc_ef == true or wc.inc_ef == false then
                global.newpriority[surface][icon1][icon2].wc.inc_ef = wc.inc_ef
            else
                game.print("inc_ef requires boolean value, not " .. tostring(wc.inc_ef))
                return
            end
        end
        if wc.empty  ~= nil then
            if wc.empty == true or wc.empty == false then
                global.newpriority[surface][icon1][icon2].wc.empty = wc.empty
                global.newpriority[surface][icon1][icon2].wc.full = not(wc.empty)
            else
                game.print("empty requires boolean value, not " .. tostring(wc.empty))
                return
            end
        end
        if wc.full ~= nil then
            if wc.full == true or wc.full == false then
                global.newpriority[surface][icon1][icon2].wc.empty = not(wc.full)
                global.newpriority[surface][icon1][icon2].wc.full = wc.full
            else
                game.print("full requires boolean value, not " .. tostring(wc.full))
                return
            end
        end
        if wc.inactivity ~= nil then
            if wc.inactivity == true or wc.inactivity == false then
                global.newpriority[surface][icon1][icon2].wc.inactivity = wc.inactivity
            else
                game.print("inactivity requires boolean value, not " .. tostring(wc.inactivity))
                return
            end
        end
        if wc.inact_int ~= nil then
            if tonumber(wc.inact_int) then
                if wc.inact_int >= 0 then
                    global.newpriority[surface][icon1][icon2].wc.inact_int = wc.inact_int
                else
                    game.print("inact_int must be greater than 0, not " .. tostring(wc.inact_int))
                    return
                end
            else
                game.print("inact_int requires numeric value, not " .. tostring(wc.inact_int))
                return
            end
        end
        if wc.wait_timer ~= nil then
            if wc.wait_timer == true or wc.wait_timer == false then
                global.newpriority[surface][icon1][icon2].wc.wait_timer = wc.wait_timer
            else
                game.print("wait_timer requires boolean value, not " .. tostring(wc.wait_timer))
                return
            end
        end
        if wc.wait_int ~= nil then
            if tonumber(wc.wait_int) then
                if wc.wait_int >= 0 then
                    global.newpriority[surface][icon1][icon2].wc.wait_int = wc.wait_int
                else
                    game.print("wait_int must be greater than 0, not " .. tostring(wc.wait_int))
                    return
                end
            else
                game.print("wait_int requires numeric value, not " .. tostring(wc.wait_int))
                return
            end
        end
        if wc.count ~= nil then
            if wc.count == true or wc.count == false then
                global.newpriority[surface][icon1][icon2].wc.count = wc.count
            else
                game.print("count requires boolean value, not " .. tostring(wc.count))
                return
            end
        end
        if wc.count_amt ~= nil then
            if tonumber(wc.count_amt) then
                global.newpriority[surface][icon1][icon2].wc.count_amt = wc.count_amt
            else
                game.print("count_amt requires numeric value, not " .. tostring(wc.count_amt))
                return
            end
        end
        if wc.count_ddn ~= nil then
            if tonumber(wc.count_ddn) then
                global.newpriority[surface][icon1][icon2].wc.count_ddn = wc.count_ddn
            else
                game.print("count_ddn requires numeric value, not " .. tostring(wc.count_ddn))
                return
            end
        end
    else
        game.print("Priority " .. surface .. ":" .. icon1 .. ":" .. icon2 .. " not found")
    end
end,

append_station = function(icon1, icon2, stationlist, surface)
    if check_icon(icon1) == "error" then
        game.print("Remote append station failed, icon " .. icon1 .. " invalid")
        return
    end
    if check_icon(icon2) == "error" then
        game.print("Remote append station failed, icon " .. icon2 .. " invalid")
        return
    end
    if surface == nil then
        surface = "nauvis"
    end
    if check_priority(icon1, icon2, surface) then
        if global.newpriority[surface][icon1][icon2] ~= {} then
            global.newpriority[surface][icon1][icon2].station = global.newpriority[surface][icon1][icon2].station or {}
            local i = table_size(global.newpriority[surface][icon1][icon2].station) + 1
            if stationlist ~= nil then
                for _,station in pairs(stationlist) do
                    global.newpriority[surface][icon1][icon2].station[i] = {"",station}
                    i = i + 1
                end
            end

            updaterequestedpublisher(icon1,icon2, surface)
        else
            game.print("Priority " .. icon1 .. ":" .. icon2 .. " not found")
        end
    else
        game.print("Priority " .. surface .. ":" .. icon1 .. ":" .. icon2 .. " not found")
    end

end,

prepend_station = function(icon1, icon2, stationlist, surface)
    if check_icon(icon1) == "error" then
        game.print("Remote prepend station failed, icon " .. icon1 .. " invalid")
        return
    end
    if check_icon(icon2) == "error" then
        game.print("Remote prepend station failed, icon " .. icon2 .. " invalid")
        return
    end
    if surface == nil then
        surface = "nauvis"
    end
    if check_priority(icon1, icon2, surface) then
        global.newpriority[surface][icon1][icon2].station = global.newpriority[surface][icon1][icon2].station or {}
        local current_stations = table.deepcopy(global.newpriority[surface][icon1][icon2].station)
        local i = 1
        if stationlist ~= nil then
            for _,station in pairs(stationlist) do
                global.newpriority[surface][icon1][icon2].station[i] = {"",station}
                i = i + 1
            end
        end
        if current_stations ~= nil then
            for _,station in pairs(current_stations) do
                global.newpriority[surface][icon1][icon2].station[i] = station
                i = i + 1
            end
        end

        updaterequestedpublisher(icon1,icon2, surface)

    else
        game.print("Priority " .. icon1 .. ":" .. icon2 .. " not found")
    end
end
})

function check_icon(icon)
    local type = "error"
    if game.item_prototypes[icon] ~= nil then
        type = "item"
    elseif game.fluid_prototypes[icon] ~= nil then
        type = "fluid"
    elseif game.virtual_signal_prototypes[icon] ~= nil then
        type = "virtual"
    end
    return type
end

function check_priority(icon1, icon2, surface)
    local check = false
    if global.newpriority[surface] ~= nil then
    if global.newpriority[surface][icon1] ~= nil then
    if global.newpriority[surface][icon1][icon2] ~= nil then
        check = true
    end
    end
    end
    return check
end
