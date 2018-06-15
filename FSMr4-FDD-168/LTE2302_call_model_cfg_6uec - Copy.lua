require 'configs/LTE2302_lte_config_utils'
require 'configs/LTE2302_lte_testline_vars_6uec'

--***************************************************************
--***************************************************************
-- BEGIN CONFIGURATION
sim_ = sim()
if (sim.INIT == sim_.state) then
	sim_:configure()
	--exec('debug_log gate=1 level=0')
end
-- generate Simmode set commands (UEC, ENB, MME, SGW, PGW)
generate_simmmode_set_commands('wraparound',
	UEC_TABLE_A,
	EPC_TABLE_A,
	ENB_TABLE_A,
	MME_TABLE_A,
	SGW_TABLE_A,
	PGW_TABLE_A
)
exec('set_enb id=2 x2=10.253.155.168:36422 plmn=244:09 s1=10.253.155.168 type=simulated enb_id_macro=0x00045 daemon=127.0.0.1:12345')
exec('set_cell id=1 enb=2 pci=16:0 tac=123 eci=0x0004501 proxy=127.0.0.1:2154 earfcn=3000:21000 bw=20MHz')

-------------------------------------------
UE_CONFIG_PARAMS = {
	enbName = "ENB_1",
	ueCount = 840,
    ueCount2 = 840

}
UEC_COUNT=0
for uec_id, uec_table in pairs(UEC_TABLE_A) do
    UEC_COUNT=UEC_COUNT+1
end
UE_COUNT = UE_CONFIG_PARAMS['ueCount']
UE_COUNT2 = UE_CONFIG_PARAMS['ueCount2']
CELL_TABLE_A = ENB_TABLE_A[UE_CONFIG_PARAMS['enbName']]['cells']
CELL_COUNT_A = table.getn( CELL_TABLE_A )

eutra_capability='C9BA050600106260C89B0D18391FF8C188FFC60C47FE30F23FF1BD11FF8DFC8FFC69E47FFFD3FFA6A2087004830D493952207058C08000000B88BC0C0000400308001000C600040034C001000C3000400344001000DB000400700001010820028010308001001C000040460800A0040C6000400700001014C2002801034C001000C20004807080010108200384000808C1201420818C000900E1000242304005082463000200384000808C1001420818C000800E100020298400508206980020038400090A6100142091A6000800E1000202D8400508206D80020018C000900E300020230400718001014C20028C1034C001001C6000405B0800A3040DB000400718001216C20028C1236C001002C000040420808C10024008184000808C1002400808410318001002C00004042080A61002400818400080A6100240080841034C001002C20004046080A61002420818C00080A61002420808C1034C001002C20004046080B61002420818C00080B61002420808C1036C001001C3000405B080BE30723FF18311FF8C188FFC61E47FE37A23FF1BF91FF8D3C8FFC6CE47FE36723FF1AF91FF8D7C8FFC6BE47FE35F23FF1BF91FF8DFC8FFC6FE47FE37F23FF1BF91FF8DFC8FFC66C47FE33623FF19791FF8CBC8FFC6FE47FE37F23FF1B791FF8DBC8FFC6FE47FE37F23FF1AF91FF8D7C8FFC6BE47FE35F23FF1BF91FF8DFC8FFC6FE47FE37F23FF1BF91FF8DFC8FFC6FE47FE37F23FF1BF91FF8DFC8FFC6FE47FE37F23FF1BF91FF8DFC8FFC6FE47FC00D00000D78001FE00000007F80000001FE00000001FE00000007F80000001FE00000007F800000001FF00000007F80000001FE00000007F80000001FE00000007F80000000000110040'

for cell_id=1, 6  do
	uec=cell_id
    exec('set_ue_group simulated id='.. cell_id ..' uec='..uec..' pdn='..uec..' eia=aes eea=aes enb=1 cell='..cell_id)
    exec('set_bearer id=1 ue_group='.. cell_id ..' default=on pdn='..uec..' qci=9 trf_type=internal')
    exec('set_bearer id=2 ue_group='.. cell_id ..' pdn='..uec..' qci=6')
    exec('set_bearer id=3 ue_group='.. cell_id ..' pdn='..uec..' qci=8')
    exec('set_bearer id=4 ue_group='.. cell_id ..' pdn='..uec..' qci=1 gbr_ul=256 gbr_dl=256 mbr_ul=256 mbr_dl=256')
    exec('set_bearer id=5 ue_group='.. cell_id ..' pdn='..uec..' qci=5')
    for imsi=1,UE_COUNT do
        ue_id = (cell_id-1)*2000+10000+imsi
        _trf_type_ = 'internal'
        _supported_bands_ = 'all'
        _imsi_='244:09:'..cell_id..'0000'.. 10000 +imsi
        _seq_=cell_id
        _ca_supported_bands_ = '4:a:a+4:a|4:c:a'
        exec('set_ue id='.. ue_id ..' group='.._seq_..' imsi='.._imsi_..' enb=1 cell='..cell_id)
        exec('ue_param id='.. ue_id ..' supported_bands='.._supported_bands_..' ca_supported_bands='.._ca_supported_bands_..' ue_eutra_capabilities='..eutra_capability)
    end
end

for uec_id=1, 6 do
    exec('set_ue_group simulated id=4'..uec_id..' pdn='..(uec_id)..' uec='..(uec_id)..' eia=aes eea=aes enb=2 cell=1')
    exec('set_bearer id=1 ue_group=4'..uec_id..' pdn='..(uec_id)..' default=on qci=9 trf_type=internal')
    exec('set_bearer id=2 ue_group=4'..uec_id..' pdn='..(uec_id)..' qci=6')
    exec('set_bearer id=3 ue_group=4'..uec_id..' pdn='..(uec_id)..' qci=8')
    exec('set_bearer id=4 ue_group=4'..uec_id..' pdn='..(uec_id)..' qci=1 gbr_ul=256 gbr_dl=256 mbr_ul=256 mbr_dl=256')
    exec('set_bearer id=5 ue_group=4'..uec_id..' pdn='..(uec_id)..' qci=5')
    for imsi=1,UE_COUNT2 do
        ue_id = (uec_id)+(UE_COUNT2*(uec_id))+imsi
        _trf_type_ = 'internal'
        _supported_bands_ = 'all'
        _imsi_='244:09:'..(uec_id)..'1000'.. 10000 +imsi
        _seq_='4'..uec_id
        _ca_supported_bands_ = '4:a:a+4:a|4:c:a'
        exec('set_ue id='.. ue_id ..' group='.._seq_..' imsi='.._imsi_..' enb=2 cell=1')
        exec('ue_param id='.. ue_id ..' supported_bands='.._supported_bands_..' ca_supported_bands='.._ca_supported_bands_..' ue_eutra_capabilities='..eutra_capability)
    end
end
exec('cfg_end')
sleep (1)
--***************************************************************
--***************************************************************
-- SET DEBUG LOG LEVELS
print("INFO: set debug log levels")

exec('debug_log level=6')

exec('sim_log_set log_to_file=on')

exec('debug_log')


--eof
