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
        tac = "130",
       cells = {{1}}
    }, 
}
local bearer_param_common = {
        trf_type    = 'internal',
        default_qci = 9,
        def_b_id    = 9,
        def_priority = 9,
        qci         = { 1,   2,   3,   4,   5,   6,   7,   8},
        mbr_ul      = {31, 144,  64,  32, nil, nil, nil, nil},
        mbr_dl      = {31, 144, 128, 320, nil, nil, nil, nil},
        gbr_ul      = {31,  31,  31,  31, nil, nil, nil, nil},
        gbr_dl      = {31,  31,  31,  31, nil, nil, nil, nil},
        bearer_id   = { 1,   2,   3,   4,   5,   6,   7,   8},
        priority    = { 2,   4,   3,   5,   1,   6,   7,   8},
}
local UE_CONFIG_PARAMS = {
{
    cell_id = {1}, -- if not set use all
   ue_group_id = {1}, -- for compability with old tests, if not set then 100*n+cellId
    ueCount = 900,
    encryption = 'snow3g+aes',
    ue_group_parametars = "category=12",
    -- ue_param = "supported_bands=7 ca_supported_bands=4:a--4:a",
    -- cqi_param = ' wb=15:15:15 rank=4 ignore_codebook_subset_restriction=on',
    ue_cap = UE_CAP.s7,
    bearer_param = bearer_param_common,
},
}
local simmode_params = {
--    epc = EPC_TABLE_DEFAULT,  -- set only when different than deafult
--    mme = MME_TABLE_DEFAULT,  -- set only when different than deafult
   enb = ENB_TABLE,
    nbr_of_sgw = 1,
    nbr_of_pgw = 2,
    nbr_of_uec = 4,
    configure_sgw_s11 = true,
    ue_config = UE_CONFIG_PARAMS,
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

exec('cfg_end')
exec('debug_log level=6')
exec('proxy_log error_mask=0 warn_mask=0 debug_mask=0 info_mask=0')
exec("sim_log_set log_to_file=on")

print(WARN_MSG)

sleep(1)

--eof
