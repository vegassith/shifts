class RequestedShift < ActiveRecord::Base
	validates_presence_of :locations
	validate :proper_times
	validate :user_shift_preferences
	
	has_many :locations_requested_shifts
	has_many :locations, :through => :locations_requested_shifts
	belongs_to :user
	belongs_to :template

	WEEK_DAY_SELECT = [
    ["Monday", 0],
    ["Tuesday", 1],
    ["Wednesday", 2],
    ["Thursday", 3],
    ["Friday", 4],
    ["Saturday", 5],
    ["Sunday", 6]
  ]
	
	protected
	def user_shift_preferences
		@shift_preference = self.user.shift_preferences.select{|sp| sp.template_id == self.template_id}.first
		@max_cont_hours = @shift_preference.max_continuous_hours
		@min_cont_hours = @shift_preference.min_continuous_hours
		errors.add_to_base("Your preferred shift length is longer than the maximum continious hours you 
												specified in your shift preferences") if (self.preferred_end - self.preferred_start)/60/60 > @max_cont_hours
		errors.add_to_base("Your preferred shift length is shorter than the minimum continious hours you 
												specified in your shift preferences") if (self.preferred_end - self.preferred_start)/60/60 < @min_cont_hours
		errors.add_to_base("Your preferred shift length is longer than the maximum continious hours you 
												specified in your shift preferences") if (self.preferred_end - self.preferred_start)/60/60 > @max_cont_hours
	end

	def proper_times
		errors.add_to_base("Acceptable start time cannot be after the preferred start time") if self.acceptable_start > self.preferred_start
		errors.add_to_base("Acceptable end time cannot be before the preferred end time") if self.acceptable_end < self.preferred_end
	end

	
end
