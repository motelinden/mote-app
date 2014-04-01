require 'spec_helper'

describe "UsersPages" do
	
	subject {page}
	
	describe "index" do
    let(:user) { FactoryGirl.create(:user) }
    before(:each) do
      sign_in user
      visit users_path
    end

    it { should have_title('All Users') }
    it { should have_content('All Users') }
		it { should_not have_link('delete') }

    describe "pagination" do

      before(:all) { 30.times { FactoryGirl.create(:user) } }
      after(:all)  { User.delete_all }

      it { should have_selector('div.pagination') }

      it "should list each user" do
        User.paginate(page: 1).each do |user|
          expect(page).to have_selector('li', text: user.name)
        end
      end
    end

		describe "delete links" do

      describe "as an admin user" do
        let(:admin) { FactoryGirl.create(:admin) }
        
				before do
          sign_in admin
          visit users_path
        end

        it { should have_link('delete', href: user_path(User.first)) }
				it { should_not have_link('delete', href: user_path(admin)) }

        it "should be able to delete another user" do
          expect do
            click_link('delete', match: :first)
          end.to change(User, :count).by(-1)
        end
      end
    end
  end

	describe 'signup page' do
		before { visit signup_path}
		let(:submit) {'Create my account'}

		describe 'with invalid information' do
			it "should not create a user" do
				expect {click_button submit}.not_to change(User,:count)
			end

			describe 'it should render the "new" after click' do
				before { click_button submit}

				it { should have_title('Sign Up')}
				it { should have_content('error')}
			end
		end

		describe 'with valid information' do
			before do
				fill_in "Name",         with: "Example User"
        fill_in "Email",        with: "user@example.com"
        fill_in "Password",     with: "foobar"
        fill_in "Confirmation", with: "foobar"
			end

			it 'should create a user' do
				expect {click_button submit}.to change(User,:count).by(1)
			end

			describe 'it should redirect to @user after saving' do
				before {click_button submit}
				let(:user) {User.find_by(email: "user@example.com")}

				it {should have_title(user.name)}
				it {should have_selector('div.alert.alert-success')}
			end
		end

		it { should have_content('Sign Up') }
		it { should have_title(full_title('Sign Up'))}
	end

	describe 'profile page' do
		let(:user) {FactoryGirl.create(:user)}
		before {visit user_path(user)}

		it {should have_content(user.name)}
		it {should have_title(user.name)}
	end

	describe 'edit page' do
		let(:user) {FactoryGirl.create(:user)}
		before do
			sign_in user
			visit edit_user_path(user)
		end

		it {should have_selector('h1','Update your profile')}
		it {should have_title(full_title('Edit User'))}
		it {should have_link('change',href:'http://gravatar.com/emails')}

		describe 'with invalid information' do
			before {click_button 'Save Changes'}

			it {should have_content('error')}
			it {should have_title(full_title('Edit User'))}
		end

		describe 'with valid information' do
			let(:new_name)  { "New Name" }
      let(:new_email) { "new@example.com" }
      before do
        fill_in "Name",             with: new_name
        fill_in "Email",            with: new_email
        fill_in "Password",         with: user.password
        fill_in "Confirm Password", with: user.password
        click_button "Save Changes"
      end

      it { should have_title(new_name) }
      it { should have_selector('div.alert.alert-success') }
      specify { expect(user.reload.name).to  eq new_name }
      specify { expect(user.reload.email).to eq new_email }
		end
	end
end