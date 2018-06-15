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
       cells = {{1, 2}, {3}}
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
        trf_type     = 'internal',
        default_qci  = 69,
        def_b_id     = 9,
        def_priority = 3,
        qci         = {65, 66},
        mbr_ul      = {31, 31},
        mbr_dl      = {31, 31},
        gbr_ul      = {31, 31},
        gbr_dl      = {31, 31},
        bearer_id   = {15, 16},
        priority    = { 3,  3},
        parameters = "preemption=on vulnerability=off",

    }
-------------------------------------------

local UE_CONFIG_PARAMS = {
{
    cell_id = {1, 2, 3}, -- if not set use all
--    ue_group_id = {1, 2}, -- for compability with old tests, if not set then 100*n+cellId
    ueCount = 1000,
    encryption = 'null+snow3g',
    ue_group_parametars = "release=12 category=6",
    ue_param = "supported_bands=all ca_supported_bands=none",
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
exec('proxy_log error_mask=0 warn_mask=0 debug_mask=0 info_mask=0')
exec("sim_log_set log_to_file=on")

print(WARN_MSG)

sleep(1)

--eof
