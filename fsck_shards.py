from __future__ import division

import json
from operator import attrgetter
from datetime import datetime
from collections import defaultdict
import time

def overlapping_bytes(shard1, shard2):
    overlap_start = max(shard1.startTime, shard2.startTime)
    overlap_end = min(shard1.endTime, shard2.endTime)
    overlap_duration = overlap_end - overlap_start
    overlap_seconds = max(0, total_seconds(overlap_duration))
    return shard2.bytes * overlap_seconds / shard2.seconds

def total_seconds(td):
    return (td.microseconds + (td.seconds + td.days * 24 * 3600) * 10**6) / 10**6

class Shard():

    """
         "bytes":8484277853,
          "maxdocid":21323963,
          "deleted":0,
          "docs":21323963,
          "segments":1,
          "version":1326326880125,
          "lvl":4},
    """

    def __init__(self, shardStr, shardElements, server):
        if not shardStr:
            return

        self.name = shardStr
        self.cid, startDateStr, endDateStr, self.extratemp = shardStr.split('-', 3)
        if '_' in self.extratemp:
            _, self.extras = self.extratemp.split('_', 1)
        else:
            self.extras = ''

        self.server = server

        self.startTime = datetime.strptime(startDateStr, '%Y%m%d.%H%M')
        self.endTime = datetime.strptime(endDateStr, '%Y%m%d.%H%M')
        self.duration = self.endTime - self.startTime
        self.tier, self.customerId, self.retention = self.cid.split('.', 2)
        self.retention = int(self.retention)
        self.seconds = total_seconds(self.duration)

        self.bytes = 1
        self.docs = 1
        self.statedLevel = 0
        self.segments = 1

        # if this shard was only found in a zkdump, then it is not reachable.
        self.reachable = False

        # zkdump doesn't have shardElements
        if shardElements is not None:
            self.bytes = long(shardElements['bytes'])
            self.docs = long(shardElements['docs'])
            self.statedLevel = int(shardElements['lvl'])
            self.segments = int(shardElements['segments'])
            self.reachable = True

        self.level = -1
        self.alreadyMerged = False

        self.customerMonikers = [ "Paid", "Free" ]

    def isPaidCustomer(self):
        return self.retention > 7

    def getAllCustomerMonikers(self):
        return self.customerMonikers

    def getCustomerMoniker(self):
        return self.customerMonikers[0] if self.isPaidCustomer() else self.customerMonikers[1]

    def startUnixTime(self):
        return int(time.mktime(self.startTime.timetuple()))

    def endUnixTime(self):
        return int(time.mktime(self.endTime.timetuple()))

    def __str__(self):
        return "Level %d shard (was %d) %s - %s starts %s ends %s on server %s timespan %s bytes %d (%s)" % (
            self.level, self.statedLevel,
            self.name, self.cid, self.startTime, self.endTime,
            self.server, self.duration, self.bytes, self.extras )

    def sameShard(self, otherShard):
        return ((self.startTime, self.endTime, self.customerId) ==
                (otherShard.startTime, otherShard.endTime, otherShard.customerId))

pd = json.loads(open('prod-size.json', 'r').read())
p2d = json.loads(open('prod2-size.json', 'r').read())

prod_custs = set(pd['collections'].keys())
prod2_custs = set(p2d['collections'].keys())

prod_missing = prod2_custs.difference(prod_custs)
prod2_missing = prod_custs.difference(prod2_custs)

total_bytes_missing = 0

collections_missing_data = defaultdict(lambda: 0)

for cust_id in prod_custs.intersection(prod2_custs):

    prod_shards = []
    for _, serverdata in pd['collections'][cust_id]['nodes'].items():
        for name, data in serverdata['shards'].items():
            if isinstance(data, basestring):
                continue
            prod_shards.append(Shard(name, data, None))
    prod_shards.sort(key=attrgetter('endTime'), reverse=True)
    prod_shards.sort(key=attrgetter('startTime'))

    prod2_shards = []
    for _, serverdata in p2d['collections'][cust_id]['nodes'].items():
        for name, data in serverdata['shards'].items():
            if isinstance(data, basestring):
                continue
            prod2_shards.append(Shard(name, data, None))
    prod2_shards.sort(key=attrgetter('endTime'), reverse=True)
    prod2_shards.sort(key=attrgetter('startTime'))

    p2index = 0
    previous_shard = None
    for shard in prod_shards:
        if shard.startTime < datetime(2012, 6, 28):
            continue
        if previous_shard is not None and previous_shard.endTime >= shard.endTime:
            continue
        previous_shard = shard
        bytes_in_prod2 = 0

        while True:
            try:
                prod2_shard = prod2_shards[p2index]
            except IndexError:
                break
            if prod2_shard.startTime > shard.endTime:
                break
            bytes_in_prod2 += overlapping_bytes(shard, prod2_shard)
            if prod2_shard.endTime > shard.endTime:
                break
            p2index += 1

        if bytes_in_prod2 < (shard.bytes * 0.9):
            print 'missing data!'
            print "prod has %d bytes, prod2 *appears* to have %d bytes" % (shard.bytes, bytes_in_prod2)
            print shard
            bytes_missing = int(shard.bytes - bytes_in_prod2)
            total_bytes_missing += bytes_missing
            collections_missing_data[cust_id] += bytes_missing

for cust_id in sorted(collections_missing_data.keys(),
        key=lambda x: collections_missing_data[x]):
    print "cust_id %s missing %d bytes" % (cust_id,
            collections_missing_data[cust_id])

print "looks like we're missing a total of %d gigs" % (total_bytes_missing //
                                                       (2 ** 30))
if prod_missing:
    print 'prod is missing customers, wtf'
    print prod_missing
