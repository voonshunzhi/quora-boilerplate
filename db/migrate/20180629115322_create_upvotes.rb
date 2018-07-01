class CreateUpvotes < ActiveRecord::Migration[5.0]
  def change
    # HINT: checkout ActiveRecord::Migration.create_table
    create_table :upvotes do |t|
   	  t.belongs_to :answer
      t.belongs_to :user
      t.timestamps
    end
  end
end