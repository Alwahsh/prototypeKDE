class AddForumStatsToFbStats < ActiveRecord::Migration
  def change
    add_column :fb_stats, :forum_stats, :text
  end
end
