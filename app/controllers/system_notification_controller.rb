class SystemNotificationController < ApplicationController
  unloadable
  layout 'base'
  before_filter :require_admin
  
  def index
    @system_notification = SystemNotification.new
  end
end
