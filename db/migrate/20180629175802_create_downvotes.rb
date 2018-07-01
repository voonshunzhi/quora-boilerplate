class CreateDownvotes < ActiveRecord::Migration[5.0]
  def change
    # HINT: checkout ActiveRecord::Migration.create_table
    create_table :downvotes do |t|
   	  t.belongs_to :answer
      t.belongs_to :user
      t.timestamps
    end
  end
end