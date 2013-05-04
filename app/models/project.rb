require 'open-uri'
require 'feedzirra'
require 'git'

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


def count_bugs
  is_successful = search_bugzilla []
  if is_successful
    num = is_successful.length
    Rails.cache.write('numBugs'+id.to_s , [num,Time.now])
    return true
  end
  return false
end


def search_git product_name
  full_string = "http://quickgit.kde.org/?p="
  full_string += product_name.chomp
  full_string += "&a=atom"
  feed = Feedzirra::Feed.fetch_and_parse(full_string)
  return [] unless feed
  unless Rails.cache.read("last_commit"+id.to_s)
    Rails.cache.write("last_commit"+id.to_s,[feed.entries.first.id,feed.last_modified])
  else
    Rails.cache.write("last_commit"+id.to_s,[feed.entries.first.id,feed.last_modified]) if feed.last_modified > Rails.cache.read("last_commit"+id.to_s)[1]
  end
  return feed.entries
end

def search_commits limit = nil
  begin
  the_array = get_array(gitRepositories)
  rescue Exception
    return nil
  end
  commits = []
  the_array.each { |product|
    begin
      g = Git.bare('.', { :repository => 'gitMirror/' + product ,:index => '.' })
      g.log(limit).each { |commit|
	commits << commit
    }
    rescue Exception
    end
  }
  return commits
end

class Project < ActiveRecord::Base
  attr_accessible :bugLists, :describtion, :gitRepositories, :ircChannels, :mailLists, :name
  
  def test_git
    commits = []
    the_array = get_array(gitRepositories)
    the_array.each { |product|
      entries = search_git product
      entries.each { |entry|
	commits << entry
      }
    }
    return commits
  end
  
  def fetch_project_repos 
    the_array = get_array(gitRepositories)
    the_array.each { |product|
      g = Git.clone('git://anongit.kde.org/'+product.chomp, 'gitMirror/' + product.chomp, :bare => true)
      #add rescue
    }
  end
  handle_asynchronously :fetch_project_repos
  
  def commits_per_author
    commits = Rails.cache.read("commits_per_author"+id.to_s)
    return commits if commits
    successful = search_commits
    return nil unless successful
    commits = Hash.new(0)
    successful.each do |commit|
      commits[commit.author.name] += 1
    end  
    Rails.cache.write("commits_per_author"+id.to_s,commits) unless commits.length == 0
    return commits
  end
  
  def array_repos
    return get_array(gitRepositories)
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
    
  # gets limited number of bugs but with all needed attributes.
  def limited_bugs offset, number = 10
    if !offset
      offset = 1
    end
    is_successful = search_bugzilla ["id","assigned_to","component","last_change_time","status","summary"],number,(offset.to_i-1)*10
    return is_successful if is_successful
    return []
  end
  
  def latest_bug 
    latest = Rails.cache.read("latest_bug"+id.to_s)
    return latest if latest
    successful = search_bugzilla ["id","creation_time"]
    last = successful[0]
    unless last 
      Rails.cache.write("latest_bug"+id.to_s,"")
      return ""
    end
    successful.each { |bug|
      if bug["creation_time"] > last["creation_time"]
	last = bug
      end
    }
    Rails.cache.write("latest_bug"+id.to_s,last)
    return last
  end
  
  def bugs_by_state
    bugs = Rails.cache.read("bugsFor"+id.to_s)
    return bugs[0] if bugs
    successful = search_bugzilla ["id","status"],0,0,true
    return nil unless successful
    bugs = Hash.new(0)
    successful.each do |bug|
      bugs[bug["status"]] += 1
      end  
      Rails.cache.write("bugsFor"+id.to_s,[bugs,Time.now])
    return bugs
  end
  
  def latest_commit
    latest = Rails.cache.read("last_commit"+id.to_s)
    return latest if latest
    return Rails.cache.read("last_commit"+id.to_s) if test_git != []
    return ["",""]
  end
  
end
