class CreateStars < ActiveRecord::Migration
  def change
    create_table :stars, :force => true do |t|
      t.belongs_to :event
      t.belongs_to :person
      t.timestamps
    end
    
    add_index :stars, :event_id
    add_index :stars, :person_id
  end
end