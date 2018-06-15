require 'configs/lte_config_utils'
require 'configs/lte_testline_vars_A_4xUEC'


--***************************************************************
--***************************************************************
-- BEGIN CONFIGURATION
sim_ = sim()
if (sim.INIT == sim_.state) then
	sim_:configure()
	exec('debug_log gate=1 level=0')
end

-- generate Simmode set commands (UEC, ENB, MME, SGW, PGW)
generate_simmmode_set_commands('wraparound',
	UEC_TABLE_A,
	EPC_TABLE_A,
	ENB_TABLE_A,
	MME_TABLE_A,
	SGW_TABLE_A,
	PGW_TABLE_A
--	ENB_TABLE_B,
--	UEC_TABLE_B
)
_TL_ID_=168
exec('set_enb id=2 x2=10.253.155.'.._TL_ID_..':36422 plmn=244:09 s1=10.253.155.'.._TL_ID_..' type=simulated enb_id_macro=0x00032 daemon=127.0.0.1:12345')
exec('set_cell id=1 enb=2 pci=16:0 tac=123 eci=0x0003201 proxy=127.0.0.1:2154 earfcn=3000:21000')


-------------------------------------------
UE_CONFIG_PARAMS = {
	enbName = "ENB_1",
	ueCount = 850,
}

UEC_COUNT=0
for uec_id, uec_table in pairs(UEC_TABLE_A) do
    UEC_COUNT=UEC_COUNT+1
end
UE_COUNT = UE_CONFIG_PARAMS['ueCount']
CELL_TABLE_A = ENB_TABLE_A[UE_CONFIG_PARAMS['enbName']]['cells']
CELL_COUNT_A = table.getn( CELL_TABLE_A )

for uec_id=1, UEC_COUNT do
    --need UEs (per uec) C1,C5:840; C2D:16; C2U:420; C3,C4,C7:600; C6: 600(uec1,2),840(uec3,4)
    --ue_group for C123467
    exec('set_ue_group simulated id='..uec_id..' pdn='..uec_id..' uec='..uec_id..' category=5 eia=null+snow3g+aes eea=null+snow3g+aes enb=1 cell='..uec_id)
    exec('set_bearer id=1 ue_group='..uec_id..' pdn='..uec_id..' default=on qci=9 trf_type=internal')
    exec('set_bearer id=2 ue_group='..uec_id..' pdn='..uec_id..' qci=6')
    exec('set_bearer id=3 ue_group='..uec_id..' pdn='..uec_id..' qci=8')
    --ue_group for C5
    exec('set_ue_group simulated id=5'..uec_id..' pdn='..uec_id..' uec='..uec_id..' category=5 eia=null+snow3g+aes eea=null+snow3g+aes enb=1 cell='..uec_id)
    exec('set_bearer id=1 ue_group=5'..uec_id..' pdn='..uec_id..' default=on qci=9 trf_type=internal')
    exec('set_bearer id=2 ue_group=5'..uec_id..' pdn='..uec_id..' qci=6')
    exec('set_bearer id=3 ue_group=5'..uec_id..' pdn='..uec_id..' qci=8')
    for imsi=1,UE_COUNT do

        --UEs for CL123467
        ue_id = (uec_id+11)*1000+imsi  --ue_id = (uec_id+X)*2000+10000+imsi
        _trf_type_ = 'internal'
        _supported_bands_ = '4'
        _ca_supported_bands_ = '4:a--4:a'
        _imsi_='244:09:'..(uec_id-1)..'000'.. 100000 +ue_id
        _seq_=uec_id

        exec('set_ue id='.. ue_id ..' group='.._seq_..' imsi='.._imsi_..' enb=1 cell='..uec_id)
        exec('ue_param id='.. ue_id ..' supported_bands='.._supported_bands_..' ca_supported_bands='.._ca_supported_bands_)
		exec('ue_param id=' ..ue_id..' ue_eutra_capabilities=c9ba050600106260c89b0d18391ff8c188ffc60c47fe30f23ff1bd11ff8dfc8ffc69e47fffd3ffa6a2087004830d493952207058c08000000b88bc0c0000400308001000c600040034c001000c3000400344001000db000400700001010820028010308001001c000040460800a0040c6000400700001014c2002801034c001000c20004807080010108200384000808c1201420818c000900e1000242304005082463000200384000808c1001420818c000800e100020298400508206980020038400090a6100142091a6000800e1000202d8400508206d80020018c000900e300020230400718001014c20028c1034c001001c6000405b0800a3040db000400718001216c20028c1236c001002c000040420808c10024008184000808c1002400808410318001002c00004042080a61002400818400080a6100240080841034c001002c20004046080a61002420818c00080a61002420808c1034c001002c20004046080b61002420818c00080b61002420808c1036c001001c3000405b080be30723ff18311ff8c188ffc61e47fe37a23ff1bf91ff8d3c8ffc6ce47fe36723ff1af91ff8d7c8ffc6be47fe35f23ff1bf91ff8dfc8ffc6fe47fe37f23ff1bf91ff8dfc8ffc66c47fe33623ff19791ff8cbc8ffc6fe47fe37f23ff1b791ff8dbc8ffc6fe47fe37f23ff1af91ff8d7c8ffc6be47fe35f23ff1bf91ff8dfc8ffc6fe47fe37f23ff1bf91ff8dfc8ffc6fe47fe37f23ff1bf91ff8dfc8ffc6fe47fe37f23ff1bf91ff8dfc8ffc6fe47fc00d00000d78001fe00000007f80000001fe00000001fe00000007f80000001fe00000007f800000001ff00000007f80000001fe00000007f80000001fe00000007f80000000000110040')

        exec('ue_cqi_param id='.. ue_id ..' wb=15:15:15 rank=4 ignore_codebook_subset_restriction=on') --added for 4x4 MIMO


        --UEs for CL5
        ue_id = (uec_id+15)*1000+imsi  --ue_id = (uec_id+X)*2000+10000+imsi
        _trf_type_ = 'internal'
        _supported_bands_ = '4'
        _ca_supported_bands_ = '4:a+4:a'
        _imsi_='244:09:'..(uec_id-1)..'000'.. 100000 +ue_id
        _seq_=uec_id

        exec('set_ue id='.. ue_id ..' group=5'.._seq_..' imsi='.._imsi_..' enb=1 cell='..uec_id)
        exec('ue_param id='.. ue_id ..' supported_bands='.._supported_bands_..' ca_supported_bands='.._ca_supported_bands_)
        exec('ue_cqi_param id='.. ue_id ..' wb=15:15:15 rank=4 ignore_codebook_subset_restriction=on') --added for 4x4 MIMO
        end

    --[[template for rest
	--firstly take one of these:
    --C2UL:
    exec('set_ue_group simulated id='..uec_id..' pdn='..uec_id..' uec='..uec_id..' category=4 eia=null+snow3g eea=null+snow3g enb=1 cell='..uec_id)
	--C6:
    exec('set_ue_group simulated id='..uec_id..' pdn='..uec_id..' uec='..uec_id..' category=5 eia=null+snow3g eea=null+snow3g enb=1 cell='..uec_id)
    --C13457:
    exec('set_ue_group simulated id='..uec_id..' pdn='..uec_id..' uec='..uec_id..' category=5 eia=null eea=null enb=1 cell='..uec_id)

    then use this
    exec('set_bearer id=1 ue_group='..uec_id..' pdn='..uec_id..' default=on qci=9 trf_type=internal')
    exec('set_bearer id=2 ue_group='..uec_id..' pdn='..uec_id..' qci=6')
    exec('set_bearer id=3 ue_group='..uec_id..' pdn='..uec_id..' qci=8')
    --exec('set_bearer id=4 ue_group='..uec_id..' pdn=5 default=on qci=9 trf_type=internal') --C7 probably not used

    and finally set UEs (watch for ca(firstly check in QC if ca is needed))
    for imsi=1,UE_COUNT do
        ue_id = (uec_id-1)*2000+10000+imsi
        _trf_type_ = 'internal'
        _supported_bands_ = '4'
        _ca_supported_bands_ = '4:a+4:a' --C5
        --_ca_supported_bands_ = '4:a--4:a' --C13467
        _imsi_='244:09:'..(uec_id-1)..'0000'.. 10000 +imsi
        _seq_=uec_id

        exec('set_ue id='.. ue_id ..' group='.._seq_..' imsi='.._imsi_..' enb=1 cell='..uec_id)
        exec('ue_param id='.. ue_id ..' supported_bands='.._supported_bands_..' ca_supported_bands='.._ca_supported_bands_)
        exec('ue_cqi_param id='.. ue_id ..' wb=15:15:15 rank=4 ignore_codebook_subset_restriction=on') --added for 4x4 MIMO
    end
    --]]
end
exec('cfg_end')
sleep (1)
--***************************************************************
--***************************************************************
-- SET DEBUG LOG LEVELS
print("INFO: set debug log levels")
-- egate.log
exec('debug_log gate=1 level=1')

print("INFO: activate RRC protocol traces for UEC1")
exec('trace uec=1 protocol=rrc off')
exec('sim_log_set log_to_file=on')

exec('debug_log level=6')  -- lowest debug level
--exec('debug_log uec=1 level=0')  -- highest debug level (level=0)
--exec('debug_log uec=1 level=1 max_log_size=61440K')  -- highest debug level=1
exec('debug_log')

print("INFO: set proxy log levels")
exec('proxy_log enb=1 cell=1 GEN=info CA=info')
--exec('proxy_log enb=1 cell=1 GEN=debug CA=debug SCH=debug')
--exec('proxy_log enb=1 cell=1 debug_mask=0x1fff')
--exec('proxy_log enb=1 cell=1 GEN=debug CA=debug SCH=debug, ULER=debug, DLER=debug')
--exec('proxy_log enb=1 cell=1 GEN=info CA=info DLER=debug')
--exec('proxy_log enb=1 cell=2 GEN=info CA=info')
--exec('proxy_log enb=1 cell=2 debug_mask=0x1fff')
--exec('proxy_log enb=1 cell=2 GEN=debug CA=debug SCH=debug, ULER=debug, DLER=debug')
--exec('proxy_log enb=1 cell=3 GEN=info CA=info')
--exec('proxy_log enb=1 cell=3 debug_mask=0x1fff')
--exec('proxy_log enb=1 cell=3 GEN=debug CA=debug SCH=debug, ULER=debug, DLER=debug')
--exec('proxy_log enb=1 cell=3 GEN=info CA=info DLER=debug')
--exec('proxy_log enb=1 cell=4 GEN=info CA=info')
--exec('proxy_log enb=1 cell=4 GEN=debug CA=debug SCH=debug, ULER=debug, DLER=debug')
--exec('proxy_log enb=1 cell=4 GEN=debug CA=debug SCH=debug, ULER=debug, DLer=debug')


--eof
