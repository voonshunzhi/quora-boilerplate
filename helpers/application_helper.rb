

	def current_user

		if session[:user_id] != nil
			true
		else
			false
		end
	end

	

