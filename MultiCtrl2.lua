_addon.name = 'MultiCtrl2'
_addon.author = 'PBW'
_addon.version = '10.1.0'
_addon.commands = {'mc'}

require('functions')
require('logger')
require('tables')
require('coroutine')
require('vectors')
json = require "dkjson"
config = require('config')
packets = require('packets')
res = require('resources')
texts = require('texts')
extdata = require('extdata')

entry_map = require('entry_map')
job_data = require('job_data')
npc_interactions = require('npc_interactions')
display = require('mc_display')

-- job registry is a key->value table/db of player name->jobs we have encountered
job_registry = T{}

default = {

	avatar='ramuh',
	indi='refresh',
	active=false,
	assist='',
	smnhelp=false,
	smnsc=false,
	smnauto=false,
	smnlead='',
	buy=false,
	autows=false,
	rangedmode=false,
	send_all_delay = 0.33,
	autosub='sleep',
	autosc=false,
	autoarts='',
    smartws=false,
	smartws_target='',
}

areas = {}

-- City areas for town gear and behavior.
areas.Cities = S{
    "Ru'Lude Gardens",
    "Upper Jeuno",
    "Lower Jeuno",
    "Port Jeuno",
    "Port Windurst",
    "Windurst Waters",
    "Windurst Woods",
    "Windurst Walls",
    "Heavens Tower",
    "Port San d'Oria",
    "Northern San d'Oria",
    "Southern San d'Oria",
	"Chateau d'Oraguille",
    "Port Bastok",
    "Bastok Markets",
    "Bastok Mines",
    "Metalworks",
    "Aht Urhgan Whitegate",
	"The Colosseum",
    "Tavnazian Safehold",
    "Nashmau",
    "Selbina",
    "Mhaura",
	"Rabao",
    "Norg",
    "Kazham",
    "Eastern Adoulin",
    "Western Adoulin",
	"Celennia Memorial Library",
	"Mog Garden",
	"Leafallia",
	"Silver Knife",
	"Chocobo Circuit"
}

areas.Abyssea = S{15,45,132,215,216,217,218,253,254}

InternalCMDS = S{

	--Battle
	'on','off','stage','fight','fightmage','fightsmall','ws','food','autosub',
	'wsall','zerg','wstype','buffup','rebuff','dd','attackon','reraise','smartws',
	'turnaround','turnback',
	
	--Job
	'brd','bst','sch','smnburn','geoburn','burn','rng','proc','wsproc','jc',
	--Travel
	'mnt','dis','warp','omen','enter',
	--Misc
	'reload','unload','fps30','fps60','lotall','cleanup','drop','book','lockstyle','wstypenew','refillmeds','unity','party',
	'get','getki','stats',
}

DelayCMDS = S{'book','get','getall','enter','enup','endown','ent','esc','getki','jc','refillmeds','unity'}

TransferCMDS = S{'mnt','dis','warp','omen','fps30','fps60','lotall'}

player = windower.ffxi.get_player()
info = windower.ffxi.get_info()

if info.logged_in then
    zone_id = info.zone
end
	
isCasting = false
isResting = false
ipcflag = false
new = 0
old = 0
log_flag = true
cancel = false

__party_only = true
__helix_timer = 0
__status = true

__playerData = {}
__processedSequences = {}
__ambuHMSequences = {}
__ambuGLSequences = {}
__invSequences = {}
__processedPokeSequence = {}

function handle_addon_command(...)

	local term = table.concat({...}, ' ')
	local args = {...}
	local cmd = args[1]
	local cmd2 = args[2]
	local cmd3 = args[3]
	local cmd4 = args[4]
	local sender_term
	
	local leader = windower.ffxi.get_player()

    term = term:gsub('<(%a+)id>', function(target_string)
        local entity = windower.ffxi.get_mob_by_target(target_string)
        return entity and entity.id or '<' .. target_string .. 'id>'
    end)
	
	local parts = {}
	for part in term:gmatch("%S+") do
		table.insert(parts, part)
	end

	if #parts >= 2 then
		table.remove(parts, 1)
		sender_term = table.concat(parts, " ")
	end
	
	if cmd == nil then
		command_check()
		return
	elseif cmd == 'moveto' then
		moveto(cmd2,cmd3,cmd4)
    elseif cmd == 'cor' or cmd == 'blu' then				-- Index / Command / Command 2
		local target = windower.ffxi.get_mob_by_target('t')
		local mob_index = target and target.valid_target and target.is_npc and target.index
		_G[cmd]:schedule(0, cmd2, mob_index)
		send_to_IPC:schedule(1, term..' '..mob_index)
	elseif cmd == 'cc' or cmd == 'fin' or cmd == 'dispelga' or cmd == 'poke' or cmd == 'pokesingle' or cmd == 'sell' then	-- Index / Command
		local target = windower.ffxi.get_mob_by_target('t')
		local mob_index = target and target.valid_target and target.is_npc and target.index
		if (cmd == 'poke' or cmd == 'pokesingle') and not mob_index then
			atc('[POKE] Abort: No target or invalid target.')
			return
		end
		_G[cmd]:schedule(0, mob_index)
		if cmd ~= 'pokesingle' then
			send_to_IPC:schedule(1, cmd..' '..mob_index)
		end
	elseif S{'enup','endown','ent','esc'}:contains(cmd) then
		basic_keys:schedule(0, cmd)
		send_to_IPC:schedule(0.25, 'basic_keys '..cmd)
	elseif cmd == 'ein' then						-- Long delay
		ein:schedule(0, cmd2)
		if cmd2 == 'enter' then
			send_to_IPC:schedule(10, term)
		else
			send_to_IPC:schedule(1, term)
		end
	elseif cmd == 'buffall' then					-- No IPC
		buffall(cmd2)
	elseif cmd == 'd2' then							-- No IPC
		d2()
	elseif cmd == 'fon' or cmd == 'foff' then		-- No IPC
		follow_command(cmd)
	elseif cmd == 'as' then							-- Leader
		--local leader = windower.ffxi.get_player()
		as:schedule(0, leader.name,cmd2,cmd3)
		send_to_IPC:schedule(0, term)
	elseif cmd == 'smn' then						-- Leader
		--local leader = windower.ffxi.get_player()
		smn:schedule(0, leader.name, cmd2, cmd3)
		send_to_IPC:schedule(0, term)
	elseif cmd == 'autosc' then						-- Leader
		--local leader = windower.ffxi.get_player()
		autosc:schedule(0, leader.name, cmd2)
		--send_to_IPC:schedule(0, cmd, cmd2, leader.name)
		send_to_IPC:schedule(0, term)
	elseif cmd == 'send' then						-- Special parameter
		send:schedule(0, sender_term)
		send_to_IPC:schedule(0.95, term)
	elseif InternalCMDS:contains(cmd) then
		if DelayCMDS:contains(cmd) then
			_G[cmd]:schedule(0, cmd2,cmd3)
			send_to_IPC:schedule(0.75, term)
		elseif TransferCMDS:contains(cmd) then
			transfer_commands:schedule(0,cmd)
			send_to_IPC:schedule(0, term)
		else
			_G[cmd]:schedule(0, cmd2,cmd3)
			send_to_IPC:schedule(0, term)
		end
    elseif cmd == 'shobu' then
        shobu()
	elseif cmd == 'debug' then
		table.vprint(__playerData)
	end
end

function colorize(text, color)
    local colors = {
        reset = "\27[0m",
        black = "\27[30m",
        red = "\27[31m",
        green = "\27[32m",
        yellow = "\27[33m",
        blue = "\27[34m",
        magenta = "\27[35m",
        cyan = "\27[36m",
        white = "\27[37m"
    }

    return colors[color] .. text .. colors.reset
end

function command_check()
	if get_map[zone_id] then
		for npcs, _ in pairs(get_map[zone_id].name) do
			for key, command in pairs(_.cmd) do
				windower.add_to_chat(13, '[MC]'..string.char(31,036)..'[GET]: '..string.char(31,158)..key.." - "..string.char(31,007).. command.description ..string.char(31,001)..' - NPC: '..string.char(31,215)..npcs)
				--atc("[GET Command]: "..key.. " - "..command.description.." - NPC: ".._)
				--atc("--------------------------")
			end
		end
	elseif npc_map[zone_id] then
		for npcs, cmd_table in pairs(npc_map[zone_id].name) do
			if cmd_table.description then
				windower.add_to_chat(13, '[MC]'..string.char(31,036)..'[ENTER]: '..string.char(31,158).. cmd_table.description ..string.char(31,001)..' - NPC: '..string.char(31,215)..npcs)
			else
				windower.add_to_chat(13, '[MC]'..string.char(31,036)..'[ENTER]: '..string.char(31,001)..' NPC: '..string.char(31,215)..npcs)
			end
		end
	else
		atcwarn('No interactive commands in this zone')
	end
	
end

function stats(args)
	local cmd = args and args:lower() or (__status and 'off' or 'on')
	if cmd == 'on' then
		__status = true
		status_info:show()
	elseif cmd == 'off' then
		__status = false
		status_info:hide()
	end
end

local captureme = false
function getMasterlevel(callback)
	local storedValues = {}
	if not captureme and callback and type(callback) == 'function' then
		captureme = windower.register_event('incoming chunk', function(id, original)
			if id == 0x061 then
				local parsed = packets.parse('incoming', original)
				if parsed then
					storedValues['EPcurrent'] = parsed['Current Exemplar Points']
					storedValues['EPTNML'] = parsed['Required Exemplar Points']
					storedValues['EPML'] = parsed['Master Level']
					callback(storedValues)
				end
				windower.unregister_event(captureme)
				captureme = nil
			end
		end)
	end
	packets.inject(packets.new('outgoing', 0x061, {['_unknown1']=('C4'):pack(255,255,255,255)}))
end

local event = false
function getCurrency(callback)  
	local currency2 = {
		["Hallmarks"] = "HM",
		["Badges of Gallantry"] = "GL",
		["Gallimaufry"] = "Gall",
		["Mog Segments"] = "Segs"
	}
	local storedValues = {}
	if not event and callback and type(callback) == 'function' then
		event = windower.register_event('incoming chunk', function(id, original)
			if id == 0x118 then
				local parsed = packets.parse('incoming', original)
				if parsed then
					for field, abbreviation in pairs(currency2) do
						if parsed[field] then
							storedValues[abbreviation] = tonumber(parsed[field])
						end
					end
			
					local items = windower.ffxi.get_items(0)
					storedValues['Gil'] = windower.ffxi.get_items().gil
					storedValues['Inventory'] = items.count 
					callback(storedValues)
				end
				windower.unregister_event(event)
				event = nil        
			end
		end)
		packets.inject(packets.new('outgoing', 0x115))
	end
end

local eventONE = false
function getCurrencyONE(callback)  
	local nation_string
	if player.nation == 0 then -- Sandy
		nation_string = "Conquest Points (San d'Oria)"
	elseif player.nation == 1 then -- Bastok
		nation_string = "Conquest Points (Bastok)"
	elseif player.nation == 2 then -- Windy
		nation_string = "Conquest Points (Windurst)"
	end
	
	local currency1 = {
		[nation_string] = "CQ",
	}
	local storedValues = {}
	if not eventONE and callback and type(callback) == 'function' then
		eventONE = windower.register_event('incoming chunk', function(id, original)
			if id == 0x113 then
				local parsed = packets.parse('incoming', original)
				if parsed then
					for field, abbreviation in pairs(currency1) do
						if parsed[field] then
							storedValues[abbreviation] = tonumber(parsed[field])
						end
					end
					callback(storedValues)
				end
				windower.unregister_event(eventONE)
				eventONE = nil        
			end
		end)
		packets.inject(packets.new('outgoing', 0x10F))
	end
end


function updateStatus(commandType, senderName, statusTable)
	local hudData
	local player = windower.ffxi.get_player()
	if commandType == 'caller' then
		hudData = __playerData[player.name]
		send_to_IPC('updateStatus request ', hudData)
		
	elseif commandType == 'request' then
		hudData = __playerData[player.name]
		dataUpdate(senderName, statusTable)
		send_to_IPC('updateStatus sent ', hudData)
		
	elseif commandType == 'sent' then
		dataUpdate(senderName, statusTable)
	end
end
	
function initHud(commandType, senderName, statusTable)
	local hudData
	local hudDataONE
	local mlData
	local player = windower.ffxi.get_player()
	if commandType == 'caller' then
		getMasterlevel(function(mlData)
			getCurrencyONE(function(hudDataONE)
				getCurrency(function(hudData)
					hudData['CQ'] = hudDataONE['CQ']
					hudData['Job'] = 'M.'..player.main_job..mlData['EPML']..'/'..player.sub_job..player.sub_job_level..' '..formatNumberAbbreviated(mlData['EPcurrent'])..'/'..formatNumberAbbreviated(mlData['EPTNML'])
					dataUpdate(player.name, hudData)
					send_to_IPC('initHud request ', hudData)
				end)
			end)
		end)
	elseif commandType == 'request' then
		getMasterlevel(function(mlData)
			getCurrencyONE(function(hudDataONE)
				getCurrency(function(hudData)
					hudData['CQ'] = hudDataONE['CQ']
					hudData['Job'] = 'M.'..player.main_job..mlData['EPML']..'/'..player.sub_job..player.sub_job_level..' '..formatNumberAbbreviated(mlData['EPcurrent'])..'/'..formatNumberAbbreviated(mlData['EPTNML'])
					dataUpdate(senderName, statusTable)
					dataUpdate(player.name, hudData)
					send_to_IPC('initHud sent ', hudData)
				end)
			end)
		end)
	elseif commandType == 'sent' then
		dataUpdate(senderName, statusTable)
	end
end

function dataUpdate(name, data)
	__playerData[name] = {
		Gil=data["Gil"],
		Gall=data["Gall"],
		Segs=data["Segs"],
		HM=data["HM"],
		GL=data["GL"],
		Inventory=data["Inventory"],
		Job=data["Job"],
		CQ=data["CQ"],
	}
end

------------
--IPC Stuff
------------

function send_to_IPC(term, tableData)
	if not tableData then
		tableData = {}
	end
	local ipc_packet = {
		sender_name=player.name, org_term=term, org_tableData= tableData
	}
	local encoded_ipc = json.encode(ipc_packet)
	windower.send_ipc_message(encoded_ipc)
end

function handle_ipc_message(msg, ...) 

	local decoded_ipc_message = json.decode(msg)
	local sender = decoded_ipc_message.sender_name
	local args = decoded_ipc_message.org_term:split(' ')
	local cmd = args[1]
	local cmd2 = args[2]
	local cmd3 = args[3]
	local cmd4 = args[4]
	local delay = get_delay()
	
	local term = decoded_ipc_message.org_term:split(' ')
	term:remove(1)
	local send_cmd = table.concat(term, " ")
	
	if cmd:lower() ~= 'party' and __party_only and not check_sender_in_party(sender) then
		return
	end

	if TransferCMDS:contains(cmd) then
		transfer_commands(cmd)
	elseif (InternalCMDS:contains(cmd)) then
		if(DelayCMDS:contains(cmd)) then
			coroutine.sleep(delay)
		end
		_G[cmd](cmd2,cmd3)
	elseif cmd == 'as' then			-- Leader
		as(sender, cmd2, cmd3)
	elseif cmd == 'smn' then		-- Leader
		smn(sender, cmd2, cmd3)
	elseif cmd == 'autosc' then		-- Leader
		autosc(sender, cmd2)
	elseif cmd == 'send' then		-- Special term
		coroutine.sleep(delay)
		send(send_cmd)
	elseif cmd == 'ein' then
		coroutine.sleep(delay)
		ein(cmd2)
	elseif cmd == 'blu' or cmd == 'cor' then	-- mob index
		_G[cmd](cmd2, cmd3)	
	elseif cmd == 'cc' or cmd == 'fin' or cmd == 'dispelga' or cmd == 'poke' or cmd == 'sell' then		-- mob index
		if cmd == 'poke' or cmd == 'sell' then
			coroutine.sleep(delay)
		end
		_G[cmd](cmd2)	
	elseif cmd == 'basic_keys' then
		basic_keys(cmd2)
	elseif cmd == 'updateStatus' then
		updateStatus(cmd2, sender, decoded_ipc_message.org_tableData)
	elseif cmd == 'initHud' then
		initHud(cmd2, sender, decoded_ipc_message.org_tableData)
    end
end

function check_sender_in_party(member_name)
    for k, v in pairs(windower.ffxi.get_party()) do
        if type(v) == 'table' then
            if member_name == v.name then
                return true
            end
        end
    end
    return false
end

function party(cmd)
	if S{'off'}:contains(cmd) then
		atc('All characters will receive IPC')
		__party_only = false
	elseif S{'on'}:contains(cmd) then
		atc('Party only mode')
		__party_only = true
	elseif not cmd then
		if __party_only then
			atc('All characters will receive IPC')
			__party_only = false
		else
			atc('Party only mode')
			__party_only = true
		end
	end
end

--------------------------------
---- Event driven functions ----
--------------------------------

function handle_login_load()
	if (windower.ffxi.get_info().logged_in) then
		player = windower.ffxi.get_player()
	end
	initHud('caller')
	settings = config.load(default)
	init_box_pos()
	atcwarn('Required addons: Selindrile\'s GearSwap, HealBot, FastCS, Organizer, TradeNPC, Send, MAA, Roller, Singer, Sparks, Powder, SellNPC')
end


function handle_zone_change(new_id, old_id)
	zone_id = new_id
	__processedSequences = {}
	__invSequences = {}
	__processedPokeSequence = {}
	__ambuHMSequences = {}
	__ambuGLSequences = {}
end

function handle_job_change(main_job_id, main_job_level, sub_job_id, sub_job_level)
	player.main_job = res.jobs[main_job_id].ens
	player.main_job_id = main_job_id
	player.main_job_level = main_job_level
	player.sub_job = res.jobs[sub_job_id].ens
	player.sub_job_id = sub_job_id
	player.sub_job_level = sub_job_level
	getMasterlevel(function(mlData)
		__playerData[player.name]['Job'] = 'M.'..player.main_job..mlData['EPML']..'/'..player.sub_job..player.sub_job_level..' '..formatNumberAbbreviated(mlData['EPcurrent'])..'/'..formatNumberAbbreviated(mlData['EPTNML'])
	end)
	updateStatus('caller')
end

function transfer_commands(cmd)
	if cmd == 'warp' and areas.Cities:contains(res.zones[zone_id].name) then
		atcwarn('Transfer command: WARP - In a city zone, skipping.')
		return
	end

	atc('Transfer command: '..cmd)
	windower.send_command(command_map[cmd])
end


-- Sub functions
function stage(cmd2)

	if not stage_data[cmd2] then
		atcwarn('Error: Not a stage setup.')
		return
	end
	
	if player.main_job == 'BRD' then
		windower.send_command('lua l singer; wait 0.5; sing clear all; mc brd reset')
	end
	
	--Unload certain addons
	windower.send_command('lua u maa;')-- lua u react')
	
	for _,job_cmds in pairs(stage_data[cmd2]) do
		if type(job_cmds)=='table' and job_cmds[player.main_job] then
			-- SJ variant
			if job_cmds[player.main_job].sj then
				for key,sub_job_cmds in pairs(job_cmds[player.main_job].sj) do
					if type(sub_job_cmds)=='table' and key == player.sub_job then
						for _,action_line in pairs(sub_job_cmds.action) do
							windower.send_command(action_line)
						end
						if sub_job_cmds.food then
							windower.send_command('gs c autofood \"'..sub_job_cmds.food..'\"')
						end
					end
				end
			-- No SJ defined
			else
				for _,action_line in pairs(job_cmds[player.main_job].action) do
					windower.send_command(action_line)
				end
				if job_cmds[player.main_job].food then
					windower.send_command('gs c autofood \"'..job_cmds[player.main_job].food..'\"')
				end
			end
		end
		-- Common to all jobs
		if job_cmds['ALL'] then
			if job_cmds['ALL'].commands then
				windower.send_command(job_cmds['ALL'].commands)
			end
			if job_cmds['ALL'].mc_settings then
				local updated_settings = settings:update(job_cmds['ALL'].mc_settings)
			end
		end
	end
	display_box()
end

function jc(cmd)
	if not job_change_data[cmd] then
		atcwarn('[JC] Not a Job Change setup.')
		return
	end

	if job_change_data[cmd] then
		atc('[JC] '..job_change_data[cmd].name)
		if player.name == "" ..settings.char1.. "" then
			windower.send_command('jc '..job_change_data[cmd].char1)
		elseif player.name == "" ..settings.char2.. "" then
			windower.send_command('jc '..job_change_data[cmd].char2)
		elseif player.name == "" ..settings.char3.. "" then
			windower.send_command('jc '..job_change_data[cmd].char3)
		elseif player.name == "" ..settings.char4.. "" then
			windower.send_command('jc '..job_change_data[cmd].char4)
		elseif player.name == "" ..settings.char5.. "" then
			windower.send_command('jc '..job_change_data[cmd].char5)
		elseif player.name == "" ..settings.char6.. "" then
			windower.send_command('jc '..job_change_data[cmd].char6)
		end
	end
end

function wsall()
	atc("WSALL!")
	local player_job = windower.ffxi.get_player()
	local MeleeJobs = S{'WAR','SAM','DRG','DRK','NIN','MNK','COR','BLU','PUP','DNC','RUN','BRD','THF','RNG','PLD','GEO','BST','RDM'}
    
    local SmartJobs = S{'WAR','COR','BRD','BLU'}
    if settings.smartws then
        if SmartJobs:contains(player_job.main_job) then
            windower.send_command('gs c smartws Bozzetto Pishogue')
        end
    else
        if MeleeJobs:contains(player_job.main_job) then
            if player_job.main_job == "SAM" then
                windower.send_command('input /ws \'Tachi: Fudo\' <t>')
            elseif player_job.main_job == "MNK" then
                windower.send_command('input /ws \'Howling Fist\' <t>')
            elseif player_job.main_job == "NIN" then
                windower.send_command('input /ws \'Blade: Metsu\' <t>')
            elseif player_job.main_job == "DRG" then
                windower.send_command('input /ws \'Stardiver\' <t>')
            elseif player_job.main_job == "DRK" then
                windower.send_command('input /ws \'Torcleaver\' <t>')
            elseif player_job.main_job == "WAR" then
                windower.send_command('input /ws \'Upheaval\' <t>')
            elseif player_job.main_job == "COR" then
                local player = windower.ffxi.get_items('equipment')
                local bag = player.range_bag
                local index = player.range
                local weapon =  windower.ffxi.get_items(bag, index).id
                if weapon == 22141 then
                    windower.send_command('input /ws \'Leaden Salute\' <t>')
				elseif weapon == 22142 then
					windower.send_command('input /ws \'Wildfire\' <t>')
				elseif weapon == 22143 then
					windower.send_command('input /ws \'Last Stand\' <t>')
                elseif weapon == 19611 then
                    windower.send_command('input /ws \'Savage Blade\' <t>')
                end
            elseif player_job.main_job == "RNG" then
			    local player = windower.ffxi.get_items('equipment')
                local bag = player.range_bag
                local index = player.range
                local weapon =  windower.ffxi.get_items(bag, index).id
                if weapon == 22139 then
                    windower.send_command('input /ws \'Trueflight\' <t>')
				elseif weapon == 22142 then
					windower.send_command('input /ws \'Wildfire\' <t>')
				elseif weapon == 22143 then
					windower.send_command('input /ws \'Last Stand\' <t>')
                elseif weapon == 19607 then
                    windower.send_command('input /ws \'Savage Blade\' <t>')
                end
            elseif player_job.main_job == "BLU" then
                windower.send_command('input /ws \'Expiacion\' <t>')
			elseif player_job.main_job == "RDM" then
                windower.send_command('input /ws \'Seraph Blade\' <t>')
            elseif player_job.main_job == "BRD" then
                windower.send_command('input /ws \'Rudra\'s Storm\' <t>')
            elseif player_job.main_job == "RUN" then
                windower.send_command('input /ws \'Dimidiation\' <t>')
            elseif player_job.main_job == "PLD" then
                windower.send_command('input /ws \'Savage Blade\' <t>')
            elseif player_job.main_job == "THF" then
                windower.send_command('input /ws \'Rudra\'s Storm\' <t>')
            elseif player_job.main_job == "DNC" then
                windower.send_command('input /ws \'Rudra\'s Storm\' <t>')
            elseif player_job.main_job == "PUP" then
                windower.send_command('input /ws \'Howling Fist\' <t>')
            elseif player_job.main_job == "BST" then
                windower.send_command('input /ws \'Decimation\' <t>')
            elseif player_job.main_job == "GEO" then
                windower.send_command('input /ws \'Black Halo\' <t>')
            end
        end
    end
end

function cc(mob_index)
	atc('[CC] - Sleep/Lullaby')
    local world = res.zones[zone_id].name
	local mob = mob_index and windower.ffxi.get_mob_by_index(mob_index)
	local spell_to_cast = nil

	if not crowd_control_data[player.main_job] or areas.Cities:contains(world) then
		atcwarn("[CC]: Abort. Non sleepable jobs or in cities area.")
		return
	end

	for sub_job,cc_spell in pairs(crowd_control_data[player.main_job]) do
		if player.sub_job == sub_job then
			spell_to_cast = cc_spell.spell
		elseif 'NON' == sub_job then
			spell_to_cast = cc_spell.spell
		end
	end
	
	if mob and spell_to_cast then --and not (player.target_locked)  then
		atcwarn("[CC]: "..spell_to_cast.." -> "..mob.name)
		windower.send_command('input /ma \"'..spell_to_cast..'\" ' .. mob.id)
	-- elseif spell_to_cast and player.target_locked then
		-- atcwarn("[CC]: "..spell_to_cast)
		-- windower.send_command('input /ma \"'..spell_to_cast..'\" <t>')
	else
		atcwarn("[CC]: No proper spell to cast due to JOB combo.")
	end
	return
end

function dispelga(mob_index)
	atc('[DISPELGA]')
    local world = res.zones[zone_id].name
    local DispelJobs = S{'WHM','BLM','RDM','BRD','SMN','SCH','GEO'}
	local mob = mob_index and windower.ffxi.get_mob_by_index(mob_index)
    
    if not (DispelJobs:contains(player.main_job) or DispelJobs:contains(player.sub_job)) or areas.Cities:contains(world) then
		atcwarn("[DISPELGA]: Non dispelable jobs or in cities area.")
		return
	end
	
	if mob then --and not (player.target_locked) then
		windower.send_command("input /ma 'Dispelga " .. mob.id)
	-- else
		-- windower.send_command("input /ma 'Dispelga' <t>")
	end
end

function fin(mob_index)
	atc('[FIN]: Dispel/Finale.')
    local world = res.zones[zone_id].name
    local DispelJobs = S{'RDM','BRD'}
	local mob = mob_index and windower.ffxi.get_mob_by_index(mob_index)
    
    if not (DispelJobs:contains(player.main_job) or DispelJobs:contains(player.sub_job)) or areas.Cities:contains(world) then
		atcwarn("[FIN]: Non dispelable jobs, skipping")
		return
	end
        
	if player.main_job == "BRD" then
		atcwarn("[FIN]: Finale")
		if mob then --and not (player.target_locked) then
			windower.send_command("input /ma 'Magic Finale' " .. mob.id)
		-- else
			-- windower.send_command("input /ma 'Magic Finale' <t>")
		end
	elseif player.main_job == "RDM" or player.sub_job == "RDM" then
		atcwarn("[FIN]: Dispel")
		if mob then --and not (player.target_locked) then
			windower.send_command("input /ma 'Dispel " .. mob.id)
		-- else
			-- windower.send_command("input /ma 'Dispel' <t>")
		end
	end

end

function on(cor_toggle)
	atc('ON: Turning on addons.')
	local world = res.zones[zone_id] and res.zones[zone_id].name
	local di_zones = S{288,289,291}
		
	local MeleeJobs = S{'WAR','SAM','DRG','DRK','NIN','MNK','COR','BLU','PUP','DNC','RUN','THF','RNG','PLD','BST','GEO','BRD'}
	local MageJobs = S{'WHM','BLM','SCH','RDM','SMN','GEO','BRD'}

	if di_zones:contains(zone) then
		atc('ON: Domain Invasion zone, removing mobilization')
		if haveBuff('Mobilization') then
			windower.send_command('cancel mobilization')
		end
	end
	
	if haveBuff('Sneak') then
		windower.send_command('cancel sneak')
	end
	
	if haveBuff('Invisible') then
		windower.send_command('cancel invisible')
	end

	if not(areas.Cities:contains(world)) then
	
		windower.send_command('hb on')
		
		if MageJobs:contains(player.main_job) then
			if player.main_job == "SCH" then
				if autoarts == 'Light' then
					windower.send_command('gs c set autobuffmode Healing')
				elseif autoarts == 'Dark' then
					windower.send_command('gs c set autobuffmode Nuking')
				else
					windower.send_command('gs c set autobuffmode auto')
				end
			else
				windower.send_command('gs c set autobuffmode auto')
			end
		end

		if player.main_job == "RUN" then
			windower.send_command('gs c set autorunemode on; gs c set autobuffmode auto')
		elseif player.main_job == "PLD" then
			windower.send_command('gs c set autobuffmode auto')
		elseif player.main_job == "BRD" then
			windower.send_command('singer on')
		elseif player.main_job == "COR" and not cor_toggle then
			windower.send_command('roller on')
		elseif player.main_job == "SCH" then
			windower.send_command('gs c set autosubmode on')
		elseif player.main_job == "RDM" then
			windower.send_command('gs c set autoarts on;')
			windower.send_command('input /ja composure <me>')
		elseif player.main_job == "WHM" then
			windower.send_command('gs c set autoarts on;')
		elseif player.main_job == "BLU" then
			windower.send_command('gs c set autobuffmode auto;')
		elseif player.main_job == "DNC" then
			windower.send_command('gs c set autosambamode haste')
			windower.send_command('gs c set autobuffmode auto')
		elseif player.main_job == "PUP" then
			windower.send_command('gs c set autopuppetmode on; gs c set autobuffmode auto')
		end
		
		-- SCH sub toggles
		if player.sub_job == "SCH" then
			if player.main_job ~= "RDM" then
				if settings.autosub == 'sleep' then
					windower.send_command('gs c set autosubmode sleep')
				elseif settings.autosub == 'on' then
					windower.send_command('gs c set autosubmode on')
                elseif settings.autosub == 'off' then
                    windower.send_command('gs c set autosubmode off')
				end
			end
		end
		
		if player.sub_job == "RUN" then
			windower.send_command('gs c set autorunemode on')
        elseif player.sub_job == "DNC" then
            windower.send_command('gs c set autosambamode haste; gs c set autobuffmode auto')
        elseif player.sub_job == "COR" then
            windower.send_command('roller on')
		end
		
		-- WS/Buff mode
		if MeleeJobs:contains(player.main_job) then
			if settings.autows then
				windower.send_command('gs c set autowsmode on; gs c set autobuffmode auto;')
				if player.main_job == "DRG" or player.sub_job == "DRG" then
					windower.send_command('gs c set autojumpmode on;')
				end
			end
			if settings.rangedmode then
				if player.main_job == "COR" or player.main_job == "RNG" then
					windower.send_command('gs c set rnghelper on;')
				end
			end
		else
			if settings.autows then
				windower.send_command('gs c set autowsmode on;')
			end
		end
	else
		atc('ON: Indoor zone: ' .. world .. ' - skipping')
	end
end

function off()
	atc('OFF: Turning off addons.')
	if player.main_job == "RUN" then
		windower.send_command('gs c set autorunemode off')
		windower.send_command('gs c set autotankmode off')
		windower.send_command('gs c set autotankfull off')
	elseif player.main_job == "PLD" then
		windower.send_command('gs c set autorunemode off')
		windower.send_command('gs c set autotankmode off')
		windower.send_command('gs c set autotankfull off')
	elseif player.main_job == "DRG" or player.sub_job == "DRG" then
		windower.send_command('gs c set autojumpmode off')
	elseif player.main_job == "RNG" or player.main_job == "COR" then
		windower.send_command('gs c set rnghelper off')
	elseif player.main_job == "SMN" then
		windower.send_command('gs c set autowardmode off; gs c set autobpmode off; gs c set autoavatar off;')
	elseif player.main_job == "PUP" then
		windower.send_command('gs c set autopuppetmode off')
	elseif player.main_job == "BST" then
		windower.send_command('gs c set autocallpet off')
	elseif player.main_job == "SCH" or player.sub_job == "SCH" then
		windower.send_command('gs c set autosubmode off')
	end

	windower.send_command('hb off')
	windower.send_command('roller off')
	windower.send_command('singer off')
	windower.send_command('gs c set autowsmode off;')
	windower.send_command('gs c set autobuffmode off;')
	windower.send_command('gs c set autonukemode off;')
	windower.send_command('gs c set autotankmode off')
	windower.send_command('gs c set autosambamode off')
	windower.send_command('gs c set autozergmode off')
	windower.send_command('gs c set autoarts off')
	windower.send_command('gs c set autofoodmode off')
end

-- Does NOT use IPC
function follow_command(cmd)
	if cmd == 'fon' then
		atc('[FOLLOW]: Follow ON.')
	elseif cmd == 'foff' then
		atc('[FOLLOW]: Follow OFF.')
	end
	windower.send_command('hb follow off; hb f dist 1.5')

	for k, v in pairs(windower.ffxi.get_party()) do
		if type(v) == 'table' and (v.name ~= player.name) then
			ptymember = windower.ffxi.get_mob_by_name(v.name)
			if not v.mob then
				atcwarn('[FOLLOW]: ' .. v.name .. ' is not in zone.')			
			else
				if ptymember and ptymember.valid_target then
					if cmd == 'fon' then
						atc('[FOLLOW]: Setting ' ..v.name.. ' to start following.')
						windower.send_command('send ' .. v.name .. ' hb f dist 1.5;')
						windower.send_command('send ' .. v.name .. ' hb follow ' .. player.name)
					else
						atc('[FOLLOW]: Setting ' ..v.name.. ' to stop following.')
						windower.send_command('send ' .. v.name .. ' hb f off')
					end
				else
					atcwarn('[FOLLOW]: ' .. v.name .. ' is not in range.')
				end
			end
		end
	end
end

function unload(addonarg)
	atc('UNLOAD: Unloading Specific ADDON.')
	windower.send_command('lua u ' ..addonarg)
end

function reload(addonarg)
	atc('RELOAD: Reload Specific ADDON.')
	if addonarg == 'multictrl' then
		atcwarn('RELOAD: Not supported!')
	else
		windower.send_command('lua r ' ..addonarg)
	end
end



function reraise()
    local player_job = windower.ffxi.get_player()
    if player_job.main_job == "WHM" then
        if not haveBuff('Reraise') then
            while not (haveBuff('Reraise')) do
                atc("[Reraise]: Attempting to cast Reraise IV.")
                windower.send_command('input /ma "Reraise IV" <me>')
                coroutine.sleep(5)
            end
        else
            atc("[Reraise]: Already have reraise!")
        end
    elseif player_job.main_job == "SCH" and not haveBuff('SJ Restriction') then
        if not haveBuff('Reraise') then
            while not (haveBuff('Reraise')) do
                atc("[Reraise]: Attempting to cast Reraise III.")
                windower.send_command('input /ma "Reraise III" <me>')
                coroutine.sleep(5)
            end
        else
            atc("[Reraise]: Already have reraise!")
        end
    elseif player_job.sub_job == "WHM" and not haveBuff('SJ Restriction') then
        if not haveBuff('Reraise') then
            while not (haveBuff('Reraise')) do
                atc("[Reraise]: Attempting to cast Reraise.")
                windower.send_command('input /ma "Reraise" <me>')
                coroutine.sleep(5)
            end
        else
            atc("[Reraise]: Already have reraise!")
        end
    else
        if not haveBuff('Reraise') then
            atc("[Reraise]: Attempting item reraise")
            windower.send_command('reraise')
        else
            atc("[Reraise]: Already have reraise!")
        end
    end
end



function brd(cmd2)
	local player_job = windower.ffxi.get_player()
	local tank_jobs = find_job_charname('tank')
	
	local zone = windower.ffxi.get_info()['zone']

	if not tank_jobs and zone ~= 60 then
		atcwarn('[BRD] Abort! No tank jobs in party!')
		return
	end
	
	if player_job.main_job == "BRD" then
		if cmd2 == 'ambu' then
			atc('[BRD] Ambu')
			windower.send_command("hb buff " ..tank_jobs.. " mage's ballad III; hb buff " ..tank_jobs.. "  sentinel's scherzo; hb on")
		elseif cmd2 == 'ody' then
			atc('[BRD] Odyssey dispel')
			windower.send_command("hb buff " ..tank_jobs.. " sentinel's scherzo; hb buff " ..tank_jobs.. " foe sirvente; hb buff " ..tank_jobs.. " scop's operetta; hb buff " ..tank_jobs.. " victory march; hb on")
		elseif cmd2 == 'arebati' then
			atc('[BRD] Arebati')
			windower.send_command("hb buff " ..tank_jobs.. " ice carol; hb buff " ..tank_jobs.. " foe sirvente; hb buff " ..tank_jobs.. " scop's operetta; hb buff " ..tank_jobs.. " ice carol II; hb on")
		elseif cmd2 == 'ongo' then
			atc('[BRD] Ongo')
			windower.send_command("hb buff " ..tank_jobs.. " victory march; hb buff " ..tank_jobs.. " scop's operetta; hb buff " ..tank_jobs.. " blade madrigal; hb buff " ..tank_jobs.. " mage's ballad iii; hb on")
		elseif zone == 60 then
			atc('[BRD] Peach Staging in Ashu Talif')
		elseif cmd2 == 'reset' then
			atc('[BRD] Reset')
			windower.send_command("hb nobuff " ..tank_jobs.. " all")
		elseif cmd2 == 'sv5' then
			atc('[BRD] SV5')
			windower.send_command('sing off; sing pl sv5; gs c set autozergmode on')
		elseif cmd2 == 'nitro' then
			atc('[BRD] NITRO')
            windower.send_command('input /ja "Nightingale" <me>; wait 1.5; input /ja "Troubadour" <me>;')
			--windower.send_command('sing off; input /ja "Nightingale" <me>; wait 1.5; input /ja "Troubadour" <me>')
		elseif cmd2 == 'zerg' then
			windower.send_command('sing off; gs c set autozergmode on')
		elseif cmd2 == 'dummy' then
			windower.send_command("input /ma 'Puppet's Operetta' <me>")
		else
			atc('[BRD] Invalid command')
		end
	else
		atc('[BRD] Incorrect job, skipping.')
	end
end

function bst(cmd2)
	local player_job = windower.ffxi.get_player()
    local petjug = ''
	if player_job.main_job == "BST" then
		if cmd2 == 'mboze' or cmd2 == 'arebati' then
            if cmd2 == 'mboze' then petjug='ScissorlegXerin' end
            if cmd2 == 'arebati' then petjug='SweetCaroline' end
			atc('[BST] Killer Toggle')
            windower.send_command('gs c set AutoCallPet off; gs c set AutoFightMode off; gs c set AutoReadyMode off; gs c set JugMode '..petjug..'; wait 5.0; input /ja "Leave" <me>; wait 2.5; gs c set AutoCallPet on')
			windower.send_command:schedule(11.0, 'input /ja "Killer Instinct" <me>; gs c set JugMode FatsoFargann; wait 3.5; input /ja "Leave" <me>; wait 3.5; gs c set AutoCallPet on; gs c set AutoReadyMode on;')
		elseif cmd2 == 'init' then
			atc('[BST] Use Killer then reset to TP pet')
			windower.send_command('wait 1.5; input /ja "Killer Instinct" <me>; wait 1.8; gs c set JugMode FatsoFargann; input /ja "Leave" <me>; wait 1.8; input /ja "Call Beast" <me>; gs c set AutoCallPet on;')
		else
			atc('[BST] Invalid command')
		end
	else
		atc('[BST] Incorrect job, skipping.')
	end
end

function cor(cmd, mob_index)
	local player_job = windower.ffxi.get_player()
    local mob = mob_index and windower.ffxi.get_mob_by_index(mob_index)
    local world = res.zones[zone_id].name
    
	if player.main_job ~= "COR" then
		atc('[COR] Incorrect job, skipping.')
		return
	end
	
	if cmd == 'melee' then
		atc('[COR] Melee rolls + higher radius')
		windower.send_command('gs c set luzafring on; roll melee;')			
	elseif cmd == 'back' then
		atc('[COR] Backline rolls + lower radius')
		windower.send_command('gs c set luzafring off; roll roll1 warlock; roll roll2 gallant;')
	elseif cmd == 'aoe' then
		atc('[COR] Set Luzaf ON')
		windower.send_command('gs c set luzafring on')
	elseif cmd == 'statue' and not(areas.Cities:contains(world)) then
		atc('[COR] Killing statues')
		windower.send_command('gs c killstatue')
	elseif cmd == 'leaden' and not(areas.Cities:contains(world)) then
		atc('[COR] Leaden Salute')
		if mob and player_job.vitals.tp > 1000 and (math.sqrt(mob.distance) < 21) then
			local self_vector = windower.ffxi.get_mob_by_id(player_job.id)
			local angle = (math.atan2((mob.y - self_vector.y), (mob.x - self_vector.x))*180/math.pi)*-1
			windower.ffxi.turn((angle):radian())
			windower.send_command:schedule(0.75,'input /ja \'Leaden Salute\' ' .. mob.id)
		else
			atc('[COR] Target too far or not enough TP!')
		end
	else
		atc('[COR] Invalid command')
	end
end

function sch(cmd2)
	local player_job = windower.ffxi.get_player()
	if player_job.main_job == "SCH" then
		if cmd2 == 'heal' then
			atc('SCH Stance: Healing')
			autoarts='Light'
			windower.send_command('gs c set autoarts light; hb enable cure; hb enable curaga; hb enable na; wait 2; gs c set autobuffmode Healing')
		elseif cmd2 == 'nuke' then
			atc('SCH Stance: Nuking')
			autoarts='Dark'
			windower.send_command('gs c set autoarts dark; hb disable cure; hb disable curaga; hb disable na; wait 2; gs c set autobuffmode Nuking')
		elseif cmd2 == 'rebuff' then
			atc('SCH Rebuff')
			windower.send_command('gs c set autoarts off; hb disable cure; hb disable curaga; hb disable na; gs c set autobuffmode off;')
			coroutine.sleep(1.8)
			windower.send_command('input /ja "Tabula Rasa" <me>; wait 1.8; input /ja "Light Arts" <me>; wait 1.8; input /ja "Accession" <me>; wait 1.8; input /ja "Perpetuance" <me>; wait 1.8; regen5 me')
			windower.send_command:schedule(13.0, 'input /ja "Penury" <me>; wait 1.8; input /ja "Accession" <me>; wait 1.8; input /ja "Perpetuance" <me>; wait 1.8; embrava me')
			windower.send_command:schedule(25.0, 'input /ja "Perpetuance" <me>; wait 1.6; regen5 '..find_job_charname('RUN'))
			windower.send_command:schedule(32.0, 'input /ja "Penury" <me>; wait 1.8; input /ja "Perpetuance" <me>; wait 1.8; embrava '..find_job_charname('RUN'))
		else
			atc('SCH Stance: No parameter specified')
		end
	else
		atc('SCH Stance: Not SCH')
	end
end

function turnaround()
	if not( player.main_job == 'PLD' or player.main_job == 'RUN') then
		windower.send_command('gaze ap off')
		local target = windower.ffxi.get_mob_by_target('t')
		local self_vector = windower.ffxi.get_mob_by_id(player.id)
		local angle = (math.atan2((target.y - self_vector.y), (target.x - self_vector.x))*180/math.pi)*-1
		coroutine.sleep(0.6)
		windower.ffxi.turn((getAngle()+180):radian()+math.pi)
	end
	--windower.ffxi.turn:schedule(3.3,((angle):radian()))
end

function turnback()
	windower.send_command('gaze ap on')
end

function lockstyle(cmd)
	if cmd and cmd:lower() == 'off' then
		atc('[LockStyle] OFF')
		windower.chat.input('/lockstyle off')
		return
	end

	for key,jobs in pairs (res.jobs) do
		if not S{'NON','MON'}:contains(jobs.ens) and player.main_job == jobs.ens then
			atc('[LockStyle] - '..jobs.ens)
			windower.chat.input('/lockstyleset '..key)
		end
	end
end

function ws(cmd2)
	if cmd2 == 'off' then
		atc('[WS]: AutoWS DISABLED')
		settings.autows = false
		windower.send_command('gs c set autowsmode off')
	elseif cmd2 == 'on' then
		atc('[WS]: AutoWS ACTIVE')
		settings.autows = true
		windower.send_command('gs c set autowsmode on')
	else
		atcwarn('[WS]: Invalid parameter specified.')
	end
	display_box()
end

function autosub(cmd2)
	
	if cmd2 == 'off' then
		if player.sub_job == "SCH" or player.main_job == "SCH" then
			if player.main_job ~= "RDM" then
				windower.send_command('gs c set autosubmode off')
			end
		end
		atc('[SLEEP]: AutoSubMode OFF')
		settings.autosub = 'off'
	elseif cmd2 == 'sleep' then
		if player.sub_job == "SCH" or player.main_job == "SCH" then
			if player.main_job ~= "RDM" then
				windower.send_command('gs c set autosubmode sleep')
			end
		end
		atc('[SLEEP]: AutoSubMode SLEEP')
		settings.autosub = 'sleep'
    elseif cmd2 == 'on' then
		if player.sub_job == "SCH" or player.main_job == "SCH" then
			if player.main_job ~= "RDM" then
				windower.send_command('gs c set autosubmode on')
			end
		end
		atc('[SLEEP]: AutoSubMode ON')
		settings.autosub = 'on'
	end
	display_box()
end

function food(cmd2)
	local MeleeJobs = S{'WAR','SAM','DRG','NIN','MNK','COR','BLU','DNC','THF','RNG','DRK','PUP','BST'}
	local Tanks = S{'RUN','PLD'}
    local MageJobs = S{'WHM','RDM','SCH','BLM','GEO','SMN','BRD'}
	
	local player_job=windower.ffxi.get_player()
	
	if cmd2 == 'normal' then
        if MeleeJobs:contains(player_job.main_job) then
            atc('[Food] - Normal')
            windower.send_command('input /item "Grape Daifuku" <me>')
        elseif Tanks:contains(player_job.main_job) then
            atc('[Food] - Normal')
            windower.send_command('input /item "Om. Sandwich" <me>')
        end
	elseif cmd2 == 'hybrid' then
        if S{'SAM','NIN','COR'}:contains(player_job.main_job) then
            atc('[Food] - Hybrid')
            windower.send_command('input /item "Rolan. Daifuku" <me>')
        end
    elseif cmd2 == 'macc' then
        if MageJobs:contains(player_job.main_job) then
            atc('[Food] - MACC')
            windower.send_command('input /item "Tropical Crepe" <me>')
        end
	elseif cmd2 == 'on' then
		atc('[Food] - ON')
		windower.send_command('gs c set autofoodmode on;')
	elseif cmd2 == 'off' then
		atc('[Food] - OFF')
		windower.send_command('gs c set autofoodmode off;')
	else
        atc('[Food]: No group specified')
	end
end

function rng(cmd2)
	local player_job=windower.ffxi.get_player()
	local RangedJobs = S{'RNG','COR'}
	
	if cmd2 == 'off' then
		atc('RNG Helper DISABLED')
		settings.rangedmode = false
		if RangedJobs:contains(player_job.main_job) then
			windower.send_command('gs c set rnghelper off')
		end
	elseif cmd2 == 'on' then
		atc('RNG Helper ACTIVE')
		settings.rangedmode = true
		if RangedJobs:contains(player_job.main_job) then
			windower.send_command('gs c set rnghelper on')
		end
	end
	display_box()
end


function smartws(cmd2)
	if cmd2 == 'off' then
		atc('Smart WS Helper DISABLED')
		settings.smartws = false
	elseif cmd2 == 'on' then
		atc('Smart WS Helper ACTIVE')
		settings.smartws = true
	else
		atc('Smart WS Target is now: '..cmd2:capitalize())
		settings.smartws_target = cmd2:capitalize()
	end
	display_box()
end

function shobu()
    local target = windower.ffxi.get_mob_by_target()
    local get_items = windower.ffxi.get_items
    local set_equip = windower.ffxi.set_equip
    local item_array = {}
    item_info = {[1]={id=26789,japanese='尚武鳳凰兜',english='"Shobuhouou Kabuto"',slot=4},}
    lang = string.lower(windower.ffxi.get_info().language)
    
    if target and not (target.is_npc) then
    
        for bag_id in pairs(res.bags:equippable(true)) do
            local bag = get_items(bag_id)
            for _,item in ipairs(bag) do
                if item.id > 0  then
                    item_array[item.id] = item
                    item_array[item.id].bag = bag_id
                    item_array[item.id].bag_enabled = bag.enabled
                end
            end
        end

        for index,stats in pairs(item_info) do
            local item = item_array[stats.id]
            if item and item.bag_enabled then
            
                local ext = extdata.decode(item)
                local enchant = ext.type == 'Enchanted Equipment'
                local recast = enchant and ext.charges_remaining > 0 and math.max(ext.next_use_time+18000-os.time(),0)
                local usable = recast and recast == 0
                local equip_slot = res.slots[stats.slot].en
                atc(stats[lang],usable and '' or recast and recast..' sec recast.')
                if usable or ext.type == 'General' then
                    if enchant and item.status ~= 5 then --not equipped
                        windower.send_command('gs disable '..equip_slot..'; input /equip '..equip_slot..' '..windower.to_shift_jis(stats[lang]))
                        repeat --waiting cast delay
                            coroutine.sleep(1)
                            local ext = extdata.decode(get_items(item.bag,item.slot))
                            local delay = ext.activation_time+18000-os.time()
                            if delay > 0 then
                                atc(stats[lang],delay)
                            elseif log_flag then
                                log_flag = false
                                atc('Item use within 3 seconds..')
                            end
                        until ext.usable or delay > 30
                    end
                    windower.chat.input('/item '..windower.to_shift_jis(stats[lang])..' '..target.id)
                    coroutine.sleep(9.2)
                    windower.send_command('gs enable '..equip_slot)
                    break;
                end
            elseif item and not item.bag_enabled then
                atc('You cannot access '..stats[lang]..' from ' .. res.bags[item.bag].name ..' at this time.')
            else
                atc('You don\'t have '..stats[lang]..'.')
            end
        end
    else
        atc("[Shobu] Invalid target.")
    end
end

function buffup()
	atc('[Buffup] Buffing up jobs.')
	local player_job = windower.ffxi.get_player()
	local buff_jobs = S{"WHM","RDM","GEO","BRD","SMN","BLM","SCH","RUN"}
	if buff_jobs:contains(player_job.main_job) then
		windower.send_command('gs c buffup')
	else
		atc('[Buffup] Not a buffup job')
	end
end

function rebuff()
	atc('[Rebuff] Buffing up jobs.')
	local player_job = windower.ffxi.get_player()
	local buff_jobs = S{"WHM","RDM","GEO","BRD","SMN","BLM","SCH","RUN"}
	if buff_jobs:contains(player_job.main_job) then
		windower.send_command('gs c buffup Rebuff')
        if player_job.main_job == "BRD" then
            windower.send_command('sing reset')
        end
	else
		atc('[Rebuff] Not a rebuff job')
	end
end

function fight()
	atc('Fight distance.')
	local player_job = windower.ffxi.get_player()
	if player_job.main_job == "WHM" then
		windower.send_command('hb f dist 19;')
	elseif player_job.main_job == "GEO" or player_job.main_job == "BRD" then
		windower.send_command('hb f dist 4.3')
	elseif player_job.main_job == "SMN" or player_job.main_job == "BLM" or player_job.main_job == "SCH" or player_job.main_job == "RDM" then
		windower.send_command('hb f dist 19')
	else
		windower.send_command('hb f dist 3.5')
	end
end

function fightmage()
	atc('Fight MAGE distance.')
	local player_job = windower.ffxi.get_player()
	local mage_jobs = S{"WHM","RDM","GEO","BRD","SMN","BLM","SCH","COR"}
	
	if mage_jobs:contains(player_job.main_job) then
		windower.send_command('hb f dist 19.5;')
	else
		windower.send_command('hb f dist 3.5')
	end
end

function fightsmall()
	atc('Close quarters fight distnace.')
	local player_job = windower.ffxi.get_player()
	if player_job.main_job == "WHM" then
		windower.send_command('hb f dist 6')
	elseif player_job.main_job == "GEO" or player_job.main_job == "BRD" then
		windower.send_command('hb f dist 4.3')
	else
		windower.send_command('hb f dist 3.1')
	end
end

function send(commands)
	atc('[Send] Sending all chars with delay: \"' .. commands .. '\"')
	windower.send_command(commands)
end



local function as_helper(cmd)
    if cmd and cmd == 'reset' then
    	windower.send_command('hb as off; hb as attack off; hb as nolock off; hb as sametarget off; gaze ap off;')
    elseif cmd and cmd == 'lead_reset' then
        windower.send_command('hb f off; hb as off; hb as attack off; hb as nolock off; hb as sametarget off; gaze ap off;')
    end
end

function as(namearg,cmd,cmd2)

	player=windower.ffxi.get_player()
	if check_leader_in_same_party(namearg) == true then
		if cmd == 'melee' then
			if player.name:lower() == namearg:lower() then
				atc('[Assist] Leader for assisting - Melee ONLY')
				as_helper('lead_reset')
			else
				local player_job = windower.ffxi.get_player()
				local MeleeJobs = S{'WAR','SAM','DRG','DRK','NIN','MNK','COR','BLU','PUP','DNC','THF','BST','RNG'}		
				if MeleeJobs:contains(player_job.main_job) then
					atc('[Assist] Attack -> ' ..namearg)
					windower.send_command('hb as ' .. namearg)
					windower.send_command('hb f ' .. namearg)
					windower.send_command('wait 0.5; hb as nolock off; hb as attack on;')
					windower.send_command('wait 0.5; hb on; gaze ap on')
				else
					atc('[Assist] Disabling attack, not melee job.')
					windower.send_command('hb assist attack off')
				end
			end
		elseif cmd == 'mag' then
			if player.name:lower() == namearg:lower() then
				atc('[Assist] Leader for assisting - Melee+Mage BRD/RDM')
				as_helper('lead_reset')
			else
				local player_job = windower.ffxi.get_player()
				local MeleeJobs = S{'WAR','SAM','DRG','DRK','NIN','MNK','COR','BLU','PUP','DNC','THF','BST','RNG','BRD','RDM'}		
				if MeleeJobs:contains(player_job.main_job) then
					atc('[Assist] Attack -> ' ..namearg)
					windower.send_command('hb as ' .. namearg)
					windower.send_command('hb f ' .. namearg)
					windower.send_command('wait 0.5; hb as nolock off; hb as attack on;')
					windower.send_command('wait 0.5; hb on; gaze ap on')
				else
					atc('[Assist] Disabling attack, not melee job.')
					windower.send_command('hb assist attack off')
				end
			end
		elseif cmd == 'all' then
			if player.name:lower() == namearg:lower() then
				atc('[Assist] Leader for assisting attack - ALL JOBS')
				as_helper('lead_reset')
			else
				atc('[Assist] Attack -> ' .. namearg)
				windower.send_command('hb as ' .. namearg)
				windower.send_command('hb f ' .. namearg)
				windower.send_command('wait 0.5; hb as nolock off; hb as attack on;')
				windower.send_command('wait 0.5; hb on; gaze ap on')
			end
		elseif cmd == 'on' then
			if player.name:lower() == namearg:lower() then
				atc('[Assist] Leader for assisting in spells - ALL JOBS')
				as_helper('lead_reset')
			else
				atc('[Assist] Spell only / no target or lock  -> ' ..namearg)
				windower.send_command('hb as ' .. namearg .. '; hb as nolock on;')
			end
		elseif cmd == 'lock' then
			if player.name:lower() == namearg:lower() then
				atc('[Assist] Leader for assisting with lock - ALL JOBS')
				as_helper('lead_reset')
			else
				atc('[Assist] Lock on assist -> ' ..namearg)
				windower.send_command('hb as ' .. namearg .. '; hb as nolock off; gaze ap off')
			end
		elseif cmd == 'same' then
			if player.name:lower() == namearg:lower() then
				atc('[Assist] Leader for assisting with same target(set target) - ALL JOBS')
				as_helper('lead_reset')
			elseif cmd2 == 'on' then
				atc('[Assist] Same target attack [ON] -> ' ..namearg)
				windower.send_command('hb as sametarget on;')
			elseif cmd2 == 'off' then
				atc('[Assist] Same target attack [OFF] -> ' ..namearg)
				windower.send_command('hb as sametarget off;')
			else
				atc('[Assist] ABORT: No argument specified for Same Target [ON/OFF]' ..namearg)
			end
		elseif cmd == 'off' then
			atc('[Assist] OFF')
			as_helper('reset')
		end
	else
		atc('[Assist] ABORT: You are not in the party or alliance!')
	end
end

function d2()
	get_spells = windower.ffxi.get_spells()
	spell = S{player.main_job_id,player.sub_job_id}[4] and (get_spells[261] 
		and {japanese='デジョン',english='"Warp"'} or get_spells[262] 
		and {japanese='デジョンII',english='"Warp II"'})
	
	if not spell then
		atc('[D2] Not BLM main or sub or no warp spells.')
		return
	end
	
	-- Have right job/sub job and spells
	for k, v in pairs(windower.ffxi.get_party()) do
		if type(v) == 'table' and v.name ~= player.name then
			ptymember = windower.ffxi.get_mob_by_name(v.name)
			-- check if party member in same zone.
			if v.mob ~= nil and math.sqrt(ptymember.distance) < 19 and windower.ffxi.get_mob_by_name(v.name).in_party then
				-- Checking recast
				check_mp_rest(262)
				coroutine.sleep(1.5)
				atc('[D2] Warping ' .. v.name)
				windower.send_command('input /ma "Warp II" ' .. v.name)
				coroutine.sleep(2.0)

				--Check if still casting
				while isCasting do
					coroutine.sleep(0.8)
				end
			end
		end
	end

	-- Warp self
	check_mp_rest(261)
	coroutine.sleep(2.2)
	atc('[D2] Warping')
	windower.send_command('input /ma "Warp" ' .. player.name)

end

function check_mp_rest(spell)
	isWaiting = true
	while isWaiting == true do
		coroutine.sleep(0.75)
		
		spell_recasts = windower.ffxi.get_spell_recasts()
		playernow = windower.ffxi.get_player().vitals.mp

		if playernow and playernow >= res.spells[spell].mp_cost and spell_recasts[spell] == 0 then
			if isResting then	-- If resting then stop resting
				coroutine.sleep(2.5)
				windower.send_command('input /heal')
			end
			isWaiting = false
		elseif spell_recasts[spell] > 0 then -- Recast
			coroutine.sleep(1.8)
		else --Not enough MP 
			if not isResting then	-- If not resting then rest
				atc('[MP Check] Resting for MP')
				windower.send_command('input /heal')
				coroutine.sleep(3)
			end
			isWaiting = true
		end
	end
end

-- Burn functions SMN/GEO
function burn(cmd2,cmd3)
	
	player = windower.ffxi.get_player()
	
	if cmd2:lower() == 'avatar' then
		if cmd3 ~= nil then
			if cmd3:lower() == 'ramuh' then
				settings.avatar = 'ramuh'
				--settings.save()
			elseif cmd3:lower() == 'ifrit' then
				settings.avatar = 'ifrit'
				--settings.save()
			elseif cmd3:lower() == 'siren' then
				settings.avatar = 'siren'
				
			else
				atc('Invalid Avatar choice')
			end
		else
			atc('Missing argument for Avatar')
		end
		
	elseif cmd2:lower() == 'on' then
		settings.active = true
		local tank_char_name = find_job_charname('tank','1',true, true)
		windower.add_to_chat(11,'Usage: //mc burn Command Variable \n')
		windower.add_to_chat(11,'\ ')
		windower.add_to_chat(11,'-Commands- \ \ \ -Variables- \n')
		windower.add_to_chat(11,'\ ')
		windower.add_to_chat(11,'\ avatar \ \ \ \ \ \ \ \ \ ramuh/ifrit')
		windower.add_to_chat(11,'\ indi \ \ \ \ \ \ \ \ \ \ \ \ torpor/malaise')
		windower.add_to_chat(11,'\ assist \ \ \ \ \ \ \ \ \ \ name of character that is engaging mob, defaults to tank in party.')
		windower.add_to_chat(11,'\ init \ \ \ \ \ \ \ \ \ \ \ \ *** Intializes commands to all chars, MUST RUN THIS AFTER setting variables. ***')
		settings.assist = tank_char_name
		if not settings.smnhelp then
			smn()
			send_to_IPC('smn')
		end
	elseif cmd2:lower() == 'off' then
		settings.active = false
	elseif cmd2:lower() == 'indi' then
		if cmd3 ~= nil then
			if cmd3:lower() == 'torpor' then
				settings.indi = 'torpor'
			elseif cmd3:lower() == 'malaise' then
				settings.indi = 'malaise'
			elseif cmd3:lower() == 'refresh' then
				settings.indi = 'refresh'
			elseif cmd3:lower() == 'fury' then
				settings.indi = 'fury'
			end
		else
			atc('Missing argument for INDI')
		end
	elseif cmd2:lower() == 'init' then
		
		if settings.assist == '' then
			atc('Cannot initialize until you set assist name')
		else
			for k, v in pairs(windower.ffxi.get_party()) do
				if type(v) == 'table' then
					if string.lower(v.name) == string.lower(settings.assist) then
						ptymember = windower.ffxi.get_mob_by_name(v.name)
						if v.mob == nil or not ptymember.valid_target then
							atcwarn('[BurnSet] ' ..v.name .. ' is not in zone or out of range.')
						else
							atc('[BurnSet] Initialize HB and assist, and disabled cures')
							
							local healers = S{'COR','WHM','RDM','RUN','THF','SCH'}
							-- Potential healers or /SJ healers don't disable hb.
							if not (healers:contains(player.main_job)) then
								windower.send_command('hb reload; wait 1.5; hb disable cure; hb disable na; hb assist ' ..settings.assist .. '; hb as nolock off; wait 1.0; hb on')
							end
							if player.main_job == 'THF' then
								atc('[BurnSet] THF Init')
								windower.send_command('wait 1.0; hb f dist 1.5; hb f ' ..settings.assist)
								windower.send_command('hb disable cure; hb disable na; hb assist ' ..settings.assist .. '; hb as nolock off; wait 1.0; hb on')
							elseif player.main_job == 'BRD' then
								atc('[BurnSet] BRD Init')
								windower.send_command('wait 1.0; hb f dist 10; hb f ' ..settings.assist)
								windower.send_command('sing n off; sing p off; sing d off; sing on; hb disable cure; hb disable na; hb assist ' ..settings.assist .. '; hb as nolock off; wait 1.0; hb on')
								if settings.indi == 'malaise' then
									windower.send_command('hb debuff fire threnody ii')
								end
							elseif player.main_job == 'RUN' then
								atc('[BurnSet] RUN Init')
								windower.send_command('gs c set autobuffmode off; hb f off; gs c set runeelement tenebrae')
								if settings.indi == 'malaise' then
									windower.send_command('gs c set runeelement ignis')
								end
							elseif player.main_job == 'COR' then
								atc('[BurnSet] COR Init')
								windower.send_command('hb reload; wait 1.5; hb on')
								if settings.indi == 'malaise' then
									windower.send_command('roll roll1 beast; wait 1.0; roll roll2 pup;')
								else
									windower.send_command('roll roll1 beast; wait 1.0; roll roll2 drachen;')
								end
							elseif player.main_job == 'SMN' then
								atc('[BurnSet] SMN Init')
								if settings.avatar == 'ramuh' then
									windower.send_command('input /ma "Ramuh" <me>; gs c set avatar ramuh;')
								elseif settings.avatar == 'ifrit' then
									windower.send_command('input /ma "Ifrit" <me>; gs c set avatar ifrit')
								elseif settings.avatar == 'siren' then
									windower.send_command('input /ma "Siren" <me>; gs c set avatar siren')
								end
							elseif player.main_job == 'GEO' then
								atc('[BurnSet] GEO Init')
								windower.send_command('gs c set autobuffmode off')
								if settings.indi == 'torpor' then
									windower.send_command('gs c autogeo frailty; wait 1; gs c autoindi torpor')
									windower.send_command('input /ma "Indi-Torpor" <me>;')
								elseif settings.indi == 'malaise' then
									windower.send_command('gs c autogeo frailty; wait 1; gs c autoindi malaise')
									windower.send_command('wait 2.0; hb follow ' ..settings.assist .. '; wait 1.0; hb f dist 5')
									windower.send_command('input /ma "Indi-Malaise" <me>;')
								elseif settings.indi == 'refresh' then
									windower.send_command('gs c autogeo frailty; wait 1; gs c autoindi refresh')
									windower.send_command('input /ma "Indi-Refresh" <me>;')
								elseif settings.indi == 'fury' then
									windower.send_command('gs c autogeo frailty; wait 1; gs c autoindi fury')
									windower.send_command('input /ma "Indi-Fury" <me>;')
								end
							end
						end
					end
				end
			end
		end
	elseif cmd2:lower() == 'assist' then
		if cmd3 ~= nil then
			for k, v in pairs(windower.ffxi.get_party()) do
				if type(v) == 'table' then
					if string.lower(v.name) == string.lower(cmd3) then
						ptymember = windower.ffxi.get_mob_by_name(v.name)
						if v.mob == nil or not ptymember.valid_target then
							atcwarn('[BurnSet] ' ..v.name .. ' is not in zone or too far away, HB will NOT function correctly.')
						else
							atc('You are now assisting ' ..cmd3)
							settings.assist = cmd3
						end
					end
				end
			end
		else
			atc('[BurnSet] Missing argument for ASSIST')
		end
	else
		atc('[BurnSet] Invalid command')
	end
	display_box()
end

function blu(cmd,mob_index)
	local world = res.zones[zone_id].name
	local mob = mob_index and windower.ffxi.get_mob_by_index(mob_index)

	if player.main_job ~= 'BLU' or areas.Cities:contains(world) then
		atc('[BLU] Abort - Not BLU job or in cities area.')
		return
	end
	if cmd then
		if cmd and cmd:lower() == 'tenebral' then
			atc('[BLU] Tenebral Crush')
			if not (player.target_locked) then
				windower.send_command("input /ma 'Tenebral Crush' " .. mob.id)
			else
				windower.send_command('input /ma "Tenebral Crush" <t>')
			end
		elseif cmd and cmd:lower() == 'anvil' then
			atc('[BLU] Anvil Lightning')
			if not (player.target_locked) then
				windower.send_command("input /ma 'Anvil Lightning' " .. mob.id)
			else
				windower.send_command('input /ma "Anvil Lightning" <t>')
			end
		elseif cmd and cmd:lower() == 'spectral' then
			atc('[BLU] Spectral Floe')
			if not (player.target_locked) then
				windower.send_command("input /ma 'Spectral Floe' " .. mob.id)
			else
				windower.send_command('input /ma "Spectral Floe" <t>')
			end
		elseif cmd and cmd:lower() == 'entomb' then
			atc('[BLU] Entomb')
			if not (player.target_locked) then
				windower.send_command("input /ma 'Entomb' " .. mob.id)
			else
				windower.send_command('input /ma "Entomb" <t>')
			end
		elseif cmd and cmd:lower() == 'searing' then
			atc('[BLU] Searing Tempest')
			if not (player.target_locked) then
				windower.send_command("input /ma 'Searing Tempest' " .. mob.id)
			else
				windower.send_command('input /ma "Searing Tempest" <t>')
			end
		elseif cmd and cmd:lower() == 'spate' then
			atc('[BLU] Scouring Spate')
			if not (player.target_locked) then
				windower.send_command("input /ma 'Scouring Spate' " .. mob.id)
			else
				windower.send_command('input /ma "Scouring Spate" <t>')
			end
		elseif cmd and cmd:lower() == 'silent' then
			atc('[BLU] Silent Storm')
			if not (player.target_locked) then
				windower.send_command("input /ma 'Silent Storm' " .. mob.id)
			else
				windower.send_command('input /ma "Silent Storm" <t>')
			end
		elseif cmd and cmd:lower() == 'blinding' then
			atc('[BLU] Blinding Fulgor')
			if not (player.target_locked) then
				windower.send_command("input /ma 'Blinding Fulgor' " .. mob.id)
			else
				windower.send_command('input /ma "Blinding Fulgor" <t>')
			end
		elseif cmd and cmd:lower() == 'subduction' then
			atc('[BLU] Subduction')
			if not (player.target_locked) then
				windower.send_command("input /ma 'Subduction' " .. mob.id)
			else
				windower.send_command('input /ma "Subduction" <t>')
			end
		else 
			atc('[BLU] Invalid Command')
		end
		windower.send_command('wait 1.9; mc cc ' .. mob.index)
	end
end

function smn(leader_smn,cmd2,cmd3)
	player=windower.ffxi.get_player()

	if cmd2 and cmd2:lower() == 'on' then
		atc('[SMN] Helper for SMN ON')
		settings.smnhelp = true
	elseif cmd2 and cmd2:lower() == 'off' then
		atc('[SMN] Helper for SMN OFF')
		settings.smnhelp = false
	elseif cmd2 == nil then
		if settings.smnhelp then
			atc('[SMN] Helper for SMN OFF')
			settings.smnhelp = false
		else
			atc('[SMN] Helper for SMN ON')
			settings.smnhelp = true
		end
	end
	
	--Active
	if settings.smnhelp then
		
		if cmd2 and cmd2:lower() == 'sc' then
			if cmd3 and cmd3:lower() == 'on' then
				atc('[SMN] SC ON')
				settings.smnsc = true
			elseif cmd3 and cmd3:lower() == 'off' then
				atc('[SMN] SC OFF')
				settings.smnsc = false
			end
			-- if settings.smnsc then
				-- atc('SMN Skillchain DISABLED')
				-- settings.smnsc = false
			-- else
				-- atc('SMN Skillchain ACTIVE')
				-- settings.smnsc = true
			-- end
		elseif cmd2 and cmd2:lower() == 'auto' then
			if cmd3 and cmd3:lower() == 'off' then
				atc('[SMN] Auto OFF')
				settings.smnauto = false
				if player.main_job == 'SMN' then
					windower.send_command('gs c set AutoAvatarMode off; gs c set AutoBPMode off; gs c set AutoSMNSCMode off;')
				end
			-- if settings.smnauto then
				-- atc('SMN Auto DISABLED')
				-- settings.smnauto = false
				-- if player.main_job == 'SMN' then
					-- windower.send_command('gs c set AutoAvatarMode off; gs c set AutoBPMode off')
				-- end
			elseif cmd3 and cmd3:lower() == 'on' then
				--Auto SC
				if settings.smnsc then
					if settings.smnlead ~= nil then
						atc('[SMN] Auto ON')
						settings.smnauto = true
						-- Leader does AutoBP and Ramuh
						if player.name:lower() == settings.smnlead and player.main_job == 'SMN' then
							windower.send_command('gs c set avatar Ramuh; gs c set AutoBPMode on; gs c set AutoSMNSCMode on;')
						-- Other SMN's use Ifrit and just autoavatar
						else
							if player.main_job == 'SMN' then
								windower.send_command('gs c set avatar Ifrit; gs c set AutoBPMode off; gs c set AutoAvatarMode on')
							end
						end
					else
						atcwarn('[SMN] No leader, cannot start Auto BP SC')
					end
				--BP Spam
				else
					if player.main_job == 'SMN'  then
						windower.send_command('gs c set avatar Ramuh; gs c set AutoBPMode on')
					end
					settings.smnauto = true
				end
			end
		elseif cmd2 and cmd2:lower() == 'lead' and cmd3 ~= nil then
			settings.smnlead = cmd3
		end
		-- SMN Auto/manual logic
		if player.main_job == 'SMN' then
			if cmd2 then
				if cmd2:lower() == 'assault' then
					windower.send_command('input /ja "Assault" <t>')
				elseif cmd2:lower() == 'release' then
					windower.send_command('input /ja "Release" <me>')
				elseif cmd2:lower() == 'retreat' then
					windower.send_command('input /ja "Retreat" <me>')
				elseif cmd2:lower() == 'vs' then
					if settings.smnsc then
						if player.name ~= leader_smn then
							windower.send_command('wait 4.0; input /ja "Flaming Crush" <t>')
						end
					else
						windower.send_command('input /ja "Volt Strike" <t>')
					end
				elseif cmd2:lower() == 'fc' then
					if settings.smnsc then
						if player.name ~= leader_smn then
							windower.send_command('wait 4.0; input /ja "Volt Strike" <t>')
						end
					else
						windower.send_command('input /ja "Flaming Crush" <t>')
					end
				elseif cmd2:lower() == 'ha' then
					if settings.smnsc then
						if player.name ~= leader_smn then
							windower.send_command('wait 4.0; input /ja "Flaming Crush" <t>')
						end
					else
						windower.send_command('input /ja "Hysteric Assault" <t>')
					end				
				elseif cmd2:lower() == 'ramuh' then
					if settings.smnsc then
						if player.name ~= leader_smn then
							windower.send_command('input /ma "Ifrit" <me>')
						end
					else
						windower.send_command('input /ma "Ramuh" <me>')
					end
				elseif cmd2:lower() == 'ifrit' then
					if settings.smnsc then
						if player.name ~= leader_smn then
							windower.send_command('input /ma "Ramuh" <me>')
						end
					else
						windower.send_command('input /ma "Ifrit" <me>')
					end
				elseif cmd2:lower() == 'siren' then
					if settings.smnsc then
						if player.name ~= leader_smn then
							windower.send_command('input /ma "Ifrit" <me>')
						end
					else
						windower.send_command('input /ma "Siren" <me>')
					end
				elseif cmd2:lower() == 'apogee' then
					windower.send_command('input /ja "Apogee" <me>')
				elseif cmd2:lower() == 'thunderspark' then
					windower.send_command('input /ja "Thunderspark" <t>')
				elseif cmd2:lower() == 'thunderstorm' then
					windower.send_command('input /ja "thunderstorm" <t>')
				elseif cmd2:lower() == 'NB' then
					windower.send_command('input /ja "Nether Blast" <t>')
				elseif cmd2:lower() == 'diabolos' then
					windower.send_command('input /ma "Diabolos" <me>')
				elseif cmd2:lower() == 'super' then
					windower.send_command('input /item "Super Revitalizer" <me>')
				elseif cmd2:lower() == 'elixir' then
					windower.send_command('input /item "Lucid Elixir II" <me>')
					windower.send_command('input /item "Lucid Elixir I" <me>')
				end
			end
		end
	end
	display_box()
end	

function autosc(leader_char, cmd2)
	player=windower.ffxi.get_player()
	
	local autosc_jobs = S{'COR','SCH','BLM','RUN','BRD','RDM','GEO','DRK','BLU','WHM','WAR'}

	local autosc_cmd = cmd2 and cmd2:lower() or (settings.autosc and 'off' or 'on')
	if S{'off'}:contains(autosc_cmd) then
		atc('Helper for Auto SC DISABLED')
		settings.autosc = false
	elseif S{'on'}:contains(autosc_cmd) then
		atc('Helper for Auto SC ACTIVE')
		settings.autosc = true
	end
	
	if settings.autosc then
		if autosc_jobs:contains(player.main_job) then
			--Marmorkrebs [Thunder Burst 3 Step SC] / Raskovniche [Aero Burst 3 Step SC]
			if cmd2 and (cmd2:lower() == 'frostbite' or cmd2:lower() == 'freezebite') then
				local mob_name
				local element_nuke
				if cmd2:lower() == 'frostbite' then
					mob_name = 'Marmorkrebs'
					element_nuke = 'lightning'
				elseif cmd2:lower() == 'freezebite' then
					mob_name = 'Raskovniche'
					element_nuke = 'wind'
				end
	
				if player.main_job == 'SCH' then				
					atc('[AUTOSC] ENDING SCH - Water [Fragmentation]')
					windower.send_command('gs c set elementalmode '..element_nuke..'; gs c set autobuffmode off; gs c set autosubmode off; input /ja "Immanence" <me>')
					windower.send_command:schedule(3.3, 'input /ma "Water" '..windower.ffxi.get_mob_by_name(mob_name).id)
					windower.send_command:schedule(8.5, 'gs c elemental nuke '..mob_name)
					windower.send_command:schedule(14.5, 'gs c elemental nuke '..mob_name)
					windower.send_command:schedule(15.8, 'gs c set autobuffmode nuking; gs c set autosubmode off;')
				elseif player.main_job == 'BLM' then
					atc('[AUTOSC] BLM Nuke')
					windower.send_command('gs c set elementalmode '..element_nuke..'; gs c set autobuffmode off')
					windower.send_command:schedule(2.9, 'gs c elemental aja '..mob_name)
					windower.send_command:schedule(7.3, 'gs c elemental nuke '..mob_name)
					windower.send_command:schedule(12.7, 'gs c elemental nuke '..mob_name)
					windower.send_command:schedule(13.5, 'gs c set autobuffmode auto')
				elseif player.main_job == 'GEO' then
					atc('[AUTOSC] GEO Nuke')
					windower.send_command('gs c set elementalmode '..element_nuke..'')
					windower.send_command:schedule(5.4, 'gs c elemental nuke '..mob_name)
					windower.send_command:schedule(9.8, 'gs c elemental nuke '..mob_name)
					windower.send_command:schedule(13.7, 'gs c elemental nuke '..mob_name)
				elseif player.main_job == 'COR' then
					atc('[AUTOSC] COR Last Stand')
					local abil_recasts = windower.ffxi.get_ability_recasts()
					local latency = 0.7
					if abil_recasts[195] < latency then
						windower.send_command:schedule(3.6, 'gs c set elementalmode '..element_nuke..'; gs c elemental quickdraw '..windower.ffxi.get_mob_by_name(mob_name).id)
					end
					windower.send_command:schedule(11.0, 'input /ws "Last Stand" <t>')
					windower.send_command:schedule(14.6, 'autora start')
				elseif player.main_job == 'RUN' then
					local abil_recasts = windower.ffxi.get_ability_recasts()
					local latency = 0.7
					atc('[AUTOSC] Rayke/Gambit')
					if abil_recasts[116] < latency then
						windower.send_command('gs c set autobuffmode off; gs c set autotankmode off; gs c set autorunemode off')
						windower.send_command:schedule(3.1, 'input /ja "Gambit" <t>')
						windower.send_command:schedule(4.2, 'gs c set autobuffmode auto; gs c set autotankmode on; gs c set autorunemode on')
					elseif abil_recasts[119] < latency then
						windower.send_command('gs c set autobuffmode off; gs c set autotankmode off; gs c set autorunemode off')
						windower.send_command:schedule(3.1, 'input /ja "Rayke" <t>')
						windower.send_command:schedule(4.2, 'gs c set autobuffmode auto; gs c set autotankmode on; gs c set autorunemode on')
					elseif abil_recasts[25] < latency then
						windower.send_command:schedule(5.1, 'input /ja "Lunge" <t>')
					end
				end
			--Upheaval > Gambit/Rayke/Earth Shot > Leaden Saluate > Steel Cyclone > Wild fire.
			elseif cmd2 and cmd2:lower() == 'upheaval' then
				local ongo = windower.ffxi.get_mob_by_name('Ongo')
				if player.main_job == 'RUN' then
					local abil_recasts = windower.ffxi.get_ability_recasts()
					local latency = 0.7
					windower.send_command('hb off; gs c set autotankmode off; gs c set autobuffmode off; gs c set autorunemode off; gs c set autowsmode off')
					atc('[AUTOSC] Rayke/Gambit')
					if abil_recasts[116] < latency then
						windower.send_command('gs c set autobuffmode off; gs c set autotankmode off; gs c set autorunemode off')
						windower.send_command:schedule(3.1, 'input /ja "Gambit" <t>')
						--windower.send_command:schedule(4.2, 'gs c set autobuffmode auto; gs c set autotankmode on; gs c set autorunemode on')
					elseif abil_recasts[119] < latency then
						windower.send_command('gs c set autobuffmode off; gs c set autotankmode off; gs c set autorunemode off')
						windower.send_command:schedule(3.1, 'input /ja "Rayke" <t>')
						--windower.send_command:schedule(4.2, 'gs c set autobuffmode auto; gs c set autotankmode on; gs c set autorunemode on')
					end
					--windower.send_command:schedule(8.0,'gs c set autobuffmode off; gs c set autotankmode off; gs c set autorunemode off')
					windower.send_command:schedule(11.0, 'input /ws "Steel Cyclone" <t>')
					windower.send_command:schedule(12.0, 'gs c set autobuffmode auto; gs c set autotankmode on; gs c set autorunemode on')
				elseif player.main_job == 'COR' then
					atc('[AUTOSC] COR Leaden and Earth Shot')
					local abil_recasts = windower.ffxi.get_ability_recasts()
					local latency = 0.7
					if abil_recasts[195] < latency then
						windower.send_command:schedule(1.5, 'gs c set elementalmode Earth; gs c elemental quickdraw Ongo')
					end
					windower.send_command:schedule(3.3, 'input /ws "Leaden Salute" <t>')
					windower.send_command:schedule(6.9, 'autora start')
					windower.send_command:schedule(16.7, 'input /ws "Wildfire" <t>')
					windower.send_command:schedule(20.3, 'autora start')
				
				elseif player.main_job == 'BLM' then
					atc('[AUTOSC] BLM Nuke')
					local abil_recasts = windower.ffxi.get_ability_recasts()
					local latency = 0.7
					windower.send_command('gs c set elementalmode earth; gs c set autobuffmode off')
					windower.send_command:schedule(2.9, 'gs c elemental aja Ongo')
					windower.send_command:schedule(7.8, 'gs c elemental nuke Ongo')
					windower.send_command:schedule(13.2, 'gs c elemental nuke Ongo')
					if abil_recasts[35] < latency then
						windower.send_command:schedule(18.1, 'gs c elemental impact Ongo')
					else
						windower.send_command:schedule(18.1, 'gs c elemental nuke Ongo')
					end
					if abil_recasts[38] < latency then
						windower.send_command:schedule(20.5, 'gs c elemental burn Ongo')
					end
					windower.send_command:schedule(22.0, 'gs c set autobuffmode auto')
				elseif player.main_job == 'SCH' then
					atc('[AUTOSC] SCH Nuke')
					local nuke_target = windower.ffxi.get_mob_by_name('Ongo').id
					windower.send_command('gs c set elementalmode earth; gs c set autobuffmode off; hb disable cure; hb mincure 4')
					if (os.clock()-__helix_timer) > 300 or haveBuff('Tablua Rasa') then
						__helix_timer = os.clock()
						windower.send_command:schedule(3.2, 'gs c elemental helix Ongo ')
					else
						windower.send_command:schedule(4.1, 'gs c elemental nuke Ongo')
					end
					windower.send_command:schedule(9.6, 'gs c elemental nuke Ongo')
					windower.send_command:schedule(14.0, 'gs c elemental nuke Ongo')
					windower.send_command:schedule(19.0, 'gs c elemental nuke Ongo')
					windower.send_command:schedule(21.5, 'gs c set autobuffmode nuking; hb enable cure;')
				elseif player.main_job == 'GEO' then
					atc('[AUTOSC] GEO Nuke')
					windower.send_command('gs c set elementalmode earth;')
					windower.send_command:schedule(5.4, 'gs c elemental nuke Ongo')
					windower.send_command:schedule(10.3, 'gs c elemental nuke Ongo')
					windower.send_command:schedule(17.0, 'gs c elemental nuke Ongo')
					windower.send_command:schedule(21.8, 'gs c elemental nuke Ongo')
				end
			--Sortie 4 Step
			elseif cmd2 and cmd2:lower() == 'sortiesc' then
				windower.send_command('gs c set autobuffmode off; gs c set autowsmode off; sing off;')
				if player.main_job == 'DRK' then
					windower.send_command:schedule(0.2, 'input /ws "Herculean Slash" <t>')
					windower.send_command:schedule(8.8, 'input /ws "Herculean Slash" <t>')
				elseif player.main_job == 'WAR' then
					windower.send_command:schedule(3.9, 'input /ws "Crescent Moon" <t>')
					windower.send_command:schedule(14.3, 'input /ws "Crescent Moon" <t>')
				end
			--Sortie SC
			elseif cmd2 and cmd2:lower() == 'sortiemb' then
				windower.send_command('gs c set autobuffmode off; gs c set autowsmode off; sing off;')
				if player.main_job == 'DRK' then
					windower.send_command:schedule(0.2, 'input /ws "Herculean Slash" <t>')
					windower.send_command:schedule(4.0, 'input /ma "Stone" <t>')
					windower.send_command:schedule(8.8, 'input /ws "Herculean Slash" <t>')
				elseif player.main_job == 'WAR' then
					windower.send_command:schedule(3.9, 'input /ws "Crescent Moon" <t>')
					windower.send_command:schedule(14.3, 'input /ws "Crescent Moon" <t>')
				elseif S{'WHM','RDM'}:contains(player.main_job) then
					windower.send_command:schedule(4.2, 'input /ma "Stone" <bt>')
					windower.send_command:schedule(9.1, 'input /ma "Aero" <bt>')
				end
			elseif cmd2 and cmd2:lower() == 'def' then
				if player.main_job == 'RUN' then
					windower.send_command('gs c set runeelement Flabra; gs c set autobuffmode off')
					while haveBuff('Flabra') ~= 3 do
						atc("Waiting on Flabra X3")
						coroutine.sleep(1.5)
					end
					windower.send_command('input /ja "Rayke" <t>')
					windower.send_command:schedule(1.5,'input /ja "Rayke" <t>')
					windower.send_command:schedule(3, 'gs c set runeelement Unda; send @DRK gs c set autowsmode on; gs c set autotankmode on; gs c set autobuffmode auto; wait 5; send @DRK gs c set weapons Caladbolg;')
				elseif player.main_job == 'DRK' then
					windower.send_command('gs c set autowsmode off; gs c set weapons Lycurgos;')
				end
			elseif cmd2 and cmd2:lower() == '4step' then
				windower.send_command('gs c set autobuffmode off; gs c set autowsmode off')
				if player.main_job == 'DRK' then
					windower.send_command:schedule(4.0, 'input /ws "Herculean Slash" <t>')
					windower.send_command:schedule(15.7, 'input /ws "Herculean Slash" <t>')
				elseif player.main_job == 'COR' then
					windower.send_command:schedule(0.2, 'input /ws "Savage Blade" <t>')
				elseif player.main_job == 'BLU' or player.main_job == 'BRD' then
					windower.send_command('hb disable cure; sing off;')
					windower.send_command:schedule(9.8, 'input /ws "Savage Blade" <t>')
					windower.send_command:schedule(9.7, 'hb enable cure; sing on;')
				end
			--Sortie E/F/G Boss
			elseif (cmd2 and cmd2:lower() == 'fire') or (cmd2 and cmd2:lower() == 'ice') or (cmd2 and cmd2:lower() == 'earth') 
				or (cmd2 and cmd2:lower() == 'wind') or (cmd2 and cmd2:lower() == 'lightning') or (cmd2 and cmd2:lower() == 'water') then
				local element = cmd2:gsub("^%l", string.upper)
				local mob_target = windower.ffxi.get_mob_by_target('t') or windower.ffxi.get_mob_by_target('bt') or nil
				
				if not mob_target or not isMonster(mob_target) then 
					atcwarn('ABORT! No battle target or target is not monster!')
					return
				end
				
				atc('[AUTOSC] Begin - '..element..' SC/MB')
				if player.main_job == 'COR' then
					atc('[AUTOSC] COR '..element..' Shot')
					windower.send_command:schedule(5.9, 'gs c set autobuffmode off; hb off;')
					windower.send_command:schedule(7.9, 'gs c set elementalmode '..element..'; gs c elemental quickdraw '..mob_target.id)
					windower.send_command:schedule(8.8, 'gs c set autobuffmode auto; hb on;')
				elseif player.main_job == 'BLM' then
					atc('[AUTOSC] BLM Nuke')
					windower.send_command('gs c set elementalmode '..element..'; gs c set autobuffmode off')
					windower.send_command:schedule(7.7, 'gs c elemental aja '..mob_target.id)
					windower.send_command:schedule(13.0, 'gs c elemental nuke '..mob_target.id)
					windower.send_command:schedule(14.0, 'gs c set autobuffmode auto')
				elseif player.main_job == 'GEO' then
					atc('[AUTOSC] GEO Nuke')
					windower.send_command('gs c set elementalmode '..element)
					windower.send_command:schedule(10.2, 'gs c elemental nuke '..mob_target.id)
					windower.send_command:schedule(14.0, 'gs c elemental nuke '..mob_target.id)
				elseif player.main_job == 'SCH' and leader_char == player.name then
					atc('[AUTOSC] SCH - (SC SCH) Nuke')
					windower.send_command('gs c set elementalmode '..element..'; gs c set autobuffmode off; gs c set autosubmode off; hb off;')
					windower.send_command:schedule(9.8, 'gs c elemental nuke '..mob_target.id)
					if find_job_charname('RDM') then
						windower.send_command:schedule(10.8, 'gs c set autobuffmode nuking; gs c set autosubmode off; hb on;')
					else
						windower.send_command:schedule(10.8, 'gs c set autobuffmode nuking; gs c set autosubmode on; hb on;')
					end
				elseif player.main_job == 'SCH' and leader_char ~= player.name then
					atc('[AUTOSC] SCH - (Standby SCH) Nuke')
					windower.send_command('gs c set elementalmode '..element..'; gs c set autobuffmode off; gs c set autosubmode off; hb off;')
					windower.send_command:schedule(8.9, 'gs c elemental nuke '..mob_target.id)
					windower.send_command:schedule(14.8, 'gs c elemental nuke '..mob_target.id)
					if find_job_charname('RDM') then
						windower.send_command:schedule(15.8, 'gs c set autobuffmode nuking; gs c set autosubmode off; hb on;')
					else
						windower.send_command:schedule(15.8, 'gs c set autobuffmode nuking; gs c set autosubmode on; hb on;')
					end
				elseif player.main_job == 'RUN' then
					local abil_recasts = windower.ffxi.get_ability_recasts()
					local latency = 0.7
					atc('[AUTOSC] Rayke/Gambit')
					if abil_recasts[116] < latency then
						windower.send_command:schedule(6.1, 'gs c set autobuffmode off; gs c set autotankmode off; hb off;')
						windower.send_command:schedule(7.9, 'input /ja "Gambit" <t>')
						windower.send_command:schedule(9.2, 'gs c set autobuffmode auto; gs c set autotankmode on; hb on;')
					elseif abil_recasts[119] < latency then
						windower.send_command:schedule(6.1, 'gs c set autobuffmode off; gs c set autotankmode off; hb off;')
						windower.send_command:schedule(7.9, 'input /ja "Rayke" <t>')
						windower.send_command:schedule(9.2, 'gs c set autobuffmode auto; gs c set autotankmode on; hb on;')
					elseif abil_recasts[25] < latency then
						windower.send_command:schedule(10.9, 'input /ja "Lunge" <t>')
					end
				end
			-- Sortie C Objectives MB x 3
			elseif (cmd2 and cmd2:lower() == 'fireproc') then
				atc('[AUTOSC] Begin - Fire Proc SC/MB')
				if player.main_job == 'BLM' or player.main_job == 'GEO' or player.main_job == 'SCH' then
					atc('[AUTOSC] BLM/GEO/SCH Proc Nuke + Real Nuke')
					windower.send_command('gs c set castingmode proc; gs c set elementalmode fire')
					windower.send_command:schedule(9.0, 'input /ma "Fire" <t>')
					windower.send_command:schedule(10.0, 'gs c set castingmode normal; gs c elemental nuke <t>')
				elseif player.main_job == 'COR' then
					windower.send_command:schedule(11.0, 'input /ja "Fire Shot" <t>')
				end
			end
		else
			atc('[AUTOSC] Not COR/RUN/SCH/BLM/BRD/GEO/RDM job, skipping.')
		end
	end
	display_box()
end	


function geoburn()
	
	player = windower.ffxi.get_player()
	local target = windower.ffxi.get_mob_by_target('t')
	local world = res.zones[windower.ffxi.get_info().zone].name

	if settings.active and settings.assist ~= '' and not(areas.Cities:contains(world)) then
		if player.main_job == 'GEO' then
			if target and target.is_npc == true and target.valid_target == true then
				atcwarn('[GEOBurn]: GEO Burn Activated for Bolster!')
				
				windower.send_command('gs c set autobuffmode off')
				windower.send_command('hb disable cure')
				windower.send_command('hb disable na')
				windower.send_command('hb on')
				
				coroutine.sleep(1.7)
				windower.send_command('input /ja "Bolster" <me>')
				coroutine.sleep(1.8)
				windower.send_command('input /ma "Geo-Frailty" <t>')
				coroutine.sleep(4.5)
				if settings.indi == 'torpor' then
					windower.send_command('input /ma "Indi-Torpor" <me>')
				elseif settings.indi == 'malaise' then
					windower.send_command('input /ma "Indi-Malaise" <me>')
				elseif settings.indi == 'refresh' then
					windower.send_command('input /ma "Indi-Refresh" <me>')
				end
				coroutine.sleep(4.5)
				windower.send_command('input /ja "Dematerialize" <me>')
				coroutine.sleep(0.75)
				--if settings.dia then
					windower.send_command('hb debuff dia II')
				--elseif not settings.dia then
					--windower.send_command('hb debuff rm dia II')
				--end
				windower.send_command('hb enable cure')
				windower.send_command('hb enable na')
				windower.send_command('hb mincure 3')
				windower.send_command('gs c set autobuffmode auto')
			else
				atcwarn('[GEOBurn]: CANCELLING, NO TARGET!')
			end
		else
			atc('[GEOBurn]: Not GEO job.')
		end
	else
		atc('[GEOBurn]: Not active or in city zone.')
	end
end

function smnburn()

	player = windower.ffxi.get_player()
	local target = windower.ffxi.get_mob_by_target('t')
	local world = res.zones[windower.ffxi.get_info().zone].name
	
	if settings.active and settings.assist ~= '' and not(areas.Cities:contains(world)) then
		if player.main_job == 'SMN' then
			if target and target.is_npc == true and target.valid_target == true then
				atcwarn('[SMNBurn]: SMN Burn Activated!')
				windower.send_command('hb on')
				-- check distance 21 or less
				coroutine.sleep(1.5)
				windower.send_command('input /ja "Astral Flow" <me>')
				coroutine.sleep(2.5)
				windower.send_command('input /ja "Assault" <t>')
				coroutine.sleep(4.2)
				windower.send_command('input /ja "Astral Conduit" <me>')
				coroutine.sleep(1.6)
				-- 9.8s
				if settings.avatar == 'ramuh' then
					if haveBuff('Vorseal') then
						windower.send_command('exec VoltStrike.txt')
					else
						windower.send_command('exec VoltStrikeREG.txt')
					end
				elseif settings.avatar == 'ifrit' then
					if haveBuff('Vorseal') then
						windower.send_command('exec FlamingCrush.txt')
					else
						windower.send_command('exec FlamingCrushREG.txt')
					end
				elseif settings.avatar == 'siren' then
					if haveBuff('Vorseal') then
						windower.send_command('exec HystericAssault.txt')
					else
						windower.send_command('exec HystericAssaultREG.txt')
					end
				end
			else
				atcwarn('[SMNBurn]: CANCELLING, NO TARGET!')
			end
		else
			atc('[SMNBurn]: Not SMN job.')
		end
	else
		atc('[SMNBurn]: Not active or in city zone.')
	end
end

-- External addons

function attackon()
	atc('[ATTACK ON]')
	local player = windower.ffxi.get_player()
	local MeleeJobs = S{'WAR','SAM','DRG','DRK','NIN','MNK','COR','BLU','PUP','DNC','RUN','PLD','THF','BST','RNG','BRD'}
	if MeleeJobs:contains(player.main_job) then
		windower.send_command('input /attack on')
	end
end

function CheckItemInInventory(item_name, amt, all_bags)
	local bag_id = (all_bags and {0,5,6,7}) or {0}
	local seal_count = 0
	local item_id = res.items:with('en', item_name:capitalize()).id
	for _,bag in ipairs(bag_id) do
		local storage = windower.ffxi.get_items(bag)
		for item, index in T(storage):it() do
			if type(item) == 'table' and item.id == item_id then
				if amt then 
					seal_count = seal_count + item.count
				else
					return true
				end
			end
		end
	end
	if seal_count >= 0 and amt then
		return seal_count
	end
	return false
end

function cleanup()
	local items = S{'Tropical Crepe','Maringna','Grape Daifuku','Rolan. Daifuku','Om. Sandwich','Pluton case','Pluton box','Boulder case','Boulder box','Beitetsu parcel','Beitetsu box','Abdhaljs Seal',}
	local meds = S{'Echo Drops','Holy Water','Remedy','Panacea','Reraiser','Hi-Reraiser','Super Reraiser','Instant Reraise','Scapegoat','Silent Oil','Prism Powder','El. Pachira Fruit'}
	local satchel_items = S{"Old Case","Ra'Kaz. Starstone","Ra'Kaz. Sapphire","Octahedrite","Hexahedrite","Voracious Psyche"}
	--local case_stuff = S{'case','box','parcel'}
    
    --get
	for k,v in pairs(items) do
        if (k:contains('case') or k:contains('box') or k:contains('parcel')) and CheckItemInInventory(k) then
            windower.send_command('get "' ..k.. '" 600')
            coroutine.sleep(0.5)
        elseif CheckItemInInventory(k) then
            windower.send_command('get "' ..k.. '" 600')
            coroutine.sleep(0.5)
        end
	end
    
	coroutine.sleep(1.8)
    --put
    for k,v in pairs(items) do
        if (k:contains('case') or k:contains('box') or k:contains('parcel')) and CheckItemInInventory(k) then
            windower.send_command('put "' ..k.. '" case 600')
            coroutine.sleep(0.5)
        elseif CheckItemInInventory(k) then
            windower.send_command('put "' ..k.. '" sack 600')
            coroutine.sleep(0.5)
        end
	end
	
	--Meds
	--get
	for k,v in pairs(meds) do
		if CheckItemInInventory(k) then
            windower.send_command('get "' ..k.. '" 600')
            coroutine.sleep(0.5)
		end
	end
    
	coroutine.sleep(1.8)
    --put
    for k,v in pairs(meds) do
        if CheckItemInInventory(k) then
            windower.send_command('put "' ..k.. '" sack 600')
            coroutine.sleep(0.5)
        end
	end
    
	--get
	for k,v in pairs(satchel_items) do
		if CheckItemInInventory(k) then
            windower.send_command('get "' ..k.. '" 600')
            coroutine.sleep(0.5)
		end
	end
    
	coroutine.sleep(1.8)
    --put
    for k,v in pairs(satchel_items) do
        if CheckItemInInventory(k) then
            windower.send_command('put "' ..k.. '" satchel 600')
            coroutine.sleep(0.5)
        end
	end
	
	-- Seal trade
	
	if windower.ffxi.get_info()['zone'] == 246 then
		atc('In Port Jeuno - attempt to trade seals to NPC')
		local seal_count
		seal_count = CheckItemInInventory('H. Kindred Crest', true)
		if seal_count > 0 and seal_count < 792 then
			atc('H. Kindred Crest: '..seal_count)
            windower.send_command('tradenpc '.. seal_count..' \"H. Kindred Crest\" Shami')
			coroutine.sleep(3.5)
			windower.send_command('setkey enter down; wait 0.25; setkey enter up;')
        end
		coroutine.sleep(5.5)
		seal_count = 0
		seal_count = CheckItemInInventory('S. Kindred Crest', true)
		if seal_count > 0 and seal_count < 792 then
			atc('S. Kindred Crest: '..seal_count)
            windower.send_command('tradenpc '.. seal_count..' \"S. Kindred Crest\" Shami')
			coroutine.sleep(3.5)
			windower.send_command('setkey enter down; wait 0.25; setkey enter up;')
		elseif seal_count > 792 then
		
			local iterations = math.floor(seal_count / 792)
			local remainder = seal_count % 792
			for k = 1, iterations do
				atc('S. Kindred Crest# '..k..' - 792')
				windower.send_command('tradenpc 792 \"S. Kindred Crest\" Shami')
				coroutine.sleep(3.5)
				windower.send_command('setkey enter down; wait 0.25; setkey enter up;')
				coroutine.sleep(3.0)
			end
			coroutine.sleep(3.5)
			atc('S. Kindred Crest - remainder: '..remainder)
			windower.send_command('tradenpc '..remainder..' \"S. Kindred Crest\" Shami')
			coroutine.sleep(3.5)
			windower.send_command('setkey enter down; wait 0.25; setkey enter up;')
        end
	end
	
end

function book()
	local zone = windower.ffxi.get_info()['zone']
	local assault_zone = S{55,56,63,66,69}
	
	if assault_zone:contains(zone) then
		if zone == 55 then
			windower.send_command('get Ilrusi Ledger; wait 1.7; tradenpc 1 "Ilrusi Ledger" "Rune of Release"')
		elseif zone == 56 then
			windower.send_command('get Periqia Diary; wait 1.7; tradenpc 1 "Periqia Diary" "Rune of Release"')
		elseif zone == 63 then
			windower.send_command('get Lebros Chronicle; wait 1.7; tradenpc 1 "Lebros Chronicle" "Rune of Release"')
		elseif zone == 66 then
			windower.send_command('get Mamool Ja Journal; wait 1.7; tradenpc 1 "Mamool Ja Journal" "Rune of Release"')
		elseif zone == 69 then
			windower.send_command('get Leujaoam Log; wait 1.7; tradenpc 1 "Leujaoam Log" "Rune of Release"')
		end

	else
		atc('[Book] Not in zone.')
	end
end

function drop(cmd2)
	local rem = S{4066,4069,4070,4071,4072,4073}
	local cells = S{5365,5366,5367,5368,5369,5370,5371,5372,5373,5374,5375,5376,5377,5378,5379,5380,5381,5382,5383,5384}
    local empy_seals = S{3110,3111,3112,3113,3114,3115,3116,3117,3118,3119,3120,3121,3122,3123,3124,3125,3126,3127,3128,
                         3129,3130,3131,3132,3133,3134,3135,3136,3137,3138,3139,3140,3141,3142,3143,3144,3145,3146,3147,
                         3148,3149,3150,3151,3152,3153,3154,3155,3156,3157,3158,3159,3160,3161,3162,3163,3164,3165,3166,
                         3167,3168,3169,3170,3171,3172,3173,3174,3175,3176,3177,3178,3179,3180,3181,3182,3183,3184,3185,
                         3186,3187,3188,3189,3190,3191,3192,3193,3194,3195,3196,3197,3198,3199,3200,3201,3202,3203,3204,
                         3205,3206,3207,3208,3209,3210,3211,3212,3213,3214,3215,3216,3217,3218,3219,3220,3221,3222,3223,
                         3224,3225,3226,3227,3228,3229}
	local crystals = S{4096,4097,4098,4099,4100,4101,4102,4103}
	local escha_trash = S{9084,9085,9210,9212,9214,9215,9216,6486,6488,6391}

	if cmd2 == 'rem' then
		atc('[Drop] Rem Chapters 6-10')
		local items = windower.ffxi.get_items()
		for index, item in pairs(items.inventory) do
			if type(item) == 'table' and rem:contains(item.id) then
				atc('[Drop] ' .. cmd2 .. ' ' .. item.id)
				windower.ffxi.drop_item(index, item.count)
			end
		end
	elseif cmd2 == 'cells' then
		atc('[Drop] Salvage cells.')
		local items = windower.ffxi.get_items()
		for index, item in pairs(items.inventory) do
			if type(item) == 'table' and cells:contains(item.id) then
				atc('[Drop] ' .. cmd2 .. ' ' .. item.id)
				windower.ffxi.drop_item(index, item.count)
			end
		end
    elseif cmd2 == 'seals' then
		atc('[Drop] Empy seals.')
		local items = windower.ffxi.get_items()
		for index, item in pairs(items.inventory) do
			if type(item) == 'table' and empy_seals:contains(item.id) then
				atc('[Drop] ' .. cmd2 .. ' ' .. item.id)
				windower.ffxi.drop_item(index, item.count)
			end
		end
    elseif cmd2 == 'crystals' then
		atc('[Drop] Crystals')
		local items = windower.ffxi.get_items()
		for index, item in pairs(items.inventory) do
			if type(item) == 'table' and crystals:contains(item.id) then
				atc('[Drop] ' .. cmd2 .. ' ' .. item.id)
				windower.ffxi.drop_item(index, item.count)
			end
		end
	elseif cmd2 == 'escha' then
		atc('[Drop] Escha Trash')
		local items = windower.ffxi.get_items()
		for index, item in pairs(items.inventory) do
			if type(item) == 'table' and escha_trash:contains(item.id) then
				atc('[Drop] ' .. cmd2 .. ' ' .. item.id)
				windower.ffxi.drop_item(index, item.count)
			end
		end
	else
		atc('[Drop] Nothing specified.')
	end
end

function zerg(cmd2)
	if cmd2 == 'on' then
		atc('[Zerg] ON')
		windower.send_command('gs c set AutoZergMode on')
	elseif cmd2 == 'off' then
		atc('[Zerg] OFF')
		windower.send_command('gs c set AutoZergMode off')
	end
end

function ein(cmd2)
	local zone = windower.ffxi.get_info()['zone']
	if zone == 78 then
		if (cmd2 == 'enter') then
			atc("[Ein] Entering Einherjar.")
			windower.send_command('wait 1; tradenpc 1 "glowing lamp" "entry gate"')
			windower.send_command('wait 4.5; setkey up down; wait 0.25; setkey up up; wait 0.7; setkey enter down; wait 0.25; setkey enter up')
		elseif (cmd2 == 'exit') then
			local items = windower.ffxi.get_items()
			local exitflag = false
			for index, item in pairs(items.inventory) do
				if type(item) == 'table' and item.id == 5414 then
					atc('[Ein] Dropping lamp to exit.')
					windower.ffxi.drop_item(index, item.count)
					exitflag = true
				end
			end
			if exitflag == false then
				atc('[Ein] No lamp in inventory!')
			end
		else
			atc('[Ein] No sub command specified')
		end
	else
		atcwarn("[Ein] Not in proper zone, skipping.")
	end
end

function dd(cmd2)
	player = windower.ffxi.get_player()
	if not cmd2 then
		if player.main_job == 'BLU' then
			windower.send_command('input /ma "Tenebral Crush" <t>')
		elseif player.main_job == 'WHM' or player.main_job == 'RDM' or player.sub_job == 'RDM' or player.sub_job == 'WHM' and not haveBuff('SJ Restriction') then
			if player.main_job == 'RDM' then
				windower.send_command('input /ma "Dia III" <t>')
			else
				windower.send_command('input /ma "Dia II" <t>')
			end
		end
	elseif cmd2 == 'def' then
		if player.main_job == 'SAM' then
			atc('[DD] - SAM')
			windower.send_command('gs c autows Tachi: Ageha')
		elseif player.main_job == 'DRK' or player.main_job == 'RUN' then
			atc('[DD] - DRK/RUN')
			windower.send_command('gs c set weapons Lycurgos; gs c autows tp 1750')
        elseif player.main_job == 'WAR' then
        	atc('[DD] - WAR')
			windower.send_command('gs c set weapons Chango; gs c autows Armor Break; gs c autows tp 1750')
		else
			atc('[DD] - Not proper job.')
		end
	end
	
end

function buffall(cmd2)
	player = windower.ffxi.get_player()
	for k, v in pairs(windower.ffxi.get_party()) do
		if type(v) == 'table' then
			if v.mob == nil then
				atc('[BuffAll] ' ..v.name .. ' is not in zone!')
			elseif windower.ffxi.get_mob_by_name(v.name).in_party then
				windower.send_command('hb buff ' .. v.name .. ' ' .. cmd2)
			end
		end
	end
end

function wstypenew(cmd2)
	if not wstype_data[player.main_job] then
		atcwarn("[WSTYPE]: Abort.")
		return
	end

	for k,v in pairs(wstype_data[player.main_job].wsgroup) do
		if k == cmd2:lower() then
			if v[player.sub_job] then
				log(v[player.sub_job])
			elseif v['NON'] then
				log(v['NON'])
			end
		end
	end

end

function wstype(cmd2)
	local player_job = windower.ffxi.get_player()
	local WSjobs = S{'COR','DRG','SAM','BLU','DRK','WAR','RNG','GEO','RDM'}		

	if cmd2 == 'leaden' then
		if WSjobs:contains(player_job.main_job) then
			if player_job.main_job == 'COR' then
				if player_job.sub_job == 'NIN' or player_job.sub_job == 'DNC' then
					atc('WS-Type: Leaden Salute')
					windower.send_command('gs c autows Leaden Salute')
					windower.send_command('gs c set weapons DualLeaden')
				else
					atc('WS-Type: Leaden Salute')
					windower.send_command('gs c autows Leaden Salute')
					windower.send_command('gs c set weapons DeathPenalty')
				end
			else
				atc('WS-Type: Leaden - Not COR, no WS change.')
			end
		else
			atc('WS-Type: Leaden - Skipping')
		end
	elseif cmd2 == 'savage' then
		if WSjobs:contains(player_job.main_job) then
			if player_job.main_job == 'COR' or player_job.main_job == 'RNG' or player_job.main_job == 'BLU' then
				if player_job.sub_job == 'NIN' or player_job.sub_job == 'DNC' or player_job.main_job == 'BLU' then
					atc('WS-Type: Savage Blade')
					if player_job.main_job == 'BLU' then
						windower.send_command('gs c set weapons NaegThib')
						windower.send_command('gs c autows Savage Blade')
					else
						windower.send_command('gs c autows Savage Blade')
						windower.send_command('gs c set weapons DualSavage')
					end
				else
					atc('WS-Type: Savage Blade')
					windower.send_command('gs c autows Savage Blade')
					windower.send_command('gs c set weapons Naegling')
				end
			else
				atc('WS-Type: Savage - Not COR/RNG, no WS change.')
			end
		else
			atc('WS-Type: Savage - Skipping')
		end
	elseif cmd2 == 'laststand' then
		if WSjobs:contains(player_job.main_job) then
			if player_job.main_job == 'COR' or player_job.main_job == 'RNG' then
				if player_job.sub_job == 'NIN' or player_job.sub_job == 'DNC' then
					atc('WS-Type: Last Stand')
					windower.send_command('gs c autows Last Stand')
					windower.send_command('gs c set weapons DualLastStand')
				else
					atc('WS-Type: Last Stand')
					windower.send_command('gs c autows Last Stand')
					windower.send_command('gs c set weapons Fomalhaut')
				end
			else
				atc('WS-Type: Last Stand - Not COR, no WS change.')
			end
		else
			atc('WS-Type: Last Stand - Skipping')
		end
	elseif cmd2 == 'wildfire' then
		if WSjobs:contains(player_job.main_job) then
			if player_job.main_job == 'COR' or player_job.main_job == 'RNG' then
				if player_job.sub_job == 'NIN' or player_job.sub_job == 'DNC' then
					atc('WS-Type: Wildfire')
					windower.send_command('gs c autows Wildfire')
					windower.send_command('gs c set weapons DualWildfire')
				else
					atc('WS-Type: Wildfire')
					windower.send_command('gs c autows Wildfire')
					windower.send_command('gs c set weapons Armageddon')
				end
			else
				atc('WS-Type: Wildfire - Not COR, no WS change.')
			end
		else
			atc('WS-Type: Wildfire - Skipping')
		end	
	elseif cmd2 == 'trueflight' then
		if WSjobs:contains(player_job.main_job) then
			if player_job.main_job == 'RNG' then
				if player_job.sub_job == 'NIN' or player_job.sub_job == 'DNC' then
					atc('WS-Type: TrueFlight')
					windower.send_command('gs c autows Trueflight')
					windower.send_command('gs c set weapons DualGastra')
				else
					atc('WS-Type: TrueFlight')
					windower.send_command('gs c autows Trueflight')
					windower.send_command('gs c set weapons Gastraphetes')
				end
			else
				atc('WS-Type: TrueFlight - Not RNG, no WS change.')
			end
		else
			atc('WS-Type: TrueFlight - Skipping')
		end	
	elseif cmd2 == 'mace' then
		if WSjobs:contains(player_job.main_job) then
			if player_job.main_job == 'DRK' or  player_job.main_job == 'WAR' then
				atc('WS is Judgment')
				windower.send_command('gs c set weapons Loxotic; gs c autows tp 1692')
			else
				atc('WS-Type: WAR/DRK Mace - Not WAR/DRK, no WS change.')
			end
		else
			atc('WS-Type: WAR/DRK Mace - Skipping')
		end	
	elseif cmd2 == 'slash' then
		if WSjobs:contains(player_job.main_job) then
			if player_job.main_job == 'COR' then
				atc('WS is Savage')
                if player_job.sub_job == 'NIN' or player_job.sub_job == 'DNC' then
                    windower.send_command('gs c autows Savage Blade')
                    windower.send_command('gs c set weapons DualSavage')
                else
                    windower.send_command('gs c autows Savage Blade')
					windower.send_command('gs c set weapons Naegling')
                end
			elseif player_job.main_job == 'DRG' then
				atc('WS is Savage')
				if player_job.sub_job == 'NIN' or player_job.sub_job == 'DNC' then
					windower.send_command('gs c autows Savage Blade')
					windower.send_command('gs c set weapons DualSavage')
				else
					windower.send_command('gs c autows Savage Blade')
					windower.send_command('gs c set weapons Naegling')
				end
			elseif player_job.main_job == 'SAM' then
				atc('WS is Fudo')
				windower.send_command('gs c autows Tachi: Fudo')
				windower.send_command('gs c set weapons Masamune')
			elseif player_job.main_job == 'DRK' then
				atc('WS is Torcleaver')
				windower.send_command('gs c set weapons Caladbolg; gs c autows tp 1000')
			elseif player_job.main_job == 'BLU' then
				atc('WS is Savage')
				windower.send_command('gs c set weapons TizThib')
				windower.send_command('gs c autows Expiacion')
			elseif player_job.main_job == 'RDM' then
				atc('WS is Savage')
				windower.send_command('gs c autows Savage Blade')
				windower.send_command('gs c set weapons DualSavage')
			elseif player_job.main_job == 'WAR' then
				atc('WS is Savage')
				windower.send_command('gs c set weapons Naegling; gs c autows tp 1000')
			elseif player_job.main_job == 'GEO' then
				atc('Indi Fury/Geo Frailty')
				windower.send_command('gs c autogeo frailty; gs c autoindi fury')
			end
		else
			atc('WS-Type: Slashing - Skipping')
		end
	elseif cmd2 == 'pierce' then
		if WSjobs:contains(player_job.main_job) then
			if player_job.main_job == 'COR' then
				atc('WS is Savage')
				windower.send_command('gs c autows Last Stand')
				windower.send_command('gs c set weapons DualLastStand')
			elseif player_job.main_job == 'DRG' then
				atc('WS is Stardiver')
				windower.send_command('gs c autows Stardiver')
				windower.send_command('gs c set weapons Trishula')
			elseif player_job.main_job == 'SAM' then
				atc('WS is Impulse')
				windower.send_command('gs c autows Tachi: Fudo')
				windower.send_command('gs c set weapons ShiningOne')
			elseif player_job.main_job == 'DRK' then
				atc('WS is Torcleaver')
				windower.send_command('gs c set weapons Caladbolg; gs c autows tp 1000')
			elseif player_job.main_job == 'BLU' then
				atc('WS is Expiacion')
				windower.send_command('gs c set weapons TizThib')
			elseif player_job.main_job == 'WAR' then
				atc('WS is Impulse')
				windower.send_command('gs c set weapons ShiningOne; gs c autows tp 1000')
			end
		else
			atc('WS-Type: Piercing - Skipping')
		end
	elseif cmd2 == 'blunt' then
		if WSjobs:contains(player_job.main_job) then
			if player_job.main_job == 'BLU' then
				atc('WS is Black Halo')
				windower.send_command('gs c set weapons Magic')
			elseif player_job.main_job == 'DRK' then
				atc('WS is Judgment')
				windower.send_command('gs c set weapons Loxotic; gs c autows tp 1692')
			elseif player_job.main_job == 'SAM' then
				atc('WS is Jinpu')
				windower.send_command('gs c set weapons Dojikiri')
				windower.send_command('gs c autows Tachi: Jinpu')
			elseif player_job.main_job == 'COR' then
				atc('WS is WildFire')
				windower.send_command('gs c autows Wildfire')
				windower.send_command('gs c set weapons DualWildfire')
			elseif player_job.main_job == 'DRG' then
				atc('WS is Retribution')
				windower.send_command('gs c autows Retribution')
				windower.send_command('gs c set weapons Malignance')
			elseif player_job.main_job == 'WAR' then
				atc('WS is Judgment')
				windower.send_command('gs c set weapons Loxotic; gs c autows tp 1692')
			end
		else
			atc('WS-Type: Blunt - Skipping')
		end
	elseif cmd2 == 'magic' then
		if WSjobs:contains(player_job.main_job) then
			if player_job.main_job == 'RNG' then
				if player_job.sub_job == 'NIN' or player_job.sub_job == 'DNC' then
					atc('WS-Type: TrueFlight')
					windower.send_command('gs c autows Trueflight')
					windower.send_command('gs c set weapons DualGastra')
				else
					atc('WS-Type: TrueFlight')
					windower.send_command('gs c autows Trueflight')
					windower.send_command('gs c set weapons Gastraphetes')
				end
			elseif player_job.main_job == 'SAM' then
				atc('WS is Jinpu')
				windower.send_command('gs c set weapons Dojikiri')
				windower.send_command('gs c autows Tachi: Jinpu')
			elseif player_job.main_job == 'COR' then
				atc('WS is Leaden')
				windower.send_command('gs c autows Leaden Salute')
				windower.send_command('gs c set weapons DualLeaden')
			elseif player_job.main_job == 'RDM' then
				atc('WS is Seraph')
				windower.send_command('gs c autows Seraph Blade')
				windower.send_command('gs c set weapons DualCroDay')
			elseif player_job.main_job == 'GEO' then
				atc('Indi Acumen/Geo Malaise')
				windower.send_command('gs c autogeo malaise; gs c autoindi acumen')
			end
		else
			atc('WS-Type: Magic - Skipping')
		end
	elseif cmd2 == 'hybrid' then
		if WSjobs:contains(player_job.main_job) then
			if player_job.main_job == 'SAM' then
				atc('WS is Jinpu')
				windower.send_command('gs c set weapons Dojikiri')
				windower.send_command('gs c autows Tachi: Jinpu')
			elseif player_job.main_job == 'COR' then
				atc('WS is Leaden')
				windower.send_command('gs c autows Leaden Salute')
				windower.send_command('gs c set weapons DualLeaden')
            elseif player_job.main_job == 'NIN' then
                atc('WS is Chi')
				windower.send_command('gs c autows Blade: Chi')
				windower.send_command('gs c set weapons Heishi')
			end
        else
            atc('WS-Type: Hybrid - Skipping')
        end
    elseif cmd2 == 'hybridvolte' then
		if WSjobs:contains(player_job.main_job) then
			if player_job.main_job == 'SAM' then
				atc('WS is Jinpu')
				windower.send_command('gs c set weapons Dojikiri')
				windower.send_command('gs c autows Tachi: Jinpu')
			elseif player_job.main_job == 'COR' then
				atc('WS is WildFire')
				windower.send_command('gs c autows Wildfire')
				windower.send_command('gs c set weapons DualWildfire')
            elseif player_job.main_job == 'NIN' then
                atc('WS is Chi')
				windower.send_command('gs c autows Blade: Chi')
				windower.send_command('gs c set weapons Heishi')
			end       
		else
			atc('WS-Type: Hybrid Volte - Skipping')
		end
    elseif cmd2 == 'jinpu' then
        if player_job.main_job == 'SAM' then
			atc('WS is Jinpu')
			windower.send_command('gs c set weapons Dojikiri')
			windower.send_command('gs c autows Tachi: Jinpu')
        else
            atc('WS-Type: Jinpu - Skipping')
        end
    elseif cmd2 == 'kagero' then
        if player_job.main_job == 'SAM' then
			atc('WS is Kagero')
			windower.send_command('gs c set weapons Dojikiri')
			windower.send_command('gs c autows Tachi: Kagero')
        else
            atc('WS-Type: Kagero - Skipping')
        end
    elseif cmd2 == 'goten' then
        if player_job.main_job == 'SAM' then
			atc('WS is Goten')
			windower.send_command('gs c set weapons Dojikiri')
			windower.send_command('gs c autows Tachi: Goten')
        else
            atc('WS-Type: Goten - Skipping')
        end
    elseif cmd2 == 'koki' then
        if player_job.main_job == 'SAM' then
			atc('WS is Koki')
			windower.send_command('gs c set weapons Dojikiri')
			windower.send_command('gs c autows Tachi: Koki')
        else
            atc('WS-Type: Koki - Skipping')
        end
    elseif cmd2 == 'fudo' then
        if player_job.main_job == 'SAM' then
			atc('WS is Fudo')
			windower.send_command('gs c set weapons Masamune')
			windower.send_command('gs c autows Tachi: Fudo')
        else
            atc('WS-Type: Fudo - Skipping')
        end
	end
end


function proc(cmd2)
	local player_job = windower.ffxi.get_player()
	local MageNukeJobs = S{'BLM','GEO','SCH','RDM'}		

	if cmd2 == 'on' then
		if MageNukeJobs:contains(player_job.main_job) then
			atc('[Proc] Weak casting mode. -PROC ON-')
			if player_job.main_job == "GEO" then
				windower.send_command('gs c autoindi refresh; gs c autogeo haste')
			else
				windower.send_command('gs c set castingmode proc')
				windower.send_command('gs c set MagicBurstMode off')
				windower.send_command('gs c set AutoNukeMode off')
			end
			windower.send_command('lua u maa')
		else
			atc('[Proc] Incorrect JOB, Skipping.')
		end
	elseif cmd2 == 'off' then
		if MageNukeJobs:contains(player_job.main_job) then
			atc('[Proc] Regular casting mode. -PROC OFF-')
			windower.send_command('gs c set castingmode normal')
			windower.send_command('gs c set MagicBurstMode lock')
			windower.send_command('gs c set AutoNukeMode off')
			windower.send_command('lua r maa')
			if player_job.main_job == "GEO" then
				windower.send_command('gs c autoindi acumen; gs c autogeo malaise')
			end
		else
			atc('[Proc] Incorrect JOB, Skipping.')
		end
	elseif cmd2 == 'nuke' then
		if MageNukeJobs:contains(player_job.main_job) then
			atc('[Proc] Autonuke - low tier')
			windower.send_command('gs c set castingmode normal')
			windower.send_command('gs c set MagicBurstMode off')
			windower.send_command('gs c set AutoNukeMode on')
			windower.send_command('lua u maa')
			if player_job.main_job == "GEO" then
				windower.send_command('gs c autoindi refresh; gs c autogeo haste')
			end
		else
			atc('[Proc] Incorrect JOB, Skipping.')
		end
	end
end

function wsproc(cmd2)
	local player_job = windower.ffxi.get_player()
	local ProcJobs = S{'WAR','BLU','RUN','THF','DRK','SAM','MNK','PUP','BRD','COR','DRG','DNC','RNG'}		

	if cmd2 == 'phy' then
		if ProcJobs:contains(player_job.main_job) then
			atc('[Proc] Physical. -PROC ON-')
			if player_job.main_job == "WAR" then
				windower.send_command('gs c autows flat blade')
			elseif player_job.main_job == "BLU" then
				windower.send_command('gs c autows brainshaker')
			elseif player_job.main_job == "BRD" then
				windower.send_command('gs c set weapons Carnwenhan; gs c autows wasp sting')
			elseif player_job.main_job == "DRG" then
				windower.send_command('gs c set weapons Naegling; gs c autows flat blade')
			elseif player_job.main_job == "DNC" then
				windower.send_command('gs c autows wasp sting')
			elseif player_job.main_job == "RNG" then
				windower.send_command('gs c set weapons DualSavage; gs c autows flat blade')
			elseif player_job.main_job == "RUN" or player_job.main_job == "DRK" then
				windower.send_command('gs c autows shockwave')
            elseif player_job.main_job == "THF" or player_job.main_job == "BRD" then
				windower.send_command('gs c autows wasp sting')
            elseif player_job.main_job == "SAM" then
				windower.send_command('gs c set weapons Norifusa; gs c autows Tachi: Hobaku')
            elseif player_job.main_job == "MNK" or player_job.main_job == "PUP" then
				windower.send_command('gs c autows Shoulder Tackle')
            elseif player_job.main_job == "COR" then
				windower.send_command('gs c set weapons DualLeaden; wait 2; gs c autows wasp sting;')
			end
		else
			atc('[Proc] Incorrect JOB, Skipping.')
		end
	elseif cmd2 == 'magic' then
		if ProcJobs:contains(player_job.main_job) then
			atc('[Proc] Magical. -PROC ON-')
			if player_job.main_job == "WAR" then
				windower.send_command('gs c autows burning blade')
			elseif player_job.main_job == "BLU" then
				windower.send_command('gs c autows shining strike')
			elseif player_job.main_job == "BRD" then
				windower.send_command('gs c set weapons Carnwenhan; gs c autows gust slash')
			elseif player_job.main_job == "DRG" then
				windower.send_command('gs c set weapons Naegling; gs c autows burning blade')
			elseif player_job.main_job == "DNC" then
				windower.send_command('gs c autows gust slash')
			elseif player_job.main_job == "RNG" then
				windower.send_command('gs c set weapons DualSavage; gs c autows burning blade')
			elseif player_job.main_job == "RUN" or player_job.main_job == "DRK" then
				windower.send_command('gs c autows freezebite')
            elseif player_job.main_job == "THF" or player_job.main_job == "BRD" then
				windower.send_command('gs c autows gust slash')
            elseif player_job.main_job == "SAM" then
				windower.send_command('gs c set weapons Norifusa; gs c autows Tachi: Goten')
            elseif player_job.main_job == "MNK" or player_job.main_job == "PUP" then
				windower.send_command('gs c autows Shoulder Tackle')
			elseif player_job.main_job == "COR" then
				windower.send_command('gs c set weapons DualLeaden; wait 2; gs c autows gust slash;')
			end
		else
			atc('[Proc] Incorrect JOB, Skipping.')
		end
	elseif cmd2 == 'off' then
		if ProcJobs:contains(player_job.main_job) then
			atc('[Proc] OFF.')
			if player_job.main_job == "WAR" then
				windower.send_command('gs c autows Upheaval')
			elseif player_job.main_job == "BLU" then
				windower.send_command('gs c autows Expiacion')
			elseif player_job.main_job == "BRD" then
				windower.send_command('gs c set weapons Carnwenhan; gs c autows Rudra\s Storm')
			elseif player_job.main_job == "DRG" or player_job.main_job == "RNG" then
				windower.send_command('gs c set weapons Naegling; gs c autows Savage Blade')
			elseif player_job.main_job == "RNG" then
				windower.send_command('gs c set weapons DualSavage; gs c autows Savage Blade')
			elseif player_job.main_job == "DNC" then
				windower.send_command('gs c autows rudra\'s storm')
			elseif player_job.main_job == "RUN" or player_job.main_job == "DRK" then
                if player_job.main_job == "RUN" then
                    windower.send_command('gs c autows Dimidiation')
                else
                    windower.send_command('gs c autows Torcleaver')
                end
            elseif player_job.main_job == "THF" or player_job.main_job == "BRD" then
				windower.send_command('gs c autows rudra\'s storm')
            elseif player_job.main_job == "SAM" then
				windower.send_command('gs c set weapons Masamune; gs c autows Tachi: Fudo')
            elseif player_job.main_job == "MNK" or player_job.main_job == "PUP" then
				windower.send_command('gs c autows Victory Smite')
            elseif player_job.main_job == "COR" then
				windower.send_command('gs c set weapons DualSavage;')
			end
		else
			atc('[Proc] Incorrect JOB, Skipping.')
		end
	end
end

---------------------------------
--Helper functions--
---------------------------------

function check_leader_in_same_party(leader)
	for k, v in pairs(windower.ffxi.get_party()) do
		if type(v) == 'table' and v.name == leader then
			atc('[CheckLeader] ' ..v.name .. ' is in party and is leader.')
			return true
		end
	end
end

function check_leader()
	 members = windower.ffxi.get_party()
	for k, v in pairs(members) do
		if type(v) == 'table' and v.name == player.name and
			(not members.alliance_leader or (members.alliance_leader and members.alliance_leader == v.mob.id)) and
			(not members.party1_leader or (members.party1_leader and members.party1_leader == v.mob.id))  then
			return true
		end
	end
	return false
end

function get_delay()
    local self = windower.ffxi.get_player().name
    local members = {}
    for k, v in pairs(windower.ffxi.get_party()) do
        if type(v) == 'table' then
            members[#members + 1] = v.name
        end
    end
    table.sort(members)
    local total_delay = 0
    for k, v in pairs(members) do
        if v == self then
			return (k - 1) * settings.send_all_delay
        end
    end
end

function moveto(tx,ty,tz, min_distance)
	min_distance = min_distance or 1.25
	
	local p = windower.ffxi.get_mob_by_target('me')

	atcwarn("Start running toward: "..tx.." ,"..ty.." ,"..tz)
	windower.ffxi.run(tx-p.x, ty-p.y)
	p_2 = windower.ffxi.get_mob_by_index(p.index)
	
	while ((V{p_2.x, p_2.y, (p_2.z*-1)} - V{tx, ty, (tz*-1)}):length()) >= min_distance do
		p_2 = windower.ffxi.get_mob_by_index(p.index)
		windower.ffxi.run(tx-p_2.x, ty-p_2.y)
		coroutine.sleep(0.15)
	end
	atcwarn("Stop running.")
	windower.ffxi.run(false)
end

function isMonster(mob_in_question)
	--local mob_in_question = windower.ffxi.get_mob_by_target('t')
	if mob_in_question and mob_in_question.is_npc and mob_in_question.spawn_type == 16 and mob_in_question.valid_target then
		return true
    else
        return false
	end
end

function haveBuff(...)
	local args = S{...}:map(string.lower)
	local player = windower.ffxi.get_player()
	local buff_count = 0
	if (player ~= nil) and (player.buffs ~= nil) then
		for _,bid in pairs(player.buffs) do
			local buff = res.buffs[bid]
			if args:contains(buff.en:lower()) then
				buff_count = buff_count +1
			end
		end
		if buff_count > 0 then
			return buff_count
		else
			return false
		end
	end
	return false
end

function getAngle(index)
    local P = windower.ffxi.get_mob_by_target('me') --get player
    local M = index and windower.ffxi.get_mob_by_id(index) or windower.ffxi.get_mob_by_target('t') --get target
    local delta = {Y = (P.y - M.y),X = (P.x - M.x)} --subtracts target pos from player pos
    local angleInDegrees = (math.atan2( delta.Y, delta.X) * 180 / math.pi)*-1 
    local mult = 10^0
    return math.floor(angleInDegrees * mult + 0.5) / mult
end

-- Credit to partyhints
function set_registry(id, job_id)
    if not id then return false end
    job_registry[id] = job_registry[id] or 'NON'
    job_id = job_id or 0
    if res.jobs[job_id].ens == 'NON' and job_registry[id] and not S{'NON', 'UNK'}:contains(job_registry[id]) then 
        return false
    end
    job_registry[id] = res.jobs[job_id].ens
    return true
end

-- Credit to partyhints
function get_registry(id)
    if job_registry[id] then
        return job_registry[id]
    else
        return 'UNK'
    end
end

function count_inv()
	local playerinv = windower.ffxi.get_items().inventory
	return playerinv.max - playerinv.count
end

-- Find which char has which job
function find_job_charname(job, job_count, in_party, with_self)

	local tank_jobs = S{"PLD","RUN"}
	local dd_jobs = S{"SAM","DRK","WAR","DRG","COR"}
	local count = 0
	local player = windower.ffxi.get_player()
	for k, v in pairs(windower.ffxi.get_party()) do
		if type(v) == 'table' then
			--if v.name ~= player.name then
			if (with_self) or (not (with_self) and v.name ~= player.name) then
				ptymember = windower.ffxi.get_mob_by_name(v.name) or nil
				if v.mob ~= nil then
					if ptymember and ptymember.valid_target and ((in_party and ptymember.in_party) or not in_party)then
						if string.lower(job) == 'tank' then
							if tank_jobs:contains(get_registry(ptymember.id)) then
								count = count +1
								if job_count and job_count == (tostring(count)) then
									return v.name
								elseif not job_count then
									return v.name
								end
							end
						elseif string.lower(job) == 'dd' then
							if dd_jobs:contains(get_registry(ptymember.id)) then
								count = count +1
								if job_count and job_count == (tostring(count)) then
									return v.name
								elseif not job_count then
									return v.name
								end
							end
						else
							if get_registry(ptymember.id) == job then
								count = count +1
								if job_count and job_count == (tostring(count)) then
									atc('[Job finder] Job: '..job.. ' Name: ' .. v.name.. ' ID: ' .. ptymember.id)
									return v.name
								elseif not job_count then
									atc('[Job finder] Job: '..job.. ' Name: ' .. v.name.. ' ID: ' .. ptymember.id)
									return v.name
								end
							end
						end
					else
						atc('[Job finder] ERROR: One or more characters not loaded.')
					end
				end
			end
		end
	end
	return nil
end

function find_missing_ki(ki_table)
	local found_ki = 0
	local keyitems = windower.ffxi.get_key_items()
	for id,ki in pairs(keyitems) do
		if ki_table:contains(ki) then
			found_ki = found_ki +1
		end
	end
	return found_ki
end

windower.register_event('addon command', handle_addon_command)
windower.register_event('ipc message', handle_ipc_message) 
windower.register_event('zone change', handle_zone_change)
windower.register_event('load','login', handle_login_load)
windower.register_event("job change", handle_job_change)
