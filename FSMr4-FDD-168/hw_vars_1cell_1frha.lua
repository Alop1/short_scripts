-- see https://confluence.inside.nokiasiemensnetworks.com/display/SIMMODE/hw_vars.lua+description
-- for description of this file

-- ********* Test ENVIRONMENT
-- hw, sim
	TEST_ENV			= 'hw'

-- ********* LTE line
-- wmp, dcm, dcm_micro [, kddi, tdlte, ...]
	LINE		= 'wmp'
	ENB_IDS         = 168
        ENB_ID          = 168 --1012
        MME_ID          = 168
-- variable used by mcm_tests.lua (added by me)
        EMSSIM          = '10.83.200.23'
-- ********* IP/Pass/Port
-- eGate server: IP address/user name/password
        SERVER_IP		= '127.0.0.1'
	USER			= 'lmts'
	USER_PASSWORD		= '!!lmts'
-- UEC eDaemon server: IP address/port/user name/password
	UEC_SERVER_IP		= '127.0.0.1'
	UEC_DAEMON_PORT		= '12345'
	UEC_USER		= 'lmts'
	UEC_USER_PASSWORD	= '!!lmts'
-- EPC eDaemon server: IP address/port/user name/password
        EPC_SERVER_IP		= '127.0.0.1'
        EPC_DAEMON_PORT		= '12345'
	EPC_USER		= 'lmts'
	EPC_USER_PASSWORD	= '!!lmts'
-- ***
-- L3SIM eDaemon server: IP addres/port
--	L3SIM_SERVER_IP		= '10.82.140.198'
--	L3SIM_DAEMON_PORT	= '31415'
-- ********* I-PHY
-- List of links to I-PHY proxies. Format: {eNB_GE_IP_proxy1:port, ..., eNB_GE_IP_proxyProxyCount:port}
	PROXY_ADDR 	= {'10.34.166.101:2152'}
-- List of UEC Server interfaces connected to Proxy eNB_GE_IP. (Optional: 2 ifs for each UEC for C-plane and U-plane)
-- Format: {{Peer_IP_uec1:port[, Peer_IP_UP_uec1:port]}, ..., {Peer_IP_uecUecCount:port[, Peer_IP_UP_uecUecCount:port]}}
	PIP_ADDR	= {{'10.34.166.1:2152'}}

-- ********* eNB
-- eNB GE IP address. Format: {ENB_S1_IP[, ENB_S1_SCTP_MULTIHOMING_IP]}
	ENB_ADDR	= {'10.253.150.' .. ENB_ID }
-- IP of simulated MME, SGW, PWG (EPC server IP on GE interface)
-- 	Format: {MME_S1_IP[, MME_S1_SCTP_MULTIHOMING_IP]}
	S1_IP		= {'10.253.152.' .. MME_ID}
-- 	Format: {{SGW1_S1U_IP_Endpoint1[,...,SGW1_S1U_IP_EndpointN]}[,..., {SGWn_S1U_IP_Endpoint1[,...,SGWn_S1U_IP_EndpointN]}]}
	S1U_IP		= {{'10.253.152.' .. MME_ID}}

-- List of physical cell id
--	PCI_LIST	= {'3:1', '3:2', '22:0'}
-- MobileContryCode:MobileNetworkCode
	PLMN		= '244:09'
-- Simulated eNB (X2 neighbour for eNB UT)
    --NBR_ENB_PROXY_ADDR = '10.34.166.26'     -- for the second eNB
    --NBR_ENB_IDS  = {126}

-- ********* UE
-- Table of bearer parameter lists (by PDN. Num of lists <= PGW_COUNT)
	BEARER_PARAM = {
		{	-- list#1 (for pdn=1)
			trf_type   = 'external',
			default_qci= 6,
			qci        = {3, 7},
			mbr_ul     = {31, nil},
			mbr_dl     = {31, nil},
			gbr_ul     = {31, nil},
			gbr_dl     = {31, nil}
		},
		{	-- list#2 (for pdn=2)
			trf_type   = 'internal',
			default_qci= 6,
			qci        = {1, 3, 5, 7},
			mbr_ul     = {31, 50, nil, nil},
			mbr_dl     = {31, 50, nil, nil},
			gbr_ul     = {31, 50, nil, nil},
			gbr_dl     = {31, 50, nil, nil}
		}
	}
	DEFAULT_PDN = 1

-- ********* Quantity
-- Number of cells (Max = 3 per proxy). Format: {num_proxy1, num_proxy2, ..., num_NumOfProxies}

-- CELLS varaible used by mcm_tests.lua and other
        CELLS                   = {1}
	CELL_COUNT		= {#CELLS}
-- Number of UEs (per cell)
	UE_COUNT		= 650
-- Number of PGWs (Max = 4)
	PGW_COUNT		= 2
-- ID used for the 1st I-PHY cell
	CELL_START_ID	= 1

-- ********* SERVICE
-- List of server IPs connected to the IPHY FSMs LMP interface.
-- That IPs should be available from the Gate server
	LMP_PROXY_IP	= {'192.168.255.127'}
-- List of user names to access the servers connected to the IPHY FSMs LMP interface.
	LMP_PROXY_USR	= {'toor4nsn'}
-- List of passwords to access the servers connected to the IPHY FSMs LMP interface.
	LMP_PROXY_PWD	= {'oZPS0POrRieRtu'}

--************************************************************************************
--************************************************************************************
-- Setup independent vars and consts
BASE_ID			   = 1000
NETWORK_NUMBER     = {'3.7', '4.7', '5.7', '6.7', '7.7', '8.7'}
NAT_NETWORK_NUMBER = {{'13.7', '14.7', '15.7', '16.7', '17.7', '18.7'}, {'23.7', '24.7', '25.7', '26.7', '27.7', '28.7'}}
PGW_ADDR     = {}
enb_id_macro = string.format("0x%05X", ENB_ID)
sec_key      = '0102030405060708090A0B0C0D0E0F10'

--************************************************************************************
--************************************************************************************
--************************************************************************************

-- WARN_MSG_CONTENT varaible used by mcm_tests.lua and others

WARN_MSG_CONTENT = "Gozilla is coming! Epected tsunami and earthquake! Stay calm! Be brave! Help injured! Keep phone!"
