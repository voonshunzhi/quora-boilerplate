class User < ActiveRecord::Base
	has_many :questions
	has_many :answers
	has_many :votes
	has_secure_password
	validates :email ,presence:true, format:{ with: /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/,message: "Email is invalid"}

	def self.find_user(id)
		user = find(id)
		user.email.scan(/[a-zA-Z0-9]+@/).first[0..-2]
	end
end