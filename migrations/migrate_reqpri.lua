log("TSM requester priority migration run")
-- surface backer name i
storage.newpublishers = storage.newpublishers or {}
for _, surface in pairs(game.surfaces) do
    if storage.newpublishers[surface.name] ~= nil then
        for station, publishers in pairs(storage.newpublishers[surface.name]) do
            for i, publisher in pairs(publishers) do
                if publisher.proc_priority == nil then
                    publisher.proc_priority = 1
                    log(station .. " was nil")
                end
                if publisher.proc_priority <= 50 then
                    publisher.proc_priority = publisher.proc_priority + 49
                    log(station .. " priority now " .. publisher.proc_priority)
                else
                    publisher.proc_priority = 99
                end
            end
        end
    end
end