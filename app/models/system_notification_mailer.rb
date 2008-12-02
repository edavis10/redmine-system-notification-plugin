class SystemNotificationMailer < Mailer
  def system_notification(system_notification)
    recipients system_notification.users.collect(&:mail)
    subject system_notification.subject
    body :body => system_notification.body
  end
end
