require File.dirname(__FILE__) + '/../spec_helper'

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

