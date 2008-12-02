require File.dirname(__FILE__) + '/../spec_helper'

module SystemNotificationSpecHelper
  def valid_attributes
    user1 = mock_model(User)
    user2 = mock_model(User)
    return { 
      :body => 'a body',
      :subject => 'a subject line',
      :users => [user1, user2]
    }
  end
end

describe SystemNotification do
  it 'should initilize errors to an empty Hash' do
    system_notification = SystemNotification.new
    system_notification.errors.should be_an_instance_of(Hash)
    system_notification.errors.should be_empty
  end

  it 'should initilize users to an empty Array' do
    system_notification = SystemNotification.new
    system_notification.users.should be_an_instance_of(Array)
    system_notification.users.should be_empty
  end
end

describe SystemNotification, "valid?" do
  include SystemNotificationSpecHelper
  
  it 'should be invalid without a subject' do
    system_notification = SystemNotification.new(valid_attributes.except(:subject))
    system_notification.valid?.should be_false
  end
  
  it 'should be invalid without a body' do
    system_notification = SystemNotification.new(valid_attributes.except(:body))
    system_notification.valid?.should be_false
  end
  
  it 'should be invalid without any users' do
    system_notification = SystemNotification.new(valid_attributes.except(:users))
    system_notification.valid?.should be_false
  end
end

describe SystemNotification, ".deliver" do
  include SystemNotificationSpecHelper

  it 'should not send if the object is invalid' do
    system_notification = SystemNotification.new(valid_attributes)
    system_notification.should_receive(:valid?).and_return(false)
    
    system_notification.deliver.should be_false
  end

  it 'should send a SystemNotification Mail' do
    system_notification = SystemNotification.new(valid_attributes)
    system_notification.should_receive(:valid?).and_return(true)
    SystemNotificationMailer.should_receive(:deliver_system_notification)
    
    system_notification.deliver.should be_true
  end
end
