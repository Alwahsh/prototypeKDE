class CreateFbStats < ActiveRecord::Migration
  def change
    create_table :fb_stats do |t|
      t.integer :project_id
      t.text :posts

      t.timestamps
    end
  end
end
