-- Configuration
local chest0 = peripheral.wrap("minecraft:ironchest_iron_0")
local chest1 = peripheral.wrap("minecraft:ironchest_copper_5")

local tChests = {chest0, chest1}

local inv_dir = "/inventory/"

-- Main code

local bRunning = true
local defCol = term.getTextColour()
-- Create working directory, if it doesn't exist
if fs.isDir(inv_dir) == false then
	fs.makeDir(inv_dir)
end

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
                        tStore[id]["count"] = chest.getItemMeta(i).count + tStore[id]["count"]
                    else
						tStore[id] = {}
                        tStore[id]["count"] = chest.getItemMeta(i).count
						tStore[id]["dispName"] = chest.getItemMeta(i).displayName
						tStore[id]["chest"] = peripheral.getName(chest)
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
				local sCount = tostring( tStore[key]["count"] )
				local sCountLen = string.len(sCount)
				for j=1 , maxb - sCountLen do
					padding = padding .. " "
				end
				sOut = sOut..padding..tStore[key]["count"] .."  ".. tStore[key]["dispName"].."\n"
			end
        end
        textutils.pagedPrint(sOut)
		-- Write stringified table to "item_catalogue"
        local sFile = fs.open(inv_dir .. "item_catalogue", "w")
        sFile.write(sOut)
		sFile.flush()
		sFile.close()
		-- Write table to "item_table"
		local tFile = fs.open(inv_dir .. "item_table", "w")
		tFile.write(tStore)
		tFile.flush()
		tFile.close()
    elseif input == "quit" then
        bRunning = false
    elseif input == "ls" then
        local sFile = fs.open(inv_dir .. "item_catalogue", "r")
        textutils.pagedPrint(sFile.readAll())
    elseif input == "help" then
        print("help: prints this help message")
        print("ls: prints out the contents of the item database")
        print("rebuild: rebuilds the item database")
        print("quit: quits the shell")
    else
		term.setTextColour( colours.red )
		print("invalid command: " .. input .. "\nTry `help` for more information.")
		term.setTextColour( defCol )
	end
end

repeat main() until bRunning == false
