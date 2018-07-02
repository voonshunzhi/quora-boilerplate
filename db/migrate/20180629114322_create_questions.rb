class CreateQuestions < ActiveRecord::Migration[5.0]
  def change
    # HINT: checkout ActiveRecord::Migration.create_table
    create_table :questions do |t|
   	  t.text :question
   	  t.integer :view,default:0
   	  t.belongs_to :user
      t.timestamps
    end
  end
end