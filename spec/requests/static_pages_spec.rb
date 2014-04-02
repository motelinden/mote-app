require 'spec_helper'

describe "Static pages" do

  subject { page }

	shared_examples_for 'title and head' do
		it { should have_content(h1)}
		it { should have_title(full_title(title))}
	end

  describe "Home page" do
		let(:h1) {'Mote App'}
		let(:title) {''}

		describe 'for non-signed-users'do
			before {visit root_path}

			it_should_behave_like 'title and head'
			it { should_not have_title('| Home')}
		
			it 'should have the right links' do
				click_link 'About'
				expect(page).to have_title(full_title('About Us'))

				click_link 'Contact'
				expect(page).to have_title(full_title('Contact Us'))

				click_link 'Help'
				expect(page).to have_title(full_title('Help'))
			end
		end

		describe 'for signed-in users' do
			let(:user) { FactoryGirl.create(:user) }
			before do
				FactoryGirl.create(:micropost, user: user, content: "Lorem ipsum")
        FactoryGirl.create(:micropost, user: user, content: "Dolor sit amet")
        sign_in user
        visit root_path
      end

			it "should render the user's feed" do
				user.feed.each do |item|
          expect(page).to have_selector("li##{item.id}", text: item.content)
        end
			end
		end
  end

  describe "Help page" do
    before { visit help_path }
		let(:h1) {'Help'}
		let(:title) {'Help'}

    it_should_behave_like 'title and head'
  end

  describe "About page" do
    before { visit about_path }
		let(:h1) {'About Us'}
		let(:title) {'About Us'}

    it_should_behave_like 'title and head'
  end

  describe "Contact page" do
    before { visit contact_path }
		let(:h1) {'Contact Us'}
		let(:title) {'Contact Us'}

    it_should_behave_like 'title and head'
  end
end
