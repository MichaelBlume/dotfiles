#!/usr/bin/ruby
#
require 'rubygems'
require 'json'
require 'net/http'
require 'uri'
require 'time'

class WTF
  @@indexer = Array.new()
  @@proxy = Array.new()
  @@fullHost = Hash.new()
  @@cid = -1
  
  def showSize() 
    puts "========== SHARDS =========="
    sUrl = '/solr/admin/cores?action=size&details=on&distrib=on&cid=-1.' + @@cid
    puts "Start\t\tEnd\t\t#{'%-15s'%'Node'}\tLevel\t#{'%15s' % 'events'}\t#{'%15s' % 'bytes'}"

    begin 
      res = Net::HTTP.get(@@fullHost[@@indexer[0]], sUrl, 8983)
    rescue Exception => ex
      puts "ERROR:\tFailed to get sizedata #{@@indexer[0]}: #{ex}"
      next
    end
    
    shards = Hash.new()
    sj = JSON.parse(res)
    sj['collections'].each do |c|
      next if c[0] != @@cid
      c[1]['nodes'].each do |n|
        nn = n[0].gsub(/\..*/, '')
        n[1]['shards'].each do |s|
          p = s[0].split('-')
          sn = p[0] + '-' + p[1] + '-' + p[2]
          shards[sn + '@' + nn] = {'bytes' => s[1]['bytes'], 'lvl' => s[1]['lvl'], 'docs' => s[1]['docs'], 'node' => nn , 'cid' => p[0], 'start' => p[1], 'end' => p[2], 'name' => s[0]}
        end # s
      end # n
    end # c

    container = Hash.new()
    contained = Hash.new()
    shards.keys.sort.each do |sn1|
      s1 = shards[sn1]
      shards.keys.sort.each do |sn2|
        s2 = shards[sn2]
        if (s2['start'] >= s1['start'] && s2['end'] <= s1['end'] && (s2['start'] != s1['start'] || s2['end'] != s1['end']))
          if (!container[sn1])
            container[sn1] = Array.new()
          end
          container[sn1].push(sn2)
          contained[sn2] = 1
        end
      end # sn2
    end # sn1

    prevEnd = nil
    shards.keys.sort.each do |sn|
      if (!contained[sn])        
        if (prevEnd && shards[sn]['start'] > prevEnd)
          snParts = sn.split("-")
          puts "\n#{prevEnd}\t#{shards[sn]['start']}\t********** MISSING **********\t\t\t\t#{snParts[0]}-#{prevEnd}-#{shards[sn]['start']}\n\n"
        end
        dumpShard(sn, shards, container, "")
        prevEnd = shards[sn]['end']
      end
    end # sn
  end

  def dumpShard(sn, shards, container, prefix)
    s = shards[sn]
    puts "#{s['start']}\t#{s['end']}\t#{'%-15s'%s['node']}\t#{s['lvl']}\t#{'%15d'%s['docs']}\t#{'%15d'%s['bytes']}\t#{prefix}#{s['name']}"
    if (container[sn])
      container[sn].each do |sn1|
        dumpShard(sn1, shards, container, prefix + "    ")
      end
    end
  end


  def showSolr()
    puts "========== SOLR =========="
    puts "#{'%-15s'%'Host'}\t#{'%-15s'%'cid'}\t\t#{'%15s' % 'events'}\t#{'%15s' % 'bytes'}\t#{'%7s'%'eps'}\t#{'%7s'%'Bps'}\tlast"

    sUrl = '/solr/admin/cores?action=active&span=multiinterval&details=collections&cid=-1.' + @@cid
    
    warns = Array.new()
    tEvents = tBytes = 0
    
    @@indexer.each do |host|
      begin 
        res = Net::HTTP.get(@@fullHost[host], sUrl, 8983)
      rescue Exception => ex
        puts "ERROR:\tFailed to get data from #{host}: #{ex}"
        next
      end

      sj = JSON.parse(res)

      
      sj['collections'].each do |c|
        next if c[0] == 'TOTAL'
        next if c[0] != @@cid
        c[1].each do |f|
          m = f[1]['metrics']['MultiInterval']
          ['Put', 'Get'].each do |d|
            l = f[1]['Last' + d]
            
            if l && l > 10000
              warns.push("WARN:\tLast #{d} #{l}ms ago")
            end
            if (m[d+'Msgs'] and m[d+'Msgs']['cnt'] > 0)
              e = m[d+'Msgs']['cnt']
              b = m[d+'Bytes']['cnt']
              puts "#{'%-15s'%host}\t#{'%-15s'%f[0]}\t#{d}\t#{'%15d' % e}\t#{'%15d' % b}\t#{'%7d' % (e/60)}\t#{'%7d' % (b/60)}\t#{l}ms"
              if (d == 'Put')
                tEvents += e
                tBytes += b
              end # add to totals
            end # puts
          end # d
        end # f
      end # c
    end # indexer
    puts"TOT\t\t\t\t\t#{'%15d' % tEvents}\t#{'%15d' % tBytes}\t#{'%7d' % (tEvents/60)}\t#{'%7d' % (tBytes/60)}"

    if (warns.length > 0) 
      puts "#{warns.join("\n")}"
    end
  end

 

  def showCollector()
    puts "========== COLLECTOR =========="
    puts "#{'%-15s'%'Host'}\t#{'%-15s'%'cid'}\tinId\t#{'%15s' % 'events'}\t#{'%15s' % 'bytes'}\t#{'%7s'%'eps'}\t#{'%7s'%'Bps'}\tinputname"

    tot = Hash.new()
    
    cUrl = '/admin?action=status&span=multiinterval&details=on&cid=-1.' + @@cid

    tEvents = tBytes = 0

    @@proxy.each do |host|
      begin
        res = Net::HTTP.get(@@fullHost[host], cUrl, 6983)
      rescue Exception => ex
        puts "ERROR:\tFailed to get data from #{host}: #{ex}"
        next
      end
      
      tot[host] = {'events' => 0, 'bytes' => 0, 'inputs' => Array.new() }
      
      sj = JSON.parse(res)
      sj['readers'].each do |c|
        next if c[0] == 'TOTAL'
        next if c[0] != @@cid
        c[1].each do |f|
          f[1].each do |i|
            m = i['metrics']['MultiInterval']
            if (m['Queued'] and m['Queued']['cnt'] and  m['Queued']['cnt']  > 0) 
              e = m['Queued']['cnt']
              tEvents += e
              b = m['Text']['cnt']
              tBytes += b
              puts "#{'%-15s'%host}\t#{'%-15s'%f[0]}\t#{i['inputid']}\t#{'%15d' % e}\t#{'%15d' % b}\t#{'%7d' % (e/60)}\t#{'%7d' % (b/60)}\t#{i['inputname']}"
            end
          end
        end
      end        
    end
    puts"TOT\t\t\t\t\t#{'%15d' % tEvents}\t#{'%15d' % tBytes}\t#{'%7d' % (tEvents/60)}\t#{'%7d' % (tBytes/60)}"


  end

  def getTruth()
    fName = '/etc/truth.json'
    File.open(fName, "r") do |file|
      sj = JSON.parse(file.read)
      sj['servers'].each do |s|
        @@fullHost[s[0]] = s[0] + '.' + sj['deployment'] + '.loggly.net'
        isSolr = isIndexer = nil
        s[1]['tags'].each do |t|
          if t == 'role:proxy=true'
            @@proxy.push(s[0])
#            puts "ADDING PROXY #{s[0]}"
          elsif t == 'role:solr=true'
            isSolr = 1
          elsif t.start_with?('solr:levels=0,')
            isIndexer = 1
          end
        end
        if (isSolr and isIndexer)
          @@indexer.push(s[0])
#          puts "ADDING INDEXER #{s[0]}"
        end
      end
    end
    @@proxy.sort!
    @@indexer.sort!
  end

  def setCid(c)
    if (c.index('.') == nil)
      @@cid = c
    else
      abort("Customer id MUST be just the is - no tier or retention days")
    end
  end
    
  def showTime()
    now = Time.new()
    puts now
  end

end  

if (ARGV.length != 1) 
  abort("Usage: #{$0} {customerId}")
end

wtf = WTF.new()
wtf.setCid(ARGV[0])
wtf.getTruth()
wtf.showTime()
wtf.showCollector()
wtf.showSolr()
wtf.showSize()

