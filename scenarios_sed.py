import json
import os
import time

with open('jason_scenarios.json', 'r') as f:
    json_obj = json.load(f)
print json_obj


for test_name in json_obj:
    print json_obj[test_name]
    command = r"sed -i 's/cells/ueCapabilities iphone7\n\t\tcells/' "+json_obj[test_name]
    os.system(command)
    time.sleep(1)





