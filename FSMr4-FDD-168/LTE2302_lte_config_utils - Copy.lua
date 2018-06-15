--************************************************************************************
-- get_ordered_keys function
--************************************************************************************
function get_ordered_keys(TABLE)
    local ordered_keys = {}
    for k in pairs(TABLE) do table.insert(ordered_keys, k) end
    table.sort(ordered_keys)
    return ordered_keys
end

--************************************************************************************
-- get_ip function
--************************************************************************************
function get_ip(network_number)
	local _ip_ = ''
	local _index_ = 1
	for w in string.gmatch(network_number, "%d+") do
		_number_ = tostring(tonumber(w))
		
		if _index_ < 4 then
			_ip_=_ip_.._number_..'.'
		else
			_ip_=_ip_.._number_
		end
		_index_=_index_+1
	end
	return _ip_
end

--************************************************************************************
-- check_user_var function
--************************************************************************************
function check_user_var(value, name)
	if (nil == value) then
		print("CFG ERROR: No "..name .. " set in testline_vars.lua")
		return false
	end
	return true
end

--************************************************************************************
-- check_testline_var_parameters function
--************************************************************************************
function check_testline_var_parameters()
	if (check_user_var(UEC_TABLE_A,"UEC_TABLE_A")
		and check_user_var(EPC_TABLE_A,"EPC_TABLE_A")
		and check_user_var(ENB_TABLE_A,"ENB_TABLE_A")
		and check_user_var(MME_TABLE_A,"MME_TABLE_A")
		and check_user_var(SGW_TABLE_A,"SGW_TABLE_A")
		and check_user_var(PGW_TABLE_A,"PGW_TABLE_A")
		) then
		return true
	end
	if (check_user_var(UEC_TABLE_B,"UEC_TABLE_B")
		and check_user_var(EPC_TABLE_B,"EPC_TABLE_B")
		and check_user_var(ENB_TABLE_B,"ENB_TABLE_B")
		and check_user_var(MME_TABLE_B,"MME_TABLE_B")
		and check_user_var(SGW_TABLE_B,"SGW_TABLE_B")
		and check_user_var(PGW_TABLE_B,"PGW_TABLE_B")
		) then
		return true
	end
	return false
end


function f_exec(cmd, variableName)
	local codeStr = "value = "..variableName
	local code = loadstring(codeStr) 
	code()
	exec(cmd..'"'..value..'"')
end

--************************************************************************************
-- set_simmode_variables function
--************************************************************************************
function set_simmode_variables(...)
	id = ... or ""
	if id ~= "" then
		id = "_"..id
	end

	--for data generation with ext_traffic libs
	f_exec('set USER=', "TESTLINE_USERNAME"..id)
	f_exec('set USER_PASSWORD=', "TESTLINE_PASSWORD"..id)
	f_exec('set SERVER_IP=', "UE_APPLICATION_PC"..id)
	f_exec('set UEC_SERVER_IP=', "UE_APPLICATION_PC"..id)
	f_exec('set UEC_USER=', "TESTLINE_USERNAME"..id)
	f_exec('set UEC_USER_PASSWORD=', "TESTLINE_PASSWORD"..id)
	f_exec('set EPC_SERVER_IP=', "CN_APPLICATION_PC"..id)
	f_exec('set EPC_USER=', "TESTLINE_USERNAME"..id)
	f_exec('set EPC_USER_PASSWORD=', "TESTLINE_PASSWORD"..id)

end


--************************************************************************************
-- set_enb_parameters function
-- The set_enb_parameters() funtion generates the following example commands for each eNB defined in ENB_TABLE
--   exec('set_enb type=external id=1 plmn=666:61 s1=172.18.1.63 enb_id_macro=0x0B007 daemon=$DAEMON_UEC_IP:$DAEMON_PORT')
--   exec('set_cell id=1 enb=1 pci=21:0 tac=12 proxy='..UEC1_PROXY_ADDR..' eci=0x0B00701')
--   exec('set_cell id=2 enb=1 pci=54:1 tac=12 proxy='..UEC1_PROXY_ADDR..' eci=0x0B00702')
--   exec('set_cell id=3 enb=1 pci=87:2 tac=12 proxy='..UEC1_PROXY_ADDR..' eci=0x0B00703')	
--************************************************************************************
function set_enb_parameters(ENB_TABLE_A, UEC_TABLE_A, egateType, ...)
	local ENB_TABLE_B, UEC_TABLE_B = ...
	if ENB_TABLE_B == nil then
		numEnb = 1
	else
		numEnb = 2
	end
	--print("CFG INFO: start reading ENB_TABLE parameters")
	egateType = egateType or "wraparound"

	for enbCounter = 1, numEnb do
		id = "_"..string.char(64 + enbCounter)
		enbId = enbCounter
		
		-- ENB_TABLE
		local codeStr = "ENB_TABLE_value = ".."ENB_TABLE"..id
		local code = loadstring(codeStr) 
		code()

		-- UEC_TABLE
		codeStr = "UEC_TABLE_value = ".."UEC_TABLE"..id
		code = loadstring(codeStr) 
		code()
		
	    	ordered_enbs_keys = get_ordered_keys(ENB_TABLE_value)
		for i = 1, table.getn(ordered_enbs_keys) do
	        	local enbKey, enbTable = ordered_enbs_keys[i], ENB_TABLE_value[ ordered_enbs_keys[i] ]
			print("CFG INFO:  generating set commands for key enb="..enbKey.." from "..codeStr)
			DAEMON_UEC_IP = UEC_TABLE_value[enbTable["uecName"]]["daemonIp"]
			DAEMON_UEC_PORT = UEC_TABLE_value[enbTable["uecName"]]["daemonPort"]
			UEC1_PROXY_IP = UEC_TABLE_value[enbTable["uecName"]]["uecProxyIp"]
			UEC1_PROXY_PORT = UEC_TABLE_value[enbTable["uecName"]]["uecProxyPort"]
			UEC1_PROXY_ADDR = UEC1_PROXY_IP..":"..UEC1_PROXY_PORT
			exec("set_enb"..
				" type="..enbTable["type"]..
				" id="..enbId..
				" plmn="..enbTable["plmn"]..
				" s1="..enbTable["s1"]..
				" enb_id_macro="..enbTable["enbIdMacro"]..
				" daemon="..DAEMON_UEC_IP..":"..DAEMON_UEC_PORT
			)
			if egateType == 'uec' or egateType == 'wraparound' then
				ordered_uec_keys = get_ordered_keys(enbTable)
				for i = 1, table.getn(ordered_uec_keys) do
					local paramKey,paramValue = ordered_uec_keys[i], enbTable[ ordered_uec_keys[i] ]
					if paramKey == "cells" then
						ordered_cells_keys = get_ordered_keys(paramValue)
						for i = 1, table.getn(ordered_cells_keys) do
							local idx,phyCellid = ordered_cells_keys[i], paramValue[ ordered_cells_keys[i] ]
							exec("set_cell"..
								" id="..idx..
								" enb="..enbId..
								" pci="..PCI_LIST[i]..
								--" pci="..math.floor(phyCellid/3)..":"..math.fmod(phyCellid,3)..
								" tac="..enbTable["tac"]..
								" proxy="..UEC1_PROXY_ADDR..
								" eci="..enbTable["enbIdMacro"].."0"..idx
								--" mandatory_for_activation=false"
							)
						end
					end
				end
			--[[
			elseif egateType == 'epc' then
				for paramKey,paramValue in pairs(enbTable) do
					if paramKey == "cells" then
						ordered_keys = get_ordered_keys(paramValue)
						for i = 1, table.getn(ordered_keys) do
							local idx,phyCellid = ordered_keys[i], paramValue[ ordered_keys[i] ]
							exec("set_cell"..
								" id="..idx..
								" enb="..enbId..
								" pci="..math.floor(phyCellid/3)..":"..math.fmod(phyCellid,3)..
								" tac="..enbTable["tac"]..
								" eci="..enbTable["enbIdMacro"].."0"..idx
							)
						end
					end
				end
			--]]		
			end
			enbId = enbId + 1
		end
		--print("CFG INFO: end reading ENB_TABLE parameters")
	end

	--print("CFG INFO: end reading ENB_TABLE parameters2")
end


--************************************************************************************
-- set_uec_parameters function
-- generates the following example commands for each UEC defined in UEC_TABLE
--   exec('set_uec id=1 ip=$DAEMON_UEC_IP:$DAEMON_PORT gtpu=on pdn=1 addr=$UEC1_ADDR/16 peer=$UEC1_PIP retries=unlimited')
--************************************************************************************
function set_uec_parameters( UEC_TABLE, PGW_TABLE )
	--print("CFG INFO: start reading UEC_TABLE parameters")
	uecId = 1
	ordered_keys = get_ordered_keys(UEC_TABLE)
	for i = 1, table.getn(ordered_keys) do
		local uecKey,uecTable = ordered_keys[i], UEC_TABLE[ ordered_keys[i] ]
		print("CFG INFO:  generating set commands for uec="..uecKey)
		exec("set_uec"..
			" id="..uecId..
            		" proxy_read_packets_threshold=20 proxy_rcv_buf_size=2000000 proxy_snd_buf_size=2000000"..
			" ip="..uecTable["daemonIp"]..":"..uecTable["daemonPort"]..
			" gtpu=on pdn="..uecTable["pdn"]..
			" addr="..get_ip( PGW_TABLE[uecTable["pgwName"]]["pgwUecIpAddress"] ).."/16"..
			" peer="..uecTable["Cplane_uecServerIp"]..":"..uecTable["uecProxyPort"]..
            " peer_uplane="..uecTable["Uplane_uecServerIp"]..":"..uecTable["uecProxyPort"]..
			" retries=unlimited"
		)
		uecId = uecId + 1
	end
	--print("CFG INFO: end reading UEC_TABLE parameters")
end


--************************************************************************************
-- set_mme_parameters function
-- generates the following example commands for each MME defined in MME_TABLE
--   exec('set_mme id=1 type=simulated ip=$DAEMON_EPC_IP:$DAEMON_PORT s1=$S1_ADDR mmegi=1 mmec=3')	
--************************************************************************************
function set_mme_parameters(MME_TABLE, EPC_TABLE)
	--print("CFG INFO: start reading MME_TABLE parameters")
	mmeId = 1
	ordered_keys = get_ordered_keys(MME_TABLE)
	for i = 1, table.getn(ordered_keys) do
		local mmeKey,mmeTable = ordered_keys[i], MME_TABLE[ ordered_keys[i] ]
		print("CFG INFO:  generating set commands for mme="..mmeKey)
		DAEMON_EPC_IP = EPC_TABLE[mmeTable["epcName"]]["daemonIp"]
		DAEMON_EPC_PORT = EPC_TABLE[mmeTable["epcName"]]["daemonPort"]
		exec("set_mme"..
			" id="..mmeId..
			" type=simulated"..
			" ip="..DAEMON_EPC_IP..":"..DAEMON_EPC_PORT..
			" s1="..mmeTable["s1Ip"]..":"..mmeTable["s1Port"]..
			" mmegi="..mmeTable["mmegi"]..
			" mmec="..mmeTable["mmec"]
		)
		mmeId = mmeId + 1
	end
	--print("CFG INFO: end reading MME_TABLE parameters")
end


--************************************************************************************
-- set_sgw_parameters function
-- generates the following example commands for each SGW defined in SGW_TABLE
--   exec('set_sgw id=1 type=simulated ip=$DAEMON_EPC_IP:$DAEMON_PORT s1u=$S1U_ADDR s11=$S11_ADDR')
--************************************************************************************
function set_sgw_parameters(SGW_TABLE, EPC_TABLE)
	--print("CFG INFO: start reading SGW_TABLE parameters")
	sgwId = 1
	ordered_keys = get_ordered_keys(SGW_TABLE)
	for i = 1, table.getn(ordered_keys) do
		local sgwKey,sgwTable = ordered_keys[i], SGW_TABLE[ ordered_keys[i] ]
		print("CFG INFO:  generating set commands for sgw="..sgwKey)
		DAEMON_EPC_IP = EPC_TABLE[sgwTable["epcName"]]["daemonIp"]
		DAEMON_EPC_PORT = EPC_TABLE[sgwTable["epcName"]]["daemonPort"]
		exec("set_sgw"..
			" id="..sgwId..
			" type=simulated"..
			" s1u_rcv_buff_size=524288 s1u_snd_buff_size=524288 s5u_rcv_buff_size=524288 s5u_snd_buff_size=524288"..
			--" s1u_rcv_buff_size=1048576 s1u_snd_buff_size=1048576 s5u_rcv_buff_size=1048576 s5u_snd_buff_size=1048576"..
			" ip="..DAEMON_EPC_IP..":"..DAEMON_EPC_PORT..
			" s1u="..sgwTable["s1uIp"]..":"..sgwTable["s1uPort"]..
			" s11="..sgwTable["s11Ip"]..":"..sgwTable["s11Port"]
		)
		sgwId = sgwId + 1
	end
	--print("CFG INFO: end reading SGW_TABLE parameters")
end


--************************************************************************************
-- set_pgw_parameters function
-- generates the following example commands for each PGW defined in PGW_TABLE
--   exec('set_pgw id=1 type=simulated ip=$DAEMON_EPC_IP:$DAEMON_PORT apn=ulm_pgw1.net devtype=tun devname=tunPGW1 addr=$PGW1_ADDR/16')
--************************************************************************************
function set_pgw_parameters(PGW_TABLE, EPC_TABLE, egateType)
	--print("CFG INFO: start reading PGW_TABLE parameters")
	egateType = egateType or "epc"
	pgwId = 1
	ordered_keys = get_ordered_keys(PGW_TABLE)
	for i = 1, table.getn(ordered_keys) do -- table.getn(ordered_keys) do
		local pgwKey,pgwTable = ordered_keys[i], PGW_TABLE[ ordered_keys[i] ]
		print("CFG INFO:  generating set commands for pgw="..pgwKey)
		DAEMON_EPC_IP = EPC_TABLE[pgwTable["epcName"]]["daemonIp"]
		DAEMON_EPC_PORT = EPC_TABLE[pgwTable["epcName"]]["daemonPort"]
		if egateType == 'epc' or egateType == 'wraparound' then
			exec("set_pgw"..
				" id="..pgwId..
				" type=simulated"..
		--		" sgi_rcv_buff_size=1048576 sgi_snd_buff_size=1048576 s5u_rcv_buff_size=1048576 s5u_snd_buff_size=1048576"..
				" ip="..DAEMON_EPC_IP..":"..DAEMON_EPC_PORT..
				" apn=ulm_pgw"..pgwId..".net devtype=tun devname=tunPGW"..pgwId..
				" addr="..get_ip( pgwTable["pgwIpAddress"] ).."/16"

			)
		elseif egateType == 'uec' then
			exec("set_pgw"..
				" id="..pgwId..
				" type=external"..
				" apn=ulm_pgw"..pgwId..".net"..
				" addr="..get_ip( pgwTable["pgwIpAddress"] ).."/16"
			)
		end
		pgwId = pgwId + 1
	end
	--print("CFG INFO: end reading PGW_TABLE parameters")
end


--************************************************************************************
-- generate_simmmode_set_commands function
--************************************************************************************
function generate_simmmode_set_commands(egateType, UEC_TABLE_A, EPC_TABLE_A, ENB_TABLE_A, MME_TABLE_A, SGW_TABLE_A, PGW_TABLE_A, ... )
	ENB_TABLE_B, UEC_TABLE_B = ...
	
	egateType = egateType or 'wraparound'

	-------------------------------------------
	check_testline_var_parameters()
	set_simmode_variables("A")
	
	-------------------------------------------
	-- EPC configuration
	if egateType == 'wraparound' or egateType == 'epc' then
		set_mme_parameters( MME_TABLE_A , EPC_TABLE_A )
		set_sgw_parameters( SGW_TABLE_A , EPC_TABLE_A )
	end
	set_pgw_parameters( PGW_TABLE_A , EPC_TABLE_A , egateType )
    
    -------------------------------------------
	-- ENB configuration
	set_enb_parameters( ENB_TABLE_A , UEC_TABLE_A , egateType , ...)
		
	-------------------------------------------
	-- UEC configuration
	if egateType == 'wraparound' or egateType == 'uec' then
		set_uec_parameters( UEC_TABLE_A , PGW_TABLE_A )
	end
end



--eof
