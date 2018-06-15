require 'configs/PS_lte_config_utils'
require 'configs/PS_lte_testline_vars_A'



--**************************************************************
--**************************************************************
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
)


-------------------------------------------
UE_CONFIG_PARAMS = {
	enbName = "ENB_1",
	ueCount = 1000,

}

-------------------------------------------
-- UE configuration
-- First 1500 UEs on every cell are 'normal' UEs
-- Then 300 UEs are configured with CA
-------------------------------------------
UE_COUNT = UE_CONFIG_PARAMS['ueCount']
CELL_TABLE_A = ENB_TABLE_A[UE_CONFIG_PARAMS['enbName']]['cells']
CELL_COUNT_A = table.getn( CELL_TABLE_A )

for cell_id=1,CELL_COUNT_A do
   uec_nr = cell_id

   exec('set_ue_group simulated id='.. cell_id ..' eia=null+snow3g eea=null+snow3g enb=1 uec='.. uec_nr ..' cell='..cell_id..' pdn='..uec_nr..' release=12 category=6')

	exec('set_bearer id=9 ue_group='.. cell_id ..' default=on pdn='.. uec_nr ..' qci=69 preemption=on vulnerability=off priority=3')
	exec('set_bearer id=15 ue_group='.. cell_id ..' pdn='.. uec_nr ..' qci=65 gbr_ul=31 gbr_dl=31 mbr_ul=31 mbr_dl=31 preemption=on vulnerability=off priority=3')
    exec('set_bearer id=16 ue_group='.. cell_id ..' pdn='.. uec_nr ..' qci=66 gbr_ul=31 gbr_dl=31 mbr_ul=31 mbr_dl=31 preemption=on vulnerability=off priority=3')

        for imsi=1,UE_COUNT do
            ue_id = (cell_id-1)*2000+10000+imsi
            _trf_type_ = 'internal'
            _supported_bands_ = 'all'
            _ca_supported_bands_ = 'none'
            _imsi_='244:09:'..cell_id..'0000'.. 10000 +imsi


            exec('set_ue id='.. ue_id ..' group='..cell_id..' imsi='.._imsi_..' enb=1 cell='..cell_id)
            exec('ue_param id='.. ue_id ..' supported_bands='.._supported_bands_..' ca_supported_bands='.._ca_supported_bands_)
        end

end


exec('cfg_end')
sleep (1)
--***************************************************************
--***************************************************************
-- SET DEBUG LOG LEVELS
print("INFO: set debug log levels")
exec('debug_log gate=1 level=3')
exec('sim_log_set log_to_file=on')
print("INFO: activate RRC protocol traces for UEC1")
exec('trace uec=1 protocol=rrc off')

exec('debug_log level=6')  -- lowest debug level
--exec('debug_log uec=1 level=0')  -- highest debug level (level=0)
--exec('debug_log uec=1 level=1 max_log_size=61440K')  -- highest debug level=1
exec('debug_log')

-- print("INFO: set proxy log levels")
-- exec('proxy_log enb=1 cell=1 GEN=info CA=info')
--exec('proxy_log enb=1 cell=1 GEN=debug CA=debug SCH=debug')
--exec('proxy_log enb=1 cell=1 debug_mask=0x1fff')
--exec('proxy_log enb=1 cell=1 GEN=debug CA=debug SCH=debug, ULER=debug, DLER=debug')
--exec('proxy_log enb=1 cell=1 GEN=info CA=info DLER=debug')
-- exec('proxy_log enb=1 cell=2 GEN=info CA=info')
--exec('proxy_log enb=1 cell=2 debug_mask=0x1fff')
--exec('proxy_log enb=1 cell=2 GEN=debug CA=debug SCH=debug, ULER=debug, DLER=debug')
-- exec('proxy_log enb=1 cell=3 GEN=info CA=info')
--exec('proxy_log enb=1 cell=3 debug_mask=0x1fff')
--exec('proxy_log enb=1 cell=3 GEN=debug CA=debug SCH=debug, ULER=debug, DLER=debug')
--exec('proxy_log enb=1 cell=3 GEN=info CA=info DLER=debug')
--exec('proxy_log enb=1 cell=4 GEN=info CA=info')
--exec('proxy_log enb=1 cell=4 GEN=debug CA=debug SCH=debug, ULER=debug, DLER=debug')
--exec('proxy_log enb=1 cell=4 GEN=debug CA=debug SCH=debug, ULER=debug, DLer=debug')


--eof
