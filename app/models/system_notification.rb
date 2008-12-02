class SystemNotification
  attr_accessor :time
  attr_accessor :subject
  attr_accessor :body
  attr_accessor :users
  attr_accessor :errors

  Times = { 
    :day => "24 hours",
    :week => "1 week",
    :month => "1 month",
    :this_year => "This year",
    :all => "All"
  }
  
  def initialize(options = { })
    self.errors = { }
    self.users = options[:users] || []
    self.subject = options[:subject]
    self.body = options[:body]
  end
  
  def valid?
    if self.subject.blank?
      self.errors[:subject] = 'activerecord_error_blank'
    end
    
    if self.body.blank?
      self.errors[:body] = 'activerecord_error_blank'
    end
    
    if self.users.empty?
      self.errors[:users] = 'activerecord_error_empty'
    end
    
    return self.errors.empty?
  end
  
  def deliver
    if self.valid?
      SystemNotificationMailer.deliver_system_notification(self)
      return true
    else
      return false
    end
  end
  
  def self.users_since(time)
    if SystemNotification::Times.include?(time.to_sym)
      if time.to_sym == :all
        users = User.find(:all)
      else
        users = User.find(:all, :conditions => ['last_login_on > (?)', time_frame(time)])
      end
    else
      users = []

    end
    return users
  end
  
  private
  
  def self.time_frame(time)
    case time.to_sym
    when :day
      1.day.ago
    when :week
      7.days.ago
    when :month
      7.month.ago
    when :this_year
      Time.parse('Jan 1 ' + Time.now.year.to_s)
    else
      nil
    end
  end
end
