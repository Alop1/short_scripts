simulatorType = 'IPHY'
egateType = 'wraparound'

GLOBAL_ENB_ID = "168"
_TL_ID_="168"
MME_IP = "10.253.152.".._TL_ID_
eNB_IP = "10.253.150.".._TL_ID_
eNB2_IP = "10.253.155.".._TL_ID_

uecProxyPort = 2152
uecProxyIp = {  -- IPHY ip
    "10.34.166.101",
    "10.34.166.102"
}

-- IPs must be set at workstation
-- set all the addresses, in test configuration tell how many should be used (simmode_params['nbr_of_sgw'])
SGW_IP = {
    "10.253.152.".._TL_ID_,
    "10.253.154.".._TL_ID_,
    "10.253.155.".._TL_ID_,
}
