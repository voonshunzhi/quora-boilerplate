class CreateVotes < ActiveRecord::Migration[5.0]
  def change
    # HINT: checkout ActiveRecord::Migration.create_table
    create_table :votes do |t|
   	  t.belongs_to :answer
      t.belongs_to :user
      t.string :value, default:0
      t.timestamps
    end
  end
end