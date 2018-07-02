

	def current_user

		if session[:user_id] != nil
			@current_user = session[:username]
			true
		else
			false
		end
	end

	

