--***************************************************
-- Testline variables
-- (generated on 2014-03-18 11:10:37)
--***************************************************
ENB_ID = _TL_ID_
server_deamonip = "127.0.0.1"  --TODO zrobic jako deafult i jak nie bedzie podane to weżmie defult , a jak bedzie to nadpisze
server_deamonport = 12345
server_s1ip = "10.253.152."..ENB_ID
        uecProxyPort = 2152
        uecProxyIp= "10.34.166.1"..ENB_ID
-----------------------------------------------
UEC_TABLE_A= {
    UEC_1 = {--TODO sprawdzic czy jest 10.34.166.x na PC i ile
        -- daemonIp = server_deamonip, -- out
        -- daemonPort = server_deamonport, -- out
        -- Cplane_uecServerIp = "10.34.166.1",
        -- Uplane_uecServerIp = "10.34.166.2",
        -- uecProxyIp =   uecProxyIp,
        -- uecProxyPort = 2152,
        pgwName = "PGW_1",
        --pdn = 1, --out
    },
    UEC_2 = {
        -- daemonIp = server_deamonip,
        -- daemonPort = server_deamonport,
        -- Cplane_uecServerIp = "10.34.166.3",
        -- Uplane_uecServerIp = "10.34.166.4",
        -- uecProxyIp =   uecProxyIp,
        -- uecProxyPort = 2152,
        pgwName = "PGW_2",
        --pdn = 1,
    },
    UEC_3 = {
        -- daemonIp = server_deamonip,
        -- daemonPort = server_deamonport,
        -- Cplane_uecServerIp = "10.34.166.5",
        -- Uplane_uecServerIp = "10.34.166.6",
        -- uecProxyIp =   uecProxyIp,
        -- uecProxyPort = 2152,
        pgwName = "PGW_3",
        --pdn = 1,
    },
--    UEC_4 = {
        -- daemonIp = server_deamonip,
        -- daemonPort = server_deamonport,
        -- Cplane_uecServerIp = "10.34.166.7",
        -- Uplane_uecServerIp = "10.34.166.8",
        -- uecProxyIp =   uecProxyIp,
        -- uecProxyPort = 2152,
  --      pgwName = "PGW_4",
  --      --pdn = 1,
  --  },
}


-----------------------------------------------
EPC_TABLE_A= {
    EPC_1 = {
        -- daemonIp = server_deamonip,
        -- daemonPort = server_deamonport,
    },
}

-----------------------------------------------
MME_TABLE_A= {
    MME_1 = {
        s1Ip = server_s1ip,
        s1Port = 36412,
        mmegi = 1,
        mmec = 3,
        epcName = "EPC_1",
    },
}

-----------------------------------------------
SGW_TABLE_A= {
    SGW_1 = {
        s1uIp = server_s1ip,
        s1uPort = 2152,
        s11Ip = server_s1ip,
        s11Port = 2153,
        epcName = "EPC_1",
    },
}

-----------------------------------------------
PGW_TABLE_A= {  -- TODO całkowicie automatyczne, ta tabelka niepotrzebna, ilość pgw = ilosć cell
    PGW_1 = {  --TODO adresy out, nazwy można tymczasosow zostawić
        --networkPrefix = "13.7",
        --pgwIpAddress = "13.7.254.254",
        --natNetworkPrefix = "11.7",
        pgwID = "1",
        --pgwUecIpAddress = "11.7.200.200",
        uecName = "UEC_1",
        epcName = "EPC_1",
    },
    PGW_2 = {
        --networkPrefix = "23.7",
        --pgwIpAddress = "23.7.254.254",
        --natNetworkPrefix = "21.7",
        pgwID = "2",
        --pgwUecIpAddress = "21.7.200.200",
        uecName = "UEC_2",
        epcName = "EPC_1",
    },
    PGW_3 = {
        --networkPrefix = "33.7",
        --pgwIpAddress = "33.7.254.254",
        --natNetworkPrefix = "31.7",
        pgwID = "3",
        --pgwUecIpAddress = "31.7.200.200",
        uecName = "UEC_3",
        epcName = "EPC_1",
    },
--[[    PGW_4 = {
        --networkPrefix = "43.7",
        --pgwIpAddress = "43.7.254.254",
        --natNetworkPrefix = "41.7",
        pgwID = "4",
        --pgwUecIpAddress = "41.7.200.200",
        uecName = "UEC_4",
        epcName = "EPC_1",
    },
    PGW_5 = {
        --networkPrefix = "53.7",
        --pgwIpAddress = "53.7.254.254",
        --natNetworkPrefix = "51.7",
        pgwID = "5",
        --pgwUecIpAddress = "51.7.200.200",
        uecName = "UEC_1",
        epcName = "EPC_1",
    },]]
}

-----------------------------------------------
ENB_TABLE_A= {
    ENB_2 = {
        type = "simulated",
        plmn = "244:09",
        enbIdMacro = '0x00032',
        s1 = "10.253.155."..ENB_ID,
        -- daemonIp = server_deamonip,
        -- daemonPort = server_deamonport,
        proxy = '127.0.0.1:2154',
        tac = "123",
        cells = {1},
        -- uecName = "UEC_1",
    },
    ENB_1 = {
        ENB_ID = _TL_ID_,
        type = "external",
        plmn = "244:09",
        enbIdMacro = string.format("0x%05X", ENB_ID+1000),-->TODO obliczanie przenieść do config_utils
        s1 = "10.253.150."..ENB_ID,
        tac = "123",
        cells = {1, 2, 3},
        -- uecName = "UEC_1", -- TODO niepotrzebne
    },
}

--***************************************************
-- Data generation with ext_traffic libs
--***************************************************
TESTLINE_USERNAME_A = "lmts"
TESTLINE_PASSWORD_A = "!!lmts"
UE_APPLICATION_PC_A = " "
CN_APPLICATION_PC_A = " "

-- TODO dodac do uec_table i pgw_table pole z max count
-- TODO w external enb dodać liczbę cellek
-- TODO whole this tables into one table, then devided in generate function
-- TODO tabelka która celka na którym iphy(może byc więcej iphy)
