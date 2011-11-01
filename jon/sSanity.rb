#!/usr/bin/ruby
#
require 'rubygems'
require 'json'
require 'net/http'
require 'uri'

class WTF
  @@solr = Array.new()
  @@fullHost = Hash.new()

  def showQSize()
    sUrl = '/solr/admin/cores?action=sanity'
    labels = [ 'mQueued', 'mActive', 'mDone', 'mFail', 'load', 'threads', 'sAwake', 'sSleep', 'idxers', 'freeM', 'totM', 'maxM', 'usedM', 'latency', 'uptime']
    puts "#{'%-30s'%'Host'}\t#{labels.join("\t")}"
    @@solr.each do |host|

      begin 
        t1 = Time.now
        res = Net::HTTP.get(@@fullHost[host], sUrl, 8983)
        t2 = Time.now
        latency = ((t2 - t1)*1000).floor
      rescue Exception => ex
        puts "ERROR:\tFailed to get data from #{host}: #{ex}"
        next
      end
      sj = JSON.parse(res)
      sd = sj['sanity']

      stats = Array.new()
      if (sd['migrations'])
        stats.push(sd['migrations']['numQueued'] || 0)
        stats.push(sd['migrations']['numActive'] || 0)
        stats.push(sd['migrations']['succeeded']['completed'] || 0)
        stats.push(sd['migrations']['failed']['completed'] || 0)
      else
        stats.push(0)
        stats.push(0)
        stats.push(0)
        stats.push(0)
      end
      
      stats.push(sd['system']['systemLoadAverage'])
      stats.push(sd['threads']['active'])

      stats.push(sd['shards']['live'])
      stats.push(sd['shards']['sleeping'])

      if (sd['indexers']) 
        stats.push(sd['indexers']['active'])
      else
        stats.push(0)
      end
      
      stats.push(sd['ram']['freeMB'])
      stats.push(sd['ram']['totalMB'])
      stats.push(sd['ram']['maxMB'])
      stats.push(sd['ram']['usedMB'])

      stats.push(latency)

      alive = sd['app']['uptimeMillis']
      if (alive < 1000) 
        stats.push('< 1sec');
      elsif (alive < 60000)
        stats.push((alive/1000).to_s + "s")
      elsif (alive < 3600000) 
        stats.push((alive/60000).to_s + "m")
      else
        h = alive/3600000
        m = (alive % 3600000) / 60000
        if (h > 24)
          d = h/24
          h = h - d*24
          stats.push(d.to_s + "d " + h.to_s + "h " + m.to_s + "m")
        else
          stats.push(h.to_s + "h " + m.to_s + "m")
        end
      end
  
      puts "#{'%-30s'%@@fullHost[host]}\t#{stats.join("\t")}"
    end # indexer
  end # def

  def getTruth()
    fName = '/etc/truth.json'
    File.open(fName, "r") do |file|
      sj = JSON.parse(file.read)
      sj['servers'].each do |s|
        @@fullHost[s[0]] = s[0] + '.' + sj['deployment'] + '.loggly.net'
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
wtf.showQSize()
