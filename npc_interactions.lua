--NPC handlers/packets

--Packet globals
__busy = false
__get_packet_sequence = {}
__get_keypress_sequence = {}
__get_menu_id = 0
__get_npc_name = ''
__received_response = false
__trade = false
__poke = false
__enough_currency = false
__currency_amount = 0

__npc_dialog = false

--Shop globals
__get_shop_slot = 0
__get_shop_item_count = 0
__shop_busy = false
__shop_packet = false
__shop_opened = false

local conquest_counter = 0
local update_render = 0
function handle_incoming_chunk(id, data, mod, inj, blk)
    if id == 0x028 then	-- Casting
        local action_message = packets.parse('incoming', data)
		if action_message["Category"] == 4 then
			isCasting = false
		elseif action_message["Category"] == 8 then
			isCasting = true
		end
	elseif id == 0x02A then
		local packet = packets.parse('incoming', data)
		if packet and packet['Message ID'] == 39994 and packet['Player'] == player.id then	-- Sortie points
			if not __processedSequences[packet['_sequence']] then
				__processedSequences[packet['_sequence']] = true
				if __playerData[player.name] then
					__playerData[player.name]['Gall'] = __playerData[player.name]['Gall'] + packet['Param 1']
					updateStatus('caller')
				end
			end
		elseif packet and packet['Message ID'] == 40005 and packet['Player'] == player.id then	-- Odyssey points
			if not __processedSequences[packet['_sequence']] then
				__processedSequences[packet['_sequence']] = true
				if __playerData[player.name] then
					__playerData[player.name]['Segs'] = __playerData[player.name]['Segs'] + packet['Param 1']
					updateStatus('caller')
				end
			end
		elseif packet and packet['Message ID'] == 39862 and packet['Player'] == player.id then	-- Ambu hallmarks
			if not __ambuHMSequences[packet['_sequence']] then
				__ambuHMSequences[packet['_sequence']] = true
				if __playerData[player.name] then
					--__playerData[player.name]['HM'] = __playerData[player.name]['HM'] + packet['Param 1']
					__playerData[player.name]['HM'] = packet['Param 2']
					updateStatus('caller')
				end
			end
		elseif packet and packet['Message ID'] == 39863 and packet['Player'] == player.id then	-- Ambu gallantry
			if not __ambuGLSequences[packet['_sequence']] then
				__ambuGLSequences[packet['_sequence']] = true
				if __playerData[player.name] then
					--__playerData[player.name]['GL'] = __playerData[player.name]['GL'] + packet['Param 1']
					__playerData[player.name]['GL'] = packet['Param 2']
					updateStatus('caller')
				end
			end
		elseif packet and packet['Message ID'] == 39164 and packet['Player'] == 17797273 then	-- Ambu using refersh
			if not __processedSequences[packet['_sequence']] then
				__processedSequences[packet['_sequence']] = true
				packets.inject(packets.new('outgoing', 0x115))
			end
		elseif packet and __trade then
			atcwarn('Packet 0x02A received: Trade V2.0')
			__received_response = true
		end
	elseif id == 0x01D or id == 0x01C or id == 0x01E or id == 0x020 then  -- Inv + Gil update 
		local packet = packets.parse('incoming', data)
		if packet and not __invSequences[packet['_sequence']] then
			__invSequences[packet['_sequence']] = true
			if __playerData[player.name] then
				__playerData[player.name]['Inventory'] = windower.ffxi.get_items(0).count
				__playerData[player.name]['Gil'] = windower.ffxi.get_items().gil
				updateStatus('caller')
			end
		end
	elseif id == 0x061 then
		local parsed = packets.parse('incoming', data)
		if parsed then
			if __playerData[player.name] then
				local storedValues = {}
				storedValues['EPcurrent'] = parsed['Current Exemplar Points']
				storedValues['EPTNML'] = parsed['Required Exemplar Points']
				storedValues['EPML'] = parsed['Master Level']
				if __playerData[player.name] then
					__playerData[player.name]['Job'] = 'M.'..player.main_job..storedValues['EPML']..'/'..player.sub_job..player.sub_job_level..' '..formatNumberAbbreviated(storedValues['EPcurrent'])..'/'..formatNumberAbbreviated(storedValues['EPTNML'])
					updateStatus('caller')
				end
				--Conquest update
				conquest_counter = conquest_counter + 1
				if conquest_counter > 20 then
					if haveBuff("Signet") then
						local tempData
						getCurrencyONE(function(tempData) end)
					end
					conquest_counter = 0
				end
			end
		end
	elseif id == 0x0DF or id == 0x0DD or id == 0x0C8 then -- Char update
        local packet = packets.parse('incoming', data)
		if packet then
			local playerId = packet['ID']
			local job = packet['Main job']
			
			if playerId and playerId > 0 then
				set_registry(packet['ID'], packet['Main job'])
			end
		end
	elseif (id == 0x032 or id == 0x034) and __busy and not inj then
		local parsed = packets.parse('incoming', data)
		if parsed and parsed['Zone'] == zone_id then
			if not __processedPokeSequence[parsed['_sequence']] then
				__processedPokeSequence[parsed['_sequence']] = true
				local target = windower.ffxi.get_mob_by_index(parsed['NPC Index']) or false
				--Packet send
				if target and target.name == __get_npc_name and parsed['Menu ID'] == __get_menu_id and (next(__get_packet_sequence) ~= nil) then
					atcwarn('Packet 0x032 / 0x034 received: Packets Command')
					__received_response = true
					if __shop_packet then
						__shop_busy = true
					end
					send_packet(parsed, __get_packet_sequence)
					return true
				--Keypresses
				elseif target and target.name == __get_npc_name and (next(__get_keypress_sequence) ~= nil) then
					atcwarn('Packet 0x032 / 0x034 received: Keypress')
					__received_response = true
					keypress_cmd(__get_keypress_sequence)
				--Poke/trade
				elseif target and target.name == __get_npc_name then
					atcwarn('Packet 0x032 / 0x034 received: Poke / Trade')
					__received_response = true
				else
					atcwarn('ABORT! Wrong NPC interaction! 0x032 / 0x034')
					__received_response = true
					send_packet(parsed, {{0,16384,0,false}})
				end
			end
		end
	-- Open shop sub menu
	elseif id == 0x03C and not inj and ((not __busy and __shop_busy) or __poke) then
		local parsed = packets.parse('incoming', data)
		if parsed then
			atcwarn('Packet 03C received - Shop opened.')
			__received_response = true
			__shop_opened = true
		end
	elseif (id == 0x38) and haveBuff('Voidwatcher') then
        local parsed = packets.parse('incoming', data)
        local mob = windower.ffxi.get_mob_by_id(parsed['Mob'])
        if not mob then elseif (mob.name == 'Riftworn Pyxis') then
            if parsed['Type'] == 'deru' then
                atc('[VW] Riftworn Pyxis spawn')
				off()
            end
        end
	-- Menu for HUD data: currencies
	elseif id == 0x118 then
		if not __playerData[player.name] then
			__playerData[player.name] = {}
		end
		local parsed = packets.parse('incoming', data)
		if parsed then
			local currency = {
				["Hallmarks"] = "HM",
				["Badges of Gallantry"] = "GL",
				["Gallimaufry"] = "Gall",
				["Mog Segments"] = "Segs",
			}
			for field, abbreviation in pairs(currency) do
				if parsed[field] then
					__playerData[player.name][abbreviation] = tonumber(parsed[field])
				end
			end
			local items = windower.ffxi.get_items(0)
			__playerData[player.name]['Gil'] = windower.ffxi.get_items().gil
			__playerData[player.name]['Inventory'] = items.count
		end
		updateStatus('caller')
	elseif id == 0x113 then
		if not __playerData[player.name] then
			__playerData[player.name] = {}
		end
		local parsed = packets.parse('incoming', data)
		if parsed then
			local nation_string
			if player.nation == 0 then -- Sandy
				nation_string = "Conquest Points (San d'Oria)"
			elseif player.nation == 1 then -- Bastok
				nation_string = "Conquest Points (Bastok)"
			elseif player.nation == 2 then -- Windy
				nation_string = "Conquest Points (Windurst)"
			end
			local currency = {
				[nation_string] = "CQ",
			}
			for field, abbreviation in pairs(currency) do
				if parsed[field] then
					__playerData[player.name][abbreviation] = tonumber(parsed[field])
				end
			end
			local items = windower.ffxi.get_items(0)
			__playerData[player.name]['Gil'] = windower.ffxi.get_items().gil
			__playerData[player.name]['Inventory'] = items.count
		end
		updateStatus('caller')
	end
end

function handle_statue_change(new, old)
	local target = windower.ffxi.get_mob_by_target('t')
    if not target or target then
        if new == 4 and __busy then
            __npc_dialog = true
        elseif old == 4 then
            __npc_dialog = false
        end
    end
	if new == 33 then	-- resting
		isResting = true
	elseif new == 00 then	-- idle
		isResting = false
	end
end

function handle_outgoing_chunk(id, original)
	if id == 0x05b and __busy then
		local parsed = packets.parse('outgoing', original)
		if parsed then
			__get_packet_sequence = {}
			__get_menu_id = 0
			__get_npc_name = ''
			__busy = false
			__poke = false
		end
	end
end

function handle_gain_buff(buff_id)
end

function handle_lose_buff(buff_id)
end

function poke(mob_index)
    atcwarn("[POKE] - Attempt to poke NPC")
	__get_npc_name = windower.ffxi.get_mob_by_index(mob_index) and windower.ffxi.get_mob_by_index(mob_index).name or nil
    if not mob_index or not __get_npc_name then
		return
		atcwarn("[POKE] - Abort, no valid target.")
	else
		__busy = true
		__poke = true
		get_poke_check_index(mob_index)
	end
	finish_interaction()
end

pokesingle = poke

function sell(mob_index)
	atcwarn("[SELL] - Attempt to poke NPC to sell junk.")
    __get_npc_name = windower.ffxi.get_mob_by_index(mob_index) and windower.ffxi.get_mob_by_index(mob_index).name or nil
    if not mob_index or not __get_npc_name then
		return
		atcwarn("[SELL] - Abort, no valid target.")
	else
		windower.send_command('sellnpc junk')
		coroutine.sleep(1.5)
		__busy = true
		__poke = true
		get_poke_check_index(mob_index)
	end
	finish_interaction()
end

local function pre_check(map_type)
	if map_type == 'get' and not (get_map[zone_id]) then
		atcwarn('[GET] Not in an listed zone, cancelling.')
		finish_interaction()
		return false
	elseif map_type == 'enter' and not (npc_map[zone_id]) then
		atcwarn('[ENTER] Not in an listed zone, cancelling.')
		finish_interaction()
		return false
	end
	
	if __busy then
		atcwarn('[GET KI] ABORT! Currently interacting with some NPC')
		return false
	end
	
	if haveBuff('Invisible') then
		windower.send_command('cancel invisible')
		coroutine.sleep(1.5)
	end
	if haveBuff('Mounted') then
		windower.send_command('input /dismount')
		coroutine.sleep(1.5)
	end
	return true
end

function npc_finder_check(get_cmd)
	for k,v in pairs (get_map[zone_id].name) do
		for k2,v2 in pairs (v) do
			for k3,v3 in pairs (v2) do
				if get_cmd == k3 then
					return k
				end
			end
		end
	end
end

function refillmeds()
	if not pre_check('get') then return end

	local category_curio = S{'meds','scrolls','foods'}
	
	for our_categories,_ in pairs (category_curio) do
		local npc_name_for_command = npc_finder_check(our_categories)
		local possible_npc = find_npc_to_poke("get", npc_name_for_command)
		local get_command = (possible_npc and get_map[zone_id].name[possible_npc.name].cmd[our_categories]) or nil
		if possible_npc and get_command then
			if get_command.packet then
				atc("[REFILL MEDS] - "..get_command.description)
				__get_packet_sequence = get_command.packet[1]
				__get_menu_id = get_command.menu_id
				__get_npc_name = possible_npc.name
				__shop_packet = true
				__busy = true
			end
			--Poke NPC
			if not get_poke_check_index(possible_npc.index) then
				finish_interaction()
			end
			coroutine.sleep(2.5)
			if __shop_opened then
				windower.send_command('setkey escape down; wait 0.25; setkey escape up;')
				coroutine.sleep(0.5)
				atc('[REFILL MEDS] - Cateogry: '..our_categories:capitalize())
				for k,v in pairs(get_map[zone_id].name[possible_npc.name]) do
					for _,med_table in pairs(v) do
						if med_table.category == our_categories then
							windower.send_command('get "' ..med_table.description.. '" 100')
							coroutine.sleep(1.2)
							local item_count = 0
							item_count = CheckItemInInventory(med_table.description, true, true)
							if item_count and item_count < med_table.count and med_table.category == our_categories then
								local amount_to_buy = med_table.count - item_count
								local free_space = count_inv()
								local total_space = math.ceil(amount_to_buy/12)

								if free_space < total_space then
									atcwarn("WARNING:  Not enough space, skipping - "..med_table.description)
								else
									atc(med_table.description.." - "..item_count.." <> Buying: "..amount_to_buy)
									if amount_to_buy > 12 then
										atc("TX: Buying in multiple transactions!")
										local small_count = 1
										for i = amount_to_buy, 1, -12 do
											if i > 12 then
												atc('TX: '..small_count..' - '..med_table.description..' <> Buying: 12')
												send_packet_shop(med_table.shop_packet_slot, 12)
											else
												atc('TX: '..small_count..' - '..med_table.description..' <> Buying: '..i)
												send_packet_shop(med_table.shop_packet_slot, i)
											end
											small_count = small_count +1
											coroutine.sleep(2.0)
										end
									else
										send_packet_shop(med_table.shop_packet_slot, amount_to_buy)
									end
								end
							else
								atcwarn('Skipping: '..med_table.description..' - Have: '..item_count)
							end
							coroutine.sleep(2.0)
							windower.send_command('put "' ..med_table.description.. '" sack 100')
							coroutine.sleep(1.2)
						end
					end
				end
				finish_interaction()
				atc("[REFILL MEDS] - Finish refilling all: "..our_categories:capitalize())
			else
				atcwarn("[REFILL MEDS] - Shop did not open!  0x03C was not received.")
				finish_interaction()
				return
			end
		else
			atcwarn("[REFILL MEDS] No NPC's nearby to poke, cancelling.")
			finish_interaction()
			return
		end
	end
	finish_interaction()
	atc("[REFILL MEDS] All actions complete.")
end

function get(cmd2,cmd3)
	local ki_count = 0
	local ki_max = 0
	if not pre_check('get') then return end

	local npc_name_for_command = npc_finder_check(cmd2)
	local possible_npc = find_npc_to_poke("get",npc_name_for_command)
	local get_command = (possible_npc and get_map[zone_id].name[possible_npc.name].cmd[cmd2]) or nil
	if possible_npc and get_command then
		if (get_command.packet) then	-- Packets
			ki_count = (get_command.ki_check and find_missing_ki(get_command.ki_check)) or (get_command.item_check and CheckItemInInventory(get_command.item_check, true, true)) or 0
			ki_max = get_command.ki_max_num or 1
			curr_validator = (get_command.curr_amount and get_command.curr_type and currency_check(get_command.curr_amount, get_command.curr_type)) or false
			if (ki_max-ki_count) > 0 and (not get_command.leader or (get_command.leader and check_leader())) then 
				if get_command.curr_amount and get_command.curr_type then
					coroutine.sleep(1)
					if not __enough_currency then
						atcwarn("[GET Packet] - Abort! Not enough currenecy: ".. __currency_amount .. " "..get_command.curr_type)
						finish_interaction()
						return
					else
						atc("[GET Packet] - Currenecy: ".. __currency_amount .. " "..get_command.curr_type)
					end
				end
				atc("[GET KI Packet] - "..get_command.description)
				__get_packet_sequence = get_command.packet[ki_max-ki_count]
				__get_menu_id = get_command.menu_id
				__get_npc_name = possible_npc.name
				__busy = true
				if get_command.shop_packet_slot and (not cmd3 or tonumber(cmd3, 10) < 12) then
					cmd3 = cmd3 or 1
					__shop_packet = true
				end
				--Poke NPC
				if not get_poke_check_index(possible_npc.index) then
					finish_interaction()
				end
				--Curio command
				coroutine.sleep(2.0)
				if __shop_opened then
					atcwarn(get_command.description.." - Buying: "..cmd3)
					send_packet_shop(get_command.shop_packet_slot, tonumber(cmd3, 10))
				end
			else
				if get_command.leader then
					atcwarn("[GET Packet] - You're not leader or in solo, not using packet command: "..get_command.description)
				else
					atcwarn("[GET Packet] - Abort! You already have maximum amount of "..get_command.description)
				end
			end
		elseif (get_command.entry_command) then	-- KeyPress
			atc("[GET] - "..get_command.description)
			__busy = true
			__get_npc_name = possible_npc.name
			__get_keypress_sequence = get_command.entry_command
			if not get_poke_check_index(possible_npc.index) then
				finish_interaction()
				return
			end
		elseif (get_command.item_id) then -- Trade
			__get_npc_name = possible_npc.name
			__busy = true
			__trade = true
			if not send_packet_trade(windower.ffxi.get_mob_by_name(possible_npc.name),find_item_index(get_command.item_id, 1)) then
				finish_interaction()
			end
		end
		finish_interaction()
	else
		atcwarn("[GET] No NPC's nearby to poke, cancelling.")
		finish_interaction()
	end
end

function enter(leader)
	if not pre_check('enter') then return end

	local possible_npc = find_npc_to_poke()
	if possible_npc then
		-- Name type
		if not(npc_map[zone_id].name[possible_npc.name].index) then
			local enter_command = npc_map[zone_id].name[possible_npc.name] or nil
			if (enter_command.packet) then	-- Packets
				atc("[ENTER Packet] - "..enter_command.description)
				__get_packet_sequence = enter_command.packet[1]
				__get_menu_id = enter_command.menu_id
				__get_npc_name = possible_npc.name
				__busy = true
				--Poke NPC
				if not get_poke_check_index(possible_npc.index) then
					finish_interaction()
				end
			else
				__busy = true
				__get_npc_name = possible_npc.name
				__get_keypress_sequence = npc_map[zone_id].name[possible_npc.name].entry_command
				if not get_poke_check_index(possible_npc.index) then
					finish_interaction()
				end
			end
		-- Index type
		else
			local enter_command = npc_map[zone_id].name[possible_npc.name].index[possible_npc.index] or nil
			if (enter_command and enter_command.packet) then	-- Packets
				atc("[ENTER Packet] - "..enter_command.description)
				__get_packet_sequence = enter_command.packet[1]
				__get_menu_id = enter_command.menu_id
				__get_npc_name = possible_npc.name
				__busy = true
				--Poke NPC
				if not get_poke_check_index(possible_npc.index) then
					finish_interaction()
				end
			elseif enter_command then
				__busy = true
				__get_npc_name = possible_npc.name
				__get_keypress_sequence = npc_map[zone_id].name[possible_npc.name].index[possible_npc.index].entry_command
				if not get_poke_check_index(possible_npc.index) then
					finish_interaction()
				end
			else
				atcwarn("[ENTER] No NPC's nearby to poke, cancelling.")
				finish_interaction()
			end
		end
		finish_interaction()
	else
		atcwarn("[ENTER] No NPC's nearby to poke, cancelling.")
		finish_interaction()
	end	
end

function currency_check(required_amount, currency_to_check)
	__enough_currency = false
	__currency_amount = 0
	local event
	local function getCurrency(name, callback)  
		local currency1 = S{"Sacred Kindred Crests","Kindred Crests","Beastman Seals","Sparks of Eminence","Unity Accolades","Conquest Points"} -- Currency1
		local currency2 = S{"Silver A.M.A.N. Vouchers Stored","Gallimaufry","Mog Segments"} -- Currency2 
		if not event and callback and type(callback) == 'function' then

			if currency1:contains(name) then
				local nationNames = {
					[0] = "San d'Oria",
					[1] = "Bastok",
					[2] = "Windurst"
				}
				name = (name == "Conquest Points") and ("Conquest Points (" .. nationNames[player.nation] .. ")") or name

				event = windower.register_event('incoming chunk', function(id, original)
					if id == 0x113 then
						local parsed = packets.parse('incoming', original)
						if parsed and parsed[name] then
							callback(name, parsed[name])
						end
						windower.unregister_event(event)
						event = nil        
					end
				end)
				packets.inject(packets.new('outgoing', 0x10F))
			elseif currency2:contains(name) then
				event = windower.register_event('incoming chunk', function(id, original)
					if id == 0x118 then
						local parsed = packets.parse('incoming', original)
						if parsed and parsed[name] then
							callback(name, parsed[name])
						end
						windower.unregister_event(event)
						event = nil        
					end
				end)
				packets.inject(packets.new('outgoing', 0x115))
			end
		end
	end

	getCurrency(currency_to_check, function(name, count)
		if count >= required_amount then
            __enough_currency = true
			__currency_amount = count
			return true
        else
            __enough_currency = false
			__currency_amount = count
			atcwarn("ABORT: Not enough currency!")
			return false
        end
	 end)
end

function keypress_cmd(key_table)
	local keypress_string = ''
	for _,press in ipairs(key_table) do
		if type(press)=='table'then
			keypress_string = keypress_string ..'setkey '..press[1]..' down; wait '..press[2]..'; setkey '..press[1]..' up; '
		else
			keypress_string = keypress_string ..'wait '..press..'; '
		end
	end
	atc('[KeyPress CMD] - '..keypress_string)
	windower.send_command(keypress_string)
end

function basic_keys(cmd)
	atc('[KeyPress] Sending -'..cmd:upper()..'- key sequence.')
	keypress_cmd(basic_key_sequence[cmd].command)
end

function finish_interaction()
	__get_keypress_sequence = {}
	__get_packet_sequence = {}
	__get_menu_id = 0
	__get_npc_name = ''
	__get_shop_item_count = 0
	__get_shop_slot = 0
	__shop_busy = false
	__shop_opened = false
	__shop_packet = false
	__busy = false
	__poke = false
	__received_response = false
	__trade = false
	atcwarn('Finish interaction')
end

function find_item_index(item_id, count)
	local inventory = windower.ffxi.get_items(0)
	if not inventory then 
		atc("[ITEM FIND] Error no inventory!")
		return 
	end
    for k, v in ipairs(inventory) do
        if v.id == item_id and v.count >= count and v.status == 0 then
            return k
        end
    end
	return nil
end

function calc_lazy_distance(a,b)
    return (a.x-b.x)^2 + (a.y-b.y)^2
end

--Find NPC that's in list to poke
function find_npc_to_poke(npc_type, select_npc_name)
	if npc_type == "get" then
		unformatted_npc_list = get_map[zone_id] and get_map[zone_id].name
		npc_list = {}
		if unformatted_npc_list then
			local index = 1
			for k,v in pairs(get_map[zone_id].name) do
				if select_npc_name == k then
					npc_list[index] = k
					index=index+1
				end
			end
		end
	else
		unformatted_npc_list = npc_map[zone_id] and npc_map[zone_id].name
		npc_list = {}
		if unformatted_npc_list then
			local index = 1
			for k,v in pairs(npc_map[zone_id].name) do
				npc_list[index] = k
				index=index+1
			end
		end
	end
	

    if not npc_list or #npc_list == 0 then
        return nil
    end
	local player_distance = windower.ffxi.get_mob_by_target('me')
	
    npcs = T(T(windower.ffxi.get_mob_list()):filter(table.contains+{npc_list}):keyset()):map(windower.ffxi.get_mob_by_index):filter(table.get-{'valid_target'})
	closest_npc = npcs:reduce(function(current, npc_of_interest)
		local npc_of_interest_dist = calc_lazy_distance(player_distance, npc_of_interest)
		local current_dist = calc_lazy_distance(player_distance, current)
		return npc_of_interest_dist < current_dist and npc_of_interest or current
	end)
    
	if closest_npc and calc_lazy_distance(player_distance, closest_npc) < 50^2 then
        return closest_npc
    end
end

local function distance_check_npc(npc)
    local player = windower.ffxi.get_mob_by_target('me')

    if npc and calc_lazy_distance(player, npc) < 6^2 then
		atc('[Dist Check] -Found-: ' ..npc.name.. ' [Distance]: ' .. math.floor(math.sqrt(npc.distance)*(10^2))/(10^2))
        return true
    else
        atcwarn('[Dist Check] -TOO FAR AWAY-: ' ..npc.name.. ' [Distance]: ' .. math.floor(math.sqrt(npc.distance)*(10^2))/(10^2))
        return false
    end
end

function get_poke_check_index(npc_index)
	count = 0
	while __received_response == false and count < 5 do
		count = count + 1
		npcstats = windower.ffxi.get_mob_by_index(npc_index)
		if not npcstats then
			atcwarn('[POKE]: Abort! NPC Target is beyond 50 yalms in current zone.')
			return false
		end
		if npcstats and distance_check_npc(npcstats) and npcstats.valid_target then
			atc('Poke #: ' ..count.. ' [NPC: ' .. npcstats.name.. ' ID: ' .. npcstats.id.. ']')
			poke_npc(npcstats.id,npcstats.index)
		end
		coroutine.sleep(3.0)
	end
	return __received_response
end

function poke_npc(npc,target_index)
	if npc and target_index then
		local packet = packets.new('outgoing', 0x01A, {
			["Target"]=npc,
			["Target Index"]=target_index,
			["Category"]=0,
			["Param"]=0,
			["_unknown1"]=0})
		packets.inject(packet)
	end
end

function send_packet(parsed, options, delay)
	local delay = (delay or 0)

	if parsed and options and type(options) == 'table' then
		coroutine.schedule(function()

			for option, index in T(options):it() do
				local option = T(option)

				coroutine.schedule(function()
					packets.inject(packets.new('outgoing', 0x05b, {
						['Menu ID']             = parsed['Menu ID'],
						['Zone']                = parsed['Zone'],
						['Target Index']        = parsed['NPC Index'],
						['Target']              = parsed['NPC'],
						['Option Index']        = option[1],
						['_unknown1']           = option[2],
						['_unknown2']           = option[3],
						['Automated Message']   = option[4]
					}))
				end, (index * 0.25))
			end
		end, delay)
	end
end

function send_packet_shop(shop_slot, item_count)
	if shop_slot and item_count then
		packets.inject(packets.new('outgoing', 0x083, {
			['Count']             	= item_count,
			['_unknown2']           = 0,
			['Shop Slot']        	= shop_slot,
			['_unknown3']        	= 0,
			['_unknown4']           = 0,
		}))
	end
end

function send_packet_trade(target, item_index)
	count = 0
	if not item_index then 
		atcwarn('[TRADE] Abort! No item found!')
		return
	end
	while __received_response == false and count < 3 do
		count = count + 1
		npcstats = windower.ffxi.get_mob_by_index(target.index)
		if not npcstats then
			atcwarn('[POKE]: Abort! NPC Target is beyond 50 yalms in current zone.')
			return false
		end
		if npcstats and distance_check_npc(npcstats) and npcstats.valid_target then
			atc('Trade #: ' ..count.. ' [NPC: ' .. npcstats.name.. ' ID: ' .. npcstats.id.. ']')
			local menu_item = 'C4I11C10HI':pack(0x36,0x20,0x00,0x00,target.id,
				1,0,0,0,0,0,0,0,0,0x00,
				item_index,0,0,0,0,0,0,0,0,0x00,
				target.index,1)
			windower.packets.inject_outgoing(0x36, menu_item)
		end
		coroutine.sleep(3.0)
	end
	return __received_response
end

function unity(status)
	local flag_bit = 0
	if status and status == 'on' then
		flag_bit = 1
		atcwarn("Unity chat is enabled")
	elseif status and status == 'off' then
		flag_bit = 0
		atcwarn("Unity chat is disabled")
	else
		atcwarn("[UNITY] No options, aborting.")
		return
	end
	packets.inject(packets.new('outgoing', 0x118, {
		['Chat Status']         = flag_bit,
		['_unknown2']           = 0,
	}))
	return
end

windower.register_event('incoming chunk', handle_incoming_chunk)
windower.register_event('outgoing chunk', handle_outgoing_chunk)
windower.register_event("gain buff", handle_gain_buff)
windower.register_event("lose buff", handle_lose_buff)
windower.register_event('status change', handle_statue_change)