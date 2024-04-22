command_map = {
	['mnt'] = 'input /mount \"Red Crab\"',
	['dis'] = 'input /dismount',
	['warp'] = 'myhome',
	['omen'] = 'myomen',
	['fps30'] = 'config FrameRateDivisor 2',
	['fps60'] = 'config FrameRateDivisor 2',
	['lotall'] = 'tr lotall',
} 

npc_map = {
	[33] = {name = {
		['Swirling Vortex'] = {entry_command = {4, {'up', 0.15}, 1.1, {'enter', 0.15}}},
		}},
	[50] = {name = {
		['Ironbound Gate'] = {entry_command = {0.85, {'up', 0.15}, 0.5, {'enter', 0.15}}}, 
		['Gate: The Pit'] = {entry_command = {0.85, {'up', 0.15}, 0.5, {'enter', 0.15}}}, 
		['Gate: Chocobo Circuit'] = {entry_command = {0.85, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		}},	
	[51] = {name = {
		['Engraved Tablet'] = {entry_command = {0.85, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		}},
	[61] = {name = {
		['Engraved Tablet'] = {entry_command = {0.85, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		}},
	[70] = {name = {
		['Ilsorie'] = {entry_command = {0.85, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		}},
	[79] = {name = {
		['Engraved Tablet'] = {entry_command = {0.85, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		}},
	[71] = {name = {
		['Gate: The Pit'] = {entry_command = {0.85, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		}},
	[72] = {name = {
		['Gilded Doors'] = {entry_command = {0.85, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		}},
	[90] = {name = {
		['Cavernous Maw'] = {entry_command = {0.85, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Veridical Conflux'] = {entry_command = {0.85, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		}},
	[111] = {name = {
		['Trail Markings'] = {entry_command = {2.5, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		}},
	[112] = {name = {
		['Trail Markings'] = {entry_command = {2.5, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		}},
	[126] = {name = {
		['Transcendental Radiance'] = {entry_command = {4, {'up', 0.15}, 1.1, {'enter', 0.15}}},
		}},
	[133] = {name = {
		['Diaphanous Device'] = {entry_command = {1.0, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Diaphanous Device #A'] = {entry_command = {1.0, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Diaphanous Device #B'] = {entry_command = {1.0, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Diaphanous Device #C'] = {entry_command = {1.0, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Diaphanous Device #D'] = {entry_command = {1.0, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Diaphanous Gadget'] = {entry_command = {1.0, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Diaphanous Gadget #A'] = {entry_command = {1.0, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Diaphanous Gadget #B'] = {entry_command = {1.0, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Diaphanous Gadget #C'] = {entry_command = {1.0, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Diaphanous Gadget #D'] = {entry_command = {1.0, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Diaphanous Gadget #E'] = {entry_command = {1.0, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Diaphanous Gadget #F'] = {entry_command = {1.0, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Diaphanous Gadget #G'] = {entry_command = {1.0, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Diaphanous Gadget #H'] = {entry_command = {1.0, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Diaphanous Bitzer #A'] = {entry_command = {1.0, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Diaphanous Bitzer #B'] = {entry_command = {1.0, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Diaphanous Bitzer #C'] = {entry_command = {1.0, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Diaphanous Bitzer #D'] = {entry_command = {1.0, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Diaphanous Bitzer'] = {entry_command = {2.0, {'up', 0.15}, 0.5, {'enter', 0.15}, 0.5, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		}},
    [137] = {name = {
		['Veridical Conflux'] = {entry_command = {2.0, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		}},
	[176] = {name ={
		['Grounds Tome'] = {description='Grounds Tome', menu_id = 24, packet = {[1]={{20,0,0,true},{20,0,0,false}}}},
		}},
	[182] = {name = {
		['???'] = {entry_command = {1.8, {'enter', 0.15}, 1.8, {'enter', 0.15}, 1.8, {'enter', 0.15}, 1.8, {'enter', 0.15}}},
		['Veridical Conflux'] = {entry_command = {1.8, {'enter', 0.15}}},
		['Veridical Conflux #01'] = {entry_command = {3.5, {'right', 0.75}, 0.6, {'enter', 0.15}}},
		['Veridical Conflux #02'] = {entry_command = {3.5, {'right', 0.75}, 0.6, {'enter', 0.15}}},
		['Veridical Conflux #03'] = {entry_command = {3.5, {'right', 0.75}, 0.6, {'enter', 0.15}}},
		['Veridical Conflux #04'] = {entry_command = {3.5, {'right', 0.75}, 0.6, {'enter', 0.15}}},
		['Veridical Conflux #05'] = {entry_command = {3.5, {'right', 0.75}, 0.6, {'enter', 0.15}}},
		['Veridical Conflux #06'] = {entry_command = {3.5, {'right', 0.75}, 0.6, {'enter', 0.15}}},
		['Veridical Conflux #07'] = {entry_command = {3.5, {'right', 0.75}, 0.6, {'enter', 0.15}}},
		['Veridical Conflux #08'] = {entry_command = {3.5, {'right', 0.75}, 0.6, {'enter', 0.15}}},
		['Veridical Conflux #09'] = {entry_command = {3.5, {'right', 0.75}, 0.6, {'enter', 0.15}}},
		['Veridical Conflux #10'] = {entry_command = {3.5, {'right', 0.75}, 0.6, {'enter', 0.15}}},
		['Veridical Conflux #11'] = {entry_command = {3.5, {'right', 0.75}, 0.6, {'enter', 0.15}}},
		['Veridical Conflux #12'] = {entry_command = {3.5, {'right', 0.75}, 0.6, {'enter', 0.15}}},
		['Veridical Conflux #13'] = {entry_command = {3.5, {'right', 0.75}, 0.6, {'enter', 0.15}}},
		['Veridical Conflux #14'] = {entry_command = {3.5, {'right', 0.75}, 0.6, {'enter', 0.15}}},
		['Veridical Conflux #15'] = {entry_command = {3.5, {'right', 0.75}, 0.6, {'enter', 0.15}}},
		}},
	-- [188] = {name = { -- Dynamis Jeuno
		-- ['Sominal Threshold'] = {description='Sominal Threshold',  menu_id = 101, packet = {[1]={{0,0,0,true},{1,0,0,false}}}},
		-- }},
	[189] = {name = {
		['Diaphanous Device'] = {entry_command = {1.0, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Diaphanous Device #A'] = {entry_command = {1.0, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Diaphanous Device #B'] = {entry_command = {1.0, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Diaphanous Device #C'] = {entry_command = {1.0, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Diaphanous Device #D'] = {entry_command = {1.0, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Diaphanous Gadget'] = {entry_command = {1.0, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Diaphanous Gadget #A'] = {entry_command = {1.0, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Diaphanous Gadget #B'] = {entry_command = {1.0, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Diaphanous Gadget #C'] = {entry_command = {1.0, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Diaphanous Gadget #D'] = {entry_command = {1.0, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Diaphanous Gadget #E'] = {entry_command = {1.0, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Diaphanous Gadget #F'] = {entry_command = {1.0, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Diaphanous Gadget #G'] = {entry_command = {1.0, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Diaphanous Gadget #H'] = {entry_command = {1.0, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Diaphanous Bitzer #A'] = {entry_command = {1.0, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Diaphanous Bitzer #B'] = {entry_command = {1.0, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Diaphanous Bitzer #C'] = {entry_command = {1.0, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Diaphanous Bitzer #D'] = {entry_command = {1.0, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Diaphanous Bitzer'] = {entry_command = {2.0, {'up', 0.15}, 0.5, {'enter', 0.15}, 0.5, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		}},
	[190] = {name ={
        ['???'] = {description='KRT', entry_command = {1.5, {'up', 0.15}, 0.5, {'enter', 0.15}}},
        }},
	[206] = {name ={
        ['Burning Circle'] = {entry_command = {1.0, {'up', 0.15}, 0.5, {'enter', 0.15}}},
        }},
	[212] = {name ={
		['Grounds Tome'] = {description='Grounds Tome', menu_id = 19, packet = {[1]={{20,0,0,true},{20,0,0,false}}}},
		}},
	[230] = {name = {
		['Gate: Chocobo Circuit'] = {entry_command = {0.85, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		}},
	[234] = {name = {
		['Gate: Chocobo Circuit'] = {entry_command = {0.85, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		}},
	[241] = {name = {
		['Gate: Chocobo Circuit'] = {entry_command = {0.85, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		}},
	[243] = {name = { -- Ru'Lude
		['Trail Markings'] = {description='Dynamis',  menu_id = 10176, packet = {[1]={{0,0,0,false}}}},
		}},
	[246] = {name = {
		['Gate: Chocobo Circuit'] = {entry_command = {0.85, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		}},
	[255] = {name = {
		['Cavernous Maw'] = {entry_command = {0.85, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		}},
	[256] = {name = {
		['Dangueubert'] = {entry_command = {2.0, {'enter', 0.15}}},
		}},
	[257] = {name = {	-- Eastern Adoulin
		['Cunegonde'] = {description='Mog Garden', menu_id = 575, packet = {[1]={{1,0,0,false}}}},
		['Krepol'] = {description='Silver Knife', entry_command = {1.3, {'enter', 0.15}}},
		['Glowing Hearth'] = {description='Silver Knife',entry_command = {1.3, {'enter', 0.15}}},
		}},
	[261] = {name = { -- [Ceizak]
		['???'] = {index = {
			[497] = {description='WKR Ceizak', entry_command = {1.5, {'down', 0.05}, 0.7, {'enter', 0.15}, 2.1, {'up', 0.15}, 0.7, {'enter', 0.15}}}, -- WKR Ceizak
			[593] = {description='Beam Up - To Sih Gates', entry_command = {0.85, {'down', 0.15}, 0.5, {'enter', 0.15}}}, --Beam Up - To Sih Gates
		}}}},
	[262] = {name = { -- [Foret]
		['???'] = {index = {
			[531] = {entry_command = {1.5, {'down', 0.05}, 0.7, {'enter', 0.15}, 2.1, {'up', 0.15}, 0.7, {'enter', 0.15}}}, -- WKR Foret
			[625] = {entry_command = {0.85, {'down', 0.15}, 0.5, {'enter', 0.15}}}, --Beam Up - To Dho Gates
		}}}},
	[263] = {name = { -- [Yorcia]
		['???'] = {index = {
			[562] = {entry_command = {1.5, {'down', 0.05}, 0.7, {'enter', 0.15}, 2.1, {'up', 0.15}, 0.7, {'enter', 0.15}}},	--WKR Yorcia
			[649] = {entry_command = {0.85, {'down', 0.15}, 0.5, {'enter', 0.15}}},  --Beam Up - To Cirdas
		}}}},
	[265] = {name = { -- [Morimor]
		['???'] = {index = { 
			[734] = {entry_command = {1.5, {'down', 0.05}, 0.7, {'enter', 0.15}, 2.1, {'up', 0.15}, 0.7, {'enter', 0.15}}}, --WKR Morimor
			[844] = {entry_command = {0.85, {'down', 0.15}, 0.5, {'enter', 0.15}}},  --Beam Up - To Moh Gates
		}}}},
	[266] = {name = { -- [Marjami]
		['???'] = {index = { 
			[416] = {entry_command = {1.5, {'down', 0.05}, 0.7, {'enter', 0.15}, 2.1, {'up', 0.15}, 0.7, {'enter', 0.15}}}, --WKR Marjami
			[507] = {entry_command = {0.85, {'down', 0.15}, 0.5, {'enter', 0.15}}},  --Beam Up - To Woh Gates
		}},
		['Scalable Area'] = {entry_command = {0.85, {'enter', 0.15}}},
		}},
	[267] = {name = { -- [Kamihr]
		['???'] = {entry_command = {1.5, {'down', 0.05}, 0.7, {'enter', 0.15}, 2.1, {'up', 0.15}, 0.7, {'enter', 0.15}}}, --WKR Kamihr
		}},
	[268] = {name = { -- [Sih Gates]
		['???'] = {entry_command = {0.85, {'down', 0.15}, 0.5, {'enter', 0.15}}},	--Beam Up/Down - To Ceizak /  Ra'Kaznar Inner Court
		}},
	[269] = {name = { -- [Moh Gates]
		['???'] = {entry_command = {0.85, {'down', 0.15}, 0.5, {'enter', 0.15}}},	--Beam Up/Down - To Morimor / Ra'Kaznar Inner Court
		}},
	[270] = {name = { -- [Cirdas Caverns]
		['???'] = {entry_command = {0.85, {'down', 0.15}, 0.5, {'enter', 0.15}}},	--Beam Up/Down - To Yorcia /  Ra'Kaznar Inner Court
		}},
	[272] = {name = { -- [Dho Gates]
		['???'] = {entry_command = {0.85, {'down', 0.15}, 0.5, {'enter', 0.15}}},	--Beam Up/Down - To Foret /  Ra'Kaznar Inner Court
		}},
	[273] = {name = { -- [Woh Gates]
		['???'] = {entry_command = {0.85, {'down', 0.15}, 0.5, {'enter', 0.15}}},	--Beam Up/Down - To Marjami /  Ra'Kaznar Inner Court
		}},
	[274] = {name = {
		['Entwined Roots'] = {entry_command = {0.85, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Vertical Transit Device'] = {entry_command = {1.1, {'enter', 0.15}}},
		}},
	[275] = {name = {
		['Diaphanous Device'] = {entry_command = {1.0, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Diaphanous Device #A'] = {entry_command = {1.0, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Diaphanous Device #B'] = {entry_command = {1.0, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Diaphanous Device #C'] = {entry_command = {1.0, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Diaphanous Device #D'] = {entry_command = {1.0, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Diaphanous Gadget'] = {entry_command = {1.0, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Diaphanous Gadget #A'] = {entry_command = {1.0, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Diaphanous Gadget #B'] = {entry_command = {1.0, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Diaphanous Gadget #C'] = {entry_command = {1.0, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Diaphanous Gadget #D'] = {entry_command = {1.0, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Diaphanous Gadget #E'] = {entry_command = {1.0, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Diaphanous Gadget #F'] = {entry_command = {1.0, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Diaphanous Gadget #G'] = {entry_command = {1.0, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Diaphanous Gadget #H'] = {entry_command = {1.0, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Diaphanous Bitzer #A'] = {entry_command = {1.0, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Diaphanous Bitzer #B'] = {entry_command = {1.0, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Diaphanous Bitzer #C'] = {entry_command = {1.0, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Diaphanous Bitzer #D'] = {entry_command = {1.0, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Diaphanous Bitzer'] = {entry_command = {2.0, {'up', 0.15}, 0.5, {'enter', 0.15}, 0.5, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		}},
	[279] = {name = {
		['Translocator #1'] = {entry_command = {1.0, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Translocator #2'] = {entry_command = {1.0, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Veridical Conflux #1'] = {entry_command = {1.0, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Veridical Conflux #2'] = {entry_command = {1.0, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Veridical Conflux #3'] = {entry_command = {1.0, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Veridical Conflux #4'] = {entry_command = {1.0, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Veridical Conflux #5'] = {entry_command = {1.0, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Veridical Conflux #6'] = {entry_command = {1.0, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Veridical Conflux #7'] = {entry_command = {1.0, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Veridical Conflux #8'] = {entry_command = {1.0, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Veridical Conflux #9'] = {entry_command = {1.0, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Veridical Conflux #10'] = {entry_command = {1.0, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Veridical Conflux #11'] = {entry_command = {1.0, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Otherworldly Vortex'] = {entry_command = {1.0, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		}},
	[280] = {name ={
		['Green Thumb Moogle']  = {description='Exit Mog Garden', menu_id=1016, packet={[1]={{255,4092,0,false}}}},
		}}, 
	[283] = {name = {
		['Dusky Forest'] = {entry_command = {0.85, {'enter', 0.15}}},
		['Reglert'] = {entry_command = {0.85, {'enter', 0.15}}},
		}},
	[298] = {name = {
		['Translocator #1'] = {entry_command = {1.0, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Translocator #2'] = {entry_command = {1.0, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Veridical Conflux #1'] = {entry_command = {1.0, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Veridical Conflux #2'] = {entry_command = {1.0, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Veridical Conflux #3'] = {entry_command = {1.0, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Veridical Conflux #4'] = {entry_command = {1.0, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Veridical Conflux #5'] = {entry_command = {1.0, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Veridical Conflux #6'] = {entry_command = {1.0, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Veridical Conflux #7'] = {entry_command = {1.0, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Veridical Conflux #8'] = {entry_command = {1.0, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Veridical Conflux #9'] = {entry_command = {1.0, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Veridical Conflux #10'] = {entry_command = {1.0, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Veridical Conflux #11'] = {entry_command = {1.0, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		['Otherworldly Vortex'] = {entry_command = {1.0, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		}},
}


get_map = {
	[15] = {name ={
		['Conflux Surveyor'] = {cmd = {
			['aby'] = {description='Abyssea Visitation - Remaining time', entry_command = {1.0, {'down', 0.05}, 0.5, {'down', 0.05}, 0.5, {'enter', 0.15}, 1.5, {'down', 0.05}, 0.5, {'enter', 0.15}, 1.5, {'up', 0.05}, 0.5, {'enter', 0.15}, 1.5, {'up', 0.05}, 0.5, {'enter', 0.15}}},
			['aby1'] = {description='Abyssea Visitation - 1 Stone', entry_command = {1.0, {'down', 0.05}, 0.5, {'down', 0.05}, 0.5, {'enter', 0.15}, 1.5, {'down', 0.05}, 0.5, {'down', 0.15}, 0.5, {'enter', 0.15}, 1.5, {'up', 0.05}, 0.5, {'enter', 0.15}, 1.5, {'up', 0.05}, 0.5, {'enter', 0.15}}},
			['aby2'] = {description='Abyssea Visitation - 2 Stone', entry_command = {1.0, {'down', 0.05}, 0.5, {'down', 0.05}, 0.5, {'enter', 0.15}, 1.5, {'down', 0.05}, 0.5, {'down', 0.05}, 0.5, {'down', 0.15}, 0.5, {'enter', 0.15}, 1.5, {'up', 0.05}, 0.5, {'enter', 0.15}, 1.5, {'up', 0.05}, 0.5, {'enter', 0.15}}},
		}}
	}},
	[45] = {name ={
		['Conflux Surveyor'] = {cmd = {
			['aby'] = {description='Abyssea Visitation - Remaining time', entry_command = {1.0, {'down', 0.05}, 0.5, {'down', 0.05}, 0.5, {'enter', 0.15}, 1.5, {'down', 0.05}, 0.5, {'enter', 0.15}, 1.5, {'up', 0.05}, 0.5, {'enter', 0.15}, 1.5, {'up', 0.05}, 0.5, {'enter', 0.15}}},
			['aby1'] = {description='Abyssea Visitation - 1 Stone', entry_command = {1.0, {'down', 0.05}, 0.5, {'down', 0.05}, 0.5, {'enter', 0.15}, 1.5, {'down', 0.05}, 0.5, {'down', 0.15}, 0.5, {'enter', 0.15}, 1.5, {'up', 0.05}, 0.5, {'enter', 0.15}, 1.5, {'up', 0.05}, 0.5, {'enter', 0.15}}},
			['aby2'] = {description='Abyssea Visitation - 2 Stone', entry_command = {1.0, {'down', 0.05}, 0.5, {'down', 0.05}, 0.5, {'enter', 0.15}, 1.5, {'down', 0.05}, 0.5, {'down', 0.05}, 0.5, {'down', 0.15}, 0.5, {'enter', 0.15}, 1.5, {'up', 0.05}, 0.5, {'enter', 0.15}, 1.5, {'up', 0.05}, 0.5, {'enter', 0.15}}},
		}}
	}},
	[50] = {name ={
		['Rytaal'] = {cmd = {
			['tag'] = {description='Assault Tag', entry_command = {2.0, {'enter', 0.15}, 0.75, {'enter', 0.15}, 0.75, {'up', 0.15}, 0.75, {'enter', 0.15}}},
		}},
		['Sorrowful Sage'] = {cmd = {
			['nyzul'] = {description='Nyzul Tag', entry_command = {1.0, {'enter', 0.15}}},
		}},
		['Wondrix'] = {cmd = {
			['gobbiebox'] = {description='Gobbie Mystery Box', entry_command = {3.0, {'enter', 0.15}, 1.5, {'right', 1.0}, 1.0, {'enter', 0.15}, 9.0, {'escape', 0.15}}},
		}},
	}},
	[132] = {name ={
		['Conflux Surveyor'] = {cmd = {
			['aby'] = {description='Abyssea Visitation - Remaining time', entry_command = {1.0, {'down', 0.05}, 0.5, {'down', 0.05}, 0.5, {'enter', 0.15}, 1.5, {'down', 0.05}, 0.5, {'enter', 0.15}, 1.5, {'up', 0.05}, 0.5, {'enter', 0.15}, 1.5, {'up', 0.05}, 0.5, {'enter', 0.15}}},
			['aby1'] = {description='Abyssea Visitation - 1 Stone', entry_command = {1.0, {'down', 0.05}, 0.5, {'down', 0.05}, 0.5, {'enter', 0.15}, 1.5, {'down', 0.05}, 0.5, {'down', 0.15}, 0.5, {'enter', 0.15}, 1.5, {'up', 0.05}, 0.5, {'enter', 0.15}, 1.5, {'up', 0.05}, 0.5, {'enter', 0.15}}},
			['aby2'] = {description='Abyssea Visitation - 2 Stone', entry_command = {1.0, {'down', 0.05}, 0.5, {'down', 0.05}, 0.5, {'enter', 0.15}, 1.5, {'down', 0.05}, 0.5, {'down', 0.05}, 0.5, {'down', 0.15}, 0.5, {'enter', 0.15}, 1.5, {'up', 0.05}, 0.5, {'enter', 0.15}, 1.5, {'up', 0.05}, 0.5, {'enter', 0.15}}},
		}}
	}},
	[215] = {name ={
		['Conflux Surveyor'] = {cmd = {
			['aby'] = {description='Abyssea Visitation - Remaining time', entry_command = {1.0, {'down', 0.05}, 0.5, {'down', 0.05}, 0.5, {'enter', 0.15}, 1.5, {'down', 0.05}, 0.5, {'enter', 0.15}, 1.5, {'up', 0.05}, 0.5, {'enter', 0.15}, 1.5, {'up', 0.05}, 0.5, {'enter', 0.15}}},
			['aby1'] = {description='Abyssea Visitation - 1 Stone', entry_command = {1.0, {'down', 0.05}, 0.5, {'down', 0.05}, 0.5, {'enter', 0.15}, 1.5, {'down', 0.05}, 0.5, {'down', 0.15}, 0.5, {'enter', 0.15}, 1.5, {'up', 0.05}, 0.5, {'enter', 0.15}, 1.5, {'up', 0.05}, 0.5, {'enter', 0.15}}},
			['aby2'] = {description='Abyssea Visitation - 2 Stone', entry_command = {1.0, {'down', 0.05}, 0.5, {'down', 0.05}, 0.5, {'enter', 0.15}, 1.5, {'down', 0.05}, 0.5, {'down', 0.05}, 0.5, {'down', 0.15}, 0.5, {'enter', 0.15}, 1.5, {'up', 0.05}, 0.5, {'enter', 0.15}, 1.5, {'up', 0.05}, 0.5, {'enter', 0.15}}},
		}}
	}},
	[216] = {name ={
		['Conflux Surveyor'] = {cmd = {
			['aby'] = {description='Abyssea Visitation - Remaining time', entry_command = {1.0, {'down', 0.05}, 0.5, {'down', 0.05}, 0.5, {'enter', 0.15}, 1.5, {'down', 0.05}, 0.5, {'enter', 0.15}, 1.5, {'up', 0.05}, 0.5, {'enter', 0.15}, 1.5, {'up', 0.05}, 0.5, {'enter', 0.15}}},
			['aby1'] = {description='Abyssea Visitation - 1 Stone', entry_command = {1.0, {'down', 0.05}, 0.5, {'down', 0.05}, 0.5, {'enter', 0.15}, 1.5, {'down', 0.05}, 0.5, {'down', 0.15}, 0.5, {'enter', 0.15}, 1.5, {'up', 0.05}, 0.5, {'enter', 0.15}, 1.5, {'up', 0.05}, 0.5, {'enter', 0.15}}},
			['aby2'] = {description='Abyssea Visitation - 2 Stone', entry_command = {1.0, {'down', 0.05}, 0.5, {'down', 0.05}, 0.5, {'enter', 0.15}, 1.5, {'down', 0.05}, 0.5, {'down', 0.05}, 0.5, {'down', 0.15}, 0.5, {'enter', 0.15}, 1.5, {'up', 0.05}, 0.5, {'enter', 0.15}, 1.5, {'up', 0.05}, 0.5, {'enter', 0.15}}},
		}}
	}},
	[217] = {name ={
		['Conflux Surveyor'] = {cmd = {
			['aby'] = {description='Abyssea Visitation - Remaining time', entry_command = {1.0, {'down', 0.05}, 0.5, {'down', 0.05}, 0.5, {'enter', 0.15}, 1.5, {'down', 0.05}, 0.5, {'enter', 0.15}, 1.5, {'up', 0.05}, 0.5, {'enter', 0.15}, 1.5, {'up', 0.05}, 0.5, {'enter', 0.15}}},
			['aby1'] = {description='Abyssea Visitation - 1 Stone', entry_command = {1.0, {'down', 0.05}, 0.5, {'down', 0.05}, 0.5, {'enter', 0.15}, 1.5, {'down', 0.05}, 0.5, {'down', 0.15}, 0.5, {'enter', 0.15}, 1.5, {'up', 0.05}, 0.5, {'enter', 0.15}, 1.5, {'up', 0.05}, 0.5, {'enter', 0.15}}},
			['aby2'] = {description='Abyssea Visitation - 2 Stone', entry_command = {1.0, {'down', 0.05}, 0.5, {'down', 0.05}, 0.5, {'enter', 0.15}, 1.5, {'down', 0.05}, 0.5, {'down', 0.05}, 0.5, {'down', 0.15}, 0.5, {'enter', 0.15}, 1.5, {'up', 0.05}, 0.5, {'enter', 0.15}, 1.5, {'up', 0.05}, 0.5, {'enter', 0.15}}},
		}}
	}},
	[218] = {name ={
		['Conflux Surveyor'] = {cmd = {
			['aby'] = {description='Abyssea Visitation - Remaining time', entry_command = {1.0, {'down', 0.05}, 0.5, {'down', 0.05}, 0.5, {'enter', 0.15}, 1.5, {'down', 0.05}, 0.5, {'enter', 0.15}, 1.5, {'up', 0.05}, 0.5, {'enter', 0.15}, 1.5, {'up', 0.05}, 0.5, {'enter', 0.15}}},
			['aby1'] = {description='Abyssea Visitation - 1 Stone', entry_command = {1.0, {'down', 0.05}, 0.5, {'down', 0.05}, 0.5, {'enter', 0.15}, 1.5, {'down', 0.05}, 0.5, {'down', 0.15}, 0.5, {'enter', 0.15}, 1.5, {'up', 0.05}, 0.5, {'enter', 0.15}, 1.5, {'up', 0.05}, 0.5, {'enter', 0.15}}},
			['aby2'] = {description='Abyssea Visitation - 2 Stone', entry_command = {1.0, {'down', 0.05}, 0.5, {'down', 0.05}, 0.5, {'enter', 0.15}, 1.5, {'down', 0.05}, 0.5, {'down', 0.05}, 0.5, {'down', 0.15}, 0.5, {'enter', 0.15}, 1.5, {'up', 0.05}, 0.5, {'enter', 0.15}, 1.5, {'up', 0.05}, 0.5, {'enter', 0.15}}},
		}}
	}},
	[230] = {name ={
		['Mystrix'] = {cmd = {
			['gobbiebox'] = {description='Gobbie Mystery Box', entry_command = {3.0, {'enter', 0.15}, 1.5, {'right', 1.0}, 1.0, {'enter', 0.15}, 9.0, {'escape', 0.15}}},
		}}
	}}, 
	[231] = {name ={
		['Trisvain'] = {cmd = {
			['htmb'] = {description='HTMB NPC', entry_command = {3.0, {'escape', 0.15}}},
		}}
	}},
	[232] = {name ={
		['Habitox'] = {cmd = {
			['gobbiebox'] = {description='Gobbie Mystery Box', entry_command = {3.0, {'enter', 0.15}, 1.5, {'right', 1.0}, 1.0, {'enter', 0.15}, 9.0, {'escape', 0.15}}},
		}},
		['Curio Vendor Moogle'] = {cmd = {
			['meds'] = {description='Meds', menu_id = 9601, packet = {[1]={{1,0,0,false}}}, count = 0, category = 'none'},
			['scrolls'] = {description='Scrolls', menu_id = 9601, packet = {[1]={{5,0,0,false}}}, count = 0, category = 'none'},
			['foods'] = {description='Foods', menu_id = 9601, packet = {[1]={{4,0,0,false}}}, count = 0, category = 'none'},
			-- Actual shop items
			['panacea'] = {description='Panacea', menu_id = 9601, packet = {[1]={{1,0,0,false}}}, shop_packet_slot = 11, count = 24, category = 'meds'},
			['echodrops'] = {description='Echo Drops', menu_id = 9601, packet = {[1]={{1,0,0,false}}}, shop_packet_slot = 13, count = 48, category = 'meds'},
			['holywater'] = {description='Holy Water', menu_id = 9601, packet = {[1]={{1,0,0,false}}}, shop_packet_slot = 15, count = 48, category = 'meds'},
			['remedy'] = {description='Remedy', menu_id = 9601, packet = {[1]={{1,0,0,false}}}, shop_packet_slot = 16, count = 48, category = 'meds'},
			['prismpowder'] = {description='Prism Powder', menu_id = 9601, packet = {[1]={{1,0,0,false}}}, shop_packet_slot = 18, count = 24, category = 'meds'},
			['silentoil'] = {description='Silent Oil', menu_id = 9601, packet = {[1]={{1,0,0,false}}}, shop_packet_slot = 19, count = 24, category = 'meds'},
			['reraiser'] = {description='Reraiser', menu_id = 9601, packet = {[1]={{1,0,0,false}}}, shop_packet_slot = 21, count = 1, category = 'meds'},
			['hireraiser'] = {description='Hi-Reraiser', menu_id = 9601, packet = {[1]={{1,0,0,false}}}, shop_packet_slot = 22, count = 1, category = 'meds'},
			['instantreraise'] = {description='Instant Reraise', menu_id = 9601, packet = {[1]={{5,0,0,false}}}, shop_packet_slot = 1, count = 1, category = 'scrolls'},
			['instantwarp'] = {description='Instant Warp', menu_id = 9601, packet = {[1]={{5,0,0,false}}}, shop_packet_slot = 0, count = 1, category = 'scrolls'},
			['grapedaifuku'] = {description='Grape Daifuku', menu_id = 9601, packet = {[1]={{4,0,0,false}}}, shop_packet_slot = 67, count = 24, category = 'foods'},
			['rolandaifuku'] = {description='Rolan. Daifuku', menu_id = 9601, packet = {[1]={{4,0,0,false}}}, shop_packet_slot = 65, count = 24, category = 'foods'},
			['maringna'] = {description='Maringna', menu_id = 9601, packet = {[1]={{4,0,0,false}}}, shop_packet_slot = 57, count = 24, category = 'foods'},
		}},
	}}, 
	[234] = {name ={
		['Bountibox'] = {cmd = {
			['gobbiebox'] = {description='Gobbie Mystery Box', entry_command = {3.0, {'enter', 0.15}, 1.5, {'right', 1.0}, 1.0, {'enter', 0.15}, 9.0, {'escape', 0.15}}},
		}}
	}}, 
	[235] = {name ={
		['Specilox'] = {cmd = {
			['gobbiebox'] = {description='Gobbie Mystery Box', entry_command = {3.0, {'enter', 0.15}, 1.5, {'right', 1.0}, 1.0, {'enter', 0.15}, 9.0, {'escape', 0.15}}},
		}},
	}}, 
	[236] = {name ={
		['Curio Vendor Moogle'] = {cmd = {
			['meds'] = {description='Meds', menu_id = 9601, packet = {[1]={{1,0,0,false}}}, count = 0, category = 'none'},
			['scrolls'] = {description='Scrolls', menu_id = 9601, packet = {[1]={{5,0,0,false}}}, count = 0, category = 'none'},
			['foods'] = {description='Foods', menu_id = 9601, packet = {[1]={{4,0,0,false}}}, count = 0, category = 'none'},
			-- Actual shop items
			['panacea'] = {description='Panacea', menu_id = 9601, packet = {[1]={{1,0,0,false}}}, shop_packet_slot = 11, count = 24, category = 'meds'},
			['echodrops'] = {description='Echo Drops', menu_id = 9601, packet = {[1]={{1,0,0,false}}}, shop_packet_slot = 13, count = 48, category = 'meds'},
			['holywater'] = {description='Holy Water', menu_id = 9601, packet = {[1]={{1,0,0,false}}}, shop_packet_slot = 15, count = 48, category = 'meds'},
			['remedy'] = {description='Remedy', menu_id = 9601, packet = {[1]={{1,0,0,false}}}, shop_packet_slot = 16, count = 48, category = 'meds'},
			['prismpowder'] = {description='Prism Powder', menu_id = 9601, packet = {[1]={{1,0,0,false}}}, shop_packet_slot = 18, count = 24, category = 'meds'},
			['silentoil'] = {description='Silent Oil', menu_id = 9601, packet = {[1]={{1,0,0,false}}}, shop_packet_slot = 19, count = 24, category = 'meds'},
			['reraiser'] = {description='Reraiser', menu_id = 9601, packet = {[1]={{1,0,0,false}}}, shop_packet_slot = 21, count = 1, category = 'meds'},
			['hireraiser'] = {description='Hi-Reraiser', menu_id = 9601, packet = {[1]={{1,0,0,false}}}, shop_packet_slot = 22, count = 1, category = 'meds'},
			['instantreraise'] = {description='Instant Reraise', menu_id = 9601, packet = {[1]={{5,0,0,false}}}, shop_packet_slot = 1, count = 1, category = 'scrolls'},
			['instantwarp'] = {description='Instant Warp', menu_id = 9601, packet = {[1]={{5,0,0,false}}}, shop_packet_slot = 0, count = 1, category = 'scrolls'},
			['grapedaifuku'] = {description='Grape Daifuku', menu_id = 9601, packet = {[1]={{4,0,0,false}}}, shop_packet_slot = 67, count = 24, category = 'foods'},
			['rolandaifuku'] = {description='Rolan. Daifuku', menu_id = 9601, packet = {[1]={{4,0,0,false}}}, shop_packet_slot = 65, count = 24, category = 'foods'},
			['maringna'] = {description='Maringna', menu_id = 9601, packet = {[1]={{4,0,0,false}}}, shop_packet_slot = 57, count = 24, category = 'foods'},
		}},
	}},
	[239] = {name ={
		['Arbitrix'] = {cmd = {
			--['gobbiebox'] = {description='Gobbie Mystery Box', entry_command = {3.0, {'enter', 0.15}, 1.5, {'right', 1.0}, 1.0, {'enter', 0.15}, 9.0, {'escape', 0.15}}},
			['gobbiebox'] = {description='Gobbie Mystery Box', menu_id = 520, packet = {[1]={{5,0,0,true},{49,0,0,true},{50,0,0,true},{53,0,0,true},{0,16384,0,false}}}},
		}}
	}},
	[240] = {name ={
		['Curio Vendor Moogle'] = {cmd = {
			['meds'] = {description='Meds', menu_id = 9601, packet = {[1]={{1,0,0,false}}}, count = 0, category = 'none'},
			['scrolls'] = {description='Scrolls', menu_id = 9601, packet = {[1]={{5,0,0,false}}}, count = 0, category = 'none'},
			['foods'] = {description='Foods', menu_id = 9601, packet = {[1]={{4,0,0,false}}}, count = 0, category = 'none'},
			-- Actual shop items
			['panacea'] = {description='Panacea', menu_id = 9601, packet = {[1]={{1,0,0,false}}}, shop_packet_slot = 11, count = 24, category = 'meds'},
			['echodrops'] = {description='Echo Drops', menu_id = 9601, packet = {[1]={{1,0,0,false}}}, shop_packet_slot = 13, count = 48, category = 'meds'},
			['holywater'] = {description='Holy Water', menu_id = 9601, packet = {[1]={{1,0,0,false}}}, shop_packet_slot = 15, count = 48, category = 'meds'},
			['remedy'] = {description='Remedy', menu_id = 9601, packet = {[1]={{1,0,0,false}}}, shop_packet_slot = 16, count = 48, category = 'meds'},
			['prismpowder'] = {description='Prism Powder', menu_id = 9601, packet = {[1]={{1,0,0,false}}}, shop_packet_slot = 18, count = 24, category = 'meds'},
			['silentoil'] = {description='Silent Oil', menu_id = 9601, packet = {[1]={{1,0,0,false}}}, shop_packet_slot = 19, count = 24, category = 'meds'},
			['reraiser'] = {description='Reraiser', menu_id = 9601, packet = {[1]={{1,0,0,false}}}, shop_packet_slot = 21, count = 1, category = 'meds'},
			['hireraiser'] = {description='Hi-Reraiser', menu_id = 9601, packet = {[1]={{1,0,0,false}}}, shop_packet_slot = 22, count = 1, category = 'meds'},
			['instantreraise'] = {description='Instant Reraise', menu_id = 9601, packet = {[1]={{5,0,0,false}}}, shop_packet_slot = 1, count = 1, category = 'scrolls'},
			['instantwarp'] = {description='Instant Warp', menu_id = 9601, packet = {[1]={{5,0,0,false}}}, shop_packet_slot = 0, count = 1, category = 'scrolls'},
			['grapedaifuku'] = {description='Grape Daifuku', menu_id = 9601, packet = {[1]={{4,0,0,false}}}, shop_packet_slot = 67, count = 24, category = 'foods'},
			['rolandaifuku'] = {description='Rolan. Daifuku', menu_id = 9601, packet = {[1]={{4,0,0,false}}}, shop_packet_slot = 65, count = 24, category = 'foods'},
			['maringna'] = {description='Maringna', menu_id = 9601, packet = {[1]={{4,0,0,false}}}, shop_packet_slot = 57, count = 24, category = 'foods'},
		}},
		['Milma-Hapilma, W.W.'] = {cmd = {
			['signet'] = {description='Signet', menu_id = 32759, packet = {[1]={{1,0,0,false}}}},
		}},
	}},
	[241] = {name ={
		['Funtrox'] = {cmd = {
			['gobbiebox'] = {description='Gobbie Mystery Box', entry_command = {3.0, {'enter', 0.15}, 1.5, {'right', 1.0}, 1.0, {'enter', 0.15}, 9.0, {'escape', 0.15}}},
		}},
		['Harara, W.W.'] = {cmd = {
			['signet'] = {description='Signet', menu_id = 32759, packet = {[1]={{1,0,0,false}}}},
		}},
	}},
	[244] = {name ={
		['Priztrix'] = {cmd = {
			['gobbiebox'] = {description='Gobbie Mystery Box', entry_command = {3.0, {'enter', 0.15}, 1.5, {'right', 1.0}, 1.0, {'enter', 0.15}, 9.0, {'escape', 0.15}}},
		}}
	}}, 
	[245] = {name ={
		['Sweepstox'] = {cmd = {
			['gobbiebox'] = {description='Gobbie Mystery Box', entry_command = {3.0, {'enter', 0.15}, 1.5, {'right', 1.0}, 1.0, {'enter', 0.15}, 9.0, {'escape', 0.15}}},
		}},
		['Greyson'] = {cmd = {
			['marsreturn'] = {description='Trade Mars Orb', item_id = 9275,},
			['marsorb'] = {description='Mars Orb', ki_max_num = 1, curr_amount = 6, curr_type = "Silver A.M.A.N. Vouchers Stored", item_check = 'Mars Orb', menu_id = 20084, packet = {[1]={{1,0,0,false}}}},
		}},
	}}, 
	[246] = {name ={
		['Joachim'] = {cmd = {
			['abystone'] = {description='Abyssea Traveler Stone KI', entry_command = {1.2, {'enter', 0.15}}},
		}},
		['Shami'] = {cmd = {
			['deimosorb'] = { description='Deimos Orb', ki_max_num = 1, curr_amount = 50, curr_type = "Kindred Crests", item_check = 'Deimos Orb', menu_id = 322, 
						packet = {[1]={{11,0,0,false}}}},
			['macroorb'] = { description='Macrocosmic Orb', ki_max_num = 1, curr_amount = 20, curr_type = "Sacred Kindred Crests", item_check = 'Macrocosmic Orb', menu_id = 322, 
						packet = {[1]={{15,0,0,false}}}},
			['moonorb'] = {	description='Moon Orb', ki_max_num = 1, curr_amount = 60, curr_type = "Beastman Seals", item_check = 'Moon Orb', menu_id = 322, 
						packet = {[1]={{5,0,0,false}}}},
		}},
	}},  
	[247] = {name ={
		['???'] = {cmd = {
			['mog'] = {	description='Moglophone', ki_max_num = 1, ki_check = S{3212}, menu_id = 2001, 
						packet = {[1]={{1,0,0,true},{4,0,0,false}}}},
			['mog2'] = {description='Moglophone II', ki_max_num = 3, ki_check = S{3234,3235,3236}, menu_id = 2001, 
						packet = {	[1]={{11,0,0,true},{268,0,0,true},{267,0,0,true},{0,16384,0,false}},
									[2]={{11,0,0,true},{524,0,0,true},{523,0,0,true},{0,16384,0,false}},
									[3]={{11,0,0,true},{780,0,0,true},{779,0,0,true},{0,16384,0,false}}}},
		}}
	}},
	[253] = {name ={
		['Conflux Surveyor'] = {cmd = {
			['aby'] = {description='Abyssea Visitation - Remaining time', entry_command = {1.0, {'down', 0.05}, 0.5, {'down', 0.05}, 0.5, {'enter', 0.15}, 1.5, {'down', 0.05}, 0.5, {'enter', 0.15}, 1.5, {'up', 0.05}, 0.5, {'enter', 0.15}, 1.5, {'up', 0.05}, 0.5, {'enter', 0.15}}},
			['aby1'] = {description='Abyssea Visitation - 1 Stone', entry_command = {1.0, {'down', 0.05}, 0.5, {'down', 0.05}, 0.5, {'enter', 0.15}, 1.5, {'down', 0.05}, 0.5, {'down', 0.15}, 0.5, {'enter', 0.15}, 1.5, {'up', 0.05}, 0.5, {'enter', 0.15}, 1.5, {'up', 0.05}, 0.5, {'enter', 0.15}}},
			['aby2'] = {description='Abyssea Visitation - 2 Stone', entry_command = {1.0, {'down', 0.05}, 0.5, {'down', 0.05}, 0.5, {'enter', 0.15}, 1.5, {'down', 0.05}, 0.5, {'down', 0.05}, 0.5, {'down', 0.15}, 0.5, {'enter', 0.15}, 1.5, {'up', 0.05}, 0.5, {'enter', 0.15}, 1.5, {'up', 0.05}, 0.5, {'enter', 0.15}}},
		}}
	}},
	[254] = {name ={
		['Conflux Surveyor'] = {cmd = {
			['aby'] = {description='Abyssea Visitation - Remaining time', entry_command = {1.0, {'down', 0.05}, 0.5, {'down', 0.05}, 0.5, {'enter', 0.15}, 1.5, {'down', 0.05}, 0.5, {'enter', 0.15}, 1.5, {'up', 0.05}, 0.5, {'enter', 0.15}, 1.5, {'up', 0.05}, 0.5, {'enter', 0.15}}},
			['aby1'] = {description='Abyssea Visitation - 1 Stone', entry_command = {1.0, {'down', 0.05}, 0.5, {'down', 0.05}, 0.5, {'enter', 0.15}, 1.5, {'down', 0.05}, 0.5, {'down', 0.15}, 0.5, {'enter', 0.15}, 1.5, {'up', 0.05}, 0.5, {'enter', 0.15}, 1.5, {'up', 0.05}, 0.5, {'enter', 0.15}}},
			['aby2'] = {description='Abyssea Visitation - 2 Stone', entry_command = {1.0, {'down', 0.05}, 0.5, {'down', 0.05}, 0.5, {'enter', 0.15}, 1.5, {'down', 0.05}, 0.5, {'down', 0.05}, 0.5, {'down', 0.15}, 0.5, {'enter', 0.15}, 1.5, {'up', 0.05}, 0.5, {'enter', 0.15}, 1.5, {'up', 0.05}, 0.5, {'enter', 0.15}}},
		}}
	}},
	[256] = {name ={
		['Fleuricette'] = {cmd = {
			['ionis'] = {description='Ionis', entry_command = {1.2, {'enter', 0.15}, 0.5, {'up', 0.15}, 0.5, {'enter', 0.15}}},
		}},
		['Rewardox'] = {cmd = {
			['gobbiebox'] = {description='Gobbie Mystery Box', entry_command = {3.0, {'enter', 0.15}, 1.5, {'right', 1.0}, 1.0, {'enter', 0.15}, 9.0, {'escape', 0.15}}},
		}},
	}},
	[257] = {name ={
		['Dimmian'] = {cmd = {
			['wkr'] = {description='WKR KIs', menu_id = 30, packet = {[1]={{13,0,0,true},{14,0,0,true},{14,0,0,false}}}},
		}},
		['Quiri-Aliri'] = {cmd = {
			['ionis'] = {description='Ionis', menu_id = 1201, packet = {[1]={{1,0,0,false}}}},
		}},
		['Winrix'] = {cmd = {
			['gobbiebox'] = {description='Gobbie Mystery Box', entry_command = {3.0, {'enter', 0.15}, 1.5, {'right', 1.0}, 1.0, {'enter', 0.15}, 9.0, {'escape', 0.15}}},
		}},
	}},
	[276] = {name ={
		['Malobra'] = {cmd = {
			['srki'] = {description='Sinister Reign KI', entry_command = {0.5, {'down', 0.15}, 1.0, {'enter', 0.15}, 1.0, {'up', 0.15}, 1.0, {'enter', 0.15}}},
			['srdrops'] = {description='Sinsiter Reign Rewards', entry_command = {0.5, {'down', 0.15}, 1.0, {'enter', 0.15}}},
		}}
	}},
	[279] = {name ={
		['Otherworldly Vortex'] = {cmd = {
			['ody'] = {description='Odyssey Rewards', entry_command = {1.3, {'escape', 0.15}}},
		}}
	}},
	[281] = {name ={
		['Soupox'] = {cmd = {
			['soupox'] = {description='Soupox NPC', entry_command = {1.3, {'escape', 0.15}}},
		}}
	}}, 
	[291] = {name ={
		['Emporox'] = {cmd = {
			['pot'] = {description='Potpourri KI', menu_id = 9751, packet = {[1]={{5,0,0,true},{5,5,0,false}}}}
		}},
		['Incantrix'] = {cmd = {
			['canteen'] = {description='Omen KI', ki_max_num = 1, ki_check = S{3137}, menu_id = 31, packet = {[1]={{2,0,0,true},{3,0,0,false}}}},
		}},
		['Earthly Concrescence'] = {cmd = {
			['omen'] = {description='Register to enter: Omen', menu_id = 16, leader = true, packet = {[1]={{1,0,0,true},{1,0,0,false}}}},
		}}
	}},
	[298] = {name ={
		['Otherworldly Vortex'] = {cmd = {
			['ody'] = {description='Odyssey Rewards', entry_command = {1.3, {'escape', 0.15}}},
		}}
	}},
}

basic_key_sequence = {
	['ent'] = {command = {0.7, {'enter', 0.15}}},
	['enup'] = {command = {0.7, {'up', 0.15}, 0.5, {'enter', 0.15}}},
	['endown'] = {command = {0.7, {'down', 0.15}, 0.5, {'enter', 0.15}}},
	['esc'] = {command = {0.7, {'escape', 0.15}}},
}

return entry_map
