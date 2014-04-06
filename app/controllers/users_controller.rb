class UsersController < ApplicationController
	before_action :signed_in_user, only: [:index,:edit, :update, :destroy, :followings, :followers]
	before_action :correct_user,   only: [:edit, :update]
	before_action :admin_user,     only: :destroy

	def index
		@title = 'All Users'
		@users = User.paginate(page: params[:page])
	end

	def show
		@user = User.find(params[:id])
		@title = @user.name
		@microposts = @user.microposts.paginate(page: params[:page])
	end

  def new
		@title = 'Sign Up'
		@user = User.new
  end

	def create
		@user = User.new(user_params)
		if @user.save
			flash[:success] = "Welcome to the Sample App!"
			redirect_to @user
		else
			@title = "Sign Up"
			render 'new'
		end
	end

	def edit
		@title = 'Edit User'
	end

	def update
		if @user.update_attributes(user_params)
			flash[:success] = 'Profile updated'
			redirect_to @user
		else
			@title='Edit User'
			render 'edit'
		end
	end

	def destroy
		User.find(params[:id]).destroy
		flash[:success] = 'User destroyed'
		redirect_to users_url
	end

	def followings
		@title = 'Followings'
		@user = User.find(params[:id])
		@users = @user.followed_users.paginate(page: params[:page])
		render 'show_follow'
	end

	def followers
		@title = 'Followers'
		@user = User.find(params[:id])
		@users = @user.followers.paginate(page: params[:page])
		render 'show_follow'
	end

	 private

    def user_params
      params.require(:user).permit(:name, :email, :password,
                                   :password_confirmation)
    end

		def correct_user
			@user = User.find(params[:id])
			redirect_to(root_path) unless current_user?(@user)
		end

		def admin_user
      redirect_to(root_path) unless current_user.admin?
    end
end
