--************************************************************************************
-- get_ordered_keys function
--************************************************************************************
function get_ordered_keys(TABLE)
    local ordered_keys = {}
    for k in pairs(TABLE) do table.insert(ordered_keys, k) end
    table.sort(ordered_keys)
    return ordered_keys
end

function get_uec_servers_ip()
        ip_table = shell("ip addr |egrep -o  10.34.166.[0-9]+ |egrep -v 255$")
        return split(ip_table,'\n')
end

function split(inputstring, separator)
        separator = separator or "%s"
        local outputstring={} ; i=1
        for substring in string.gmatch(inputstring, "([^"..separator.."]+)") do
                outputstring[i] = substring
                i = i + 1
        end
        return outputstring
end

function shell(command)
    local output, handler
    handler = assert(io.popen(command, "r"))
    output = handler:read("*all")
    handler:close()
    return output
end


function debug_level(level)
    if level < 6 then
        level = 6
    end
    exec('debug_log level='..level)
    exec('debug_log l3sim=1 level='..level)
    exec('proxy_log error_mask=0 warn_mask=0 debug_mask=0 info_mask=0')
    exec('sim_log_set log_to_file=on')
end
--************************************************************************************
-- get_ip function
--************************************************************************************
-- function geit_ip(network_number) -- looks unnecessary, left for easier refactoring
--     if 1 then
--         return network_number
--     end
--     local _ip_ = ''
--     local _index_ = 1
--     for w in string.gmatch(network_number, "%d+") do
--         _number_ = tostring(tonumber(w))
--
--         if _index_ < 4 then
--             _ip_=_ip_.._number_..'.'
--         else
--             _ip_=_ip_.._number_
--         end
--         _index_=_index_+1
--     end
--     return _ip_
-- end

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
    if (check_user_var(UEC_TABLE_DEFAULT,"UEC_TABLE_DEFAULT")
        and check_user_var(EPC_TABLE_DEFAULT,"EPC_TABLE_DEFAULT")
        and check_user_var(ENB_TABLE_DEFAULT,"ENB_TABLE_DEFAULT")
        and check_user_var(MME_TABLE_DEFAULT,"MME_TABLE_DEFAULT")
        and check_user_var(SGW_TABLE_DEFAULT,"SGW_TABLE_DEFAULT")
        and check_user_var(PGW_TABLE_DEFAULT,"PGW_TABLE_DEFAULT")
        ) then
            print("all set")
        return true
    end
    -- if (check_user_var(UEC_TABLE_B,"UEC_TABLE_B")
    --     and check_user_var(EPC_TABLE_B,"EPC_TABLE_B")
    --     and check_user_var(ENB_TABLE_B,"ENB_TABLE_B")
    --     and check_user_var(MME_TABLE_B,"MME_TABLE_B")
    --     and check_user_var(SGW_TABLE_B,"SGW_TABLE_B")
    --     and check_user_var(PGW_TABLE_B,"PGW_TABLE_B")
    --     ) then
    --     return true
    -- end
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
-- set_mme_parameters function
-- generates the following example commands for each MME defined in MME_TABLE
--   exec('set_mme id=1 type=simulated ip=$DAEMON_EPC_IP:$DAEMON_PORT s1=$S1_ADDR mmegi=1 mmec=3')
--************************************************************************************
function set_mme_parameters(MME_TABLE, EPC_TABLE)
    ordered_keys = get_ordered_keys(MME_TABLE)
    for mmeId = 1, table.getn(ordered_keys) do
        local mmeKey,mmeTable = ordered_keys[mmeId], MME_TABLE[ ordered_keys[mmeId] ]
        print("CFG INFO:  generating set commands for mme="..mmeKey)
        DAEMON_EPC_IP = EPC_TABLE[mmeTable["epcName"]]["daemonIp"] or server_deamonip
        DAEMON_EPC_PORT = EPC_TABLE[mmeTable["epcName"]]["daemonPort"] or server_deamonport
        exec("set_mme"..
            " id="..mmeId..
            " type=simulated"..
            " ip="..DAEMON_EPC_IP..":"..DAEMON_EPC_PORT..
            " s1="..mmeTable["s1Ip"]..":"..mmeTable["s1Port"]..
            " mmegi="..mmeTable["mmegi"]..
            " mmec="..mmeTable["mmec"]
        )
    end
end

--************************************************************************************
-- set_sgw_parameters function
-- generates the following example commands for each SGW defined in SGW_TABLE
--   exec('set_sgw id=1 type=simulated ip=$DAEMON_EPC_IP:$DAEMON_PORT s1u=$S1U_ADDR s11=$S11_ADDR')
--************************************************************************************
-- 
function set_sgw_parameters(SGW_TABLE, EPC_TABLE)
    ordered_keys = get_ordered_keys(SGW_TABLE)
    for sgwId = 1, table.getn(ordered_keys) do
        local sgwKey,sgwTable = ordered_keys[sgwId], SGW_TABLE[ ordered_keys[sgwId] ]
        print("CFG INFO:  generating set commands for sgw="..sgwKey)
        DAEMON_EPC_IP = EPC_TABLE[sgwTable["epcName"]]["daemonIp"] or server_deamonip
        DAEMON_EPC_PORT = EPC_TABLE[sgwTable["epcName"]]["daemonPort"] or server_deamonport
        exec("set_sgw"..
            " id="..sgwId..
            " type=simulated"..
            " ip="..DAEMON_EPC_IP..":"..DAEMON_EPC_PORT..
            " s1u="..sgwTable["s1uIp"]..":"..sgwTable["s1uPort"]..
            " s11="..sgwTable["s11Ip"]..":"..sgwTable["s11Port"]
        )
    end
end

--************************************************************************************
-- set_pgw_parameters function
-- generates the following example commands for each PGW defined in PGW_TABLE
--   exec('set_pgw id=1 type=simulated ip=$DAEMON_EPC_IP:$DAEMON_PORT apn=ulm_pgw1.net devtype=tun devname=tunPGW1 addr=$PGW1_ADDR/16')
--************************************************************************************
function set_pgw_parameters(PGW_TABLE, EPC_TABLE, egateType)
    egateType = egateType or "epc"
    ordered_keys = get_ordered_keys(PGW_TABLE)
    for pgwId = 1, table.getn(ordered_keys) do
        local pgwKey,pgwTable = ordered_keys[pgwId], PGW_TABLE[ ordered_keys[pgwId] ]
        pgw_IP = pgwTable["pgwID"].."3.7.254.254"
        print("CFG INFO:  generating set commands for pgw="..pgwKey)
        DAEMON_EPC_IP = EPC_TABLE[pgwTable["epcName"]]["daemonIp"] or server_deamonip
        DAEMON_EPC_PORT = EPC_TABLE[pgwTable["epcName"]]["daemonPort"] or server_deamonport
        if egateType == 'epc' or egateType == 'wraparound' then
            exec("set_pgw"..
                " id="..pgwId..
                " type=simulated"..
                " ip="..DAEMON_EPC_IP..":"..DAEMON_EPC_PORT..
                " apn=ulm_pgw"..pgwId..".net devtype=tun devname=tunPGW"..pgwId..
                " addr="..pgw_IP.."/16"
            )
        elseif egateType == 'uec' then
            exec("set_pgw"..
                " id="..pgwId..
                " type=external"..
                " apn=ulm_pgw"..pgwId..".net"..
                " addr="..pgw_IP.."/16"
            )
        end
    end
end

--************************************************************************************
-- set_enb_parameters function
-- The set_enb_parameters() funtion generates the following example commands for each eNB defined in ENB_TABLE
--   exec('set_enb type=external id=1 plmn=666:61 s1=172.18.1.63 enb_id_macro=0x0B007 daemon=$DAEMON_UEC_IP:$DAEMON_PORT')
--   exec('set_cell id=1 enb=1 pci=21:0 tac=12 proxy='..UEC_PROXY_ADDR..' eci=0x0B00701')
--   exec('set_cell id=2 enb=1 pci=54:1 tac=12 proxy='..UEC_PROXY_ADDR..' eci=0x0B00702')
--   exec('set_cell id=3 enb=1 pci=87:2 tac=12 proxy='..UEC_PROXY_ADDR..' eci=0x0B00703')
--************************************************************************************
function set_enb_parameters(ENB_TABLE, egateType)--, ...)
    --print("CFG INFO: start reading ENB_TABLE parameters")
    egateType = egateType or "wraparound"

    ordered_enbs_keys = get_ordered_keys(ENB_TABLE)
    for enbId = 1, table.getn(ordered_enbs_keys) do
        local enbKey, enbTable = ordered_enbs_keys[enbId], ENB_TABLE[ ordered_enbs_keys[enbId] ]
        print("CFG INFO:  generating set commands for key enb="..enbKey)
        DAEMON_UEC_IP = enbTable["daemonIp"] or server_deamonip
        DAEMON_UEC_PORT = enbTable["daemonPort"] or server_deamonport
        x2_addr = ''
        if enbTable["type"]=="simulated" then
            x2_addr = ' x2='..enbTable['s1']..':36422'
        end
        exec("set_enb"..
            " type="..enbTable["type"]..
            x2_addr..
            " id="..enbId..
            " plmn="..enbTable["plmn"]..
            " s1="..enbTable["s1"]..
            " enb_id_macro="..enbTable["enbIdMacro"]..
            " daemon="..DAEMON_UEC_IP..":"..DAEMON_UEC_PORT -- 
        )
        if egateType == 'uec' or egateType == 'wraparound' then
            cell_table = enbTable['cells']
            for iphy_id = 1, #cell_table do
                cell_id_list = cell_table[iphy_id]
                for i, phyCellid in pairs(cell_id_list) do
                    if enbTable["type"]=="simulated" then
                        UEC_PROXY_ADDR=enbTable["proxy_IP"]..":"..enbTable["proxy_port"]+i-1
                        phyCellid=phyCellid+100
                    else
                        UEC_PROXY_ADDR = uecProxyIp[iphy_id]..":"..uecProxyPort
                    end
                    exec("set_cell"..
                        " id="..phyCellid..
                        " enb="..enbId.. --
                        " pci="..math.floor(phyCellid/3)..":"..math.fmod(phyCellid,3)..
                        " tac="..enbTable["tac"].. -- tracking area code konfiguracja na cell
                        " proxy="..UEC_PROXY_ADDR..  -- adres iphy
                        " eci="..enbTable["enbIdMacro"]..string.format("%02X",phyCellid)--
                    )
                end
            end
        end
        -- enbId = enbId + 1
    end
    --print("CFG INFO: end reading ENB_TABLE parameters")
    -- end
    if verbosity > 1 then
        print("eNB configuration done")
    end
    --print("CFG INFO: end reading ENB_TABLE parameters2")
end

--************************************************************************************
-- set_uec_parameters function
-- generates the following example commands for each UEC defined in UEC_TABLE
--   exec('set_uec id=1 ip=$DAEMON_UEC_IP:$DAEMON_PORT gtpu=on pdn=1 addr=$UEC1_ADDR/16 peer=$UEC1_PIP retries=unlimited')
--************************************************************************************
function set_uec_parameters( UEC_TABLE, PGW_TABLE)
    j = 1
    ordered_keys = get_ordered_keys(UEC_TABLE)
    for uecId  = 1, table.getn(ordered_keys) do
        if j+1 > #UEC_IPs then
            print("CFG ERR: too few uecServerIp")
            return false
        end
        local uecKey,uecTable = ordered_keys[uecId ], UEC_TABLE[ ordered_keys[uecId] ]
        print("CFG INFO:  generating set commands for uec="..uecKey)
        UEC_PROXY_PORT = uecTable["uecProxyPort"] or uecProxyPort
        DAEMON_IP = uecTable["daemonIp"] or server_deamonip
        DAEMON_PORT = uecTable["daemonPort"] or server_deamonport
        pgw_uec_IP = PGW_TABLE[uecTable["pgwName"]]["pgwID"].."1.7.200.200"
        exec("set_uec"..
            " id="..uecId..
            " proxy_read_packets_threshold=20 proxy_rcv_buf_size=500000 proxy_snd_buf_size=500000".. -- not in PS
            " ip="..DAEMON_IP..":"..DAEMON_PORT..
            " gtpu=on pdn="..uecId..
            " addr="..pgw_uec_IP.."/16"..
            " peer="..UEC_IPs[j]..":"..UEC_PROXY_PORT..
            " peer_uplane="..UEC_IPs[j+1]..":"..UEC_PROXY_PORT..
            " retries=unlimited"
        )
        j = j + 2
    end
end


--************************************************************************************
-- generate_simmmode_set_commands function
--************************************************************************************
function generate_simmmode_set_commands(PARAMS)
    -- ENB_TABLE_B, UEC_TABLE_B = ...
    egateType = 'wraparound' -- 

    -------------------------------------------
    check_testline_var_parameters()  -- 
    -- 
    set_simmode_variables("A") -- 
    EPC_TABLE = PARAMS['epc'] or EPC_TABLE_DEFAULT -- 
    MME_TABLE = PARAMS['mme'] or MME_TABLE_DEFAULT
    SGW_TABLE = PARAMS['sgw'] or SGW_TABLE_DEFAULT
    PGW_TABLE = PARAMS['pgw'] or PGW_TABLE_DEFAULT
    ENB_TABLE = PARAMS['enb'] or ENB_TABLE_DEFAULT
    UEC_TABLE = PARAMS['uec'] or UEC_TABLE_DEFAULT
    -------------------------------------------
    -- EPC configuration
    set_mme_parameters( MME_TABLE , EPC_TABLE )
    set_sgw_parameters( SGW_TABLE , EPC_TABLE )
    set_pgw_parameters( PGW_TABLE , EPC_TABLE , egateType )

    -------------------------------------------
    -- ENB configuration
    set_enb_parameters( ENB_TABLE , egateType)-- , ...)

    -------------------------------------------
    -- UEC configuration
    if simulatorType == 'IPHY' then  -- NOTE only when simulator is I-PHY
        set_uec_parameters( UEC_TABLE , PGW_TABLE )
    end

end

function configure_bearers(BEARER_PARAM, cell_id, group_id)

    BEARER_PARAM = {BEARER_PARAM}
    uec_id = 1
    if BEARER_PARAM[uec_id].trf_type == nil or
       BEARER_PARAM[uec_id].default_qci == nil then
        print("CONFIGURATION_ERROR: Check BEARER_PARAM in hw_vars.lua: List#"..uec_id..": default bearer qci or/and traffic type is not defined")
        exec('reset')
        return false
    end -- for check if parameters for default bearer are defined

    -- set default bearer
    if BEARER_PARAM[uec_id].def_priority then
        priority = ' priority='..BEARER_PARAM[uec_id].def_priority
    else
        priority = ''
    end

    if BEARER_PARAM[uec_id].parameters then
        additional_bearer_parameters = ' '..BEARER_PARAM[uec_id].parameters
    else
        additional_bearer_parameters = ''
    end
    if BEARER_PARAM[uec_id].trf_type == 'external' then  -- if external ip and nat_ip defined in BEARER_PARAM
        external_ip = ' ip='..BEARER_PARAM[uec_id].IP..' nat_ip='..BEARER_PARAM[uec_id].NAT_IP
    else
        external_ip = ''
    end -- for check of traffic type
    exec('set_bearer default=on'..
        ' id='..(BEARER_PARAM[uec_id].def_b_id or '1')..
        ' ue_group='..group_id..
        ' pdn='..cell_id..
        ' qci='..BEARER_PARAM[uec_id].default_qci..
        ' trf_type='..BEARER_PARAM[uec_id].trf_type..
        -- external_ip..
        priority..
        additional_bearer_parameters)

    -- set dedicated bearers
    for bear_i,cur_qci in ipairs(BEARER_PARAM[uec_id].qci) do
        --set bearer id
        if BEARER_PARAM[uec_id].bearer_id and BEARER_PARAM[uec_id].bearer_id[bear_i] then
            bearer_id = BEARER_PARAM[uec_id].bearer_id[bear_i]
        else
            bearer_id = bear_i + 1
        end

        --set mbr and gbr if defined
        mbr_gbr_param = ''
        if BEARER_PARAM[uec_id].mbr_ul and
           BEARER_PARAM[uec_id].mbr_dl and
           BEARER_PARAM[uec_id].mbr_ul[bear_i] and
           BEARER_PARAM[uec_id].mbr_dl[bear_i] then
            mbr_gbr_param = mbr_gbr_param..' mbr_ul='..BEARER_PARAM[uec_id].mbr_ul[bear_i]
            mbr_gbr_param = mbr_gbr_param..' mbr_dl='..BEARER_PARAM[uec_id].mbr_dl[bear_i]
        end
        if BEARER_PARAM[uec_id].gbr_ul and
           BEARER_PARAM[uec_id].gbr_dl and
           BEARER_PARAM[uec_id].gbr_ul[bear_i] and
           BEARER_PARAM[uec_id].gbr_dl[bear_i] then
            mbr_gbr_param = mbr_gbr_param..' gbr_ul='..BEARER_PARAM[uec_id].gbr_ul[bear_i]
            mbr_gbr_param = mbr_gbr_param..' gbr_dl='..BEARER_PARAM[uec_id].gbr_dl[bear_i]
        end

        priority = ''
        if BEARER_PARAM[uec_id].priority and BEARER_PARAM[uec_id].priority[bear_i] then
            priority = ' priority='..BEARER_PARAM[uec_id].priority[bear_i]
        end
        exec('set_bearer id='..bearer_id..
            ' ue_group='.. group_id ..
            ' pdn='..cell_id..
            ' qci='..cur_qci..
            mbr_gbr_param..
            priority..
            additional_bearer_parameters)
    end -- for bear_i
end

function set_ue_with_bearers(ENB_TABLE, UEC_TABLE, UE_CONFIG_PARAMS, BEARER_PARAM,rest)

    UEC_COUNT=0
    for uec_id, uec_table in pairs(UEC_TABLE) do
        UEC_COUNT=UEC_COUNT+1
    end

    for group_id,UE_GROUP_CONFIG_PARAMS in ipairs(UE_CONFIG_PARAMS) do
        uec_id = group_id
        -- UE_GROUP_CONFIG_PARAMS = UE_CONFIG_PARAMS[uec_id]
        UE_COUNT = UE_GROUP_CONFIG_PARAMS['ueCount']
        encryption = UE_GROUP_CONFIG_PARAMS['encryption'] or 'aes'--'none'
        cell_id = UE_GROUP_CONFIG_PARAMS['cell_id']
        -- 
        additional_ue_group_parametars = UE_GROUP_CONFIG_PARAMS["ue_group_parametars"] or ""
        print("set "..uec_id.." group")
        exec('set_ue_group simulated id='..group_id..
            ' pdn='..cell_id..
            ' uec='..cell_id..
            ' eia='..encryption..
            ' eea='..encryption..
            ' enb=1 cell='..cell_id..
            " "..additional_ue_group_parametars)
        configure_bearers(BEARER_PARAM[group_id], cell_id, group_id)
        -- exec('set_bearer id=1 ue_group='..uec_id..' pdn='..uec_id..' default=on qci=9 trf_type=internal')
        -- exec('set_bearer id=2 ue_group='..uec_id..' pdn='..uec_id..' qci=6')
        -- exec('set_bearer id=3 ue_group='..uec_id..' pdn='..uec_id..' qci=8')

        for imsi=1,UE_COUNT do
            -- uec_id = group_id
            ue_id = (group_id+11)*1000+imsi  --ue_id = (uec_id+X)*2000+10000+imsi
            _trf_type_ = 'internal'
            -- NOTE plmn+10 cyfr
            _imsi_='244:09:'..(group_id-1)..'000'.. 100000 +ue_id -- 

            exec('set_ue id='.. ue_id ..' group='..group_id..' imsi='.._imsi_..' enb=1 cell='..cell_id)
            if UE_GROUP_CONFIG_PARAMS["ue_param"] then
                exec('ue_param id='.. ue_id ..' '..UE_GROUP_CONFIG_PARAMS["ue_param"])
            end
            if UE_GROUP_CONFIG_PARAMS['cqi_param'] then
                exec('ue_cqi_param id='.. ue_id ..' '.. UE_GROUP_CONFIG_PARAMS['cqi_param'])
            end
            --
        end
        print(group_id.." group done")
    end
end

function configure_default_sequences(uec_count)
    for uec_id=1, uec_count do

        exec('seq_set id=1'..uec_id..
        ' name=attach-detach ue_group='.. uec_id)
        exec('ue_attach')
        exec('sleep 2')
        exec('ue_detach')
        exec('seq_end')

        exec('seq_set id=2'..uec_id..
        ' name=att_sleep_det ue_group='.. uec_id)
        exec('ue_attach')
        exec('sleep 1000')
        exec('ue_detach')
        exec('seq_end')

        exec('seq_set id=3'..uec_id..
        ' name=attach_with_trf ue_group='.. uec_id)
        exec('ue_attach')
        exec('sleep 1')
        exec('trf_data_start id=1 kbps=1 dir=dl')
        exec('sleep 1000')
        exec('ue_detach')
        exec('seq_end')
    end
end

--eof
