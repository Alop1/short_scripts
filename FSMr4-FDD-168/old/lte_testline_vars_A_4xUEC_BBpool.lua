--***************************************************
-- Testline variables
-- (generated on 2014-03-18 11:10:37)
--***************************************************
ENB_ID = _TL_ID_
server_deamonip = "127.0.0.1"
server_deamonport = 12345
server_s1ip = MMI_IP
        uecProxyPort = 2152
        uecProxyIp= IPHY_IP
-----------------------------------------------
UEC_TABLE_DEFAULT= {
    UEC_1 = {
        pgwName = "PGW_1",
    },
    UEC_2 = {
        pgwName = "PGW_2",
    },
    UEC_3 = {
        pgwName = "PGW_3",
    },
    UEC_4 = {
        pgwName = "PGW_4",
    },
}


-----------------------------------------------
EPC_TABLE_DEFAULT= {
    EPC_1 = {
        daemonIp = server_deamonip,
        daemonPort = server_deamonport,
    },
}

-----------------------------------------------
MME_TABLE_DEFAULT= {
    MME_1 = {
        s1Ip = server_s1ip,
        s1Port = 36412,
        mmegi = 1,
        mmec = 3,
        epcName = "EPC_1",
    },
}

-----------------------------------------------
SGW_TABLE_DEFAULT= {
    SGW_1 = {
        s1uIp = server_s1ip,
        s1uPort = 2152,
        s11Ip = server_s1ip,
        s11Port = 2153,
        epcName = "EPC_1",
    },
}

-----------------------------------------------
PGW_TABLE_DEFAULT= {
    PGW_1 = {
        pgwID = "1",
        uecName = "UEC_1",
        epcName = "EPC_1",
    },
    PGW_2 = {
        pgwID = "2",
        uecName = "UEC_2",
        epcName = "EPC_1",
    },
    PGW_3 = {
        pgwID = "3",
        uecName = "UEC_3",
        epcName = "EPC_1",
    },
    PGW_4 = {
        pgwID = "4",
        uecName = "UEC_4",
        epcName = "EPC_1",
    },
    PGW_5 = {
        pgwID = "5",
        uecName = "UEC_1",
        epcName = "EPC_1",
    },
}

-----------------------------------------------
ENB_TABLE_DEFAULT= {
    ENB_1 = {
        ENB_ID = _TL_ID_,
        type = "external",
        plmn = "244:09",
        enbIdMacro = string.format("0x%05X", ENB_ID+1000),
        s1 = "10.254.197."..ENB_ID,
        tac = "123",
        cells = {{1, 2}, {3, 4}}
    },
}

--***************************************************
-- Data generation with ext_traffic libs
--***************************************************
TESTLINE_USERNAME_A = "lmts"
TESTLINE_PASSWORD_A = "!!lmts"
UE_APPLICATION_PC_A = " "
CN_APPLICATION_PC_A = " "
