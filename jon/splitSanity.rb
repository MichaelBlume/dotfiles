#!/usr/bin/ruby
#
require 'rubygems'
require 'json'
require 'net/http'
require 'uri'

class WTF
  @@proxy = Array.new()
  @@fullHost = Hash.new()
  @@errors = Array.new()

  def showSanity()
    sUrl = '/admin?action=sanity'
    labels = ['rxAlive', 'lastRx', 'idxTx', 'idxTx0', 'idxTxN', 'load', 'threads', 'freeM', 'totM', 'maxM', 'usedM', 'latency', 'uptime']
    puts "#{'%-30s'%'Host'}\t#{labels.join("\t")}"
    @@proxy.each do |host|

      begin 
        t1 = Time.now
        res = Net::HTTP.get(@@fullHost[host], sUrl, 7983)
        t2 = Time.now
        latency = ((t2 - t1)*1000).floor
      rescue Exception => ex
        @@errors.push("Failed to get data from #{host}: #{ex}")
        next
      end

      begin
        sj = JSON.parse(res)
      rescue Exception => ex
        @@errors.push("Failed to parse data from #{host}: #{ex}")
        next
      end

      sd = sj['sanity']

      stats = Array.new()

      if (sd['readers']['UNKNOWN'])
        rx = sd['readers']['UNKNOWN']
        stats.push(rx['alive'])
        stats.push(rx['lastMsg'][0])
      else
        stats.push(0)
        stats.push(0)
      end
      
      if (sd['writers']['IDX'])
        idx = sd['writers']['IDX']
        idxCnt = idx['alive'].to_i
        stats.push(idxCnt)
        stats.push(idx['lastMsg'][0])
        stats.push(idx['lastMsg'][idxCnt-1])
      else
        stats.push(0)
        stats.push(0)
        stats.push(0)
      end
        
      stats.push(sd['system']['systemLoadAverage'])
      stats.push(sd['threads']['active'])

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
          if t == 'role:proxy=true'
            @@proxy.push(s[0])
          end
        end
      end
    end
    @@proxy.sort!
  end

  def showErrors()
    puts @@errors.join("\n")
  end

end  

wtf = WTF.new()
wtf.getTruth()
wtf.showSanity()
wtf.showErrors()
