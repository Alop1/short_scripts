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
       cells = {{1, 2, 3},{ 4 ,5, 6}}
    },
}
local bearer_param_common = {
    trf_type    = 'internal',
    default_qci = 9,
    def_b_id    = 1,
    qci         = {6, 7, 8},
    mbr_ul      = {},
    mbr_dl      = {},
    gbr_ul      = {},
    gbr_dl      = {},
    bearer_id   = {2, 3, 4}

}
local UE_CONFIG_PARAMS = {
{
    cell_id = {1, 2, 3}, -- if not set use all
    ue_group_id = {11, 22, 33}, -- for compability with old tests, if not set then 100*n+cellId  --TODO not sure about these numbers
    ueCount = 1000,
    encryption = 'snow3g+aes', -- if not set then "snow3g+aes"
    -- integrity = 'null+snow3g+aes', -- if not set, the same as encryption
    ue_group_parametars = "release=13 category-dl=12 category-ul=13 ul_64QAM_supported=true",  -- additional_ue_group_parametars
    -- ue_param = "supported_bands=4 ca_supported_bands=4:a--4:a", -- exec('ue_param id='.. ue_id ..' '..UE_CONFIG_PARAMS["ue_param"])
    -- cqi_param = ' wb=15:15:15 rank=4 ignore_codebook_subset_restriction=on', -- exec('ue_cqi_param id='.. ue_id ..' '.. UE_CONFIG_PARAMS['cqi_param'])
    ue_cap = UE_CAP.s7, -- exec('ue_param id='.. ue_id ..' ue_eutra_capabilities='..UE_CONFIG_PARAMS['ue_cap'])
    bearer_param = bearer_param_common,
},
}
local simmode_params = {
--    epc = EPC_TABLE_DEFAULT,  -- set only when different than deafult
--    mme = MME_TABLE_DEFAULT,  -- set only when different than deafult
   enb = ENB_TABLE,
    nbr_of_sgw = 1,
    nbr_of_pgw = 2,
    nbr_of_uec = 1,
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

