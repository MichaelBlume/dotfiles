#!/usr/bin/ruby
#
# check the local solrserver, and bounce it if it is non-responsive and 
# has been running for more than some minimum amount of time (@minRunSecs)
#
require "rubygems"
require "json"
require "timeout"
require "socket"
require "net/http"
require "net/https"
require "uri"
require "date"


#==================== Log some JSON to hoover ====================
#
def log_to_loggly(msg)
  msg['hostname'] = Socket.gethostname
  
  # log to kiwi.loggly.com, input bounce_solr
  uri = URI.parse('https://logs.loggly.com/inputs/f7931796-e3b2-4dd1-8c83-1401176da256');

  http = Net::HTTP.new(uri.host, uri.port)
  http.use_ssl = true
  http.verify_mode = OpenSSL::SSL::VERIFY_NONE

  request = Net::HTTP::Post.new(uri.request_uri)
  request.set_form_data(msg)
  if (msg['level'] != 'info')
    puts "#{Time.now().strftime('%F %T')} #{msg}"
  end

  res = http.request(request)
end


#==================== Is localhost solrserver boken? ====================
#
def is_broken(timeout_secs)
  uri = URI.parse("http://localhost:8983/solr/admin/cores?action=version")
  request = Net::HTTP::Get.new("#{uri.path}?#{uri.query}")
  
  # default to NOT being broken, just to be safe
  ret = false
  
  begin 
    Timeout.timeout(timeout_secs) do
      start = Time.now
      response = Net::HTTP.start(uri.host, uri.port) do |http|
        http.request(request)
      end # Net::HTTP.start
      duration = Time.now - start
      log_to_loggly('level' => 'info', 'msg' => "ok", 'duration' => duration, 'timoutSecs' => timeout_secs, 'needBounce' => false)
    end # Timeout
  rescue Timeout::Error => e
    log_to_loggly('level' => 'error', 'msg' => "Timeout while fetching #{uri}")
    ret = true
  rescue => e
    log_to_loggly('level' => 'error', 'msg' => "Unexpected exception while fetching #{uri}: #{e}")
    ret = true
  end
  return ret
end

#==================== Is solrserver bouncable? ====================
#
def pid_to_bounce(min_run_secs)
  ss = `supervisorctl status loggly-solrserver`
  pid = ss.scan(/.*pid (\d+),.*/)
  
  ps = `ps --no-heading -o etime #{pid}`
  etimes = ps.split(/:/)
  el = etimes.length
  msg = {'pid' => pid, 'ps' => ps, 'needBounce' => true, 'level' => 'warn'}

  # default to NOT being bouncable, just to be safe
  ret = nil

  if (el > 2)
    # ps returns a time that is one of DD-HH:MM:SS, HH:MM:SS, or MM:SS, so if we split
    # on colon and find more than 2 segments, we must be using the 1st or 2nd of these
    # which means we've been running at least one hour
    #
    msg['msg'] = "SolrServer runtime > 1 hour"
    ret = pid
  else 
    runtime_secs = etimes[el-1].to_i + etimes[el-2].to_i * 60
    msg['runtime'] = runtime_secs
    if runtime_secs > min_run_secs
      # solr has been alive long enough to know better
      msg['msg'] = "SolrServer runtime > minRunSecs (#{min_run_secs}) - safe to bounce"
      ret = pid
    else
      # solr hasn't been alive long enough to kill
      msg['msg'] = "SolrServer runtime <= minRunSecs (#{min_run_secs}) - not safe to bounce"
    end
  end
  log_to_loggly(msg)
  return ret
end

#==================== M A I N ====================
#

# how long is too long to wait for a response?
timeout_secs = 40

# never kill a solr that hasn't been running for at least this long (10 minutes)
min_run_secs = 10 * 60

if is_broken(timeout_secs)
  pid = pid_to_bounce(min_run_secs)
  if pid
    result = `kill #{pid} 2>&1`
    log_to_loggly('level' => 'info', 'msg' => "killed #{pid}", 'result' => result)
  end
end
