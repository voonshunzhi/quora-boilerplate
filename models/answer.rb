class Answer < ActiveRecord::Base
	has_many :votes
	belongs_to :user
	belongs_to :question
end