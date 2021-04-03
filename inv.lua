chest0 = peripheral.wrap("minecraft:ironchest_iron_0")
chest1 = peripheral.wrap("minecraft:ironchest_copper_5")
bRunning = true

local tChests = {chest0, chest1}

local function main()
    -- Prompt
    write("? ")
    input = io.read()
    input = input:gsub("%s+", "")
    
    -- Commands
    if input == "cat" then
        local sOut = ""
        local b = {}
        local maxb = 1
        for k,chest in pairs(tChests) do
            local a = chest.list()
                  
            for i=1, #a do
                if a[i] ~= nil then
                    local id = chest.getItemMeta(i).rawName
                    if b[id] ~= nil then
                        b[id] = chest.getItemMeta(i).count + b[id]
                    else
                        b[id] = chest.getItemMeta(i).count
                    end
                
                    if string.len( tostring(b[id]) ) > maxb then
                        maxb = string.len( tostring(b[id]) )
                    end
                end
            end
            for i=1, #a do
                if a[i] ~= nil then
                    local name = chest.getItemMeta(i).displayName
                    local id = chest.getItemMeta(i).rawName
                    local bid_len = string.len( tostring(b[id]) )
                    
                    local padding = ""
                    
                    if sOut:match(name) == nil then
                        for j=1, maxb-bid_len do
                            padding = padding .. " "
                        end
                        sOut = sOut..padding..b[id] .."  ".. name.."\n"
                    end
                end
            end
        end
        textutils.pagedPrint(sOut)
        local file = fs.open("item_catalogue", "w")
        file.write(sOut)
    end
    if input == "quit" then
        bRunning = false
    end
    if input == "ls" then
        local file = fs.open("item_catalogue", "r")
        textutils.pagedPrint(file.readAll())
    end
end

repeat main() until bRunning == false