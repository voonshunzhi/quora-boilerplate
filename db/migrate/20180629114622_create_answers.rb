class CreateAnswers < ActiveRecord::Migration[5.0]
  def change
    # HINT: checkout ActiveRecord::Migration.create_table
    create_table :answers do |t|
   	  t.text :answer
   	  t.integer :vote, :default => 0
   	  t.belongs_to :user
      t.belongs_to :question
      t.timestamps
    end
  end
end