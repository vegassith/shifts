require 'rails_helper'

describe "User Profiles", :user do 
	before :each do
		full_setup
	end

	context "When user is using Shifts" do
		before(:each) do
			sign_in(@user.login)
			visit user_profile_path(@user.login)
		end

		it "can upload a profile picture" do
			expect do
				click_on "Edit"
				attach_file "user_profile_photo", Rails.root.join("app/assets/images/fail_yale.jpg")
				click_on "Update"
				click_on "Crop"
			end.to change{find('div#profile_left img')["src"]}
		end

		context "When having profile fields of different types" do

			it "renders and updates Text Field correctly" do 
				create_field_and_entry("text_field", @user, "text content")
				click_on "Edit"
				expect(page).to have_field(@profile_field.name, with: "text content", type: "text")
				fill_in @profile_field.name, with: "changed content"
				click_on "Update"
				expect(page).to have_content("changed content")
				expect{@profile_entry.reload}.to change{@profile_entry.content}
			end
			it "renders and updates List correctly" do
				create_field_and_entry("select", @user,"s2", "s1, s2, s3")
				click_on "Edit"
				expect(page).to have_select(@profile_field.name, selected: "s2")
				select "s1", from: @profile_field.name
				click_on "Update"
				expect(page).to have_content("s1")
				expect{@profile_entry.reload}.to change{@profile_entry.content}
			end
			it "renders and updates Multiple Choice correctly" do
				create_field_and_entry("radio_button", @user, "r2", "r1,r2,r3")
				click_on "Edit"
				expect(page).to have_checked_field("r2")
				choose "r3"
				click_on "Update"
				expect(page).to have_content("r3")
				expect{@profile_entry.reload}.to change{@profile_entry.content}

			end
			it "renders and updates checkboxes correctly" do
				create_field_and_entry("check_box", @user, "c1,c2", "c1,c2, c3")
				click_on "Edit"
				expect(page).to have_checked_field("c1")
				expect(page).to have_checked_field("c2")
				uncheck "c1"
				check "c3"
				click_on "Update"
				expect(page).not_to have_content("c1")
				expect(page).to have_content("c2")
				expect(page).to have_content("c3")
				expect{@profile_entry.reload}.to change{@profile_entry.content}
			end
			it "renders and updates Paragraph Text correctly" do 
				create_field_and_entry("text_area", @user, "text area")
				click_on "Edit"
				expect(page).to have_selector("textarea", text: "text area")
				find("textarea").set(text: "more text")
				click_on "Update"
				expect(page).to have_content("more text")
				expect{@profile_entry.reload}.to change{@profile_entry.content}
			end
			it "renders and updates picture link correctly" do 
				url = "http://weknowmemes.com/wp-content/uploads/2012/09/id-give-a-fuck-but.jpg"
				create_field_and_entry("picture_link", @user, nil)
				click_on "Edit"
				expect(page).to have_field(@profile_field.name, type: "text")
				fill_in @profile_field.name, with: url
				click_on "Update"
				expect(page).to have_selector("img[src='#{url}']")
				expect{@profile_entry.reload}.to change{@profile_entry.content}
			end
		end

		it "cannot update his non-editable profile fields"
		it "can see public profile fields"
		it "cannot see non-public profile fields"
		it "can see profile fields on index page"
		it "cannot see certain profile fields on index page"
	end
	context "When admin is using Shifts" do 
		before(:each) {sign_in(@admin.login)}
		# xit "displays user profile fields" do
		# 	visit user_profile_fields_path
		# 	save_and_open_page
		# end

		it "can create a profile field"
		it "can edit a profile field"
		it "can destroy a profile field"
		it "can update the profile of another user"
	end
end
