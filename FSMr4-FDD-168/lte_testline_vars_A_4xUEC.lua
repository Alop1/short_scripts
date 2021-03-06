--***************************************************
-- Testline variables
-- (generated on 2014-03-18 11:10:37)
--***************************************************
iphy_ip = "10.34.166.101"
iphy_ip_table = {"10.34.166.101","10.34.166.101","10.34.166.102","10.34.166.102"} 
server_deamonip = "127.0.0.1"
server_deamonport = 12345
server_s1ip = "10.253.152.168"
-----------------------------------------------
UEC_TABLE_A= {
	UEC_1 = {
		daemonIp = server_deamonip,
		daemonPort = server_deamonport,
		Cplane_uecServerIp = "10.34.166.1",
        Uplane_uecServerIp = "10.34.166.2",
		uecProxyIp = iphy_ip,
		uecProxyPort = 2152,
		pgwName = "PGW_1",
        pdn = 1,
	},   
    UEC_2 = {
		daemonIp = server_deamonip,
		daemonPort = server_deamonport,
		Cplane_uecServerIp = "10.34.166.3",
        Uplane_uecServerIp = "10.34.166.4",
		uecProxyIp = iphy_ip,
		uecProxyPort = 2152,
		pgwName = "PGW_2",
        pdn = 1,
	},
    UEC_3 = {
		daemonIp = server_deamonip,
		daemonPort = server_deamonport,
		Cplane_uecServerIp = "10.34.166.5",
        Uplane_uecServerIp = "10.34.166.6",
		uecProxyIp = iphy_ip,
		uecProxyPort = 2152,
		pgwName = "PGW_3",
        pdn = 1,
	},
    UEC_4 = {
		daemonIp = server_deamonip,
		daemonPort = server_deamonport,
		Cplane_uecServerIp = "10.34.166.7",
        Uplane_uecServerIp = "10.34.166.8",
		uecProxyIp = iphy_ip,
		uecProxyPort = 2152,
		pgwName = "PGW_4",
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
		daemonIp = server_deamonip,
		daemonPort = server_deamonport,
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
    -- SGW_2 = {
		-- s1uIp = server_s1ip,
		-- s1uPort = 2152,
		-- s11Ip = server_s1ip,
		-- s11Port = 2153,
		-- epcName = "EPC_1",
	-- },
    -- SGW_3 = {
		-- s1uIp = server_s1ip,
		-- s1uPort = 2152,
		-- s11Ip = server_s1ip,
		-- s11Port = 2153,
		-- epcName = "EPC_1",
	-- },
    -- SGW_4 = {
		-- s1uIp = server_s1ip,
		-- s1uPort = 2152,
		-- s11Ip = server_s1ip,
		-- s11Port = 2153,
		-- epcName = "EPC_1",
	-- },
}

------------------------------------------------
PGW_TABLE_A= {
	PGW_1 = {
		networkPrefix = "13.7",
		pgwIpAddress = "13.7.254.254",
		natNetworkPrefix = "11.7",
		pgwUecIpAddress = "11.7.200.200",
		uecName = "UEC_1",
		epcName = "EPC_1",
	}, 
    PGW_2 = {
		networkPrefix = "23.7",
		pgwIpAddress = "23.7.254.254",
		natNetworkPrefix = "21.7",
		pgwUecIpAddress = "21.7.200.200",
		uecName = "UEC_2",
		epcName = "EPC_1",
	},
    PGW_3 = {
		networkPrefix = "33.7",
		pgwIpAddress = "33.7.254.254",
		natNetworkPrefix = "31.7",
		pgwUecIpAddress = "31.7.200.200",
		uecName = "UEC_3",
		epcName = "EPC_1",
	},
    PGW_4 = {
		networkPrefix = "43.7",
		pgwIpAddress = "43.7.254.254",
		natNetworkPrefix = "41.7",
		pgwUecIpAddress = "41.7.200.200",
		uecName = "UEC_4",
		epcName = "EPC_1",
	},
    PGW_5 = {
		networkPrefix = "53.7",
		pgwIpAddress = "53.7.254.254",
		natNetworkPrefix = "51.7",
		pgwUecIpAddress = "51.7.200.200",
		uecName = "UEC_1",
		epcName = "EPC_1",
	},
}

-----------------------------------------------
ENB_TABLE_A= {
	ENB_1 = {
		type = "external",
		plmn = "244:09",
		enbIdMacro = "0x000A8",
		s1 = "10.253.150.168",
		tac = "123",
		cells = {1,2,3,4},
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
