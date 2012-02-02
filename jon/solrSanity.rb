#!/usr/bin/ruby
#
# Columns are
#
# idxAct     number of active indexing threads
# inSock     number of 0MQ sockets indexers are reading from
#
# migQd      number of queued migration requests
# migAct     number of migrator threads currently active
# migOK      number of migrations that have completed successfully
# migBad     number of migrations that have completed with some kind of failure
#
# chlQd
#  ...       same as above, but for Chill threads (merging)
# chlBad
#
# load       load average of the machine
# threads    number of active threads in the app
#
# sAwake     number of shards that are AWAKE
# sSleep     number of shards that are asleep
#
# freeM      MBytes of RAM allocated but not used in JVM
# totM       MBytes of RAM allocated in JVM
# maxM       Maximum MBytes of RAM available to JVM
# usedM      MBytes of RAM in use by JVM
#
# latency    milliseconds latency to service action=SANITY request
#
# version    beSolr/solrserver version number
# uptime     how long has solrserver been running?
#

require 'rubygems'
require 'json'
require 'net/http'
require 'uri'

class WTF
  @@solr = Array.new()
  @@fullHost = Hash.new()

  def showSanity()
    sUrl = '/solr/admin/cores?action=sanity'
    labels = [ 'idxAct', 'inSock', 'migQd', 'migAct', 'migOK', 'migBad', 'chlQd', 'chlAct', 'chlOK', 'chlBad', 'load', 'threads', 'sAwake', 'sSleep', 'freeM', 'totM', 'maxM', 'usedM', 'latency', 'version', "\tuptime"]
    puts "#{'%-30s'%'Host'}\t#{labels.join("\t")}"
    @@solr.each do |host|

      begin 
        t1 = Time.now
        res = Net::HTTP.get(@@fullHost[host], sUrl, 8983)
        t2 = Time.now
        latency = ((t2 - t1)*1000).floor
      rescue Exception => ex
        puts "ERROR:\tFailed to get data from #{host}"
        next
      end
      begin
        sj = JSON.parse(res)
      rescue Exception => ex
        puts "ERROR\tFailed to parse data from #{host}"
        next
      end
      sd = sj['sanity']

      stats = Array.new()

      if (sd['indexers'])
        stats.push(sd['indexers']['active'] || 0)
        stats.push(sd['indexers']['insocks'] || 0)
      else
        stats.push(0)
        stats.push(0)
      end

      addCounts(sd, 'MIGRATOR', stats)
      addCounts(sd, 'CHILLER', stats)
      
      stats.push(sd['system']['systemLoadAverage'])
      stats.push(sd['threads']['active'])

      stats.push(sd['shards']['live'])
      stats.push(sd['shards']['sleeping'])

      stats.push(sd['ram']['freeMB'])
      stats.push(sd['ram']['totalMB'])
      stats.push(sd['ram']['maxMB'])
      stats.push(sd['ram']['usedMB'])

      stats.push(latency)
      stats.push(sd['app']['version'])  

      alive = sd['app']['uptimeMillis']
      if (alive < 1000) 
        stats.push('         <1s');
      elsif (alive < 60000)
        s = alive/1000
        stats.push("         #{'%2d'%s}s")
      elsif (alive < 3600000) 
        m = alive/60000
        s = alive/1000 - (m*60)
        stats.push("      #{'%02d'%m}m#{'%02d'%s}s")
      else
        h = alive/3600000
        m = (alive % 3600000) / 60000
        if (h > 24)
          d = h/24
          h = h - d*24
          stats.push("#{'%2d'%d}d#{'%02d'%h}h#{'%02d'%m}m")
        else
          stats.push("   #{'%2d'%h}h#{'%02d'%m}m")
        end
      end


      puts "#{'%-30s'%@@fullHost[host]}\t#{stats.join("\t")}"
    end # indexer
  end # def

    def addCounts(sd, role, stats)
      if (sd[role])
        md = sd[role]
        ['queued', 'active', 'success', 'fail'].each do |c|
          cd = md[c]
          if (cd)
            begin
              stats.push(cd['cnt'])
            rescue Exception => ex
              stats.push(0)
            end
          else
            stats.push(0)
          end
        end
      else
        stats.push(0)
        stats.push(0)
        stats.push(0)
        stats.push(0)
      end
    end


  def getTruth()
    fName = '/etc/truth.json'
    File.open(fName, "r") do |file|
      sj = JSON.parse(file.read)
      sj['servers'].each do |s|
        if (sj['deployment'])
          @@fullHost[s[0]] = s[0] + '.' + sj['deployment'] + '.loggly.net'
        else
          @@fullHost[s[0]] = s[0]
        end
        s[1]['tags'].each do |t|
          if t == 'role:solr=true'
            @@solr.push(s[0])
          end
        end
      end
    end
    @@solr.sort!
  end
end  

wtf = WTF.new()
wtf.getTruth()
wtf.showSanity()
