require 'redmine'

Redmine::Plugin.register :system_notification_plugin do
  name 'Redmine System Notification plugin'
  author 'Eric Davis'
  description 'The System Notification plugin allows Administrators to send systemwide email notifications to specific users.'
  url 'https://projects.littlestreamsoftware.com/projects/redmine-notify'
  author_url 'http://www.littlestreamsoftware.com'

  version '0.2.0'

  requires_redmine :version_or_higher => '0.8.0'

  
  menu :admin_menu, :system_notification, { :controller => 'system_notification', :action => 'index'}, :caption => :system_notification
end
