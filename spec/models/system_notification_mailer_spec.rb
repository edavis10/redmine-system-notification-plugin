require File.dirname(__FILE__) + '/../spec_helper'

describe SystemNotificationMailer, 'system_notification' do
  include SystemNotificationSpecHelper

  before(:each) do
    @user = mock_model(User, :name => 'Test user', :mail => 'admin@example.com', :pref => { })
    User.stub!(:current).and_return(@user)
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
    @mail.encoded.should match(/#{ Regexp.escape(@system_notification.body) }/)
  end

  it 'should render the textile content into HTML' do
    @mail.encoded.should match(/<strong>textile<\/strong>/)
  end
  
  it 'should use the Current user as the reply to' do
    @mail.from.should include(@user.mail)
  end
  
end
