--************************************************************************************
require "configs/hw_vars_189"


exec('debug_log level=5')
exec('debug_log l3sim=1 level=5')
exec('proxy_log error_mask=0 warn_mask=0 debug_mask=0 info_mask=0')
exec('sim_log_set log_to_file=on')
--************************************************************************************
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

function check_user_var(name)
	if not _G[name] then
		print("CFG ERROR: variable '"..name.."' is not defined!")
		return false
	end
	return true
end

function make_str(fmt, s, digits, value)
	if 0 == digits then
		return s
	else
		return string.format('%.'..(s:len()-digits)..'s%0'..digits..fmt, s, value)
	end
end


--************************************************************************************
--************************************************************************************
--CHECK USER VARS PERAMETRES
if (check_user_var("UEC_DAEMON_PORT")
and check_user_var("EPC_DAEMON_PORT")
and check_user_var("PROXY_ADDR")
and check_user_var("PIP_ADDR")
and check_user_var("ENB_ADDR")
and check_user_var("S1_IP")
and check_user_var("PGW_COUNT")
and check_user_var("CELL_COUNT")
and check_user_var("UE_COUNT")
and check_user_var("PLMN")
and check_user_var("BEARER_PARAM")
and check_user_var("LINE")
and check_user_var("SERVER_IP")
and check_user_var("UEC_SERVER_IP")
and check_user_var("EPC_SERVER_IP")
	) then

--************************************************************************************
--************************************************************************************
--COUNTABLE PARAMETERES

	S1_ADDR				=	''
	S11_ADDR			=	{}
	S1U_ADDR			= 	{}
	UEC_ADDR			=	{}
	UEC_PIP				=	{}

	-- S1 SCTP multihoming parameters
	local mme_s1_multihome_str, enb_s1_multihome_str = "", ""
	-- MME S1 multihoming
	if tostring(type(S1_IP)) ~= "table" then
		-- no multihoming, one S1 to be configured
		S1_ADDR = S1_IP..':36412'
		S1_IP = {S1_IP}
	else
		S1_ADDR = S1_IP[1]..':36412'
		for s1_sctp_i = 2, #S1_IP do
			mme_s1_multihome_str = " s1_multihome_ip="..S1_IP[s1_sctp_i]
		end
	end
	-- ENB S1 multihoming
	if tostring(type(ENB_ADDR)) ~= "table" then
		-- no multihoming, one S1 to be configured
		ENB_ADDR = {ENB_ADDR}
	else
		for s1_sctp_i = 2, #ENB_ADDR do
			enb_s1_multihome_str = " s1_multihome_ip="..ENB_ADDR[s1_sctp_i]
		end
	end

	-- multi sgw parameters
	if tostring(type(S1U_IP)) ~= "table" then
		-- each record in the table corresponds to one SGW
		S1U_IP = {S1U_IP}
	end
	for sgw_i = 1, #S1U_IP do
		if tostring(type(S1U_IP[sgw_i])) ~= "table" then
			-- each recond in the table corresponds to one S1U EndPoint for current SGW
			S1U_IP[sgw_i] = {S1U_IP[sgw_i]}
		end
	end
	if #S1U_IP == 0 then
		-- if S1U_IP has not been defined or empty table => TL has one SGW with 1 S1U EndPoint and S1U IP == S1 IP
		S1U_ADDR =	{{S1_IP[1]..':2152'}}
		S11_ADDR =  {S1_IP[1]..':2153'}
	else
		-- number of elements in S1U_IP table == number of SGWs
		-- number of elements in S1U_IP[sgw_index] tables == number of S1U EndPoints
		S1U_ADDR = S1U_IP
		for s11_port_shift = 1, #S1U_IP do
			S11_ADDR[s11_port_shift] =  S1_IP[s11_port_shift]..':'..(2152 + s11_port_shift)
		end
	end

	-- multi uec parameters
	if #PIP_ADDR > #NAT_NETWORK_NUMBER then
		print("\n*********\nCONFIGURATION_ERROR: Size of PIP_ADDR is more than size of NAT_NETWORK_NUMBER \n*********")
		exec('reset')
		return false
	end
	for uec_id = 1, #PIP_ADDR do
		UEC_PIP[uec_id] = PIP_ADDR[uec_id]
		UEC_ADDR[uec_id]= NAT_NETWORK_NUMBER[uec_id][1]..'.200'..'.200'
	end

	for pgw_i = 1, PGW_COUNT do
		PGW_ADDR[pgw_i]	= 	NETWORK_NUMBER[pgw_i]..'.'..'254'..'.'..'254'
	end

	is_hw = true
	if TEST_ENV ~= nil then
		if tostring(TEST_ENV) == 'sim' then
			is_hw = false
		end
	end

	BASE_ID = BASE_ID or 1000
	DEFAULT_PDN = DEFAULT_PDN or 1
	SHIFT_ID = BASE_ID
	if tonumber(BASE_ID) < tonumber(UE_COUNT) then SHIFT_ID = UE_COUNT end

--*****************************************************************************
--*****************************************************************************
-- SET VARIABLES (Only variables used in test scripts are set as environment variables)

	exec('set LINE=\"'..LINE..'\"')

	exec('set SERVER_IP=\"'..SERVER_IP..'\"')
	exec('set USER=\"'..USER..'\"')
	exec('set USER_PASSWORD=\"'..USER_PASSWORD..'\"')

	exec('set UEC_SERVER_IP=\"'..UEC_SERVER_IP..'\"')
	exec('set UEC_USER=\"'..UEC_USER..'\"')
	exec('set UEC_USER_PASSWORD=\"'..UEC_USER_PASSWORD..'\"')

	exec('set EPC_SERVER_IP=\"'..EPC_SERVER_IP..'\"')
	exec('set EPC_USER=\"'..EPC_USER..'\"')
	exec('set EPC_USER_PASSWORD=\"'..EPC_USER_PASSWORD..'\"')

	local total_cell_count = 0
	for i = 1, #CELL_COUNT do
		total_cell_count = total_cell_count + CELL_COUNT[i]
	end
	exec('set CELL_COUNT=\"'..total_cell_count..'\"')
	exec('set BASE_ID=\"'..BASE_ID..'\"')
	exec('set SHIFT_ID=\"'..SHIFT_ID..'\"')

	-- how many hex digits should be masked to fit UEs
	local hex_digits = math.ceil(math.log(UE_COUNT)/math.log(16))
	local dec_digits = math.ceil(math.log(UE_COUNT)/math.log(10))

	-- For compatibility with old version hw_vars (before trunk revision 335)
	if not _G["ENB_UT_HW_TAC"] then ENB_UT_HW_TAC = 123 end
	if not _G["ENB_UT_SIM_TAC"] then ENB_UT_SIM_TAC = 12 end
	if not _G["NBR_CELL_TAC"] then NBR_CELL_TAC = 3 end
	if not _G["RNC_PARAM_LIST"] then RNC_PARAM_LIST = { utran_enb_id = {} } end
	if not _G["ue_security"] then ue_security = { 'eia=null eea=null' } end


	exec('set ENB_UT_HW_TAC=\"'..ENB_UT_HW_TAC..'\"')
	exec('set ENB_UT_SIM_TAC=\"'..ENB_UT_SIM_TAC..'\"')
	exec('set NBR_CELL_TAC=\"'..NBR_CELL_TAC..'\"')

	--form CELL_ID_ARRAY for iterative cells id
	if CELL_ID_ARRAY==nil then
		CELL_ID_ARRAY={}
		for proxy_i = 1, #PROXY_ADDR do
			CELL_ID_ARRAY[proxy_i]={}
			for cell_i = 1, CELL_COUNT[proxy_i] do
				CELL_ID_ARRAY[proxy_i][cell_i]=cell_i
				--debug print to be removed
				print("forming CELL_ID_ARRAY from CELL_COUNT")
				print("proxy_i= "..proxy_i.." cell_i="..cell_i.." CELL_ID_ARRAY[proxy_i][cell_i]="..CELL_ID_ARRAY[proxy_i][cell_i])
			end
		end
	end


	--***************************************************************
--***************************************************************
-- BEGIN CONFIGURATION
	sim_ = sim()
	sim_.exec_throw = true
	if (sim.INIT == sim_.state) then
		sim_:configure()
		exec('debug_log gate=1 level=5')
	end
-------------------------

-- CONFIGURE MME
	exec('set_mme id=1 ip=$EPC_SERVER_IP:'..EPC_DAEMON_PORT..' s1='..S1_ADDR..mme_s1_multihome_str..' mmegi=1 mmec=3')

-- CONFIGURE SGW
	for sgw_i = 1, #S1U_ADDR do
		exec('set_sgw id='..sgw_i..' ip=$EPC_SERVER_IP:'..EPC_DAEMON_PORT..' s1u='..S1U_ADDR[sgw_i][1]..' s11='..S11_ADDR[sgw_i])
		-- endpoints will be added after configuration finished, because the command is unavailable in configuring state
		-- for s1u_endpoint_i = 2, #S1U_ADDR[sgw_i] do
		--	exec('sgw_add_s1u_iface id='..sgw_i..' s1u='..S1U_ADDR[sgw_i][s1u_endpoint_i])
		-- end
	end

-- CONFIGURE PGW
	for pgw_i = 1, PGW_COUNT do
		if is_hw then
			exec('set_pgw id='..pgw_i..' ip=$EPC_SERVER_IP:'..EPC_DAEMON_PORT..' apn=I-PHY_PGW'..pgw_i..'.net devname=tunPGW'..pgw_i..' addr='..PGW_ADDR[pgw_i]..'/16')
		else
			exec('set_pgw id='..pgw_i..' type=simulated ip=$EPC_SERVER_IP:'..EPC_DAEMON_PORT..' apn=sI-PHY_PGW'..pgw_i..'.net devname=stunPGW'..pgw_i..' addr='..PGW_ADDR[pgw_i]..'/16')
		end
	end

-- CONFIGURE ENB UNDER TEST
	if is_hw then
		exec('set_enb id=1 plmn='..PLMN..' s1='..ENB_ADDR[1]..enb_s1_multihome_str..' enb_id_macro='..enb_id_macro..' daemon=$EPC_SERVER_IP:'..EPC_DAEMON_PORT)
	else
		exec('set_enb id=1 plmn='..PLMN..' s1='..ENB_ADDR[1]..enb_s1_multihome_str..' type=simulated enb_id_macro='..enb_id_macro..' daemon=$EPC_SERVER_IP:'..EPC_DAEMON_PORT)
	end

-- CONFIGURE NEIGHBOR ENB (SIMULATED ENB)
	if tostring(type(NBR_ENB_ADDR)) ~= "table" then
		-- backward compatibility with previos versions of hw_vars
		NBR_ENB_ADDR = {NBR_ENB_ADDR}
	end
	-- configure simulated eNB in case of at least one not nil NBR_ENB_ADDR is defined in hw_vars
	for nbr_i = 1, #NBR_ENB_ADDR do
		-- init base for s1u_port and simulated cells ports. s1u_port should be unique for every simulated eNB as well as cells ports on this eNB
		local nbr_port_shift = nbr_i + 1 + (nbr_i - 1) * total_cell_count
		-- init unique enb id macro identifier for every simulated eNB and format it as 5 symbols hex string
		local nbr_enb_id_macro = string.format("0x%05x", (nbr_i + 1))
		exec('set_enb id='..(nbr_i + 1)..' type=simulated x2='..NBR_ENB_ADDR[nbr_i]..':36422 x2_peers=none s1='..NBR_ENB_ADDR[nbr_i]..' plmn='..PLMN..' enb_id_macro='..nbr_enb_id_macro..' daemon=$EPC_SERVER_IP:'..EPC_DAEMON_PORT)
		-- configure total number of cell (sum of CELL_COUNT array elements) simulated cells for every simulated eNB
		for nbr_cell_i = 1, total_cell_count do
			-- init unique cell identifier for current eNB
			--local pci = 30 + nbr_i + nbr_cell_i
			local pci = 30 + (nbr_i-1)*total_cell_count + nbr_cell_i
			-- init group part of the pci
			local group = math.floor(tonumber(pci) / 3)
			-- init cell part of the pci
			local cell = tonumber(pci) % 3
			exec('set_cell id='..nbr_cell_i..' enb='..(nbr_i + 1)..' tac='..NBR_CELL_TAC..' pci='..group..':'..cell..' earfcn=2100:20100 proxy=$EPC_SERVER_IP:'..(EPC_DAEMON_PORT-10000-nbr_port_shift-nbr_cell_i)..' eci='..nbr_enb_id_macro..string.format("%2x", pci))
		end
	end

	CELL_ID_ARRAY_LINED = {}
-- CONFIGURE CELLS ON ENB UNDER TEST
	local random_port = math.random(1100, 1999)
	local start_id = 1
	local id_offset = 0
	if (tostring(LINE) == 'dcm' or tostring(LINE) == 'dcm_micro') and CELL_START_ID then start_id = CELL_START_ID end
	for proxy_i = 1, #PROXY_ADDR do
		for cell_i = 1, CELL_COUNT[proxy_i] do
            if PCI_LIST_NUM and PCI_LIST_NUM[cell_i] then
                eci = enb_id_macro..PCI_LIST_NUM[cell_i]
            else
			eci = enb_id_macro..'0'..(cell_i + id_offset + start_id - 1)
            end

			cell_id_from_array = CELL_ID_ARRAY[proxy_i][cell_i]
			CELL_ID_ARRAY_LINED[cell_i + id_offset ] = cell_id_from_array
			--debug_print_to_be_removed

			print("proxy_i="..proxy_i.." cell_i="..cell_i.." CELL_ID_ARRAY[proxy_i][cell_i]="..CELL_ID_ARRAY[proxy_i][cell_i])
			if is_hw then
				if PCI_LIST and PCI_LIST[cell_i + id_offset] then
					--exec('set_cell id='..(cell_i + id_offset)..' enb=1 pci='..PCI_LIST[cell_i + id_offset]..' tac='..ENB_UT_HW_TAC..' proxy='..PROXY_ADDR[proxy_i]..' eci='..eci)
					exec('set_cell id='..(cell_id_from_array + id_offset)..' enb=1 pci='..PCI_LIST[cell_i + id_offset]..' tac='..ENB_UT_HW_TAC..' proxy='..PROXY_ADDR[proxy_i]..' eci='..eci)
				else
					--exec('set_cell id='..(cell_i + id_offset)..' enb=1 tac='..ENB_UT_HW_TAC..' proxy='..PROXY_ADDR[proxy_i]..' eci='..eci)
					exec('set_cell id='..(cell_id_from_array + id_offset)..' enb=1 tac='..ENB_UT_HW_TAC..' proxy='..PROXY_ADDR[proxy_i]..' eci='..eci)
				end
			else
				if PCI_LIST and PCI_LIST[cell_i + id_offset] then
					--exec('set_cell id='..(cell_i + id_offset)..' enb=1 pci='..PCI_LIST[cell_i + id_offset]..' tac='..ENB_UT_SIM_TAC..' proxy=$EPC_SERVER_IP:'..tostring(random_port - cell_i - id_offset)..' eci='..eci)
					exec('set_cell id='..(cell_id_from_array + id_offset)..' enb=1 pci='..PCI_LIST[cell_i + id_offset]..' tac='..ENB_UT_SIM_TAC..' proxy=$EPC_SERVER_IP:'..tostring(random_port - cell_i - id_offset)..' eci='..eci)
				else
					print("\n*********\nCONFIGURATION_ERROR: Check PCI_LIST in hw_vars.lua: PCI_LIST is the table of Physical Cell Ids. Number of elements == number of cells. Format of the element is 'v1:v2'. v1 = 0..167, v2 = 0..2\n*********")
					exec('reset')
					return false
				end
			end
		end -- cells
		id_offset = CELL_COUNT[proxy_i]
	end -- proxies

-- CONFIGURE UEC
	local uplane_str = ''
	for uec_id = 1, #UEC_PIP do
		if 1 < #UEC_PIP[uec_id] then uplane_str = " peer_uplane="..UEC_PIP[uec_id][2] end
		if is_hw then
			exec('set_uec id='..tostring(uec_id)..' proxy_read_packets_threshold=20 proxy_rcv_buf_size=500000 proxy_snd_buf_size=500000 ip=$UEC_SERVER_IP:'..UEC_DAEMON_PORT..' gtpu=on pdn='..tostring(uec_id)..' addr='..UEC_ADDR[uec_id]..'/16 peer='..tostring(UEC_PIP[uec_id][1])..uplane_str..' retries=100')
		else
			exec('set_uec id='..tostring(uec_id)..' ip=$UEC_SERVER_IP:'..UEC_DAEMON_PORT..' pdn='..tostring(uec_id)..' addr='..UEC_ADDR[uec_id]..'/16 peer='..tostring(UEC_PIP[uec_id][1])..uplane_str)
		end
	end

-- CONFIGURE UES
	exec('set_param SEC_OP_KEY=63BFA50EE6523365FF14C1F45F88737D')

--------------------------------------------
	local _ip_ 		= {}
	local _nat_ip_ 	= {}
	for uec_id = 1, #NAT_NETWORK_NUMBER do _nat_ip_[uec_id] = {} end
	local cur_b_id = 1
	local cur_qci = 1
	local cur_mbr_ul = 1; cur_mbr_dl = 1; cur_gbr_ul = 1; cur_gbr_dl = 1
    for uec_id = 1, #PIP_ADDR do
    	for cell_id = 1, total_cell_count do
    		cell_id_from_array = CELL_ID_ARRAY_LINED[cell_id]

            exec('set_ue_group simulated id='..cell_id .. uec_id ..' uec='.. uec_id.. '  eia=null eea=null cell='..CELL_ID_ARRAY[1][cell_id]..' pdn='..uec_id)


            --debug_print_to_be_removed
    		print("cell_id="..cell_id.."  CELL_ID_ARRAY_LINED[cell_id]="..CELL_ID_ARRAY_LINED[cell_id])
            print("uec_id="..uec_id.." PIP_ADDR="..#PIP_ADDR.." UE_COUNT="..UE_COUNT)

            for temp_ue_id=1,UE_COUNT do
              local start_id = ((uec_id-1)*total_cell_count+cell_id) * UE_COUNT - UE_COUNT

              exec('set_ue    id='.. start_id + temp_ue_id ..' group='..cell_id .. uec_id ..' imsi='.. PLMN .. ':'..cell_id.. uec_id.. '000'.. 10000 +temp_ue_id .. ' cell='..CELL_ID_ARRAY[1][cell_id])
--              exec('ue_param  id='.. start_id + temp_ue_id ..' supported_bands=1,3,4,6,19,21,28')
				exec('ue_param id=' .. start_id + temp_ue_id ..' ue_eutra_capabilities=c9ba050600106260c89b0d18391ff8c188ffc60c47fe30f23ff1bd11ff8dfc8ffc69e47fffd3ffa6a2087004830d493952207058c08000000b88bc0c0000400308001000c600040034c001000c3000400344001000db000400700001010820028010308001001c000040460800a0040c6000400700001014c2002801034c001000c20004807080010108200384000808c1201420818c000900e1000242304005082463000200384000808c1001420818c000800e100020298400508206980020038400090a6100142091a6000800e1000202d8400508206d80020018c000900e300020230400718001014c20028c1034c001001c6000405b0800a3040db000400718001216c20028c1236c001002c000040420808c10024008184000808c1002400808410318001002c00004042080a61002400818400080a6100240080841034c001002c20004046080a61002420818c00080a61002420808c1034c001002c20004046080b61002420818c00080b61002420808c1036c001001c3000405b080be30723ff18311ff8c188ffc61e47fe37a23ff1bf91ff8d3c8ffc6ce47fe36723ff1af91ff8d7c8ffc6be47fe35f23ff1bf91ff8dfc8ffc6fe47fe37f23ff1bf91ff8dfc8ffc66c47fe33623ff19791ff8cbc8ffc6fe47fe37f23ff1b791ff8dbc8ffc6fe47fe37f23ff1af91ff8d7c8ffc6be47fe35f23ff1bf91ff8dfc8ffc6fe47fe37f23ff1bf91ff8dfc8ffc6fe47fe37f23ff1bf91ff8dfc8ffc6fe47fe37f23ff1bf91ff8dfc8ffc6fe47fc00d00000d78001fe00000007f80000001fe00000001fe00000007f80000001fe00000007f800000001ff00000007f80000001fe00000007f80000001fe00000007f80000000000110040')

            end




    	--	for ue_index = 1, UE_COUNT do

    	--		ue_id 			= BASE_ID + SHIFT_ID * (cell_id - 1) + ue_index
    	--		subnet_addr 	= cell_id..tostring(math.floor((ue_index - 1) / 250) + 1)
    	--		ue_ip_id 		= ue_index % 250
    	--		host_number 	= '00'..ue_ip_id
    	--		host_number 	= string.sub(host_number, #host_number - 2)
    	--		ue_index_str 	= '000'..ue_index
    	--		ue_index_str 	= string.sub(ue_index_str, #ue_index_str - 3)
    	--		_imsi_			= string.sub(PLMN..':111111111111', 1, 12)..cell_id..ue_index_str

    	--		for ip_i = 1, 6 do
    	--			_ip_[ip_i] 		= get_ip(  NETWORK_NUMBER[ip_i]..'.'..subnet_addr..'.'..host_number)
    	--			for uec_id = 1, #NAT_NETWORK_NUMBER do
    	--				_nat_ip_[uec_id][ip_i] 	= get_ip(NAT_NETWORK_NUMBER[uec_id][ip_i]..'.'..subnet_addr..'.'..host_number)
    	--			end
    	--		end

    	--		if ue_index == UE_COUNT - 1 then
    	--			_sec_key_ 	= make_str('X', sec_key, hex_digits, ue_index-1)..' eea=null eia=null'
    	--		else
    	--			_sec_key_ 	= make_str('X', sec_key, hex_digits, ue_index-1)..' '..ue_security[1+((ue_index-1) % #ue_security)]
    	--		end
    	--
        --        --local uec_id = 1
        --        --if 0 == ue_index%#UEC_PIP then uec_id = #UEC_PIP else uec_id = ue_index%#UEC_PIP end
    	--

        --
        --    	exec('set_ue id='..ue_id..' uec='..uec_id..' sec_key='.._sec_key_..' imsi='.._imsi_..' cell='..cell_id_from_array..' pdn='..DEFAULT_PDN)
        --        exec("ue_param id="..ue_id.. " supported_bands=1,3,4,6,19,21,28")

              -- CONFIGURE BEARERS
    			cur_b_id = 1
    			--for uec_id = 1, #BEARER_PARAM do
    				if uec_id > PGW_COUNT then
    					print("\n*********\nCONFIGURATION_ERROR: Check PGW_COUNT in hw_vars.lua: PGW_COUNT = "..PGW_COUNT.." < Num of Bearer Param Lists in BEARER_PARAM\n*********")
    					exec('reset')
    					return false
    				end -- for check if num of pgw is enough
    				if BEARER_PARAM[uec_id].trf_type == nil or
    				   BEARER_PARAM[uec_id].default_qci == nil then
    					print("\n*********\nCONFIGURATION_ERROR: Check BEARER_PARAM in hw_vars.lua: List#"..uec_id..": default bearer qci or/and traffic type is not defined\n*********")
    					exec('reset')
    					return false
    				end -- for check if parameters for default bearer are defined
    				if cur_b_id > 8 then
    					print("CONFIGURATION_WARNING: Current Bearer Identifier = "..cur_b_id.." > 8 (Max Number of Bearers for 1 UE)")
    				else
    					-- set default bearer
    					if BEARER_PARAM[uec_id].trf_type == 'external' then
    						exec('set_bearer id='..cur_b_id..' ue_group='.. cell_id .. uec_id ..' default=on pdn='..uec_id..' qci='..BEARER_PARAM[uec_id].default_qci..' ip='.._ip_[uec_id]..' nat_ip='.._nat_ip_[uec_id][uec_id]..' trf_type=external')
    					else
    						--exec('set_bearer id='..cur_b_id..' ue_group='..cell_id .. uec_id ..' default=on pdn='..uec_id..' qci='..BEARER_PARAM[uec_id].default_qci..' ip='.._ip_[uec_id]..' trf_type='..BEARER_PARAM[uec_id].trf_type)
    						exec('set_bearer id='..cur_b_id..' ue_group='..cell_id .. uec_id ..' default=on pdn='..uec_id..' qci='..BEARER_PARAM[uec_id].default_qci..'  trf_type='..BEARER_PARAM[uec_id].trf_type)
    					end -- for check of traffic type
    					cur_b_id = cur_b_id + 1
    					-- set dedicated bearers
    					for bear_i,cur_qci in ipairs(BEARER_PARAM[uec_id].qci) do
    						if BEARER_PARAM[uec_id].mbr_ul == nil or
    						   BEARER_PARAM[uec_id].mbr_dl == nil or
    						   BEARER_PARAM[uec_id].gbr_ul == nil or
    						   BEARER_PARAM[uec_id].gbr_dl == nil then
    							print("\n*********\nCONFIGURATION_ERROR: Check BEARER_PARAM in hw_vars.lua: List#"..uec_id..": MBR ul/dl["..bear_i.."] and GBR ul/dl["..bear_i.."] should be defined and initialized (by nil for non-GBR) \n*********")
    							exec('reset')
    							return false
    						else
    							if BEARER_PARAM[uec_id].mbr_ul[bear_i] == nil or
    							   BEARER_PARAM[uec_id].mbr_dl[bear_i] == nil or
    							   BEARER_PARAM[uec_id].gbr_ul[bear_i] == nil or
    							   BEARER_PARAM[uec_id].gbr_dl[bear_i] == nil then
    								exec('set_bearer id='..cur_b_id..' ue_group='..cell_id .. uec_id ..' pdn='..uec_id..' qci='..cur_qci)
    							else
    								cur_mbr_ul = BEARER_PARAM[uec_id].mbr_ul[bear_i]
    								cur_mbr_dl = BEARER_PARAM[uec_id].mbr_dl[bear_i]
    								cur_gbr_ul = BEARER_PARAM[uec_id].gbr_ul[bear_i]
    								cur_gbr_dl = BEARER_PARAM[uec_id].gbr_dl[bear_i]
    								exec('set_bearer id='..cur_b_id..' ue_group='..cell_id .. uec_id ..' pdn='..uec_id..' qci='..cur_qci..' gbr_ul='..cur_gbr_ul..' gbr_dl='..cur_gbr_dl..' mbr_ul='..cur_mbr_ul..' mbr_dl='..cur_mbr_dl)
    							end -- for check of grb/sbr
    						end -- for check if all params for dedicated bearers are defined
    						cur_b_id = cur_b_id + 1
    					end -- for bear_i

    				end -- for check num of bearer <= 8
    			--end -- for pdn_i
    	end -- for cell
     end --for uec

 ue_group=1

 seq_nr=0
   --[[ for uec__id=1,#PIP_ADDR do
        for cell_id=1,total_cell_count do
  --          exec('set_ue_group simulated id='..cell_id .. uec__id ..' uec='.. uec__id.. '  eia=aes+snow3g eea=aes+snow3g cell='..CELL_ID_ARRAY[1][cell_id])


  --          exec('set_bearer id=1 ue_group='..cell_id .. uec__id ..' default=on pdn=1 qci=9 trf_type=internal')
  --          exec('set_bearer id=2 ue_group='..cell_id .. uec__id ..' pdn=1 qci=6')
  --          exec('set_bearer id=3 ue_group='..cell_id .. uec__id ..' pdn=1 qci=8')
  --          exec('set_bearer id=4 ue_group='..cell_id .. uec__id ..' default=on pdn=2 qci=9 trf_type=internal')
  --          exec('set_bearer id=5 ue_group='..cell_id .. uec__id ..' pdn=2 qci=6')
  --          exec('set_bearer id=6 ue_group='..cell_id .. uec__id ..' pdn=2 qci=8')
  --          exec('set_bearer id=7 ue_group='..cell_id .. uec__id ..' default=on pdn=3 qci=5 trf_type=internal')
  --          exec('set_bearer id=8 ue_group='..cell_id .. uec__id ..' pdn=3 qci=1 gbr_ul=64 gbr_dl=64 mbr_ul=64 mbr_dl=64')

----            exec('set_bearer id=1 pdn=1 ue_group='..cell_id..' qci=8 trf_type=internal default=on')
----            exec('set_bearer id=2 pdn=1 ue_group='..cell_id..' qci=1 gbr_ul=31 gbr_dl=31 mbr_ul=31 mbr_dl=31')

  --          UE_COUNT = 500
  --          for imsi=1,UE_COUNT do
  --              exec('set_ue    id='.. uec__id.. cell_id * UE_COUNT +imsi ..' group='..cell_id .. uec__id ..' imsi='.. PLMN .. ':'..cell_id.. uec__id.. '000'.. 10000 +imsi .. ' cell='..CELL_ID_ARRAY[1][cell_id])
  --              exec('ue_param  id='.. uec__id.. cell_id * UE_COUNT +imsi ..' supported_bands=1,3,4,6,19,21,28')
  --          end

---- seq numbers: 1,6,11,16, target usage: Call Stability TC (250UE/cell, 250 UE with traffic)
--            exec('seq_set id='.. (seq_nr * 5 + 1) * uec__id .. ' name=Attach-Sleep-Detach ue_group='..cell_id .. uec__id)
--            exec('ue_attach')
--            --exec('trf_data_start id=1 size=884 burst=1 period_ms=300 dir=dl')
--            exec('trf_data_start id=1 size=884 burst=2 period_ms=30 dir=dl')
--            exec('trf_data_start id=1 size=884 burst=1 period_ms=60 dir=ul')
--            exec('sleep 300')
--            exec('ue_detach')
--            exec('seq_end')
--
-- seq numbers: 2,7,12,17, target usage: C-Plane Capacity TC (50 (attach/detach)/s/cellno traffic)
            exec('seq_set id='.. (seq_nr*5 + 2) * uec__id .. ' name=Attach-Detach ue_group='..cell_id .. uec__id)
            exec('ue_attach')
            exec('sleep 2')
            exec('ue_detach')
            exec('seq_end')

------ seq numbers: 3,8,13,18, target usage: C-Plane Capacity TC (50 (attach/detach)/s/cellno traffic)
--            exec('seq_set id='.. (seq_nr*5 + 3)  * uec__id.. ' name=im_exit ue_group='..cell_id .. uec__id)
--            exec('ue_attach')
--            exec('sleep 10')
--
--            exec('im_exit by=ue')
--            exec('sleep 6')
--
--            exec('ue_detach')
--            exec('seq_end')

-- seq numbers: 4,9,14,19, target usage: Cell Capacity TC (3000UE/cell, 750 UE without traffic)
            exec('seq_set id='.. (seq_nr*5 + 4)  * uec__id.. ' name=Att_sleep_Det ue_group='..cell_id .. uec__id)
            exec('ue_attach')
            exec('sleep 1000')
            --exec('im_entry by=ue')
            --exec('sleep 5')
            --exec('trf_data_start id=1 bps=56 dir=dl')
            exec('ue_detach')
            exec('seq_end')

-- seq numbers: 5,10,15,20, target usage: Cell Capacity TC (3000UE/cell, 2250 UE with traffic)
            exec('seq_set id='.. (seq_nr*5 + 5)  * uec__id.. ' name=Attach_with_trf ue_group='..cell_id .. uec__id)
            exec('ue_attach')
            exec('sleep 1')
            exec('trf_data_start id=1 kbps=1 dir=dl')
            --exec('trf_data_start id=1 size=834 burst=1 period_ms=130 dir=dl')
            exec('sleep 1000')
            exec('ue_detach')
            exec('seq_end')
            seq_nr=seq_nr+1
    end

end
	]]--
    --run through RNC_PARAM_LIST
	for i, utran_enb_id_iter in ipairs(RNC_PARAM_LIST.utran_enb_id) do

		exec("set_utran_rnc id="..RNC_PARAM_LIST.utran_rnc_ut_id[i].." host_enb="..RNC_PARAM_LIST.utran_enb_id[i].." rnc_id="..RNC_PARAM_LIST.phy_utra_cell_id[i])
		exec("set_utran_cell id="..RNC_PARAM_LIST.utran_cell_id[i].." rnc="..RNC_PARAM_LIST.utran_rnc_ut_id[i].." pci="..RNC_PARAM_LIST.phy_utra_cell_id[i].." uarfcn="..RNC_PARAM_LIST.uarfcn[i])

	end --for i, rnc_instance_id in ipairs() do

	exec('debug_log level=5')
	exec('set_log log_to_file=on')

--	exec('trace on protocol=rrc uec=1')
	exec('proxy_log error_mask=0 warn_mask=0 debug_mask=0 info_mask=0')
	exec('cfg_end')
	sleep (0.3)

	-- adding SGW S1U endpoint
	for sgw_i = 1, #S1U_ADDR do
		-- add endpoints if are defined
		for s1u_endpoint_i = 2, #S1U_ADDR[sgw_i] do
			exec('sgw_add_s1u_iface id='..sgw_i..' s1u='..S1U_ADDR[sgw_i][s1u_endpoint_i])
		end
	end
--	sleep (1.7)
end -- if

-- Overwrite iphy.xml file if file found from current execute folder
local f,err = io.open("iphy.xml", "r")
if f then
	f:close()
	print("INF - iphy.xml file found. Overwrite file.")
	os.execute("scp iphy.xml toor4nsn@192.168.255.20:/rom/simmode/.")
	sleep(2)
	print("INF - iphy.xml overwrite DONE")
else
	print("INF - iphy.xml file not found from current execute folder. Use existing file.")
end
