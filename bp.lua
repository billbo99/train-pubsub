script.on_event(defines.events.on_player_setup_blueprint, function(event)
    --    game.print("In BP setup")
    storage.player = storage.player or {}
    storage.player[event.player_index] = storage.player[event.player_index] or {}
    storage.player[event.player_index].bp = {}
    for idx, entity in pairs(event.mapping.get()) do
        if entity.name == "train-publisher" then
            storage.player[event.player_index].bp = storage.player[event.player_index].bp or {}
            storage.player[event.player_index].bp[idx] = entity
            --    game.print(entity.unit_number)
        end
    end
end)

script.on_event(defines.events.on_player_configured_blueprint, function(event)
    --   game.print("In BP configured")
    local status, err = pcall(function()
        local player = game.players[event.player_index]
        local stack = player.cursor_stack
        if stack.valid == true then
            if stack.is_blueprint == true then
                --    game.print("BP held")
                for idx, bp_entity in pairs(storage.player[event.player_index].bp) do
                    --     game.print(idx .. " :  " .. bp_entity.unit_number)
                    for i, entity in pairs(storage.newpublishers[player.surface.name]) do
                        for j, res_entity in pairs(entity) do
                            if res_entity.entity.unit_number == bp_entity.unit_number then
                                --    game.print("entity =  bp entity")
                                stack.set_blueprint_entity_tags(idx, {
                                    resource = res_entity.priority.resource,
                                    id = res_entity.priority.id,
                                    hide = res_entity.hide,
                                    proc_priority = res_entity.proc_priority
                                })
                                break
                            end
                        end
                    end
                end
            end
        end
    end)
    if not status then
        game.print("Blueprint changed - Requester's details not saved")
    end
end)