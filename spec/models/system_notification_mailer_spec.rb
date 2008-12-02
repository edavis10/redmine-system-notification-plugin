require File.dirname(__FILE__) + '/../spec_helper'

describe SystemNotificationMailer, 'system_notification' do
  include SystemNotificationSpecHelper

  before(:each) do
    @system_notification = SystemNotification.new(valid_attributes)
    @mail = SystemNotificationMailer.create_system_notification(@system_notification)
  end
  
  it 'should send to the users specified' do
    @mail.bcc.should have(2).things
    @mail.bcc.should include("user1@example.com")
    @mail.bcc.should include("user2@example.com")
  end

  it 'should use the subject from the object' do
    @mail.subject.should eql(@system_notification.subject)
  end
  
  it 'should use the body from the object' do
    @mail.body.should match(/#{ @system_notification.body }/)
  end
  
end
