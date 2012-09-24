#!/usr/bin/env python
import envoy
import requests
import time

r = envoy.run("find /Users/mike/Dropbox/writing | grep -v DS_Store | xargs wc -c")
count = r.std_out.split()[-2]
kb_written = int(count) // 1024

url = "https://www.beeminder.com/api/v1/users/mblume/goals/writing/datapoints.json"
r = requests.post(url,
        {'auth_token':'qiqScsHpQmRrSMKDsM1e'
        ,'timestamp':time.time()
        ,'value': kb_written
        })
with open('/Users/mike/.logs/writing_outputs', 'a') as f:
    f.write(str(kb_written))
    f.write('\n')
    f.write(r.text)
    f.write('\n')
