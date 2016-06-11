class CreateTopologies < ActiveRecord::Migration
  def change
    create_table :topologies do |t|
      t.string :name
      t.integer :x
      t.integer :y

      t.timestamps null: true
    end
  end
end
