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
end
