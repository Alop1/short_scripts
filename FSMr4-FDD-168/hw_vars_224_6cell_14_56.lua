-- see https://confluence.inside.nokiasiemensnetworks.com/display/SIMMODE/hw_vars.lua+description
-- for description of this file
--

-- ********* Test ENVIRONMENT
-- hw, sim
	TEST_ENV		= 'hw'

-- ********* LTE line
-- wmp, dcm, dcm_micro, lrc, fzm [, kddi, tdlte, ...]
	LINE				= 'wmp'
    ENB_ID              = 168 --168
    MME_ID              = 168

-- variable used by mcm_tests.lua (added by me)
    EMSSIM              = '10.83.200.23'

-- ********* IP/Pass/Port
-- eGate server: IP address/user name/password
	SERVER_IP			= '127.0.0.1'
	USER				= 'lmts'
	USER_PASSWORD		= '!!lmts'
-- UEC eDaemon server: IP address/port/user name/password
	UEC_SERVER_IP		= '127.0.0.1'
	UEC_DAEMON_PORT		= '12345'
	UEC_USER			= 'lmts'
	UEC_USER_PASSWORD	= '!!lmts'
-- EPC eDaemon server: IP address/port/user name/password
	EPC_SERVER_IP		= '127.0.0.1'
	EPC_DAEMON_PORT		= '12345'
	EPC_USER			= 'lmts'
	EPC_USER_PASSWORD	= '!!lmts'
-- ***
-- L3SIM eDaemon server: IP addres/port
--  L3SIM_SERVER_IP		= '127.0.0.1'
--  L3SIM_DAEMON_PORT	= '12345'

-- ********* I-PHY
-- List of links to I-PHY proxies. Format: {eNB_GE_IP_proxy1:port, ..., eNB_GE_IP_proxyProxyCount:port}
	PROXY_ADDR 	= {'10.34.166.101:2152'} --, '11.34.166.45:2152' }
-- List of UEC Server interfaces connected to Proxy eNB_GE_IP. (Optional: 2 ifs for each UEC for C-plane and U-plane)
-- Format: {{Peer_IP_uec1:port[, Peer_IP_UP_uec1:port]}, ..., {Peer_IP_uecUecCount:port[, Peer_IP_UP_uecUecCount:port]}}
--	PIP_ADDR	= {{'10.34.166.1:2152', '10.34.166.3:2152'}, {'10.34.166.2:2152', '10.34.166.4:2152'}, {'10.34.166.5:2152', '10.34.166.6:2152'}}
	PIP_ADDR	= {{'10.34.166.1:2152','10.34.166.2:2152'}}

-- ********* eNB
-- eNB GE IP address. Format: {ENB_S1_IP[, ENB_S1_SCTP_MULTIHOMING_IP]}
	ENB_ADDR	= {'10.253.150.' .. ENB_ID }
-- IP of simulated MME, SGW, PWG (EPC server IP on GE interface)
-- 	Format: {MME_S1_IP[, MME_S1_SCTP_MULTIHOMING_IP]}
	S1_IP		= {'10.253.152.' .. MME_ID}
-- 	Format: {{SGW1_S1U_IP_Endpoint1[,...,SGW1_S1U_IP_EndpointN]}[,..., {SGWn_S1U_IP_Endpoint1[,...,SGWn_S1U_IP_EndpointN]}]}
	S1U_IP		= {{'10.253.152.' .. MME_ID}}
-- List of physical cell id
--    PCI_LIST	= {'0:1', '0:2', '1:1', '1:2', '2:1', '2:2', '3:1', '3:2', '4:1', '4:2', '5:1', '5:2'}
-- MobileContryCode:MobileNetworkCode
	PLMN		= '244:09'
-- Simulated eNB (X2 neighbour for eNB UT)
--    NBR_ENB_PROXY_ADDR = '10.34.166.61'     -- for the second eNB
	ENB_UT_HW_TAC = 123
	ENB_UT_SIM_TAC = 12
-- TAC	for NBR_ENB cells
	NBR_CELL_TAC = 3

-- ********* UE
-- Table of bearer parameter lists (by PDN. Num of lists <= PGW_COUNT)
	BEARER_PARAM = {
		{	-- list#1 (for pdn=1)
			trf_type   = 'internal',
			default_qci= 9, --9
			qci        = {6,7,8}, --6,8
			mbr_ul     = {nil,nil}, -- nil,nil
			mbr_dl     = {nil,nil},
			gbr_ul     = {nil,nil},
			gbr_dl     = {nil,nil}
		},
		{	-- list#2 (for pdn=2)
			trf_type   = 'internal',
			default_qci= 9,
			qci        = {6,7,8},
			mbr_ul     = {nil,nil},
			mbr_dl     = {nil,nil},
			gbr_ul     = {nil,nil},
			gbr_dl     = {nil,nil}
		},		
		{	-- list#3 (for pdn=3)
			trf_type   = 'internal',
			default_qci= 9,
			qci        = {6,7,8},
			mbr_ul     = {},
			mbr_dl     = {},
			gbr_ul     = {},
			gbr_dl     = {}
		}
	}
	DEFAULT_PDN = 1

-- ********* Quantity
-- Number of cells (Max = 3 per proxy). Format: {num_proxy1, num_proxy2, ..., num_NumOfProxies}
CELL_COUNT		= {4,2}
-- Number of UEs (per cell)
UE_COUNT		= 1000
-- Number of PGWs (Max = 4)
	PGW_COUNT		= 2

-- ********CELL_ID_ARRAY
--  If defined, these values are used instead of consecutive numbering [1..CELL_COUNT]
    --CELL_ID_ARRAY = {{1,2,3,13}} --, {45,16}}
	CELL_ID_ARRAY = {{1,2,3,4},{5,6}} --, {45,16}}
	

-- ********* L3SIM
	PROTO_ADDR	= '127.0.0.1:60606'
-- L3SIM Server interface connected to FAM. Peer_IP:port
	ATTSS_PEER_ADDR	= '127.0.0.1:19888'
	AP3_PEER_ADDR = '127.0.0.1:19892' --TODO: need better name
-- ID used for the 1st I-PHY cell
	--CELL_START_ID = 3

-- ********* SERVICE
-- List of server IPs connected to the IPHY FSMs LMP interface.
-- That IPs should be available from the Gate server
	LMP_PROXY_IP	= {'127.0.0.1'} --, '192.168.255.127'}
-- List of user names to access the servers connected to the IPHY FSMs LMP interface.
	LMP_PROXY_USR	= {'lmts'}--, 'lmts'}
-- List of passwords to access the servers connected to the IPHY FSMs LMP interface.
	LMP_PROXY_PWD	= {'!!lmts'} --, '!!lmts'}

--************************************************************************************
--************************************************************************************
--************************************************************************************
-- Setup independent vars and consts
BASE_ID			   = 0
NETWORK_NUMBER     = {'3.7', '4.7', '5.7', '6.7', '7.7', '8.7'}
NAT_NETWORK_NUMBER = {{'13.7', '14.7', '15.7', '16.7', '17.7', '18.7'}, {'23.7', '24.7', '25.7', '26.7', '27.7', '28.7'}} --, {'33.7', '34.7', '35.7', '36.7', '37.7', '38.7'}}
PGW_ADDR     = {}
SGW_ADDRS = {'10.253.152.' .. ENB_ID}
SGW_COUNT		= #SGW_ADDRS
enb_id_macro = '0x000A8'
sec_key      = '0102030405060708090A0B0C0D0E0F10'

--************************************************************************************
--************************************************************************************
--************************************************************************************
-- Misc params
-- configured variety of security algorithms combinations
-- NOTE! till PDCP-security is not supported in HO keep 1st UE unsecured
-- if you need unsecure UEs - comment out all lines in array ue_security, except with 'null'
-- For all unsecure UE array should be like:
-- ue_security = { 'eia=null eea=null' }

--here list security algorithm which UEs will have. If some algorithms are not supported, comment them out of this array
	ue_security = {
		--'eia=null+snow3g eea=null+snow3g',
		--'eia=null+aes eea=null+aes',
		--'eia=null+zuc eea=null+zuc',
		--'eia=null+snow3g+aes eea=null+snow3g+aes',
		'eia=null eea=null'
	}


--************************************************************************************
--************************************************************************************
--************************************************************************************
-- Setup UTRAN eNB, rnc, cells
--Be aware that Rnc instance should be also configured on eNB UT (SCFC file on WMP)
--For DCM UTRAN is not supported yet, so leave RNC_PARAM_LIST.utran_enb_id empty like this :
-- RNC_PARAM_LIST = { utran_enb_id = {} }
-- or comment out whole RNC_PARAM_LIST
--[[
 RNC_PARAM_LIST = {
			--if want cfg without UTRAN leave this array empty: utran_enb_id = {}
			utran_enb_id = {2}, --this is neighbour enb id, make sure enb with such id is configured
			utran_rnc_ut_id  = {22},
			utran_cell_id  = {1},
			phy_utra_cell_id  = {222},
			uarfcn     = {'4140:4140'}
}
--]]

--Example of RNC_PARAM_LIST for multiple rnc instances :
--Number of parameters in array in every line should be the same
--[[
	RNC_PARAM_LIST = {
			utran_enb_id = {2, 2, 3}, --this is neighbour enb id, make sure enb with such id is configured. Several rnc instances can be on 1 neighbour enb
			utran_rnc_ut_id  = {22, 23, 24}, --parameter should be unique
			utran_cell_id  = {1, 2, 3},	--parameter should be unique. this cell should be configured
			phy_utra_cell_id  = {222, 333, 444}, --parameter should be unique
			uarfcn     = {'4140:4140', '4140:4140', '4140:4140'}

		}
--]]


-- WARN_MSG_CONTENT varaible used by mcm_tests.lua and others

WARN_MSG_CONTENT = "Gozilla is coming! Expected tsunami and earthquake! Stay calm! Be brave! Help injured! Keep phone!"
