-- enables the transfer of priorities between surfaces and across saves
local function priority_shortcut(event)
    local prototype = event.prototype_name
	if prototype ~= "TSM-priority-transfer" then return end
    local gui = game.players[event.player_index].gui.screen
    local frame = gui.prioritytfr_frame
    if frame then
        frame.destroy()
        return
    end
    frame = gui.add{
        type = "frame",
        name = "prioritytfr_frame",
        direction = "vertical",
        caption = {"prioritytfr-title"}
 --       style = mod_gui.frame_style
    }
    frame.location = {200,200}
    local flow = frame.add{type = "flow", name = "flow", direction = "vertical"}
 --   flow.add{type = "label", caption = {"exclusion-title"}}
 --   flow.drag_target = frame
    local scroll = flow.add{type = "scroll-pane", name = "priscroll"}
    prioritytfr_detail(game.players[event.player_index])
end

function prioritytfr_detail(player)
    local scroll = player.gui.screen.prioritytfr_frame.flow.priscroll
    scroll.add{type="label", name="surface_copy", caption="Surface to surface copy"}
    local transfer = scroll.add{type = "table", name = "transfer_pri", column_count = 4, style = "PubSub_table_style"}
    local surface_sel = {}
    for _,surface in pairs(game.surfaces) do
        table.insert(surface_sel,{"",surface.name})
    end
    transfer.add{type="drop-down", name="from_surface", caption="From", items=surface_sel, selected_index=1}
    transfer.add{type="label", name="to", caption="to"}
    transfer.add{type="drop-down", name="to_surface", caption="To", items=surface_sel, selected_index=1}
    transfer.add{type="sprite-button", name="surface_copy", sprite="train_manager", tooltip={"gui-trainps.execute"}}
    scroll.add{type="label", name="surface_delete", caption="Surface Priorities Delete"}
    local delete = scroll.add{type = "table", name = "delete_pri", column_count = 2, style = "PubSub_table_style"}
    delete.add{type="drop-down", name="delete_surface", caption="Delete", items=surface_sel, selected_index=1}
    delete.add{type="sprite-button", name="surface_delete", sprite="train_manager", tooltip={"gui-trainps.execute"}}
    scroll.add{type="label", name="surface_export", caption="Surface Priorities Export to file"}
    local export = scroll.add{type = "table", name = "export_pri", column_count = 3, style = "PubSub_table_style"}
    export.add{type="drop-down", name="export_surface", caption="Export", items=surface_sel, selected_index=1}
    export.add{type="textfield", name="export_filename"}
    export.add{type="sprite-button", name="surface_export", sprite="train_manager", tooltip={"gui-trainps.execute"}}
    scroll.add{type="label", name="surface_import", caption="Surface Priorities Import from file"}
    local import = scroll.add{type = "table", name = "import_pri", column_count = 3, style = "PubSub_table_style"}
    import.add{type="drop-down", name="import_surface", caption="Export", items=surface_sel, selected_index=1}
    import.add{type="textfield", name="import_filename"}
    import.add{type="sprite-button", name="surface_import", sprite="train_manager", tooltip={"gui-trainps.execute"}}
end

local function safe_priority_import(file,to_surface)
    for icon1,surf in pairs(file) do
        for icon2,surface in pairs(surf) do
            remote.call("TSM-API","define_new_priority",icon1,icon2,{},to_surface)
            if surface.wc ~= nil then
                remote.call("TSM-API","update_wc",icon1,icon2,surface.wc,to_surface)
              else
                game.print(icon1 .. icon2 .. " wc is nil")
              end
        end
    end
end

function surface_copy(event)
    local player = game.players[event.player_index]
    local scroll = player.gui.screen.prioritytfr_frame.flow.priscroll
    local from_surface = game.surfaces[scroll.transfer_pri.from_surface.selected_index].name
    local to_surface = game.surfaces[scroll.transfer_pri.to_surface.selected_index].name
    if from_surface == to_surface then
        player.print("Priority copy needs different from and to surfaces")
        return
    end
    game.print("found index " .. from_surface)
    safe_priority_import(global.newpriority[from_surface], to_surface)
    -- for icon1,surf in pairs(global.newpriority[from_surface]) do
    --     for icon2,surface in pairs(surf) do
    --     -- game.print(surface.resource.name .. icon1)
    --     -- game.print(surface.id.name .. icon2)
    -- --    local stationlist = table.deepcopy(surface.station)
    -- --    local wc = table.deepcopy(surface.wc)
    --     remote.call("TSM-API","define_new_priority",icon1,icon2,{},to_surface)
    --  --
    --   --  game.write_file("wc",serpent.block(surface.wc),{comment=false})
    --   if surface.wc ~= nil then
    --     remote.call("TSM-API","update_wc",icon1,icon2,surface.wc,to_surface)
    --   else
    --     game.print(icon1 .. icon2 .. " wc is nil")
    --   end
    --     end
    -- end
end
function surface_delete(event)
    local player = game.players[event.player_index]
    local scroll = player.gui.screen.prioritytfr_frame.flow.priscroll
    local delete_surface = game.surfaces[scroll.delete_pri.delete_surface.selected_index].name
    if player.admin ~= true then
        player.print("Deletion of priority list is for admins only")
        return
    end
  --  game.write_file("pre-delete-priority",serpent.block(global.newpriority),{comment=false})
    global.newpriority[delete_surface] = {}
end

function surface_export(event)
    local player = game.players[event.player_index]
    local scroll = player.gui.screen.prioritytfr_frame.flow.priscroll
    local export_surface = game.surfaces[scroll.export_pri.export_surface.selected_index].name
    local export_file = scroll.export_pri.export_filename.text
    game.write_file(export_file, game.encode_string(game.table_to_json(global.newpriority[export_surface])), false, event.player_index)
    player.print("Saved to script-output/" .. export_file)
end

function surface_import(event)
    local player = game.players[event.player_index]
    local scroll = player.gui.screen.prioritytfr_frame.flow.priscroll
    if player.admin ~= true then
        player.print("Import of priority list is for admins only")
        return
    end
    local import_surface = game.surfaces[scroll.import_pri.import_surface.selected_index].name
    local import_file = scroll.import_pri.import_filename.text
    game.print(import_file)
 --   local file = io.open(import_file, "rb")
    if game.decode_string(import_file) then
        local tmp_table = game.json_to_table(game.decode_string(import_file))
        if type(tmp_table) == "table" then
            global.newpriority = global.newpriority or {}
            global.newpriority[import_surface] = {}
            safe_priority_import(tmp_table, import_surface)
         --   global.newpriority[import_surface] = tmp_table
            player.print("Import Complete")
        else
            game.print("File not table")
        end
    else
        game.print("Cannot decode file")
    end
end

script.on_event( defines.events.on_lua_shortcut, priority_shortcut )
