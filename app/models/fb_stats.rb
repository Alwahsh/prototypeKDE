class FbStats < ActiveRecord::Base
  attr_accessible :posts, :project_id, :start_date, :forum_stats, :forum_start_date 
end
