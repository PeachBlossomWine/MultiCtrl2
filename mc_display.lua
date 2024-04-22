-------------
-- Display --
-------------
local mprefix = ('[%s] '):format(_addon.name)

function atc(...)
    local args = T({...})
	local msg = table.concat({...}, ' ')
    windower.add_to_chat(478, mprefix..msg)
	--478 L.blue
end

function atcwarn(...)
    local args = T({...})
	local msg = table.concat({...}, ' ')
    windower.add_to_chat(3, mprefix..msg)
end

-- Display functions

burn_status = nil
smn_help = nil
buy_help = nil
ws_help = nil
rng_help = nil
sleep_help = nil
food_help = nil
auto_sc = nil
smart_help = nil
status_info = nil

function init_box_pos()
    -- Define the positions and settings in a table
	local winRes = windower.get_windower_settings()
	local settings = {
        {text = "burn_status", x = winRes["ui_x_res"]-645, y = 105},
        {text = "smn_help", x = winRes["ui_x_res"]-645, y = 45},
        {text = "buy_help", x = winRes["ui_x_res"]-645, y = 200},
        {text = "ws_help", x = winRes["ui_x_res"]-510, y = 45},
        {text = "rng_help", x = winRes["ui_x_res"]-510, y = 105},
        {text = "sleep_help", x = winRes["ui_x_res"]-510, y = 25},
        {text = "auto_sc", x = winRes["ui_x_res"]-510, y = 85},
        {text = "smart_help", x = winRes["ui_x_res"]-510, y = 65},
    }

    local font = 'Arial'
    local size = 10
    local bold = true
    local bg = 0
    local strokewidth = 2
    local stroketransparancy = 192

    for _, item in ipairs(settings) do
        if _G[item.text] then
            _G[item.text]:destroy() -- Destroy the existing text objects
        end
        _G[item.text] = texts.new()
        _G[item.text]:pos(item.x, item.y)
        _G[item.text]:font(font)
        _G[item.text]:size(size)
        _G[item.text]:bold(bold)
        _G[item.text]:bg_alpha(bg)
        _G[item.text]:right_justified(false)
        _G[item.text]:stroke_width(strokewidth)
        _G[item.text]:stroke_transparency(stroketransparancy)
    end
	
	status_info = texts.new()
	status_info:pos(winRes["ui_x_res"]-700,winRes["ui_y_res"]-350)
	status_info:font('Consolas')
    status_info:size(9)
    status_info:bg_alpha(75)
    display_box()
end

display_box = function()
	local clr = {
		r='\\cs(240,28,28)', -- Red for active
        h='\\cs(255,192,0)', -- Yellow for active booleans and non-default modals
		w='\\cs(255,255,255)', -- White for labels and default modals
        g='\\cs(0,255,127)', -- Green
        s='\\cs(96,96,96)' -- Gray for inactive booleans
    }
	burn_status:clear()
	burn_status:append(' ')

	
	smn_help:clear()
	smn_help:append(' ')
	
	buy_help:clear()
	buy_help:append(' ')
	
	ws_help:clear()
	ws_help:append(' ')
	
	sleep_help:clear()
	sleep_help:append(' ')
	
	rng_help:clear()
	rng_help:append(' ')
	
	auto_sc:clear()
	auto_sc:append(' ')
    
    smart_help:clear()
    smart_help:append(' ')
	

	if settings.smnhelp then
		if settings.smnsc then
			smn_help:append(string.format("%sSMN: %sON - SC", clr.w, clr.r))
		else
			smn_help:append(string.format("%sSMN: %sON", clr.w, clr.r))
		end 
		
		if settings.smnauto then
			smn_help:append(string.format("\n%s AutoBP: %sON", clr.w, clr.r))
		else
			smn_help:append(string.format("\n%s AutoBP: %sOFF", clr.w, clr.r))
		end
		
		if settings.smnlead then
			smn_help:append(string.format("\n%s Leader: %s" .. settings.smnlead , clr.w, clr.r))
		else
			smn_help:append(string.format("\n%s Leader: %s", clr.w, clr.r))
		end
		
	else
		smn_help:clear()
	end
	
	if settings.autows then
		ws_help:append(string.format("%sWS/BUFF: %sON", clr.w, clr.r))
	else
		ws_help:clear()
	end
	
    if settings.autosub then
        if settings.autosub == 'sleep' then
            sleep_help:append(string.format("%sAuto-Sub: %sSLEEP", clr.w, clr.r))
        elseif settings.autosub == 'on' then
            sleep_help:append(string.format("%sAuto-Sub: %sON", clr.w, clr.r))
        elseif settings.autosub == 'off' then
            sleep_help:append(string.format("%sAuto-Sub: %sOFF", clr.w, clr.r))
        end
    end
	
	if settings.rangedmode then
		rng_help:append(string.format("%sRNG: %sON", clr.w, clr.r))
	else
		rng_help:clear()
	end
	
	if settings.autosc then
		auto_sc:append(string.format("%sAUTO SC: %sON", clr.w, clr.r))
	else
		auto_sc:clear()
	end

	if settings.buy then
		buy_help:append(string.format("%sBUY HELPER: %sON", clr.w, clr.r))
	else
		buy_help:clear()
	end

	if settings.smartws then
		smart_help:append(string.format("%sSMART WS: %sON", clr.w, clr.r))
	else
		smart_help:clear()
	end
    
    if settings.active then
		burn_status:append(string.format("%s1HR Burn: %sON", clr.w, clr.r))

		if settings.avatar == 'ramuh' then
			burn_status:append(string.format("\n%s Avatar: %s" .. settings.avatar, clr.w, clr.h))
			
		elseif settings.avatar == 'ifrit' then
			burn_status:append(string.format("\n%s Avatar: %s" .. settings.avatar, clr.w, clr.h))
			
		elseif settings.avatar == 'siren' then
			burn_status:append(string.format("\n%s Avatar: %s" .. settings.avatar, clr.w, clr.h))
		end
		
		if settings.indi == 'torpor' then
			burn_status:append(string.format("\n%s Indi Spell: %s" .. settings.indi, clr.w, clr.h))
		elseif settings.indi == 'malaise' then
			burn_status:append(string.format("\n%s Indi Spell: %s" .. settings.indi, clr.w, clr.h))
		elseif settings.indi == 'refresh' then
			burn_status:append(string.format("\n%s Indi Spell: %s" .. settings.indi, clr.w, clr.h))
		end
		
		if settings.assist then
			burn_status:append(string.format("\n%s Assiting: %s" .. settings.assist, clr.w, clr.h))
		else
			burn_status:append(string.format("\n%s Assiting: ", clr.w))
		end
    else
		burn_status:clear()
    end
	
	smn_help:show()
	buy_help:show()
	ws_help:show()
	sleep_help:show()
	rng_help:show()
	auto_sc:show()
	burn_status:show()
    smart_help:show()
end

status_hud = function()
    local clr = {
        r='\\cs(240,28,28)',    -- Red for active
        h='\\cs(255,192,0)',    -- Yellow for active booleans and non-default modals
        w='\\cs(255,255,255)',  -- White for labels and default modals
        g='\\cs(0,255,200)',  	-- Aqua
		g2='\\cs(0,255,127)',	-- Green
        s='\\cs(96,96,96)'      -- Gray for inactive booleans
    }
   
	local paddingSpace = {}
    local totalGil = T{}
    local update_string = {}
	
	for name,data in pairs(__playerData) do
		for k,v in pairs (data) do
			if paddingSpace[k] and #tostring(v) > paddingSpace[k] then
				paddingSpace[k] = #tostring(v)
			else
				paddingSpace[k] = #tostring(v)
			end
		end
	end

	-- Current instance
	local currentCharData = __playerData[player.name]
	local temp      		= ""
	local currencyTemp 		= ""
	local currencyTempLine2 = ""
	local pad       		= (""):lpad(" ", (8 - #player.name))

	do
		temp = (temp .. string.format("%s[%s]%s ", clr.h, player.name, pad))
	end
	
	if currentCharData then
		for currency, value in pairs (currentCharData) do
			do
				if currency == 'Gil' then
					currencyTemp = (currencyTemp .. string.format("%s%s: %s%s%s", clr.w, currency, clr.g, formatNumberAbbreviated(value), (""):lpad(" ", (11 - #tostring(value)))))
					totalGil:insert(value)
				--elseif currency == 'CQ' then
					--currencyTemp = (currencyTemp .. string.format("%s%s: %s%s%s", clr.w, currency, clr.g, formatNumberAbbreviated(value), (""):lpad(" ", ((paddingSpace[currency]+10) - #tostring(value)))))
				elseif S{'GL','HM','Job'}:contains(currency) then
					currencyTempLine2 = (currencyTempLine2 .. string.format("%s%s: %s%s%s", clr.w, currency, clr.g, value, (""):lpad(" ", ((paddingSpace[currency]+3) - #tostring(value)))))
				elseif currency == 'Inventory' then
					local colorInv = '\\cs(255,255,255)'
					if value >=60 and value < 70 then
						colorInv = '\\cs(255,165,0)'
					elseif value >=70 then
						colorInv = '\\cs(240,28,28)'
					end
					currencyTempLine2 = (currencyTempLine2 .. string.format("%s%s%s/80%s", colorInv, value, clr.w, (""):lpad(" ", ((paddingSpace[currency]+3) - #tostring(value)))) .. "   ")
				else
					currencyTemp = (currencyTemp .. string.format("%s%s: %s%s%s", clr.w, currency, clr.g, formatNumberAbbreviated(value), (""):lpad(" ", ((paddingSpace[currency]+2) - #tostring(value)))))
				end
			end
		end
		table.insert(update_string, (temp .. currencyTemp))
		table.insert(update_string, (currencyTempLine2))
	end

	-- Rest of instances
    for name, data in pairs(__playerData) do
		if name ~= player.name then
			local temp      		= ""
			local currencyTemp 		= ""
			local currencyTempLine2 = ""
			local pad       		= (""):lpad(" ", (8 - #name))

			do
				temp = (temp .. string.format("%s[%s]%s ", clr.h, name, pad))
			end
			
			for currency, value in pairs (data) do
				do
					if currency == 'Gil' then
						currencyTemp = (currencyTemp .. string.format("%s%s: %s%s%s", clr.w, currency, clr.g, formatNumberAbbreviated(value), (""):lpad(" ", (11 - #tostring(value)))))
						totalGil:insert(value)
					--elseif currency == 'CQ' then
						--currencyTemp = (currencyTemp .. string.format("%s%s: %s%s%s", clr.w, currency, clr.g, formatNumberAbbreviated(value), (""):lpad(" ", ((paddingSpace[currency]+10) - #tostring(value)))))
					elseif S{'GL','HM','Job'}:contains(currency) then
						currencyTempLine2 = (currencyTempLine2 .. string.format("%s%s: %s%s%s", clr.w, currency, clr.g, value, (""):lpad(" ", ((paddingSpace[currency]+3) - #tostring(value)))))
					elseif currency == 'Inventory' then
						local colorInv = '\\cs(255,255,255)'
						if value >=60 and value < 70 then
							colorInv = '\\cs(255,165,0)'
						elseif value >=70 then
							colorInv = '\\cs(240,28,28)'
						end
						currencyTempLine2 = (currencyTempLine2 .. string.format("%s%s%s/80%s", colorInv, value, clr.w, (""):lpad(" ", ((paddingSpace[currency]+3) - #tostring(value)))) .. "   ")
					else
						currencyTemp = (currencyTemp .. string.format("%s%s: %s%s%s", clr.w, currency, clr.g, formatNumberAbbreviated(value), (""):lpad(" ", ((paddingSpace[currency]+2) - #tostring(value)))))
					end
				end
			end
			table.insert(update_string, (temp .. currencyTemp))
			table.insert(update_string, (currencyTempLine2))
		end
    end
	table.insert(update_string, string.format("Total Gil: %s%s", clr.g2, addCommasToNumber(totalGil:sum())))
    status_info:text(table.concat(update_string, '\n'))
	if __status and not status_info:visible() then
		status_info:show()
	end
end

function formatNumberAbbreviated(input)
	local number = input
	if type(input) == "string" then
        number = tonumber(input)
    end
    local formatted = string.format("%.2fM", number / 1000000)
	return formatted
end

function addCommasToNumber(number)
    local formatted = tostring(number)
    local reverse = string.reverse(formatted)
    local result = ""

    for i = 1, #reverse do
        result = result .. string.sub(reverse, i, i)
        if i % 3 == 0 and i < #reverse then
            result = result .. ","
        end
    end

    return string.reverse(result)
end

local last_render = 0
windower.register_event('prerender', function()
    local player = windower.ffxi.get_player()
    if not windower.ffxi.get_info().logged_in or not player then -- stops prender if not loged in yet
        return
    end
    if (os.clock()-last_render) > 1.5 and __status then
		status_hud()
		last_render = os.clock()
	end
end)