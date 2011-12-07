#!/usr/bin/ruby
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
    labels = [ 'idxAct', 'inSock', 'migMax', 'migPri', 'migQd', 'migAct', 'migOK', 'migBad', 'chlMax', 'chlPri', 'chlQd', 'chlAct', 'chlOK', 'chlBad', 'load', 'threads', 'sAwake', 'sSleep', 'freeM', 'totM', 'maxM', 'usedM', 'latency', 'version', 'uptime']
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

    def addCounts(sd, role, stats)
      if (sd[role])
        md = sd[role]
        if (md['pool'])
          stats.push(md['pool']['max'] || 0)
          stats.push(md['pool']['priority'] || 0)
        else
          stats.push(0)
          stats.push(0)
        end
        
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
