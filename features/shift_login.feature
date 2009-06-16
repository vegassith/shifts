Feature: Regular user logs into a shift
	As a regular user
	I want to log into a shift
	So that I can begin updating my report

Scenario: Log into an unscheduled shift
  Given I just got through CAS with the login "catest"
	And I am not logged into a shift report
	When I am on the homepage
	And I follow "Here"
  And I follow "Shifts"
	Then I should not see "Return to current shift"
	#When I follow "Start an unscheduled shift"
  When I follow "Power sign up"
  When I select "AJ Espinosa" from "shift_user_id"
  When I select "TTO" from "shift_location_id"
	When I press "Submit"
	Then I should see "Unscheduled Shift"
	Then I should see "TTO"
	When I press "Create Report"
	Then I should see "Shift Report at the TTO"
	And my shift report should have 1 comment

Scenario: Fail to log into a second report
  Given I just got through CAS with the login "catest"
  #And I am on the homepage
	#Routes have changed
	When I am logged into a shift report
  And I am on shifts
	And I follow "Shifts"
	Then I should see "Return to current shift"
	When I select "AJ Espinosa" from "shift_user_id"
  And I follow "Start an unscheduled shift"
	When I select "TTO" from "shift_location_id"
	When I press "Submit"
	Then I should see "You are already signed into a shift!"
	And I should be on the shift page
	When I follow "STC"

