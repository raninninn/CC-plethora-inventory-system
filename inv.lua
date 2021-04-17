-- Configuration
local chest0 = peripheral.wrap("minecraft:ironchest_iron_0")
local chest1 = peripheral.wrap("minecraft:ironchest_copper_5")

local io_drive = "drive_0"

local tChests = {chest0, chest1}

local inv_dir = "/inventory/"

---- Main code ----

local w,h = term.getSize()
local bRunning = true
local defCol = term.getTextColour()
local suck = false

-- Create working directory, if it doesn't exist
if fs.isDir(inv_dir) == false then
	fs.makeDir(inv_dir)
end

local function loadItemTable()
	if not fs.exists(inv_dir.."item_table")
	or fs.isDir(inv_dir.."item_table")
	or fs.isReadOnly(inv_dir.."item_table")
	then
		return _,"Error reading "..inv_dir.."item_table"
	end
	local tItemFile = fs.open(inv_dir.."item_table", "r")
	local tItemFileContents = tItemFile.readAll()
	return textutils.unserialise( tItemFileContents )
end

-- Load item table
local tStore,err = loadItemTable()
if tStore == nil then
	tStore = {}
	term.setTextColor( colors.red )
	print( err.."\nContinue anyway? (y/N)" )
	term.setTextColor( colors.white )
	local r = read()
	if r:lower() ~= "y" then
		return
	end
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
		tStore = {}

		-- Progress bar initialization
		term.setCursorPos(w-1, h-1)
		term.write("|")
		term.setCursorPos(2, h-1)
		term.write("|")
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
			-- Progress bar
			for i=1, math.max( (w-3)/#tChests ) do
				term.write("#")
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
		tFile.write(textutils.serialise( tStore ))
		tFile.flush()
		tFile.close()
    elseif input == "quit" then
        bRunning = false
    elseif input == "ls" then
        local sFile = fs.open(inv_dir .. "item_catalogue", "r")
		if sFile ~= nil then
	        textutils.pagedPrint(sFile.readAll())
		else
			print("Couldn't list item catalogue. Please `rebuild`.")
		end
    elseif input == "help" then
        print("help:     prints this help message")
        print("ls:       prints out the contents of the item database")
        print("rebuild:  rebuilds the item database")
		print("suck:     suck the items in `io_drive` into the chests")
		print("suck-on:  sucks all items in `io_drive` into the chests until turned off")
		print("suck-off: see `suck-on`")
        print("quit:     quits the shell")
    elseif input == "suck" then
		for key, chest in pairs(tChests) do
			for i=1, peripheral.wrap(io_drive).size() do
				chest.pullItems(io_drive, i)
			end
		end
	elseif input == "suck-on" then
		suck = true
	elseif input == "suck-off" then
		suck = false 
	else
		term.setTextColour( colours.red )
		print("invalid command: " .. input .. "\nTry `help` for more information.")
		term.setTextColour( defCol )
	end
end

local function cSuck()
	if suck == true then
		for key, chest in pairs(tChests) do
			for i=1, peripheral.wrap(io_drive).size() do
				chest.pullItems(io_drive, i)
			end
		end
	else
		sleep(0.1)
	end
end

parallel.waitForAny( 
	function () 
		repeat main() until bRunning == false end,
	function ()
		repeat cSuck() until bRunning == false end
)
