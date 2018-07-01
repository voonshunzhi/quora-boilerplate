class Upvote < ActiveRecord::Base
	belongs_to :user
	belongs_to :answer

	def self.find_number_of_votes(answer_id)
		num_of_votes = where(answer_id:answer_id).count
	end
end