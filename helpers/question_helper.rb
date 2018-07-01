def find_user(id)
		user_email = User.find(answer.user_id).email
		username = user_email.gsub(/[A-Za-z0-9]+@/,"")
		username
end