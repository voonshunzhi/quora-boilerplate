require_relative './config/init.rb'
set :run, true
enable :sessions


#Rootpath=============================================
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
		redirect "/profile/#{session[:username]}"
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
			@question.update(view:@question.view + 1)
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

#Edit Question================================================
get '/questions/edit/:question_id' do
	@edit_question = Question.find(params[:question_id])
	if @edit_question.user_id == session[:user_id]
		erb :'edit'
	else
		flash[:warning] = "You couldn't edit this question"
		redirect "/questions/#{params[:question_id]}"
	end
end

put '/questions/edit/:question_id' do
	question = Question.find(params[:question_id])
	if question.update_attributes(params[:edit])
		flash[:notice] = "Question successfully updated!"
	else
		flash[:warning] = "Question update unsuccessful!"
	end
	redirect "/questions/#{params[:question_id]}"
end

#DeleteQuestion================================================
delete '/questions/:id' do
	question = Question.find(params[:id].to_i)
	if question.user_id == session[:user_id]
		if question.delete
			flash[:notice] = "Question #{question.question[0..10]}................ is deleted!"
			redirect "/profile/#{session[:username]}"
		else
			flash[:notice] = "Question #{question.question[0..10]}................ is not yet deleted!"
			redirect "/questions/#{params[:id]}"
		end
	else
		flash[:warning] = "You couldn't delete this question!"
		redirect "/questions/#{params[:id]}"
	end
end
#Upvotes======================================================
get '/:votes/:question_id/:ans_id' do
	if !session[:username].nil? && !session[:user_id].nil?
			action = params[:votes]
			question_id = params[:question_id]
			ans_id = params[:ans_id]
				if action == "upvotes"
					if Vote.find_by(answer_id:ans_id,user_id:session[:user_id]) != nil
						vt = Vote.find_by(answer_id:ans_id,user_id:session[:user_id])
						if vt.value != 'up'
							ans = Answer.find(ans_id)
							ans.update(vote:ans.vote + 1)
							vt.update(value:"up")
							flash[:notice] = "Upvoted!"
							redirect "/questions/#{question_id}"
						else
							flash[:notice] = "Not Upvoted!"
							redirect "/questions/#{question_id}"
						end
					else
						vt = Vote.new(answer_id:ans_id,user_id:session[:user_id],value:"up")
							if vt.save
								ans = Answer.find(ans_id)
								ans.update(vote:ans.vote + 1)
								flash[:notice] = "Upvoted!"
								redirect "/questions/#{question_id}"
							end
					end
				elsif action == "downvotes"
					if Vote.find_by(answer_id:ans_id,user_id:session[:user_id])
						vt = Vote.find_by(answer_id:ans_id,user_id:session[:user_id])
						if vt.value == "0" || vt.value == 'up'
							ans = Answer.find(ans_id)
							ans.update(vote:ans.vote - 1)
							vt.update(value:"down")
							flash[:notice] = "Downvoted!"
							redirect "/questions/#{question_id}"
						else
							flash[:notice] = "Not downvoted!"
							redirect "/questions/#{question_id}"
						end
					else
						vt = Vote.new(answer_id:ans_id,user_id:session[:user_id],value:"down")
							if vt.save
								ans = Answer.find(ans_id)
								ans.update(vote:ans.vote - 1)
								flash[:notice] = "Downvoted!"
								redirect "/questions/#{question_id}"
							end
					end
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





