local goldChest = "expandedstorage:gold_chest"
--position of turtle based on flat plane, so x and y is used, no depth axis.
local turtle_position = {0,0}

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

--determines if turtle has an satisfactory amount of fuel before it can run
function determine_fuel_state()
	local start = true
	local fuel_amt = turtle.getFuelLevel()
	if fuel_amt < 100 then
		print("This turtle doesn't have enough fuel.")
		start = false
		return start
	end

	print("Fuel Level: " .. fuel_amt)
	return start
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
	print("Length: " .. length)
	print("Width: " .. width)
	return length, width
end


function return_to_zero_zero()
	for xPos = 1, math.abs(turtle_position[1]) do
		if (turtle_position[1] > 0) then
			turtle.forward()
			change_position("s")
		elseif (turtle_position[1] < 0) then
			turtle.back()
			change_position("n")
		end
	end
	for yPos = 1, math.abs(turtle_position[2]) do
		if (turtle_position[2] > 0) then
			--CURRENT DIRECTION: WEST
			turtle.turnRight()
			turtle.forward()
			change_position("w")
		elseif (turtle_position[1] < 0) then
			--CURRENT DIRECTION: EAST
			turtle.turnLeft()
			turtle.forward()
			change_position("e")
		end
	end
	print("Returned to origin")
end


function farming_main(length, width)
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
		local moving_east = true
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
			if (c ~= length) then
				turtle.forward()
				change_position("e")
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

	if (r == width and width % 2 == 0) then
		--CURRENT DIRECTION: SOUTH
		turtle.turnLeft()
	elseif (r == width and width % 2 == 1) then
		--CURRENT DIRECTION: SOUTH
		turtle.turnRight()
	end
end


--main function to load up methods
function main()
	start = determine_fuel_state()
	if start then
		-- local length, width = map_out_perimeter()
		local length = 12
		local width = 14
		farming_main(length, width)
		return_to_zero_zero()
	end
end

main()