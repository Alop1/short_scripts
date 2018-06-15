----------------------------------------------------------
--- IF YOU NEED TO MODIFY THIS FILE PLEASE LET ME KNOW ---
---              lukasz.kordula@nokia.com              ---
----------------------------------------------------------
-----------------------------------------------

---**************************
-- TODO add support for IPv6
---**************************

--- Deafult global variables
WARN_MSG = ""
INFO_MSG = ""
-----------------------------------------------
EPC_TABLE_DEFAULT= {
        daemonIp = "127.0.0.1" ,
        daemonPort = 12345,
}
-----------------------------------------------
MME_TABLE_DEFAULT= {
    MME_1 = {
        s1Ip = MME_IP,
        s1Port = 36412,
        mmegi = 1,
        mmec = 3,
--        plmn = "001:02",       -- Needed for
--        tac_list = "123,130",  -- multiple MME
    },
}
-----------------------------------------------
ENB_TABLE_DEFAULT= {
    ENB_1 = {
        ENB_ID = GLOBAL_ENB_ID,
        type = "external",
        plmn = "244:09",
        s1 = eNB_IP,
        tac = "123",
        cells = {{1}}
    },
}
-----------------------------------------------
UE_CAP = {
    s7 = "c9ba050600106260c89b0d18391ff8c188ffc60c47fe30f23ff1bd11ff8dfc8ffc69e47fffd3ffa6a2087004830d493952207058c08000000b88bc0c0000400308001000c600040034c001000c3000400344001000db000400700001010820028010308001001c000040460800a0040c6000400700001014c2002801034c001000c20004807080010108200384000808c1201420818c000900e1000242304005082463000200384000808c1001420818c000800e100020298400508206980020038400090a6100142091a6000800e1000202d8400508206d80020018c000900e300020230400718001014c20028c1034c001001c6000405b0800a3040db000400718001216c20028c1236c001002c000040420808c10024008184000808c1002400808410318001002c00004042080a61002400818400080a6100240080841034c001002c20004046080a61002420818c00080a61002420808c1034c001002c20004046080b61002420818c00080b61002420808c1036c001001c3000405b080be30723ff18311ff8c188ffc61e47fe37a23ff1bf91ff8d3c8ffc6ce47fe36723ff1af91ff8d7c8ffc6be47fe35f23ff1bf91ff8dfc8ffc6fe47fe37f23ff1bf91ff8dfc8ffc66c47fe33623ff19791ff8cbc8ffc6fe47fe37f23ff1b791ff8dbc8ffc6fe47fe37f23ff1af91ff8d7c8ffc6be47fe35f23ff1bf91ff8dfc8ffc6fe47fe37f23ff1bf91ff8dfc8ffc6fe47fe37f23ff1bf91ff8dfc8ffc6fe47fe37f23ff1bf91ff8dfc8ffc6fe47fc00d00000d78001fe00000007f80000001fe00000001fe00000007f80000001fe00000007f800000001ff00000007f80000001fe00000007f80000001fe00000007f80000000000110040",
  catm = "560000008000001000804510021200055C041900",
}
simulated_enb_cell_proxy_port = 2254  --TODO consider this, maybe set different start number

--************************************************************************************
-- get_ordered_keys function
--************************************************************************************
function get_ordered_keys(TABLE)
    local ordered_keys = {}
    for k in pairs(TABLE) do table.insert(ordered_keys, k) end
    table.sort(ordered_keys)
    return ordered_keys
end

function shell(command)
    local output, handler
    handler = assert(io.popen(command, "r"))
    output = handler:read("*all")
    handler:close()
    return output
end

function split(inputstring, separator)
    separator = separator or "%s"
    local i = 1
    local outputstring = {}
    for substring in string.gmatch(inputstring, "([^"..separator.."]+)") do
        outputstring[i] = substring
        i = i + 1
    end
    return outputstring
end

function get_uec_servers_ip(prefix)
    prefix = prefix or "10.34.166"
    local ip_table = shell("ip addr |egrep -o  "..prefix..".[0-9]+ |egrep -v [0-9]{3}$")
    return split(ip_table,'\n')
end

function check_consts(ip_table)
    local ret_struct = {ok = 0, err = 0}
    for i = 1, #ip_table do
        local result = shell("ip addr |egrep -o  "..ip_table[i].." |egrep -v 255$")
        if result == ip_table[i]..'\n' then
            ret_struct['ok'] = ret_struct['ok'] + 1
        else
            ret_struct['err'] = ret_struct['err'] + 1
        end
    end
    if ret_struct['err'] > 0 then
        WARN_MSG = WARN_MSG.."\nNot all IP addresses are available at workstation!"
        print("Not all IP addresses are available at workstation!")
    end
    return ret_struct
end

function dump(table) -- useful for debug
   if type(table) == 'table' then
      local ret_str = '{ '
      for i, value in pairs(table) do
         if type(i) ~= 'number' then i = '"'.. i ..'"' end
         ret_str = ret_str .. '['.. i ..'] = ' .. dump(value) .. ',\n'
      end
      return ret_str .. '} '
   else
      return tostring(table)
   end
end

---************************************************************************************
-- set_mme_parameters function
-- generates the following example commands for each MME defined in MME_TABLE
-- exec('set_mme id=1 type=simulated ip=$DAEMON_EPC_IP:$DAEMON_PORT s1=$S1_ADDR mmegi=1 mmec=3')
--************************************************************************************
function set_mme_parameters(MME_TABLE, EPC_TABLE, params)
    local ordered_keys = get_ordered_keys(MME_TABLE)
    if table.getn(ordered_keys) > 1 then
        set_multi_mme(MME_TABLE, EPC_TABLE, params)
    else
        local mmeTable = MME_TABLE[ ordered_keys[1] ]
        if verbosity > 1 then
            print("CFG INFO:  generating set commands for MME_1")
        end
        local DAEMON_EPC_IP = EPC_TABLE["daemonIp"]
        local DAEMON_EPC_PORT = EPC_TABLE["daemonPort"]
        exec("set_mme id=1"
            .." type=simulated"
            .." ip="..DAEMON_EPC_IP..":"..DAEMON_EPC_PORT
            .." s1="..mmeTable.s1Ip..":"..mmeTable.s1Port
            .." mmegi="..mmeTable.mmegi
            .." mmec="..mmeTable.mmec
            ..params
        )
    end
end

---************************************************************************************
-- set_mme_parameters function
-- generates the following example commands for each MME defined in MME_TABLE
-- exec('mme_pool_area id=n mmegi=1 plmn=427:01 tac_list=130')
-- exec('set_mme id=n ip=:$DAEMON_PORT s1=$MME_S1_IP:$MME_S1_PORT pool=n:4')
--************************************************************************************
function set_multi_mme(MME_TABLE, EPC_TABLE, params)
    local ordered_keys = get_ordered_keys(MME_TABLE)
    for mmeId = 1, table.getn(ordered_keys) do
        local mmeTable = MME_TABLE[ ordered_keys[mmeId] ]
        if verbosity > 1 then
            print("CFG INFO:  generating set commands for MME="..ordered_keys[mmeId])
        end
        local DAEMON_EPC_IP = EPC_TABLE["daemonIp"]
        local DAEMON_EPC_PORT = EPC_TABLE["daemonPort"]
        exec('mme_pool_area id='..mmeId
                ..' mmegi='..mmeTable.mmegi
                ..' plmn='..mmeTable.plmn
                ..' tac_list='..mmeTable.tac_list)
        exec("set_mme"
            .." id="..mmeId
            .." type=simulated"
            .." ip="..DAEMON_EPC_IP..":"..DAEMON_EPC_PORT
            .." s1="..mmeTable.s1Ip..":"..mmeTable.s1Port
            .." pool="..mmeId..":"..mmeTable.mmec
            ..params
        )
    end
end

---************************************************************************************
-- set_sgw_parameters function
-- generates the following example commands for each SGW defined in SGW_TABLE
-- exec('set_sgw id=N type=simulated ip=$DAEMON_EPC_IP:$DAEMON_PORT s1u=$S1U_ADDR s11=$S11_ADDR:$S11_PORT')
--************************************************************************************
function set_sgw_parameters(num_of_sgw, EPC_TABLE, configure_s11)
    local server_s1ip = MME_IP
    local buffers = " s1u_rcv_buff_size=1048576 s1u_snd_buff_size=1048576 s5u_rcv_buff_size=1048576 s5u_snd_buff_size=1048576"
    for sgwId = 1, num_of_sgw do
        if verbosity > 1 then
            print("CFG INFO:  generating set commands for SGW="..sgwId)
        end
        local DAEMON_EPC_IP = EPC_TABLE["daemonIp"]
        local DAEMON_EPC_PORT = EPC_TABLE["daemonPort"]
        local s1uIP = SGW_IP[sgwId]

        local s11 = ''
        if configure_s11 then
            s11 = " s11="..server_s1ip..":"..2152+sgwId
        end
        exec("set_sgw"
            .." id="..sgwId
            ..buffers
            .." type=simulated"
            .." ip="..DAEMON_EPC_IP..":"..DAEMON_EPC_PORT
            .." s1u="..s1uIP..s11
        )
    end
end

---************************************************************************************
-- set_pgw_parameters function
-- generates the following example commands for each PGW defined in PGW_TABLE
--   exec('set_pgw id=1 type=simulated ip=$DAEMON_EPC_IP:$DAEMON_PORT apn=ulm_pgw1.net devtype=tun devname=tunPGW1 addr=$PGW1_ADDR/16')
--************************************************************************************
function set_pgw_parameters(nbr_of_pgw, EPC_TABLE, emergancy_pgw)
    local buffers = " sgi_rcv_buff_size=1048576 sgi_snd_buff_size=1048576 s5u_rcv_buff_size=1048576 s5u_snd_buff_size=1048576 "
    local DAEMON_EPC_IP = EPC_TABLE["daemonIp"]
    local DAEMON_EPC_PORT = EPC_TABLE["daemonPort"]

    local IPv6 = false -- TODO get this as variable
    for pgwId = 1, nbr_of_pgw do
        if verbosity > 1 then
            print("CFG INFO:  generating set commands for PGW="..pgwId)
        end
        local pgw_IP = 40+pgwId..".7.254.254/16"  -- TODO add support for both IPv4 and IPv6
        if IPv6 then
            pgw_IP = "20:"..230+pgwId..":0000:0000:0000:0:FFFF:FFFE/63"
        end
        exec("set_pgw"
          .." id="..pgwId
          ..  buffers
--          .." type=simulated"  -- simulated is default
          .." ip="..DAEMON_EPC_IP..":"..DAEMON_EPC_PORT
          .." devtype=tun devname=tunPGW"..pgwId
          .." apn=krklab_pgw"..pgwId..".net"
          .." addr="..pgw_IP
        )
    end
    if emergancy_pgw then
        exec("set_pgw"
          .." id=31"
          ..  buffers
--          .." type=simulated"  -- simulated is default
          .." ip="..DAEMON_EPC_IP..":"..DAEMON_EPC_PORT
          .." devtype=tun devname=tunPGW31"
          .." emergency=on"
          .." apn=krklab_pgw31.net"
          .." addr=71.7.254.254/16" -- TODO add support for IPv6
        )
    end
end

---************************************************************************************
-- set_cells function
-- The set_cells() funtion generates the following example commands for each cell defined in ENB_TABLE
--   exec('set_cell id=1 enb=1 pci=21:0 tac=12 proxy='..UEC_PROXY_ADDR..' eci=0x0B00701')
--   ...
--************************************************************************************
function set_cells(enbId, enb_macro_id, enbTable)
    for iphy_id = 1, #enbTable.cells do
        local cell_id_list = enbTable.cells[iphy_id]
        for i, phyCellid in pairs(cell_id_list) do
            if verbosity > 1 then
                print("CFG INFO:  generating set commands for eNB="..enbId.." cellID="..phyCellid)
            end
            local UEC_PROXY_ADDR, tac
            local pci = ''
            if enbTable["type"]=="simulated" then
                local proxy_port
                if enbTable["proxy_port"] then
                    proxy_port = enbTable["proxy_port"]+i-1
                else
                    proxy_port = simulated_enb_cell_proxy_port
                    simulated_enb_cell_proxy_port = simulated_enb_cell_proxy_port + 1
                end
                -- TODO be aware of proxy port collision possibility !!!
                UEC_PROXY_ADDR=enbTable["proxy_IP"]..":"..proxy_port
--                phyCellid=phyCellid+100  -- TODO is this necessary?
                pci = " pci="..math.floor(phyCellid/3)..":"..math.fmod(phyCellid,3)
            else
                UEC_PROXY_ADDR = uecProxyIp[iphy_id]..":"..uecProxyPort
            end

            if tostring(type(enbTable.tac)) == "table" then
                if enbTable.tac[phyCellid] then
                    tac = enbTable.tac[phyCellid]
                else
                    tac = enbTable.tac["default"]
                end
            else
                tac = enbTable["tac"]
            end

            local cell_param = ''
            if enbTable.cell_params then
                if enbTable.cell_params[phyCellid] then
                    cell_param = ' '..enbTable.cell_params[phyCellid]
                else
                    cell_param = ' '..enbTable.cell_params["default"]
                end
            end
            exec("set_cell"
             .. " id="..phyCellid
             .. " enb="..enbId
             .. pci
             .. " tac=".. tac
             .. " proxy="..UEC_PROXY_ADDR  -- adres iphy
             .. " eci="..enb_macro_id..string.format("%02X",phyCellid)
             -- TODO sometimes id != eci, check why and how ot handle it
             .. cell_param
            )
        end
    end
end

---************************************************************************************
-- set_nb_cells function
-- The set_nb_cells() funtion generates the following example commands for each narrow bandcell defined in ENB_TABLE
--   exec('set_cell id=1 enb=1 technology=nblte parent_cell=$parent_cell_id prb_offset=19:20" pci=21:0 tac=12 proxy='..UEC_PROXY_ADDR..' eci=0x0B00701')
--   ...
--************************************************************************************
function set_nb_cells(enbId, enb_macro_id, enbTable)
    for phyCellid, parent_cell_id in pairs(enbTable.nb_cells) do
        exec("set_cell"
         .. " id="..phyCellid
         .. " enb="..enbId
         .. " technology=nblte"
         .. " parent_cell="..parent_cell_id
         .. " prb_offset=19:20"
         .. " tac="..enbTable["nb_tac"]
         .. " eci="..enb_macro_id..string.format("%02X",phyCellid)
         .. " mandatory_for_activation=false"
        )
    end
end

---************************************************************************************
-- set_liquid_cells function
-- The set_cells() funtion generates the following example commands for each cell defined in ENB_TABLE
--   exec('set_cell id=11 enb=1 pci=21:0 tac=12 proxy='..UEC_PROXY_ADDR..' eci=0x0B0070B')
--   exec('set_cell id=12 enb=1 pci=21:1 tac=12 proxy='..UEC_PROXY_ADDR..' eci=0x0B0070C')
--   exec('enb_set_cell_group enb=1 group=1 subcell=11 subcell=12)
--   ...
--************************************************************************************
function set_liquid_cells(enbId, enb_macro_id, enbTable)
    for iphy_id = 1, #enbTable.liquid_cells do
        local liquid_cell_group = enbTable.liquid_cells[iphy_id]
        for i, cell_id_list in pairs(liquid_cell_group) do
            local subcells = ""
            for j, phyCellid in pairs(cell_id_list) do

                local cell_param = ""
                if enbTable.cell_params then
                    if enbTable.cell_params[phyCellid] then
                        cell_param = ' '..enbTable.cell_params[phyCellid]
                    else
                        cell_param = ' '..enbTable.cell_params["default"]
                    end
                end

                local tac
                if tostring(type(enbTable.tac)) == "table" then
                    if enbTable.tac[phyCellid] then
                        tac = enbTable.tac[phyCellid]
                    else
                        tac = enbTable.tac["default"]
                    end
                else
                    tac = enbTable["tac"]
                end

                exec('set_cell id='..phyCellid
                 .. ' enb='..enbId
                 .. ' tac='..tac
                 .. ' proxy='..uecProxyIp[iphy_id]..":"..uecProxyPort
                 .. ' eci='..enb_macro_id..string.format("%02X",i)
                 .. cell_param
                )
                subcells = subcells..' subcell='..phyCellid
            end
            exec('enb_set_cell_group enb='..enbId..' group='..i..subcells)
        end
    end
end

---************************************************************************************
-- set_cells function in LMTS env
-- The set_cells() funtion generates the following example commands for each cell defined in ENB_TABLE
--   exec('set_cell id=1 enb=1 pci=21:0 tac=12 eci=0x0B00701')
--   ...
--************************************************************************************
function set_lmts_cells(enbId, enb_macro_id, enbTable)
    local cell_id_list = enbTable.cells[1] -- [1] <- for table compability with iphy
    for i, phyCellid in pairs(cell_id_list) do
        if verbosity > 1 then
            print("CFG INFO:  generating set commands for eNB="..enbId.." cellID="..phyCellid)
        end
        local tac
        local pci = ''
        if enbTable["type"]=="simulated" then
            -- TODO
            phyCellid=phyCellid+100
            pci = " pci="..math.floor(phyCellid/3)..":"..math.fmod(phyCellid,3)
        end

        if tostring(type(enbTable.tac)) == "table" then
            if enbTable.tac[phyCellid] then
                tac = enbTable.tac[phyCellid]
            else
                tac = enbTable.tac["default"]
            end
        else
            tac = enbTable["tac"]
        end

        local cell_param = ''
        if enbTable.cell_params then
            if enbTable.cell_params[phyCellid] then
                cell_param = ' '..enbTable.cell_params[phyCellid]
            else
                cell_param = ' '..enbTable.cell_params["default"]
            end
        end
        exec("set_cell"
         .. " id="..phyCellid
         .. " enb="..enbId
         .. pci
         .. " tac=".. tac
         .. " eci="..enb_macro_id..string.format("%02X",phyCellid)
         .. cell_param
        )
    end
end

--************************************************************************************
-- function choose which set_*_cells should be used
--************************************************************************************
function set_cells_common(enbId, enb_macro_id, enbTable)
    if simulatorType == 'IPHY' then
        if verbosity > 2 then
            print("CELL TABLE:")
            print(dump(enbTable['cells']))
            print("NARROW BAND CELL TABLE:")
            print(dump(enbTable['nb_cells']))
            print("LIQUID CELL TABLE:")
            print(dump(enbTable['liquid_cells']))
        end
        if enbTable.cells then
            set_cells(enbId, enb_macro_id, enbTable)
        end
        if enbTable.nb_cells then
            set_nb_cells(enbId, enb_macro_id, enbTable)
        end
        if enbTable.liquid_cells then
            set_liquid_cells(enbId, enb_macro_id, enbTable)
        end
    elseif simulatorType == "LMTS" then  -- TODO probably the same for RTG
        if verbosity > 2 then
            print("CELL TABLE:")
            print(dump(enbTable['cells']))
        end
        if enbTable.cells then
            set_lmts_cells(enbId, enb_macro_id, enbTable)
        end
    end

end


-- TODO add description
function set_multi_enb(enbTable, EPC_TABLE)
    local s1_parts = split(enbTable.s1, ".")
    local s1_addr_main = s1_parts[1]..'.'..s1_parts[2]..'.'..s1_parts[3]..'.'
    local s1_addr_rest = s1_parts[4]

    for i = 1, enbTable.multiply-1 do
        local enbId = enbTable.start_id+i

        local s1u = ''
        if enbTable.s1u then
            local s1u_p = split(enbTable.s1u, ".")
            s1u = ' s1u='..s1u_p[1]..'.'..s1u_p[2]..'.'..s1u_p[3]..'.'..s1u_p[4]+i
        end
        local enb_macro_id = string.format("0x%05X", enbId)
        local enb_param = ''
        if enbTable.enb_param then
            enb_param = ' '..enbTable.enb_param
        end
        exec("set_enb id="..enbId
         .. " type="..enbTable["type"]
         .. " plmn="..enbTable["plmn"]
         .. " s1="..s1_addr_main..s1_addr_rest+i
         ..   s1u
         .. " enb_id_macro="..enb_macro_id
         ..   enb_param  -- x2_peers, x2 and other like this
         .. " daemon="..(enbTable.daemonIp or EPC_TABLE["daemonIp"])
              .. ":"..(enbTable.daemonPort or EPC_TABLE["daemonPort"])
        )
        set_cells_common(enbId, enb_macro_id, enbTable)
    end
end

--************************************************************************************
-- set_enb_parameters function
-- The set_enb_parameters() funtion generates the following example commands for each eNB defined in ENB_TABLE
--   exec('set_enb type=external id=1 plmn=666:61 s1=172.18.1.63 enb_id_macro=0x0B007 daemon=$DAEMON_UEC_IP:$DAEMON_PORT')
--   then set_cells_common() function
--************************************************************************************
function set_enb_parameters(ENB_TABLE, EPC_TABLE)
    local ordered_enbs_keys = get_ordered_keys(ENB_TABLE)
    for enbId = 1, table.getn(ordered_enbs_keys) do
        local enbTable =  ENB_TABLE[ordered_enbs_keys[enbId]]
        if verbosity > 1 then
            print("CFG INFO:  generating set commands for eNB="..enbId)
        end

        local simulated_enb_params = ''
        local enb_macro_id = ''
        if enbTable["type"]=="simulated" then
            if enbTable.multiply then
                set_multi_enb(enbTable, EPC_TABLE)
                enbId = enbTable.start_id -- to avoid id collision
            end
            simulated_enb_params = --' x2='..enbTable['s1']..':36422' .. -- TODO x2 probably not needed, be default the same as s1
                                 " daemon="..(enbTable.daemonIp or EPC_TABLE["daemonIp"])
                                     .. ":"..(enbTable.daemonPort or EPC_TABLE["daemonPort"])
            enb_macro_id = enbTable['enbIdMacro'] or string.format("0x%05X", enbTable.start_id)
            -- TODO check how it looks on lmts
        else
            enb_macro_id = string.format("0x%05X", enbTable['ENB_ID'])
        end

        local enb_param = ''
        if enbTable.enb_param then
            enb_param = ' '..enbTable.enb_param
        end

        local s1u = ''
        if enbTable.s1u then
            s1u = ' s1u='..enbTable.s1u
        end

        exec("set_enb id="..enbId
         .. " type="..enbTable["type"]
         .. " plmn="..enbTable["plmn"]
         .. " s1="..enbTable["s1"]
         ..   s1u
         .. " enb_id_macro="..enb_macro_id
         ..   enb_param  -- x2_peers, x2 and other like this
         ..   simulated_enb_params
        )
        set_cells_common(enbId, enb_macro_id, enbTable)
    end
    if verbosity > 1 then
        print("eNB configuration done")
    end
end
--************************************************************************************
-- set_uec_parameters function
-- generates the following example commands for each UEC defined in UEC_TABLE
--   exec('set_uec id=1 ip=$DAEMON_UEC_IP:$DAEMON_PORT gtpu=on pdn=1 addr=$UEC1_ADDR/16 peer=$UEC1_PIP retries=unlimited')
--************************************************************************************
function set_uec_parameters( nbr_uf_uec, nbr_of_pgw, EPC_TABLE)
    local j = 1
    for uecId  = 1, nbr_uf_uec do
        if j+1 > #UEC_IPs then
            print("CFG ERR: too few uecServerIp")
            WARN_MSG = WARN_MSG.."\nCFG ERR: too few uecServerIp"
            return false
        end
        if verbosity > 1 then
            print("CFG INFO:  generating set commands for UEC="..uecId)
        end
        local UEC_PROXY_PORT =  uecProxyPort
        local DAEMON_IP = EPC_TABLE["daemonIp"]
        local DAEMON_PORT = EPC_TABLE["daemonPort"]
        local pgw_uec_IP = uecId.."2.7.200.200"  -- TODO what about IPv6
        local buffers = " proxy_rcv_buf_size=2000000 proxy_snd_buf_size=2000000"
        exec("set_uec"
            .." id="..uecId
            .." proxy_read_packets_threshold=20".. buffers
            .." daemon="..DAEMON_IP..":"..DAEMON_PORT
            .." gtpu=on pdn="..uecId
            .." addr="..pgw_uec_IP.."/16"
            .." peer="..UEC_IPs[j]..":"..UEC_PROXY_PORT
            .." peer_uplane="..UEC_IPs[j+1]..":"..UEC_PROXY_PORT
            .." retries=unlimited"
        )
        j = j + 2
    end
end


-- TODO add description
--************************************************************************************
-- generate_simmmode_set_commands function
--************************************************************************************
function generate_simmmode_set_commands(PARAMS)
    -------------------------------------------
    local EPC_TABLE = PARAMS['epc'] or EPC_TABLE_DEFAULT
    local MME_TABLE = PARAMS['mme'] or MME_TABLE_DEFAULT
    local ENB_TABLE = PARAMS['enb'] or ENB_TABLE_DEFAULT

    local mme_params
    local sgw_ip_nbr = check_consts(SGW_IP)

    local nbr_of_sgw = PARAMS['nbr_of_sgw'] or 1  -- 1..31 Remember about IP addreses
    local nbr_of_pgw = PARAMS['nbr_of_pgw'] or 1  -- 1..31
    local nbr_of_uec = PARAMS['nbr_of_uec'] or 1  -- 1..16

    if PARAMS.mme_params then
        mme_params = " "..PARAMS.mme_params
    else
        mme_params = ""
    end

    -------------------
    -- check set values
    if nbr_of_sgw > sgw_ip_nbr.ok then
        nbr_of_sgw = sgw_ip_nbr.ok
        WARN_MSG = WARN_MSG.."\nNot enough IP defined for SGW. Number of SGW set to "..nbr_of_sgw
    end

    -------------------------------------------
    -- EPC configuration
    set_mme_parameters(  MME_TABLE, EPC_TABLE, mme_params )

    set_sgw_parameters( nbr_of_sgw, EPC_TABLE, PARAMS.configure_sgw_s11 )
    set_pgw_parameters( nbr_of_pgw, EPC_TABLE, PARAMS.emergency_pgw)

    -------------------------------------------
    -- ENB configuration
    set_enb_parameters( ENB_TABLE , EPC_TABLE )

    if PARAMS.additional_functions then
        for i, element in pairs(PARAMS.additional_functions) do
            exec(element)
        end
    end

    -------------------------------------------
    -- UEC configuration
    if simulatorType == 'IPHY' then
        set_uec_parameters( nbr_of_uec, nbr_of_pgw , EPC_TABLE )
        if PARAMS.ue_config then  -- TODO temporary 'if', for compability but normally it should be without 'if' by default
            set_ue_with_bearers(PARAMS.ue_config,PARAMS)
        end
    elseif simulatorType == "LMTS" then  -- TODO może lepiej będzie zrobić osobne generate_set_simmode_commands dla EPCsima?
        configure_lmts_bearers(PARAMS) -- todo rename
    elseif simulatorType == "RTG" then  -- TODO
        -- TODO RTG configuration is simiral od LMTS, maybe I do not need this
        configure_lmts_bearers(PARAMS) -- todo rename
    end

end

--************************************************************************************
-- set_bearers function
-- generates the following example commands for bearers
-- exec('set_bearer id=1 ue[_group]='..id..' pdn='..uec_id..' default=on qci=9 trf_type=internal')
-- exec('set_bearer id=2 ue[_group]='..id..' pdn='..uec_id..' qci=6')
-- exec('set_bearer id=3 ue[_group]='..id..' pdn='..uec_id..' qci=8')
--************************************************************************************
-- TODO maybe split it for configure_bearers_for_ue_group and configure_bearers_for_ue
function configure_bearers(BEARER_PARAM, pdn_id, dst_id)  -- dst_id should be like "ue_group=x" or "ue=x"

    if verbosity > 2 then
        print(dump(BEARER_PARAM))
    end
    if BEARER_PARAM.trf_type == nil or
       BEARER_PARAM.default_qci == nil then
        print("CONFIGURATION_ERROR: Check BEARER_PARAM in group: ".. dst_id ..", default bearer qci or/and traffic type is not defined")
        exec('reset')
        return false
    end -- for check if parameters for default bearer are defined

    local priority
    if BEARER_PARAM.def_priority then
        priority = ' priority='..BEARER_PARAM.def_priority
    else
        priority = ''
    end

    local additional_bearer_parameters
    if BEARER_PARAM.parameters then
        additional_bearer_parameters = ' '..BEARER_PARAM.parameters
    else
        additional_bearer_parameters = ''
    end

    -- set default bearer
    exec('set_bearer default=on'..
        ' id='..(BEARER_PARAM.def_b_id or '1')..
        ' '.. dst_id ..
        ' pdn='.. pdn_id ..
        ' qci='..BEARER_PARAM.default_qci..
        ' trf_type='..BEARER_PARAM.trf_type..
        priority..
        additional_bearer_parameters)

    -- set dedicated bearers
    for bear_i,cur_qci in ipairs(BEARER_PARAM.qci) do
        local bearer_id
        if BEARER_PARAM.bearer_id and BEARER_PARAM.bearer_id[bear_i] then
            bearer_id = BEARER_PARAM.bearer_id[bear_i]
        else
            bearer_id = bear_i + 1
        end

        --set mbr and gbr if defined
        local mbr_param
        if BEARER_PARAM.mbr_ul and
           BEARER_PARAM.mbr_dl and
           BEARER_PARAM.mbr_ul[bear_i] and
           BEARER_PARAM.mbr_dl[bear_i] then
            mbr_param = ' mbr_ul='..BEARER_PARAM.mbr_ul[bear_i]..' mbr_dl='..BEARER_PARAM.mbr_dl[bear_i]
        else
            mbr_param = ''
        end

        local gbr_param
        if BEARER_PARAM.gbr_ul and
           BEARER_PARAM.gbr_dl and
           BEARER_PARAM.gbr_ul[bear_i] and
           BEARER_PARAM.gbr_dl[bear_i] then
            gbr_param = ' gbr_ul='..BEARER_PARAM.gbr_ul[bear_i]..' gbr_dl='..BEARER_PARAM.gbr_dl[bear_i]
        else
            gbr_param = ''
        end

        priority = ''
        if BEARER_PARAM.priority and BEARER_PARAM.priority[bear_i] then
            priority = ' priority='..BEARER_PARAM.priority[bear_i]
        end
        exec('set_bearer id='..bearer_id..
            ' '.. dst_id ..
            ' pdn='.. pdn_id ..
            ' qci='..cur_qci..
            mbr_param..gbr_param..
            priority..
            additional_bearer_parameters)
    end -- for bear_i
end


-- TODO add description
function set_ue_with_bearers(UE_CONFIG_PARAMS, simmode_params)

    local ue_id = 0
    local uec_count = simmode_params.nbr_of_uec
    local ue_group_counter = 0
    for i,UE_GROUP_CONFIG_PARAMS in ipairs(UE_CONFIG_PARAMS) do
        local g_id = 100 * (i-1) -- each ue_config param +100
        local enb_id = UE_GROUP_CONFIG_PARAMS['enb_id'] or 1
        local enb_info = enb(enb_id)
        local plmn = enb_info.cfg.glob_id.plmn_id

        -- if cell_id is not set in UE_CONFIG_PARAMS then use all cells
        if not UE_GROUP_CONFIG_PARAMS['cell_id'] then
            UE_GROUP_CONFIG_PARAMS['cell_id'] = {}
            for cell in enb_info.cells do
                UE_GROUP_CONFIG_PARAMS['cell_id'][cell.id] = cell.id
            end
        end
        if UE_GROUP_CONFIG_PARAMS.start_ue_id then
            ue_id = UE_GROUP_CONFIG_PARAMS.start_ue_id-1
        end
        local UE_COUNT = UE_GROUP_CONFIG_PARAMS['ueCount']
        local encryption = UE_GROUP_CONFIG_PARAMS['encryption'] or 'snow3g+aes'
        local integrity = UE_GROUP_CONFIG_PARAMS['integrity'] or encryption -- if not defined, the same as encryption
        local bearer_param = UE_GROUP_CONFIG_PARAMS['bearer_param']
        if verbosity > 2 then
            print("cell count: ".. enb_info.cells_num)
            print(dump(UE_GROUP_CONFIG_PARAMS))
        end
        for j, cell_id in pairs(UE_GROUP_CONFIG_PARAMS['cell_id']) do
            ue_group_counter = ue_group_counter + 1
            local group_id
            if UE_GROUP_CONFIG_PARAMS['ue_group_id'] then
                group_id = UE_GROUP_CONFIG_PARAMS['ue_group_id'][j]
            else
                group_id = g_id + cell_id
            end

            local additional_ue_group_parametars = UE_GROUP_CONFIG_PARAMS["ue_group_parametars"] or ""
            if verbosity > 1 then
                print("set "..group_id.." group")
            end
            local pdn_id
            if UE_GROUP_CONFIG_PARAMS['pdn_id'] then
                pdn_id = UE_GROUP_CONFIG_PARAMS['pdn_id'][j]
            else
                pdn_id = (((ue_group_counter - 1) % simmode_params.nbr_of_pgw) + 1)
            end
            local uec_id
            if UE_GROUP_CONFIG_PARAMS['uec_id'] then
                uec_id = UE_GROUP_CONFIG_PARAMS['uec_id'][j]
            else
                uec_id = ((ue_group_counter-1)%uec_count)+1
            end
            exec('set_ue_group simulated id='..group_id  -- ue group id should be cell id + [100*x if more group at this cell]
               ..' pdn='..pdn_id
               ..' uec='..uec_id
               ..' enb='..enb_id
               ..' cell='..cell_id
               ..' eia='..integrity
               ..' eea='..encryption
               .. " "..additional_ue_group_parametars)
            if verbosity > 2 then
                print("debug dump of bearer_param")
                print(dump(bearer_param))
            end

            -- check if bearer_param is table or table of tables
            if tostring(type(bearer_param[1])) == "table" then -- if table of tables run multiple times
                for k, bear_param in pairs(bearer_param) do
                    configure_bearers(bear_param, pdn_id+k-1, "ue_group="..group_id)
                end
            else  -- if table then run configure_bearers() only once
                configure_bearers(bearer_param, pdn_id, "ue_group="..group_id)
            end

            if simmode_params.emergency_pgw then  -- if emergency pdn, bearers should be added to all ues
                configure_bearers(simmode_params.emergency_pgw, 31, "ue_group="..group_id)
            end

            for i=1,UE_COUNT do
                ue_id = ue_id + 1  -- just enumerate
                local padding = string.rep("0",7-string.len(tostring(plmn))) -- handle when PLMN have diffenern number of digits
                local _imsi_ = string.format("%s:%s%04d%05d", plmn, padding, group_id, ue_id) -- example.imsi=244:09:P123412345

                exec('set_ue id='.. ue_id
                  ..' enb='  ..enb_id
                  ..' cell=' ..cell_id
                  ..' group='..group_id
                  ..' imsi=' .._imsi_
                )
                if UE_GROUP_CONFIG_PARAMS["ue_param"] then
                    exec('ue_param id='.. ue_id ..' '..UE_GROUP_CONFIG_PARAMS["ue_param"])
                end
                if UE_GROUP_CONFIG_PARAMS['ue_cap'] then
                    if UE_GROUP_CONFIG_PARAMS['ue_cap'] == "random" then
                        math.randomseed(os.time())
                        local ue_cap_ordered_keys = get_ordered_keys(UE_CAP)
                        local ue_cap_random_id = math.random(1, ue_cap_ordered_keys-1)
                        exec('ue_param id='.. ue_id ..' ue_eutra_capabilities='..ue_cap_ordered_keys[ue_cap_random_id])
                        -- TODO test it if works, for now pointless bacause only one ue_cap
                    else
                        exec('ue_param id='.. ue_id ..' ue_eutra_capabilities='..UE_GROUP_CONFIG_PARAMS['ue_cap'])
                    end
                end
                if UE_GROUP_CONFIG_PARAMS['cqi_param'] then
                    exec('ue_cqi_param id='.. ue_id ..' '.. UE_GROUP_CONFIG_PARAMS['cqi_param'])
                end
            end
        if verbosity > 1 then
            print(group_id.." group done")
        end
        end
    end
end

-- TODO add description
function configure_lmts_bearers(PARAMS)

    local ue_config_params_table = PARAMS.ue_config
    local nbr_of_pdn = PARAMS.nbr_of_pgw
    local ue_id = 1

    exec('set_param SEC_OP_KEY='..PARAMS.SEC_OP_KEY)
    for i,ue_config_params in ipairs(ue_config_params_table) do
        local sec_key=ue_config_params.sec_key

        local ue_count = ue_config_params.ueCount

        -- retreive plmn and imsi
        local imsi_parts = split(ue_config_params.start_imsi, ":")
        local plmn = imsi_parts[1]..':'..imsi_parts[2]
        local start_imsi = imsi_parts[3]

        local encryption = ue_config_params.encryption or 'snow3g+aes'
        local integrity = ue_config_params.integrity or encryption -- if not defined, the same as encryption

        local bearer_param = ue_config_params.bearer_param
        local pdnswitch=1
        for i=1,ue_count do
            exec('set_ue external id='..ue_id
              ..' pdn='..pdnswitch
              ..' sec_key='..sec_key
              ..' imsi='..plmn..':'..start_imsi+i-1 -- -1 bacuase start_imsi also included
              ..' eea='..encryption
              ..' eia='..integrity
            )

            if tostring(type(bearer_param[1])) == "table" then -- if table of tables run multiple times
                nbr_of_pdn = PARAMS.nbr_of_pgw - table.getn(bearer_param)+1
                for k, bear_param in pairs(bearer_param) do
                    configure_bearers(bear_param, pdnswitch+k-1, "ue="..ue_id)
                end
            else  -- if table then run configure_bearers() only once
                configure_bearers(bearer_param, pdnswitch, "ue="..ue_id)
            end

            if pdnswitch < nbr_of_pdn then
                pdnswitch = pdnswitch + 1
            else
                pdnswitch = 1
            end
            ue_id = ue_id + 1
        end
    end

    --for LMTS UEs it is may be turned on the feature of network-initiated bearer activation by sending traffic packets to the specified port
    exec('pgw_lmts_param bearer_activation_by_trf=on')
end

--eof
