class Notice < ActiveRecord::Base
  belongs_to :author, class_name: "User"
  belongs_to :remover, class_name: "User"
  belongs_to :department

  has_and_belongs_to_many :locations
  has_and_belongs_to_many :loc_groups

  validate :content_or_label, :presence_of_locations, :proper_time

  attr_accessor :start_date
  attr_accessor :start_time
  attr_accessor :end_date
  attr_accessor :end_time

  #before_destroy :destroy_user_sinks_user_sources    TODO:  this validation fails, but also is never called as we never delete notices.
  scope :in_department, ->(dept){ where(department_id: dept)}
  scope :created_by, ->(user){ where(author_id: user)}
  scope :inactive, -> {where(" end < ?", Time.now.utc)}
  scope :not_link, where("type != ?", "Link")
  scope :upcoming,  -> {where("start > ? ", Time.now.utc)}
  scope :global,  where(department_wide: true)
  scope :active, -> {where("start <= ? AND end is ? OR end > ?", Time.now.utc, nil, Time.now.utc)}

  def self.active_links
    Link.active
  end

  def self.active_notices
    Announcement.active.ordered_by_start + Sticky.active.ordered_by_start
  end

  def display_for
    display_for = []
    #TODO Figure out why users isn't a valid method
    #display_for.push "for users #{self.users.collect{|n| n.name}.to_sentence}" unless self.users.empty?
    #display_for.push "for locations #{self.locations.collect{|l| l.short_name}.to_sentence}" unless self.locations.empty?
    display_for.join "<br/>"
  end

  def is_upcoming?
    return self.start > Time.now if self.start
    false
  end

  def display_locations
    if self.department_wide
      return self.department.locations
    end
    a = self.locations
    b = self.loc_groups.collect(&:locations).flatten
    (a + b).uniq
  end

  def remove(user)
    self.errors.add(:base, "This notice has already been removed by #{remover.name}.") and return if self.remover && self.end
    self.start = Time.now if self.start > Time.now
    self.end = Time.now
    self.indefinite = false
    self.remover = user
    true if self.save
  end

  def content_with_formatting
    content.sanitize_and_format
  end

  private
  #Validations
  def presence_of_locations
    if self.display_locations.empty?
			errors.add  :base, "Your #{self.class.name.downcase} must display somewhere"
  	end
	end

  def proper_time
    errors.add :base, "Start/end time combination is invalid." if self.end && self.start >= self.end
  end

	def content_or_label
		if self.content.blank?
			if self.type == "Link"
				errors.add :base, "Your link must have a label"
			else
				errors.add :base, "Your #{self.type.downcase} must have content"
			end
		end
	end
end
