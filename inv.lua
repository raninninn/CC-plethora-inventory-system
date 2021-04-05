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
    if input == "rebuild" then
        local sOut = ""
        local count = {}
        local maxb = 1
		local tStore = {}
        for k,chest in pairs(tChests) do
            local a = chest.list()

            for i=1, #a do
                if a[i] ~= nil then
                    local id = chest.getItemMeta(i).rawName
                    if tStore[id] ~= nil then
                        tStore[id]["count"] = chest.getItemMeta(i).count + b[id]
                    else
                        tStore[id]["count"] = chest.getItemMeta(i).count
						tStore[id]["dispName"] = chest.getItemMetat(i).displayName
						tStore[id]["chest"] = chest
						tStore[id]["slot"] = i
                    end
                
                    if string.len( tostring(tStore[id]["count"]) ) > maxb then
                        maxb = string.len( tostring(tStore[id]["count"]) )
                    end
                end
            end
			-- Make string out of table
			for key,value in pairs(tStore) do
				local padding = ""
				for j=1 , maxb - bid_len do
					padding = padding .. " "
				end
				sOut = sOut..padding..tStore[key]["count"] .."  ".. tStore[key]["dispName"].."\n"
			end
--            for i=1, #tStore do
  --              if a[i] ~= nil then
    --                local name = tStore[1]
      --              local id = chest.getItemMeta(i).rawName
        --            local bid_len = string.len( tostring(b[id]) )
          --          
            --        local padding = ""
              --      
                --    if sOut:match(name) == nil then
                  --      for j=1, maxb-bid_len do
                    --        padding = padding .. " "
                      --  end
--                        sOut = sOut..padding..b[id] .."  ".. name.."\n"
  --                  end
    --            end
       --     end
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
    if input == "help" then
        print("help: prints this help message")
        print("ls: prints out the contents of the item database")
        print("rebuild: rebuilds the item database")
        print("quit: quits the shell")
    end
end

repeat main() until bRunning == false
