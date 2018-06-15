--***************************************************
-- Testline variables
-- (generated on 2014-03-18 11:10:37)
--***************************************************

-----------------------------------------------
PCI_LIST        = {'0:1', '0:2', '1:0', '1:1', '1:2', '2:0'}
ENB_ID = 68
UEC_TABLE_A= {
	UEC_1 = {
		daemonIp = "127.0.0.1",
		daemonPort = 12345,
		Cplane_uecServerIp = "10.34.166.1",
        Uplane_uecServerIp = "10.34.166.2",
		uecProxyIp = "10.34.166.101",
		uecProxyPort = 2152,
		pgwName = "PGW_1",
        pdn = 1,
	},   
    UEC_2 = {
		daemonIp = "127.0.0.1",
		daemonPort = 12345,
		Cplane_uecServerIp = "10.34.166.3",
        Uplane_uecServerIp = "10.34.166.4",
		uecProxyIp = "10.34.166.101",
		uecProxyPort = 2152,
		pgwName = "PGW_2",
        pdn = 2,
	},
    UEC_3 = {
		daemonIp = "127.0.0.1",
		daemonPort = 12345,
		Cplane_uecServerIp = "10.34.166.5",
        Uplane_uecServerIp = "10.34.166.6",
		uecProxyIp = "10.34.166.101",
		uecProxyPort = 2152,
		pgwName = "PGW_3",
        pdn = 3,
	},
    UEC_4 = {
		daemonIp = "127.0.0.1",
		daemonPort = 12345,
		Cplane_uecServerIp = "10.34.166.7",
        Uplane_uecServerIp = "10.34.166.8",
		uecProxyIp = "10.34.166.101",
		uecProxyPort = 2152,
		pgwName = "PGW_4",
        pdn = 1,
	},
    UEC_5 = {
		daemonIp = "127.0.0.1",
		daemonPort = 12345,
		Cplane_uecServerIp = "10.34.166.9",
        Uplane_uecServerIp = "10.34.166.10",
		uecProxyIp = "10.34.166.101",
		uecProxyPort = 2152,
		pgwName = "PGW_5",
        pdn = 1,
	},
    UEC_6 = {
		daemonIp = "127.0.0.1",
		daemonPort = 12345,
		Cplane_uecServerIp = "10.34.166.14",
        Uplane_uecServerIp = "10.34.166.12",
		uecProxyIp = "10.34.166.101",
		uecProxyPort = 2152,
		pgwName = "PGW_6",
        pdn = 1,
	},
}

--UEC_TABLE_B= {
--        UEC_1 = {
--                daemonIp = "10.83.206.79",
--                daemonPort = 10000,
--                uecServerIp = "10.34.166.1",
--                uecProxyIp = "10.34.166.115",
--                uecProxyPort = 2153,
--                pgwName = "PGW_1",
--        },
--}


-----------------------------------------------
EPC_TABLE_A= {
	EPC_1 = {
		daemonIp = "127.0.0.1",
		daemonPort = 12345,
	},
}

-----------------------------------------------
MME_TABLE_A= {
	MME_1 = {
		s1Ip = "10.253.152.168",
		s1Port = 36412,
		mmegi = 1,
		mmec = 3,
		epcName = "EPC_1",
	},
}

-----------------------------------------------
SGW_TABLE_A= {
	SGW_1 = {
		s1uIp = "10.253.152.168",
		s1uPort = 2152,
		s11Ip = "10.253.152.168",
		s11Port = 2153,
		epcName = "EPC_1",
	},
}

------------------------------------------------
PGW_TABLE_A= {
	PGW_1 = {
		networkPrefix = "13.7",
		pgwIpAddress = "13.7.254.254",
		natNetworkPrefix = "11.7",
		pgwUecIpAddress = "11.7.200.200",
		epcName = "EPC_1",
	}, 
    PGW_2 = {
		networkPrefix = "23.7",
		pgwIpAddress = "23.7.254.254",
		natNetworkPrefix = "21.7",
		pgwUecIpAddress = "21.7.200.200",
		epcName = "EPC_1",
	},
    PGW_3 = {
		networkPrefix = "33.7",
		pgwIpAddress = "33.7.254.254",
		natNetworkPrefix = "31.7",
		pgwUecIpAddress = "31.7.200.200",
		epcName = "EPC_1",
	},
    PGW_4 = {
		networkPrefix = "43.7",
		pgwIpAddress = "43.7.254.254",
		natNetworkPrefix = "41.7",
		pgwUecIpAddress = "41.7.200.200",
		epcName = "EPC_1",
	},
    PGW_5 = {
		networkPrefix = "53.7",
		pgwIpAddress = "53.7.254.254",
		natNetworkPrefix = "51.7",
		pgwUecIpAddress = "51.7.200.200",
		epcName = "EPC_1",
	},
    PGW_6 = {
		networkPrefix = "63.7",
		pgwIpAddress = "63.7.254.254",
		natNetworkPrefix = "61.7",
		pgwUecIpAddress = "61.7.200.200",
		epcName = "EPC_1",
	},
}

-----------------------------------------------
ENB_TABLE_A= {
	ENB_1 = {
		type = "external",
		plmn = "244:09",
		enbIdMacro = string.format("0x%05X", 1000+ENB_ID),
		s1 = "10.253.150.168",
		tac = "123",
		cells = {1,2,3,4,5,6},
		uecName = "UEC_1",
	},

}

--***************************************************
-- Data generation with ext_traffic libs
--***************************************************
TESTLINE_USERNAME_A = "lmts"
TESTLINE_PASSWORD_A = "!!lmts"
UE_APPLICATION_PC_A = " "
CN_APPLICATION_PC_A = " "
