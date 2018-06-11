package.path = package.path .. ';/home/kpatro/lua_scripts/?.lua'

require "wrapper"
require "common"

local obj = {};

-----------------------------------------------------------------------------------------------------------------
--           MAIN FUNCTION
-----------------------------------------------------------------------------------------------------------------
function obj.init_traffic()

        ----------- CONSTANTS -----------
        local FUNC_NAME = "init_traffic"
        local ATTACH_SLEEP_TIME = 1   -- sleep time between attaches
        local BUNDLE_SIZE       = 50  -- number of ues attached at once
        local BEARER_ID         = 1   -- bearer id
        local TEST_DURATION     = 600  -- test duration after all ues started transfer
        local RETRIES				    = 15	-- verify functions retry count * 0.2s = 3s

        -- enb id, cell id --
        local enb_list = {
                {1, 1}                  -- first enb
        }

        local ue_list_per_enb = {
                fill_ue_list(1, 100)    -- first enb ue list
        }

        local transfer_profiles_per_enb = {
                {       --first enb transfer profiles
                        {protocol_dl = traffic.UDP, burst_dl = 1, protocol_ul = traffic.UDP, burst_ul = 1, period_dl = 8, packet_size_dl = 660,  period_ul = 8, packet_size_ul = 70},
                }
        }

        ----------- VARIABLES -----------
        local result = true
        local err_str = ""
        local ues_active = 0

        local drb_obj_table = {}
        local trf_obj_table_dl = {}
        local trf_obj_table_ul = {}

        --------------------------------------------------------------------------------------
        local temp_result = true
        local temp_str = ""

        -- Step 1 - Test pre-conditions
        printStep(FUNC_NAME .. ": Initialize UE locations")
        for index, enb_data in ipairs(enb_list) do
               temp_result, temp_str = obj.change_detached_ue_locations(ue_list_per_enb[index], enb_data[1], enb_data[2], RETRIES)
                if temp_result == false then
                        print_err(color_text("Test pre-condition function is failed. Test will be stopped.", CL_RED))
                        obj.detach_ue(ue_list_per_enb[index])
                        return temp_result, temp_str
                end
        end

        --------------------------------------------------------------------------------------
        -- Step 2 - Attach
        printStep(FUNC_NAME .. ": Attach UEs")
        for index, enb_data in ipairs(enb_list) do
                ues_active, temp_str = obj.attach_ue_in_bundles(ue_list_per_enb[index], BUNDLE_SIZE, ATTACH_SLEEP_TIME) -- exception: a function has non-boolean value as the first returned argument
                if (temp_str ~= nil) then
                        obj.detach_ue(ue_list_per_enb[index])
                        return false, temp_str
                end
        end

        --------------------------------------------------------------------------------------
        -- Step 3 - Traffic list generation
        printStep(FUNC_NAME .. ": Fill UEs traffic lists")
        for index, enb_data in ipairs(enb_list) do
                drb_obj_table[index], trf_obj_table_dl[index], trf_obj_table_ul[index] = obj.fill_ue_traffic_list(ue_list_per_enb[index], transfer_profiles_per_enb[index], BEARER_ID)
        end

        --------------------------------------------------------------------------------------
        -- Step 4 - Traffic
        printStep(FUNC_NAME .. ": Start traffic")
        for index, enb_data in ipairs(enb_list) do
                -- obj.start_traffic sleeps 0.2s after processing each ue
                temp_result, temp_str = obj.start_traffic(ue_list_per_enb[index], drb_obj_table[index], trf_obj_table_dl[index], trf_obj_table_ul[index], RETRIES)
                if temp_result == false then
            						result = false
            						err_str = err_str .. temp_str
            		end
        end


	--------------------------------------------------------------------------------------
        -- Step 5 - start eMBMS sessions and traffic
	
	printStep(FUNC_NAME .. ": Start eMBMS traffic")	

	exec("mbms_session_start type=debug m1_dst_addr=232.1.70.1 m1_teid=1 dst_ip=1.2.3.1 dst_port=2001 qci=1 gbr=5000 tmgi=1:244:08 sync_seq=8 sync_period=125 trf_adapt_scheme=buffering max_delay=90")
        exec("mbms_session_start type=debug m1_dst_addr=232.1.70.2 m1_teid=1 dst_ip=1.2.3.1 dst_port=2002 qci=1 gbr=5000 tmgi=2:244:08 sync_seq=8 sync_period=125 trf_adapt_scheme=buffering max_delay=90")
        exec("mbms_session_start type=debug m1_dst_addr=232.1.70.3 m1_teid=1 dst_ip=1.2.3.1 dst_port=2003 qci=1 gbr=5000 tmgi=3:244:08 sync_seq=8 sync_period=125 trf_adapt_scheme=buffering max_delay=90")

	sleep(1)

	iperf1 = io.popen("iperf -c 1.2.3.1 -u -b 5000k -i1 -p2001 -t86400 -l570 > /dev/null")
        iperf2 = io.popen("iperf -c 1.2.3.1 -u -b 5000k -i1 -p2002 -t86400 -l570 > /dev/null")
        iperf3 = io.popen("iperf -c 1.2.3.1 -u -b 5000k -i1 -p2003 -t86400 -l570 > /dev/null")


	--------------------------------------------------------------------------------------
        -- WAIT FOR TEST END AND PRINT STATS

        local seconds_left = TEST_DURATION
        for i = 0, TEST_DURATION / 2, 1 do
                for index, enb_data in ipairs(enb_list) do
			
                        exec("cell_stats id=" .. enb_data[2] .. " type=pusch")
                        exec("cell_stats id=" .. enb_data[2] .. " type=pdsch")
			exec("mbms_stats")
                end
                print_info(FUNC_NAME .. ": " .. color_text(seconds_left .. " seconds left ", CL_GREEN))
                seconds_left = seconds_left - 2
                sleep(2)
        end

	--------------------------------------------------------------------------------------
        -- Step 6 - Stop eMBMS traffic
	
	printStep(FUNC_NAME .. ": Stop eMBMS traffic")
	os.execute("pgrep iperf | xargs kill -9")
	
	exec("mbms_session_stop tmgi=1:244:08")
        exec("mbms_session_stop tmgi=2:244:08")
        exec("mbms_session_stop tmgi=3:244:08")

        --------------------------------------------------------------------------------------
        -- Step 7 - Detach
        printStep(FUNC_NAME .. ": Detach UEs")
        for index, enb_data in ipairs(enb_list) do
                obj.detach_ue(ue_list_per_enb[index])
        end


	printStep('All test cases has executed')

        if (err_str == "") then err_str = nil end
        return result, err_str

end

-----------------------------------------------------------------------------------------------------------------
--           SERVICE FUNCTIONS
-----------------------------------------------------------------------------------------------------------------
function obj.attach_ue_in_bundles(ue_list, bundle_size, sleep_time)
        local ues_active = 0
        local err_str = ""

        local ues_no = #ue_list
        local ue_begin = ue_list[1]
        local ue_end = ue_list[ues_no]
        local bundles_no = math.floor(ues_no/bundle_size)

        local temp_result = 0
        local temp_str = ""

        for bdl_id = 1, bundles_no, 1 do
                temp_result, temp_str = ue_fast_attach_range(ue_begin + (bdl_id - 1) * bundle_size, ue_begin + bdl_id * bundle_size - 1)
                ues_active = ues_active + temp_result
                if (temp_str ~= nil) then
                        err_str = err_str .. temp_str
                end
                print_info("Sleeping " .. sleep_time .. " seconds after attaching " .. temp_result .. " ues...")
                sleep(sleep_time)
        end

        if ue_end - (ue_begin + bundles_no * bundle_size) > -1 then
                temp_result, temp_str = ue_fast_attach_range(ue_begin + bundles_no * bundle_size, ue_end)
                ues_active = ues_active + temp_result
                if (temp_str ~= nil) then
                        err_str = err_str .. temp_str
                end
        end

        if (err_str == "") then err_str = nil end
        return ues_active, err_str
end

---------------------------------------------------
function obj.change_detached_ue_locations(ue_list, target_enb_id, target_cell_id, retries)
        local result = true
        local err_str = ""

        local temp_result = true
        local temp_str = ""

        for index, ue_id in ipairs(ue_list) do
                local ue_obj = ue(ue_id)

                temp_result, temp_str = change_location(ue_obj, target_enb_id, target_cell_id, retries)
                if temp_result == false then
                        result = false
                        err_str = err_str .. temp_str
                end
        end

        if (err_str == "") then err_str = nil end
        return result, err_str
end

---------------------------------------------------
function obj.detach_ue(ue_list)
        -- detach all ues
        ue_fast_detach(ue_list)

        -- kill ue if it hands
        for index, ue_id in ipairs(ue_list) do
                local ue_obj = ue(ue_id)
                if(ue_obj.state ~= ue.OFF)  then
                        exec('ue_kill id='..ue_obj.id)
                end
        end

        return true, nil
end

---------------------------------------------------
function obj.fill_ue_traffic_list(ue_list, transfer_profiles, bearer_id)
        local drb_obj_table = {}
        local trf_obj_table_dl = {}
        local trf_obj_table_ul = {}
        local transfer_profiles_no = #transfer_profiles

        for index, ue_id in pairs(ue_list) do
                drb_obj_table[ue_id] = ue(ue_id):bearer(bearer_id)
        end

        local temp_dl
        local temp_ul

        for tp_id = 1, transfer_profiles_no, 1 do
          temp_dl, temp_ul = create_traffic_udp(transfer_profiles[tp_id])
          trf_obj_table_dl[tp_id] = temp_dl
          trf_obj_table_ul[tp_id] = temp_ul
        end

        return drb_obj_table, trf_obj_table_dl, trf_obj_table_ul
end

---------------------------------------------------
function obj.start_traffic(ue_list, drb_table, trf_dl_table, trf_ul_table, retries)
        local result = true
        local err_str = ""

        local transfer_profiles_no = 0

        local temp_result = true
        local temp_str = ""

        for index, ue_id in ipairs(ue_list) do
                if #trf_dl_table == #trf_ul_table then
                        transfer_profiles_no = #trf_dl_table
                else
                        err_str = "Number of DL and UL profiles do not match\n"
                        return false, err_str
                end

                temp_result, temp_str = verify_ue_state_on_idle(ue(ue_id), retries)
                if temp_result == false then
                        return temp_result, temp_str
                end

                for tp_id = 1, transfer_profiles_no, 1 do
                        temp_result, temp_str = start_traffic(drb_table[ue_id], trf_dl_table[tp_id], tp_id, bearer.DL, retries)
                        if temp_result == false then
                                result = false
                                err_str = err_str .. temp_str
                        end

                        print_info("UE: " .. ue_id .. " DL traffic start result: " .. tostring(temp_result))
                end

                for tp_id = 1, transfer_profiles_no, 1 do
                        temp_result, temp_str = start_traffic(drb_table[ue_id], trf_ul_table[tp_id], tp_id + transfer_profiles_no, bearer.UL, retries)
                        if temp_result == false then
                                result = false
                                err_str = err_str .. temp_str
                        end

                        print_info("UE: " .. ue_id .. " DL traffic start result: " .. tostring(temp_result))
                end

                sleep(0.2)
        end

        if (err_str == "") then err_str = nil end
        return result, err_str
end
---------------------------------------------------

obj.init_traffic();
