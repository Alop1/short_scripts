require 'configs/testline_consts'
require 'configs/lte_config_utils_common'

verbosity = 1 -- 0 - quiet, 1 - warning, 2 - info,  3 - debug

UEC_IPs = get_uec_servers_ip()

local ENB_TABLE = {
    ENB_1 = {
        ENB_ID = GLOBAL_ENB_ID,
        type = "external",
        plmn = "244:09",
        s1 = eNB_IP,
        tac = "123",
        cells = {{1, 2, 3}},
    },
}
local simmode_params = {
--    epc = EPC_TABLE_DEFAULT,  -- set only when different than deafult
--    mme = MME_TABLE_DEFAULT,  -- set only when different than deafult
    enb = ENB_TABLE,
    nbr_of_sgw = 1,
    nbr_of_pgw = 3,
    nbr_of_uec = 3,
    configure_sgw_s11 = true,
}
local bearer_param_common = {
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
}
local UE_CONFIG_PARAMS = {
{  --  non-CA
--    enb_id = 1, --specify enb_id, if not set then =1
    cell_id =      {1,  2,  3},
    ue_group_id = {11, 22, 33}, -- for compability with old tests, if not set then 100*n+cellId
    ueCount = 850,
    encryption = 'snow3g+aes',
    -- ue_group_parametars = "category=11",
--    ue_group_parametars = "dl_256QAM_supported=true ul_64QAM_supported=true release=12 category=11 category-dl=11 category-ul=5",
--    ue_param = "supported_bands=all ca_supported_bands=none",
--    cqi_param = ' wb=15:15:15 rank=4 ignore_codebook_subset_restriction=on',--added for 4x4 MIMO
    ue_cap = UE_CAP.s7,
    bearer_param = bearer_param_common,
},
}

--***************************************************************
-- BEGIN CONFIGURATION
--***************************************************************
sim_ = sim()
if (sim.INIT == sim_.state) then
    sim_:configure()
end
exec('debug_log level=3')
exec("sim_log_set log_to_file=on")

generate_simmmode_set_commands(simmode_params)
if simulatorType == 'IPHY' then
    set_ue_with_bearers(UE_CONFIG_PARAMS,simmode_params)
end

exec('cfg_end')
exec('debug_log level=6')

print(WARN_MSG)

sleep(1)

--eof
