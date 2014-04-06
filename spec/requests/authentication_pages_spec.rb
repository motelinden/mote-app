require 'spec_helper'

describe "AuthenticationPages" do

	subject {page}

	describe 'signin page' do
		before {visit signin_path}

		it {should have_selector('h1','Sign In')}
		it {should have_title(full_title('Sign In'))}

		describe 'with invalid information' do
			before {click_button 'Sign In'}

			it {should have_title('Sign In')}
			it {should have_selector('div.alert.alert-error')}

			describe 'flash messages should disapper after visit another page' do
				before {click_link 'Mote App'}
				it {should_not have_selector('div.alert.alert-error')}
			end
		end

		describe "with valid information" do
      let(:user) { FactoryGirl.create(:user) }
			before {sign_in user}

      it { should have_title(user.name) }
			it { should have_link('Users',       href: users_path) }
      it { should have_link('Profile',     href: user_path(user)) }
      it { should have_link('Sign Out',    href: signout_path) }
			it { should have_link('Settings',    href: edit_user_path(user)) }
      it { should_not have_link('Sign In', href: signin_path) }

			describe 'followed by signout' do
				before {click_link 'Sign Out'}
				it {should have_link('Sign In')}
			end
    end
	end

	describe 'authorization' do

		describe 'when the user is non-signed' do
			let(:user) {FactoryGirl.create(:user)}
			let(:non_admin) {FactoryGirl.create(:user)}

			describe 'when try to visit edit page' do
				before {visit edit_user_path(user)}
				it {should have_title('Sign In')}

				describe 'friendly redirect' do
					before {sign_in user}

					it {should have_title('Edit User')}
				end
			end

			describe "when try to delete another user" do
				before do
					sign_in non_admin,no_capybara: true
					delete user_path(user)
				end

				specify { expect(response).to redirect_to(root_path) }
			end

			describe 'submitting to the update action' do
				before {patch user_path(user)}
				specify {expect(response).to redirect_to(signin_path)}
			end

			describe 'when visit the Users page' do
				before {visit users_path}

				it {should have_title('Sign In')}
			end

			describe 'about microposts' do
				describe "try to patch a post request to microposts" do
          before { post microposts_path }
          specify { expect(response).to redirect_to(signin_path) }
        end

        describe "try to the destroy a micropost" do
          before { delete micropost_path(FactoryGirl.create(:micropost)) }
          specify { expect(response).to redirect_to(signin_path) }
        end
			end

			describe 'visiting the followings page' do
				before {visit followings_user_path(user)}
				it {should have_title('Sign In')}
			end

			describe 'visiting the followers page' do
				before {visit followers_user_path(user)}
				it {should have_title('Sign In')}
			end

      describe "submitting to the create action" do
        before { post relationships_path }
        specify { expect(response).to redirect_to(signin_path) }
      end

      describe "submitting to the destroy action" do
        before { delete relationship_path(1) }
        specify { expect(response).to redirect_to(signin_path) }
      end
		end

		describe "when the user has signed in but try to edit ather's account" do
      let(:user) { FactoryGirl.create(:user) }
      let(:ather_user) { FactoryGirl.create(:user, email: "ather@example.com") }
      before { sign_in user, no_capybara: true }

			describe "when try to get the edit page" do
        before { get edit_user_path(ather_user) }
        specify { expect(response.body).not_to match(full_title('Edit user')) }
        specify { expect(response).to redirect_to(root_url) }
      end

			describe "when try to invoke the update action" do
        before { patch user_path(ather_user) }
        specify { expect(response).to redirect_to(root_url) }
      end
    end
	end
end
