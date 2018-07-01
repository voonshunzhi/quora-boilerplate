require_relative './config/init.rb'
set :run, true
enable :sessions


get '/' do
  erb :"home"
end

#SignUp==============================================
get '/sign_up' do
	@current_user = 'sign_up'
  erb :"sign_up"
end

post '/sign_up' do
	@error = []
	@email = params[:user][:email].gsub(/\s+/,"")
	@password = params[:user][:password]
	@confirm_password = params[:user][:confirmPassword]
	if @password != @confirm_password
		@error << "Password do not match"
		erb :"sign_up"
	else

		val = User.where(email:@email)
		if val.length != 0
			@error << "Email is already in use . Please try again."
			erb :"sign_up"
		else
				user = User.new(email: @email, password: @password, password_confirmation: @password)
				user.save
				if user.errors.any?
					@errors_array = user.errors
					erb :"sign_up"
				else
					redirect '/log_in'
				end
		end
	
	end
	
end


#LogIn===============================================
get '/log_in' do
	@current_user = 'log_in'
	if session[:username].nil? && session[:user_id].nil?
		erb :'log_in'
	else
		redirect '/profile/#{session[:username]}'
	end
end

post '/log_in' do

	@email = params[:login][:email].gsub(/\s+/,"")
	@password = params[:login][:password]

	if user = User.find_by(email:@email).try(:authenticate, @password)
		session[:user_id] = user.id
		session[:username] = user.email.scan(/[A-Za-z0-9]+@/).first[0..-2]
		redirect "/profile/#{session[:username]}"
	else
		@error = []
		@error << "Password or email is incorrect.Try again"
		erb :'log_in'
	end
end


#Profile=============================================
get '/profile/:username' do
	if params.has_key?(:username)

		username = params[:username]

		if !session[:username].nil? && !session[:user_id].nil?
			if session[:username] == username
				@questions = Question.all
				erb :'profile'
			end
		else
			redirect "/log_in"
		end
	else
		redirect "/log_in"
	end
end

post '/profile/:username' do
		username = params[:username]
			if session[:username] == username
				question = params[:question][:content]
				ask_id = session[:user_id]
				question = Question.new(question:question,user_id:ask_id)
				question.save
				@questions = Question.all
				erb :'profile'
			else
				redirect "/log_in"
			end
	
end

#Questions===========================================
get '/questions/:question_id' do
		if !session[:username].nil? && !session[:user_id].nil?
			question_id = params[:question_id]
			@question = Question.find(question_id)
			@answer = Answer.where(question_id:question_id).order(vote: :desc)
			erb :'question'
		else
			redirect "/log_in"
		end
end

post '/questions/:question_id' do
	answer = params[:question][:answer]
	ans_id = session[:user_id]
	question_id = params[:question_id]
	ans = Answer.new(answer:answer,user_id:ans_id,question_id:question_id)
	ans.save
	redirect "/questions/#{question_id}" 
end


#Upvotes======================================================
get '/upvotes/:question_id/:ans_id' do
	if !session[:username].nil? && !session[:user_id].nil?
			question_id = params[:question_id]
			ans_id = params[:ans_id]
			user_id = session[:user_id]
			found = Upvote.where(user_id:user_id,answer_id:ans_id).count

			if found == 0
				uv = Upvote.new(user_id:user_id,answer_id:ans_id)
				uv.save
				answer_votes = Answer.find(ans_id.to_i)
				answer_votes.update(vote:answer_votes.vote + 1)
				redirect "/questions/#{question_id}"
			else
				redirect "/questions/#{question_id}"
			end
	else
		redirect "/log_in"
	end
	
end
#Downvote=====================================================
get '/downvotes/:question_id/:ans_id' do
	if !session[:username].nil? && !session[:user_id].nil?
		question_id = params[:question_id]
		ans_id = params[:ans_id]
		user_id = session[:user_id]
		found = Downvote.where(user_id:user_id,answer_id:ans_id).count

		if found == 0
			uv = Downvote.new(user_id:user_id,answer_id:ans_id)
			uv.save
			uv = Upvote.find_by(user_id:user_id,answer_id:ans_id)
			uv.delete
			answer_votes = Answer.find(ans_id.to_i)
			answer_votes.update(vote:answer_votes.vote - 1)
			redirect "/questions/#{question_id}"
		else
			redirect "/questions/#{question_id}"
		end
	else
		redirect "/log_in"
	end
	
end
#Logout========================================================
get '/logout' do
	session[:username] = nil
	session[:user_id] = nil
	redirect '/'
end





