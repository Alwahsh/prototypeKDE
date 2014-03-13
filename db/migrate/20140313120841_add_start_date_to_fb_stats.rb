class AddStartDateToFbStats < ActiveRecord::Migration
  def change
    add_column :fb_stats, :start_date, :string
  end
end
