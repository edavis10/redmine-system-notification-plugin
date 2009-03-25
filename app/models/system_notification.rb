class SystemNotification
  attr_accessor :time
  attr_accessor :subject
  attr_accessor :body
  attr_accessor :users
  attr_accessor :errors

  if Redmine.const_defined?(:I18n)
    include Redmine::I18n
  else
    include GLoc
  end

  def initialize(options = { })
    self.errors = { }
    self.users = options[:users] || []
    self.subject = options[:subject]
    self.body = options[:body]
  end
  
  def valid?
    self.errors = { }
    if self.subject.blank?
      self.errors['subject'] = 'activerecord_error_blank'
    end
    
    if self.body.blank?
      self.errors['body'] = 'activerecord_error_blank'
    end
    
    if self.users.empty?
      self.errors['users'] = 'activerecord_error_empty'
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
  
  def self.times
    {
      :day => ll(current_language, :text_24_hours),
      :week => ll(current_language, :text_1_week),
      :month => ll(current_language, :text_1_month),
      :this_year => ll(current_language, :text_this_year),
      :all => ll(current_language, :text_all_time)
    } 
  end

  def self.users_since(time, filters = { })
    if SystemNotification.times.include?(time.to_sym)
      members = Member.find(:all, :include => :user, :conditions => self.conditions(time, filters))
      return members.collect(&:user).uniq
    else
      return []
    end
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

  def self.conditions(time, filters = { })
    c = ARCondition.new
    c.add ["#{User.table_name}.status = ?", User::STATUS_ACTIVE]
    c.add ["#{User.table_name}.last_login_on > (?)", time_frame(time)] unless time.to_sym == :all
    c.add ["project_id IN (?)", filters[:projects]] if filters[:projects]
    return c.conditions
  end

end
