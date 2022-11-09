local goldChest = "expandedstorage:gold_chest"
local water = "minecraft:water"
--position of turtle based on flat plane, so x and y is used, no depth axis.
local turtle_position = {0,0}
local runs = 0

--changes the x or y position of the turtle based on direction it travels
function change_position(direction)
	if (direction == "n") then
		turtle_position[1] = turtle_position[1] + 1
	elseif (direction == "s") then
		turtle_position[1] = turtle_position[1] - 1
	elseif (direction == "e") then
		turtle_position[2] = turtle_position[2] + 1
	elseif (direction == "w") then
		turtle_position[2] = turtle_position[2] - 1
	end

end

--returns the slot or nil or an inputted item from inventory
function find_item_slot(item)
	for slot = 1, 16 do
		turtle.select(slot)
		item_in_slot = turtle.getItemDetail()
		if item_in_slot ~= nil then
			if string.find(item_in_slot.name, item) == 1 then
				return slot
			end
		end
	end
end


function pit_stop(length, width)
	local current_fuel = turtle.getFuelLevel()
	local area = length * width
	if current_fuel < area then
		local amt_coal = math.ceil(((area-current_fuel) + 300)/80)
		turtle.select(1)
		turtle.suckDown()
		local item = turtle.getItemDetail()
		if (item ~= nil) then
			if (item.count >= amt_coal) then
				turtle.refuel(amt_coal)
				turtle.dropDown()
			else
				print("---------OUT OF FUEL----------")
				turtle.dropDown()
				os.exit()
			end
		end
	end
end

--turtle runs around the perimeter of the area to determine length and width
--returns length and width
function map_out_perimeter()
	local length = 0
	local width = 0
	turtle.forward()
	change_position("n")
	turtle.turnLeft()

	local corner = 1
	while (corner <= 4) do
		turtle.forward()
		if (corner == 1) then
			change_position("w")
		elseif (corner == 2) then
			change_position("n")
		elseif (corner == 3) then
			change_position("e")
		elseif (corner == 4) then
			change_position("s")
		end
		local state, data = turtle.inspectDown()
		if (state == false) then
			turtle.back()
			if (corner == 1) then
				change_position("e")
				length = math.abs(turtle_position[2])
			elseif (corner == 2) then
				change_position("s")
				width = math.abs(turtle_position[1])
			elseif (corner == 3) then
				change_position("w")
			elseif (corner == 4) then
				change_position("n")
			end
			turtle.turnRight()
			corner = corner + 1
		end
	end
	while (turtle_position[2] ~= 0) do
		length = length + 1
		turtle.forward()
		change_position("w")
	end
	turtle.turnRight()
	turtle.back()
	change_position("s")
	length = length + 1
	return length, width
end


function return_to_zero_zero(moving_east)
	for xPos = 1, math.abs(turtle_position[1]) do
		if (turtle_position[1] > 0) then
			turtle.forward()
			change_position("s")
		elseif (turtle_position[1] < 0) then
			turtle.back()
			change_position("n")
		end
	end

	if (moving_east == false) then
		--CURRENT DIRECTION: WEST
		turtle.turnRight()
	elseif (moving_east) then
		--CURRENT DIRECTION: EAST
		turtle.turnLeft()
	end

	for yPos = 1, math.abs(turtle_position[2]) do
		if (moving_east == false) then
			--CURRENT DIRECTION: WEST
			turtle.forward()
			change_position("w")
		elseif (moving_east) then
			--CURRENT DIRECTION: EAST
			turtle.forward()
			change_position("e")
		end
	end

	if (moving_east == false) then
		--CURRENT DIRECTION: NORTH
		turtle.turnRight()
	elseif (moving_east) then
		--CURRENT DIRECTION: NORTH
		turtle.turnLeft()
	end

	runs = runs + 1
	term.setCursorPos(1,4)
	print("           -" .. runs .. " RUNS COMPLETED-")
end


function dump_inv()
	for slot = 1, 16 do
		turtle.select(slot)
		local item_in_slot = turtle.getItemDetail()
		if (item_in_slot ~= nil) then
			turtle.dropDown(item_in_slot.count)
		end
	end
end


function farming_main(length, width)
	local moving_east = true
	--travels to first corner
	--will be at bottom left of farm after first while
	--CURRENT DIRECTION: WEST
	turtle.forward()
	change_position("n")
	turtle.turnLeft()
	while true do
		local state, data = turtle.inspectDown()
		if (state == true) then
			turtle.forward()
			change_position("w")
		elseif (state == false) then
			turtle.back()
			change_position("e")
			--CURRENT DIRECTION: NORTH
			turtle.turnRight()
			--CURRENT DIRECTION: EAST
			turtle.turnRight()
			break
		end
	end
	for r = 1, width do
		if (r % 2 == 1) then
			moving_east = true
		elseif (r % 2 == 0) then
			moving_east = false
		end

		for c = 1, length do
			local state, data = turtle.inspectDown()
			if (state == true) then
				if (data.state.age == 7) then
					local crop_slot = 0
					turtle.digDown()
					if (data.name == "minecraft:wheat") then
						crop_slot = find_item_slot("minecraft:wheat_seeds")
					elseif (data.name == "minecraft:potatoes") then
						crop_slot = find_item_slot("minecraft:potato")
					elseif (data.name == "minecraft:carrots") then
						crop_slot = find_item_slot("minecraft:carrot")
					end
					turtle.select(crop_slot)
					turtle.placeDown()
				end
			end
			if (c ~= length and moving_east) then
				turtle.forward()
				change_position("e")
			elseif (c ~= length and moving_east == false) then
				turtle.forward()
				change_position("w")
			end
		end
		if (moving_east and r ~= width) then
			turtle.turnLeft()
			turtle.forward()
			change_position("n")
			turtle.turnLeft()
		elseif (moving_east == false and r ~= width) then
			turtle.turnRight()
			turtle.forward()
			change_position("n")
			turtle.turnRight()
		end
	end

	if (width % 2 == 0) then
		--CURRENT DIRECTION: SOUTH
		turtle.turnLeft()
	elseif (width % 2 == 1) then
		--CURRENT DIRECTION: SOUTH
		turtle.turnRight()
	end

	return_to_zero_zero(not moving_east)
end


--will run if turtle get chunk unloaded and turns off
--useful when turtle is stuck in middle and has to be started
function startup()
	local state, data = turtle.inspectDown()
	while true do
		if (state == false) then
			turtle.down()
			state, data = turtle.inspectDown()
			if state then
				if (data.name == water) then
					turtle.up()
					turtle.forward()
				else
					turtle.turnLeft()
					break
				end
			end
		elseif (data.name == goldChest) then
			turtle.turnLeft()
			turtle.turnLeft()
			return
		else
			turtle.forward()
		end
		state, data = turtle.inspectDown()
	end
	while true do
		state, data = turtle.inspect()
		if state then
			if (data.name == goldChest) then
				turtle.up()
				turtle.forward()
				turtle.turnLeft()
				break
			end
		end
		turtle.forward()
		turtle.turnLeft()
		state, data = turtle.inspect()
		if (state) then
			turtle.turnRight()
			
		end
	end
end


--main function to load up methods
function main()
	local state, data = turtle.inspectDown()
	if (data.name ~= goldChest) then
		startup()
	end
	turtle.suckDown()
	turtle.refuel(2)
	turtle.dropDown()
	local length, width = map_out_perimeter()
	term.clear()
	term.setCursorPos(1,1)
	print("------------FARMING**TURTLE------------")
	while true do
		term.setCursorPos(1,2)
		pit_stop(length, width)
		farming_main(length, width)
		dump_inv()
		print("         -TAKING A BREAK-")
		sleep(60)
	end
end

main()