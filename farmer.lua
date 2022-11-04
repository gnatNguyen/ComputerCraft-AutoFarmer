local goldChest = "expandedstorage:gold_chest"
--position of turtle based on flat plane, so x and y is used, no depth axis.
local turtle_position = {0,0}


function change_position(direction)
	if (direction == "n") then
		turtle_position[0] = turtle_position[0] + 1
	elseif (direction == "s") then
		turtle_position[0] = turtle_position[0] - 1
	elseif (direction == "e") then
		turtle_position[1] = turtle_position[1] + 1
	elseif (direction == "w") then
		turtle_position[1] = turtle_position[1] - 1
	end
end

function find_item_slot(item)
	for slot = 1, slot < 16 do
		turtle.select(slot)
		item_in_slot = turtle.getItemDetail()
		if item_in_slot ~= nil then
			if string.find(item_in_slot.name, item_name) ~= nil then
				return slot
			end
		end
	return nil
end

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


function map_out_perimeter()
	local length = 0
	local width = 0
	turtle.foward()
	change_position("n")
	turtle.turnLeft()

	local corner = 1
	while (corner <= 4) do
		turtle.foward()
		if (corner == 1) then
			change_position("w")
		elseif (corner == 2) then
			change_position("n")
		elseif (corner == 3) then
			change_position("e")
		elseif (corner == 4) then
			change_position("s")
		end
		state, data = turtle.inspectDown()
		if (state == false) then
			turtle.back()
			if (corner == 1) then
				change_position("e")
				length = math.abs(turtle_position[1])
			elseif (corner == 2) then
				change_position("s")
				width = math.abs(turtle_position[0])
			elseif (corner == 3) then
				change_position("w")
			elseif (corner == 4) then
				change_position("n")
			end
			turtle.turnRight()
			corner = corner + 1
		end
	end

	while (turtle_position[1] ~= 0) do
		turtle.foward()
		change_position("w")
	end
	print("Length: " .. length)
	print("Width: " .. width)
	return length, width
end