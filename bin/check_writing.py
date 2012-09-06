#!/usr/bin/env python
import envoy
import requests
import time

r = envoy.run("find /Users/mike/Dropbox/writing | grep -v DS_Store | xargs wc -c | tail -n1")
count, total = r.std_out.split()
kb_written = int(count) // 1024
print kb_written

url = "https://www.beeminder.com/api/v1/users/mblume/goals/writing/datapoints.json"
r = requests.post(url,
        {'auth_token':'qiqScsHpQmRrSMKDsM1e'
        ,'timestamp':time.time()
        ,'value': kb_written
        })
print r.text
