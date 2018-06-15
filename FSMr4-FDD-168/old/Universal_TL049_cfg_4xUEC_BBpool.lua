-- _TL_ID_="69"
require 'configs/testline_consts'
require 'configs/lte_config_utils_BBpool'
require 'configs/lte_testline_vars_A_4xUEC_BBpool'

-- TODO require in future
-- lte_config utils
-- testline vars
-- test vars (eg uec pa)
verbosity = 2 -- 0 - quiet, 1 - warning, 2 - info,  3 - debug

debug_level(5)
--***************************************************************
--***************************************************************
-- BEGIN CONFIGURATION
sim_ = sim()
if (sim.INIT == sim_.state) then
    sim_:configure()
    exec('debug_log gate=1 level=0')
end

UEC_IPs = get_uec_servers_ip()
-- generate Simmode set commands (UEC, ENB, MME, SGW, PGW)
simmode_params = {
    uec = UEC_TABLE_DEFAULT,
    epc = EPC_TABLE_DEFAULT,
    enb = ENB_TABLE_DEFAULT,
    mme = MME_TABLE_DEFAULT,
    sgw = SGW_TABLE_DEFAULT,
    pgw = PGW_TABLE_DEFAULT
}

generate_simmmode_set_commands(--'wraparound', -- wraparound not needed
simmode_params
)
ue_security = {
    null = 'eia=null eea=null',
    aes  = 'eia=null+aes eea=null+aes',
    zuc  = 'eia=null+zuc eea=null+zuc',
    snow = 'eia=null+snow3g eea=null+snow3g',
    all  = 'eia=snow3g+aes eea=snow3g+aes',
    nall = 'eia=null+snow3g+aes eea=null+snow3g+aes',
}
-------------------------------------------
UE_CONFIG_PARAMS = {
{
    -- enbName = "ENB_1",
    ueCount = 850, --back to 850
    encryption = 'null+snow3g+aes',
    ue_group_parametars = "category=5",
    ue_param = "supported_bands=4 ca_supported_bands=4:a--4:a",
    cqi_param = ' wb=15:15:15 rank=4 ignore_codebook_subset_restriction=on',--added for 4x4 MIMO
    cell_id = 1,
},
{
    -- enbName = "ENB_1",
    ueCount = 850, --back to 850
    encryption = 'null+snow3g+aes',
    ue_group_parametars = "category=5",
    ue_param = "supported_bands=4 ca_supported_bands=4:a--4:a",
    cqi_param = ' wb=15:15:15 rank=4 ignore_codebook_subset_restriction=on',--added for 4x4 MIMO
    cell_id = 2,
},
{
    -- enbName = "ENB_1",
    ueCount = 850, --back to 850
    encryption = 'null+snow3g+aes',
    ue_group_parametars = "category=5",
    ue_param = "supported_bands=4 ca_supported_bands=4:a--4:a",
    cqi_param = ' wb=15:15:15 rank=4 ignore_codebook_subset_restriction=on',--added for 4x4 MIMO
    cell_id = 3,
},
{
    -- enbName = "ENB_1",
    ueCount = 850, --back to 850
    encryption = 'null+snow3g+aes',
    ue_group_parametars = "category=5",
    ue_param = "supported_bands=4 ca_supported_bands=4:a--4:a",
    cqi_param = ' wb=15:15:15 rank=4 ignore_codebook_subset_restriction=on',--added for 4x4 MIMO
    cell_id = 4,
},
}
BEARER_PARAM = {
    {
        trf_type    = 'internal',
        default_qci = 9,
        def_b_id    = 1,
        qci         = {6, 8},
        mbr_ul      = {},
        mbr_dl      = {},
        gbr_ul      = {},
        gbr_dl      = {},
        bearer_id   = {2, 3},
        --parameters = "preemption=on vulnerability=off",
    },
    {
        trf_type    = 'internal',
        default_qci = 9,
        def_b_id    = 1,
        qci         = {6, 8},
        mbr_ul      = {},
        mbr_dl      = {},
        gbr_ul      = {},
        gbr_dl      = {},
        bearer_id   = {2, 3}
    },
    {
        trf_type    = 'internal',
        default_qci = 9,
        def_b_id    = 1,
        qci         = {6, 8},
        mbr_ul      = {},
        mbr_dl      = {},
        gbr_ul      = {},
        gbr_dl      = {},
        bearer_id   = {2, 3}
    },
    {
        trf_type    = 'internal',
        default_qci = 9,
        def_b_id    = 1,
        qci         = {6, 8},
        mbr_ul      = {},
        mbr_dl      = {},
        gbr_ul      = {},
        gbr_dl      = {},
        bearer_id   = {2, 3}
    },
}
rest = { -- TODO need better name
-- use dl256qam ?
-- use ul64qam ?
-- nbr_of_iphy = ..
-- nbr of pgw = ..
-- nbr of cells = ..
-- nbr of sht = ..
-- use_sht = true/false
-- use sth_else = true/false
}
set_ue_with_bearers(ENB_TABLE_DEFAULT,UEC_TABLE_DEFAULT,UE_CONFIG_PARAMS,BEARER_PARAM,rest)
--
-- configure_default_sequences(UEC_COUNT)
exec('cfg_end')
sleep (1)
--***************************************************************
--***************************************************************
-- SET DEBUG LOG LEVELS
-- print("INFO: set debug log levels")
-- exec('debug_log gate=1 level=1')

-- print("INFO: activate RRC protocol traces for UEC1")
-- exec('trace uec=1 protocol=rrc off')
-- exec('sim_log_set log_to_file=on')

-- exec('debug_log level=5')  -- lowest debug level
--exec('debug_log uec=1 level=0')  -- highest debug level (level=0)
--exec('debug_log uec=1 level=1 max_log_size=61440K')  -- highest debug level=1
-- exec('debug_log')

-- print("INFO: set proxy log levels")
-- exec('proxy_log enb=1 cell=1 GEN=info CA=info')
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
