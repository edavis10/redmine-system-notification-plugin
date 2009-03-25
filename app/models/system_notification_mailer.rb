class SystemNotificationMailer < Mailer
  def system_notification(system_notification)
    recipients system_notification.users.collect(&:mail)
    subject system_notification.subject
    from User.current.mail
    
    content_type "multipart/alternative"

    part "text/plain" do |p|
      p.body = render_message("system_notification.erb", :body => system_notification.body)
    end
    
    part "text/html" do |p|
      p.body = render_message("system_notification.text.html.erb", :body => system_notification.body)
    end

  end
end
