class SystemNotificationController < ApplicationController
  unloadable
  layout 'base'
  before_filter :require_admin
  
  def index
    @system_notification = SystemNotification.new
  end
  
  def create
    @system_notification = SystemNotification.new(params[:system_notification])
    @system_notification.users = SystemNotification.users_since(params[:system_notification][:time]) if params[:system_notification][:time]
    if @system_notification.deliver
      flash[:notice] = "System Notification was successfully sent."
      redirect_to :action => 'index'
    end
  end
end
