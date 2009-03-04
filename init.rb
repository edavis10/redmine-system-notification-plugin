require 'redmine'

Redmine::Plugin.register :system_notification_plugin do
  name 'Redmine System Notification plugin'
  author 'Eric Davis'
  description 'This is a plugin for Redmine to allow an Administrator to send systemwide notifications to specific users'
  version '0.1.0'
  
  menu :admin_menu, :system_notification, { :controller => 'system_notification', :action => 'index'}, :caption => :system_notification
end
