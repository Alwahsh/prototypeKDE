class AddForumStartDateToFbStats < ActiveRecord::Migration
  def change
    add_column :fb_stats, :forum_start_date, :string
  end
end
