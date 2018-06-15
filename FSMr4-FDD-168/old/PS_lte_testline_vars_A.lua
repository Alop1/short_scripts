--***************************************************
-- Testline variables
-- (generated on 2014-03-18 11:10:37)
--***************************************************
ENB_ID = 68
server_deamonip = "127.0.0.1"
server_s1ip = "10.254.220."..ENB_ID
iphy_ip_table = {"10.34.166.168","10.34.166.168","10.34.166.169"} -- cell1, cell2, cell3
iphy_ip = "10.34.166.1"..ENB_ID

-----------------------------------------------
UEC_TABLE_A= {
	UEC_1 = {
		daemonIp = server_deamonip,
		daemonPort = 12345,
		uecServerIp = "10.34.166.1",
		uecProxyIp = iphy_ip,
		uecProxyPort = 2152,
		UEC_PIP_UPLANE="10.34.166.10:2152",
		pgwName = "PGW_1",
        pdn = 1,
	},
	UEC_2 = {
		daemonIp = server_deamonip,
		daemonPort = 12345,
		uecServerIp = "10.34.166.2",
		uecProxyIp = iphy_ip,
		uecProxyPort = 2152,
		UEC_PIP_UPLANE="10.34.166.11:2152",
		pgwName = "PGW_2",
        pdn = 2,
	},
	UEC_3 = {
        daemonIp = server_deamonip,
        daemonPort = 12345,
        uecServerIp = "10.34.166.3",
        uecProxyIp = iphy_ip,
        uecProxyPort = 2152,
		UEC_PIP_UPLANE="10.34.166.12:2152",
        pgwName = "PGW_3",
		pdn = 3,
        },

}


-----------------------------------------------
EPC_TABLE_A= {
	EPC_1 = {
		daemonIp = server_deamonip,
		daemonPort = 12345,
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
PGW_TABLE_A= {
	PGW_1 = {
		networkPrefix = "3.7",
		pgwIpAddress = "3.7.254.254",
		natNetworkPrefix = "11.7",
		pgwUecIpAddress = "11.7.200.200",
		uecName = "UEC_1",
		epcName = "EPC_1",
	},
	PGW_2 = {
		networkPrefix = "32.7",
		pgwIpAddress = "32.7.254.254",
		natNetworkPrefix = "21.7",
		pgwUecIpAddress = "21.7.200.200",
		uecName = "UEC_2",
		epcName = "EPC_1",
	},
        PGW_3 = {
                networkPrefix = "62.7",
                pgwIpAddress = "62.7.254.254",
                natNetworkPrefix = "31.7",
                pgwUecIpAddress = "31.7.200.200",
                uecName = "UEC_3",
                epcName = "EPC_1",
        },
}

-----------------------------------------------
ENB_TABLE_A= {
	ENB_1 = {
		type = "external",
		plmn = "244:09",
		enbIdMacro = string.format("0x%05X", 1000+ENB_ID),
		s1 = "10.254.197."..ENB_ID,
		tac = "123",
		cells = {1, 2, 3},
		uecName = "UEC_1",
	},

}

--ENB_TABLE_B= {
--      ENB_2 = {
--		type = "simulated",
--                plmn = "244:09",
--                enbIdMacro = "0x003F5",
--                s1 = "10.34.166.116",
--		--s1 = "10.254.221.117",
--                tac = "123",
--                cells = {1},
--                uecName = "UEC_1",
--        },
--
--}

--***************************************************
-- Data generation with ext_traffic libs
--***************************************************
TESTLINE_USERNAME_A = "lmts"
TESTLINE_PASSWORD_A = "!!lmts"
UE_APPLICATION_PC_A = " "
CN_APPLICATION_PC_A = " "
--[[ looks like not used here
-- ********* UE
BEARER_PARAM = {	-- Table of bearer parameter lists (by PDN. Num of lists <= PGW_COUNT)
	{		-- list#1 (for pdn=1)
		trf_type        = 'internal',
		default_qci     = 9,
		qci             = {1,	5,	7,	8,	6,	3,	4	},
		mbr_ul     	= {64,	nil,	nil,	nil,	nil,	16,	16	},
		mbr_dl          = {64,	nil,	nil,	nil,	nil,	16,	16	},
		gbr_ul          = {31,	nil,	nil,	nil,	nil,	16,	16	},
		gbr_dl          = {31,	nil,	nil,	nil,	nil,	16,	16	}
	}
}

PGW_COUNT	= 1
--]]
--[[
NETWORK_NUMBER     = {'3.7', '4.7', '5.7', '6.7', '7.7', '8.7'}
NAT_NETWORK_NUMBER = {{'13.7', '14.7', '15.7', '16.7', '17.7', '18.7'}, {'23.7', '24.7', '25.7', '26.7', '27.7', '28.7'}}
PGW_ADDR     = {}
]]--
