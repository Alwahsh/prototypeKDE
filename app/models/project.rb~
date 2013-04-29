require 'open-uri'
#require 'feedzirra'


def search_bugzilla include_fields,limit=0,offset=0,getAll=false,creation_time = nil
  full_string = 'https://bugs.kde.org/jsonrpc.cgi?method=Bug.search&params=[{"product":'+convert_array_to_string_array(get_array(bugLists))+',"include_fields":'+ convert_array_to_string_array(include_fields)
  full_string += ',"status":["UNCONFIRMED","CONFIRMED","ASSIGNED","REOPENED"]' if !getAll
  full_string += ',"limit":'+limit.to_s+',"offset":'+offset.to_s if limit != 0
  full_string += ',"creation_time":"'+ get_time_as_string(creation_time) +'"' if creation_time
  full_string += '}]'
  unparsed = open(URI::encode(full_string))
  parsed = ActiveSupport::JSON.decode(unparsed)
  return parsed["result"]["bugs"] if parsed["result"]
  Rails.cache.write "error", parsed["error"]
end

def get_time_as_string time
  return time.strftime("%Y-%m-%dT%H:%M:%SZ")
  time.year + '-' + time.month + '-' + time.mday + 'T' + time.hour + ':' + time.minute + ':' + time.second + 'Z'
end

def get_array text_to_parse
  return text_to_parse.split("\n")
end

def convert_array_to_string_array to_convert
  converted = "["
  to_convert.each do |element| 
    converted += '"' + element.chomp + '",'
  end
  return converted + "]" if converted.length == 1
  return converted[0..-2] + "]"
end

def fetch_bugs 
  is_successful = search_bugzilla ["id","status"],0,0,true
  if is_successful
    num = is_successful.length
    Rails.cache.write('bugsFor'+id.to_s , is_successful)
    return true
  end
  return false
end

def count_bugs
  is_successful = search_bugzilla []
  if is_successful
    num = is_successful.length
    Rails.cache.write('numBugs'+id.to_s , [num,Time.now])
    return true
  end
  return false
end

=begin
def search_git
  feed = Feedzirra::Feed.fetch_and_parse("http://quickgit.kde.org/?p=websites%2Fprojects-kde-org.git&a=atom")
  return feed.entries.first.id
end
=end

class Project < ActiveRecord::Base
  attr_accessible :bugLists, :describtion, :gitRepositories, :ircChannels, :mailLists, :name
  
  def test_git
    return search_git
  end
  
  def number_of_bugs
    num = Rails.cache.read('numBugs'+id.to_s)
    #if num
    #  return num[0] if search_bugzilla([],0,0,false,num[1]).length == 0
    #end
    return num[0] if num
    if count_bugs
      return Rails.cache.read('numBugs'+id.to_s)[0]
    end
    return "Not found."
  end
  
  # gets all bugs with status only.
  def all_bugs
    bugs = Rails.cache.read('bugsFor'+id.to_s)
      if !bugs
	if !fetch_bugs
	  return []
	end
      end
    return Rails.cache.read('bugsFor'+id.to_s)
  end
  
  # gets limited number of bugs but with all needed attributes.
  def limited_bugs offset, number = 10
    if !offset
      offset = 1
    end
    is_successful = search_bugzilla ["id","assigned_to","component","last_change_time","status","summary"],number,(offset.to_i-1)*10
    return is_successful if is_successful
    return []
  end
  
  def bugs_by_state
    bugs_hash = Hash.new()
    bugs = all_bugs
    bugs_hash["UNCONFIRMED"] = []
    bugs_hash["CONFIRMED"] = []
    bugs_hash["ASSIGNED"] = []
    bugs_hash["REOPENED"] = []
    bugs_hash["RESOLVED"] = []
    bugs_hash["NEEDSINFO"] = []
    bugs_hash["VERIFIED"] = []
    bugs_hash["CLOSED"] = []
    bugs.each do |bug|
      status = bug["status"]
      bugs_hash[status] << status
    end
    return bugs_hash
  end
    
  
end
