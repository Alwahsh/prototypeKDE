class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.string :name
      t.text :describtion
      t.text :bugLists
      t.text :gitRepositories
      t.text :mailLists
      t.text :ircChannels

      t.timestamps
    end
  end
end
