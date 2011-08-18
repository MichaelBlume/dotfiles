#!/usr/bin/ruby
#
require 'rubygems'
require 'json'
require 'net/http'
require 'uri'

class WTF
  @@indexer = Array.new()
  @@proxy = Array.new()
  @@fullHost = Hash.new()
  
  def showSolr()
    puts "========== SOLR =========="
    puts "\t#{'%15s' % 'events'}\t#{'%15s' % 'bytes'}\t#{'%7s'%'eps'}\t#{'%7s'%'Bps'}\tlastMsg"

    sUrl = '/solr/admin/cores?action=active&span=multiinterval&details=insocks'
    
    tot = Hash.new()
    
    @@indexer.each do |host|
      begin 
        res = Net::HTTP.get(@@fullHost[host], sUrl, 8983)
      rescue Exception => ex
        puts "ERROR:\tFailed to get data from #{host}: #{ex}"
        next
      end

      sj = JSON.parse(res)

      warns = Array.new()
      t = { 'events' => 0, 'bytes' => 0, 'lastmsg' => Array.new() }
      
      sj['insocks'].each do |p|
        next if p[0] == 'TOTAL'
        pName = "In" + p[0].gsub(/.*\/\/proxy/, 'Prx').gsub(/\..*/, '')
        if p[1]['lastmsg'] > 10000
          warns.push("WARN:\tLast message sent #{p[1]['lastmsg']}ms ago from #{pName} to #{host}")
        end
        m = p[1]['metrics']['MultiInterval']
        if !tot.has_key?(pName)
          tot[pName] = {'events' => 0, 'bytes' => 0, 'lastmsg' => Array.new()}
        end
        
        if m['Events'] and m['Events']['cnt'] > 0
          t['lastmsg'].push(p[1]['lastmsg'])
          t['events'] += m['Events']['cnt']
          tot[pName]['events'] += m['Events']['cnt']
          t['bytes'] += m['Bytes']['cnt']
          tot[pName]['bytes'] += m['Bytes']['cnt']
        end
      end      
      tot["Idx" + host.gsub(/solr/,'').gsub(/-/,'')] = t
    end
    
    tEvents = tBytes = 0
    tot.keys.sort.each() do |k|
      next if k.start_with?('Idx')
      t = tot[k]
      puts "#{k}\t#{'%15d' % t['events']}\t#{'%15d' % t['bytes']}\t#{'%7d' % (t['events']/60)}\t#{'%7d' % (t['bytes']/60)}\t#{t['lastmsg'].sort.join(',')}"
      tEvents += t['events']
      tBytes += t['bytes']
    end
    puts "InTOT\t#{'%15d' % tEvents}\t#{'%15d' % tBytes}\t#{'%7d' % (tEvents/60)}\t#{'%7d' % (tBytes/60)}"
    puts
    tEvents = tBytes = 0
    tot.keys.sort.each() do |k|
      next if k.start_with?('In')
      t = tot[k]
      puts "#{k}\t#{'%15d' % t['events']}\t#{'%15d' % t['bytes']}\t#{'%7d' % (t['events']/60)}\t#{'%7d' % (t['bytes']/60)}\t#{t['lastmsg'].sort.join(',')}"
      tEvents += t['events']
      tBytes += t['bytes']
    end
    puts "IdxTOT\t#{'%15d' % tEvents}\t#{'%15d' % tBytes}\t#{'%7d' % (tEvents/60)}\t#{'%7d' % (tBytes/60)}"
    

  end

  def showSplitter()
    puts "========== SPLITTER =========="
    puts "\t#{'%15s' % 'events'}\t#{'%15s' % 'bytes'}\t#{'%7s'%'eps'}\t#{'%7s'%'Bps'}\tlastMsg"
    
    sUrl = '/admin?action=status&details=on&span=multiinterval'

    tot = Hash.new()
    warns = Array.new()

    tEvents = tBytes = 0
    @@proxy.each do |host|
      begin 
        res = Net::HTTP.get(@@fullHost[host], sUrl, 7983)
      rescue Exception => ex
        puts "ERROR:\tFailed to get data from #{host}: #{ex}"
        next
      end

      #GAH! fix broken JSON for "mode":
      res.gsub!(/PIPELINE/, '"PIPELINE"')
      res.gsub!(/PUBSUB/, '"PUBSUB"')
      
      #GAH! remove broken JSON for "connection":
      res.gsub!(/"connection".*\]\]",/ , "")

      sj = JSON.parse(res)
      sIn = sj['insocks']['in.client']
      sOut = sj['outsocks']
      sIndexers = sj['indexers']

      tP = "In" + host.gsub(/proxy/, 'Prx')
      tot[tP] = Hash.new()
      tot[tP]['lastmsg'] = Array.new().push(sIn['lastmsg'])
      tot[tP]['qsize'] = Array.new().push(sIn['qsize'])
      tot[tP]['events'] = sIn['metrics']['MultiInterval']['Events']['cnt']
      tot[tP]['bytes'] = sIn['metrics']['MultiInterval']['Bytes']['cnt']

      sOut.each do |out|
        if (out[0].include?('IDX'))
          s = out[0].gsub(/auto_out_/, '').gsub(/\..*/, '').gsub(/solr/, 'Out').gsub(/-/, '')
          if !tot.has_key?(s)
            tot[s] = Hash.new()
            tot[s]['lastmsg'] = Array.new()
            tot[s]['qsize'] = Array.new()
            tot[s]['events'] = 0;
            tot[s]['bytes'] = 0
          end
          tot[s]['lastmsg'].push(out[1]['lastmsg'])
          if (out[1]['lastmsg'] > 10000)
            warns.push("WARN:\tLast Message sent #{out[1]['lastmsg']}ms ago from #{host} to #{out[0]}")
          end
          tot[s]['qsize'].push(out[1]['qsize'])
          tot[s]['events'] += out[1]['metrics']['MultiInterval']['Events']['cnt']
          tot[s]['bytes'] += out[1]['metrics']['MultiInterval']['Bytes']['cnt']
        end
      end
      t = tot[tP]
      puts "#{tP}\t#{'%15d' % t['events']}\t#{'%15d' % t['bytes']}\t#{'%7d' % (t['events']/60)}\t#{'%7d' % (t['bytes']/60)}\t#{t['lastmsg'].join(',')}\t#{t['qsize'].join(',')}"
      tEvents +=  t['events']
      tBytes +=  t['bytes']
    end
    puts "InTOT\t#{'%15d' % tEvents}\t#{'%15d' % tBytes}\t#{'%7d' % (tEvents/60)}\t#{'%7d' % (tBytes/60)}"
    puts
    
    tEvents = tBytes = 0
    tot.keys.sort.each do |k|
      if k.start_with?("O")
        t = tot[k]
        puts "#{k}\t#{'%15d' % t['events']}\t#{'%15d' % t['bytes']}\t#{'%7d' % (t['events']/60)}\t#{'%7d' % (t['bytes']/60)}\t#{t['lastmsg'].sort.join(',')}\t#{t['qsize'].sort.join(',')}"
        tEvents +=  t['events']
        tBytes +=  t['bytes']
      end
    end
    puts "OutTOT\t#{'%15d' % tEvents}\t#{'%15d' % tBytes}\t#{'%7d' % (tEvents/60)}\t#{'%7d' % (tBytes/60)}"
    if (warns.length > 0) 
      puts "#{warns.join('\n')}"
    end
  end


  def showCollector()
    puts "========== COLLECTOR =========="
    puts "\t#{'%15s' % 'events'}\t#{'%15s' % 'bytes'}\t#{'%7s'%'eps'}\t#{'%7s'%'Bps'}"

    tot = Hash.new()
    
    cUrl = '/admin?action=status&span=multiinterval&details=outsocks'

    tEvents = tBytes = 0

    @@proxy.each do |host|
      begin
        res = Net::HTTP.get(@@fullHost[host], cUrl, 6983)
      rescue Exception => ex
        puts "ERROR:\tFailed to get data from #{host}: #{ex}"
        next
      end
      
      tot[host] = {'events' => 0, 'bytes' => 0, 'lastmsg' => Array.new()}
      
      #GAH! fix broken JSON for "mode":
      res.gsub!(/PIPELINE/, '"PIPELINE"')
      
      sj = JSON.parse(res)
      s = sj['outsocks']['out.splitter']
      tot[host]['lastmsg'].push(s['lastmsg'])
      m = s['metrics']['MultiInterval']
      if m['Events'] and m['Events']['cnt'] > 0
        tot[host]['events'] += m['Events']['cnt']
        tot[host]['bytes'] += m['Bytes']['cnt']
      end
      
      t = tot[host]
      puts "#{host}\t#{'%15d' % t['events']}\t#{'%15d' % t['bytes']}\t#{'%7d' % (t['events']/60)}\t#{'%7d' % (t['bytes']/60)}\t#{t['lastmsg']}"
      tEvents += t['events']
      tBytes += t['bytes']
      
      lastM = sj['outsocks']['out.splitter']['lastmsg']
      #puts "#{host} last sent msg to splitter #{lastM}ms ago"
      if (lastM > 10000)
        puts "WARN:\tLast Message sent #{lastM}ms ago from #{host} to splitter"
      end        
    end
    puts"OutTOT\t#{'%15d' % tEvents}\t#{'%15d' % tBytes}\t#{'%7d' % (tEvents/60)}\t#{'%7d' % (tBytes/60)}"

  end

  def getTruth
    fName = '/etc/truth.json'
    File.open(fName, "r") do |file|
      sj = JSON.parse(file.read)
      sj['servers'].each do |s|
        @@fullHost[s[0]] = s[0] + '.' + sj['deployment'] + '.loggly.net'
        isSolr = isIndexer = nil
        s[1]['tags'].each do |t|
          if t == 'role:proxy=true'
            @@proxy.push(s[0])
            puts "ADDING PROXY #{s[0]}"
          elsif t == 'role:solr=true'
            isSolr = 1
          elsif t.start_with?('solr:levels=0,')
            isIndexer = 1
          end
        end
        if (isSolr and isIndexer)
          @@indexer.push(s[0])
          puts "ADDING INDEXER #{s[0]}"
        end
      end
    end
    @@proxy.sort!
    @@indexer.sort!
  end
end  

  
span = ARGV[0]
wtf = WTF.new()
wtf.getTruth()
#wtf.showCollector()
wtf.showSplitter()
wtf.showSolr()

