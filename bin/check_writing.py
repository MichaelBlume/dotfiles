#!/usr/bin/env python
import envoy

r = envoy.run("find /home/mike/Dropbox/writing | xargs wc --bytes | tail -n1")
nothing, count, total = r.std_out.split(' ')
print int(count) // 1024

