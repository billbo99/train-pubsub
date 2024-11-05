commands.add_command("CreateIndex", { "createindex_help" }, function(event)
    storage.sub_index = {}
    storage.subscriptions = storage.subscriptions or {}
    -- storage.subscriptions now keyed by train
    for i, subs in pairs(storage.subscriptions) do
        if storage.sub_index[subs.backer_name] == nil then
            -- storage.sub_index[subs.backer_name] = subs.train.id
            storage.sub_index[subs.backer_name] = i
            -- debugp(subs.backer_name .. " : " .. storage.sub_index[subs.backer_name])
        end
    end
end)

commands.add_command("trainInfo", { "trainInfo_help" }, function(event)
    local player = game.players[event.player_index]
    storage.trains = {}

    for _, surface in pairs(game.surfaces) do
        local trains = game.train_manager.get_trains({ surface = surface.name })
        for _, train in pairs(trains) do
            storage.trains[train.id] = train
        end
    end
    player.print(table_size(storage.trains) .. " train(s) discovered")
end)

commands.add_command("debug_on", { "trainInfo_help" }, function(event)
    storage.db_on = true
end)

commands.add_command("debug_off", { "trainInfo_help" }, function(event)
    storage.db_on = false
end)

commands.add_command("Get_requests_file", { "get requests file help" }, function(event)
    helpers.write_file("requests_log.json", serpent.block(storage.newrequests), false, event.player_index)
    game.players[event.player_index].print("requests_log.json saved")
end)

commands.add_command("Get_sub_index", { "get sub index help" }, function(event)
    helpers.write_file("sub_index.json", serpent.block(storage.sub_index), false, event.player_index)
    game.players[event.player_index].print("sub_index.json saved")
end)

commands.add_command("Get_trains", { "get trains help" }, function(event)
    helpers.write_file("trains.json", serpent.block(storage.trains), false, event.player_index)
    game.players[event.player_index].print("trains.json saved")
    helpers.write_file("trains_res.json", serpent.block(storage.train_res), false, event.player_index)
    game.players[event.player_index].print("trains_res.json saved")
end)

commands.add_command("TSM_Dump_Storage", { "" }, function(event)
    helpers.write_file("tsm_storage.json", serpent.block(storage), false, event.player_index)
end)

commands.add_command("Get_pslogs", { "get pslogs help" }, function(event)
    helpers.write_file("trainpubs.json", serpent.block(storage.publishers), false, event.player_index)
    helpers.write_file("trainnewpubs.json", serpent.block(storage.newpublishers), false, event.player_index)
    helpers.write_file("trainreqs.json", serpent.block(storage.requests), false, event.player_index)
    helpers.write_file("trainnewreqs.json", serpent.block(storage.newrequests), false, event.player_index)
    helpers.write_file("trainpriorities.json", serpent.block(storage.priority), false, event.player_index)
    helpers.write_file("trainnewpriorities.json", serpent.block(storage.newpriority), false, event.player_index)
    helpers.write_file("counters.json", serpent.block(storage.newcounters), false, event.player_index)
    --    helpers.write_file("subscriptions",serpent.block(storage.counters),{comment=false})
    game.players[event.player_index].print("json files saved")
end)


commands.add_command("rebuild_trains", { "rebuild_trains_help" }, function(event)
    storage.trains = {}
    for _, surface in pairs(game.surfaces) do
        local trains = game.train_manager.get_trains({ surface = surface.name })
        for i, train in pairs(trains) do
            storage.trains[train.id] = train
        end
    end
    game.players[event.player_index].print(table_size(storage.trains) .. " train(s) indexed")
end)

commands.add_command("Get_pubstops", { "get pubstops help" }, function(event)
    helpers.write_file("pubstops.json", serpent.block(storage.pubstops), false, event.player_index)
    game.players[event.player_index].print("pubstops.json saved")
end)

commands.add_command("fix_ps_stations", { "fix ps stations help" }, function(event)
    local x = 0
    x = fix_ps_stations()
    if x ~= nil then
        game.players[event.player_index].print(x .. " nil stations removed")
    else
        game.players[event.player_index].print("0 nil stations removed")
    end
end)

commands.add_command("reset", { "reset_help" }, function(event)
    game.players[event.player_index].print("reset is redacted - use /tsm_reset")
end)

commands.add_command("tsm_reset", { "reset_help" }, function(event)
    reset_requests()
    reset_trains()
end)

commands.add_command("tsm_export", "Export Supply Source Priorities", function(event)
    local player = game.players[event.player_index]
    helpers.write_file("tsm_export.txt", helpers.encode_string(helpers.table_to_json(storage.newpriority)), false,
        event.player_index)
    player.print("Saved to script-output\tsm_export.txt")
end)

commands.add_command("tsm_import", "Import Supply Source Priorities", function(event)
    local player = game.players[event.player_index]
    if player.admin and event.parameter then
        local decode_string = helpers.decode_string(event.parameter)
        if decode_string then
            local tmp_table = helpers.json_to_table(decode_string)
            if type(tmp_table) == "table" then
                storage.newpriority = tmp_table
                player.print("Import Complete")
            end
        else
            player.print("/tsm_import blueprint_string")
        end
    else
        game.print(string.format("%s tried to import a TSM configuration as a non-admin", player.name))
    end
end)

commands.add_command("tsm_remove_dup_rq", "Remove Duplicate Requesters", function(event)
    local player = game.players[event.player_index]
    for surface in pairs(storage.newpublishers) do
        if storage.newpublishers[surface] and table_size(storage.newpublishers[surface]) > 0 then
            for i, pub in pairs(storage.newpublishers[surface]) do
                if tonumber(i) ~= nil then
                    player.print(i)
                    helpers.write_file("curr_pub.json", serpent.block(pub), false, event.player_index)
                    if pub == nil then
                        player.print(i .. " removed")
                        table.remove(storage.newpublishers[surface], i)
                    elseif pub.backer_name == i then
                        local entity = pub.entity
                        player.print(pub.entity.unit_number)
                        --	for j,kpub in pairs()
                    end
                end
            end
        end
    end
end)