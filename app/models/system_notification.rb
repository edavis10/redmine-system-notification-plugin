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
  
  def initialize
    self.errors = { }
    self.users = []
  end
end
