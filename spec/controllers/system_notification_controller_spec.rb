require File.dirname(__FILE__) + '/../spec_helper'

describe SystemNotificationController do
  it 'should allow administrator access' do
    admin = mock_model(User, :admin? => true, :logged? => true)
    User.should_receive(:current).at_least(:once).and_return(admin)
    get :index
    response.should be_success
  end
  
  it 'should deny anonymous users' do
    get :index
    response.should_not be_success
  end

  it 'should deny non-administrator users' do
    user = mock_model(User, :admin? => false, :logged? => true)
    User.should_receive(:current).at_least(:once).and_return(user)
    get :index
    response.should_not be_success
  end
end

describe SystemNotificationController,'#create with valid SystemNotification' do
  before(:each) do
    admin = mock_model(User, :admin? => true, :logged? => true)
    User.stub!(:current).at_least(:once).and_return(admin)
    
    user1 = mock_model(User)
    user2 = mock_model(User)
    @users = [user1, user2]

    @system_notification = mock_model(SystemNotification, :subject => 'Test', :body => 'A notification', :time => 'week', :users => @users)
    @system_notification.stub!(:deliver).and_return(true)
    @system_notification.stub!(:users=)
    SystemNotification.stub!(:new).and_return(@system_notification)
    SystemNotification.stub!(:users_since).with('week').and_return(@users)
  end
  

  it 'should redirect to the #index' do
    post :create, :system_notification => { :subject => 'Test', :body => 'A notification', :time => 'week'}
    response.should be_redirect
    response.should redirect_to(:controller => 'system_notification', :action => 'index')
  end
  
  it 'should display a message to the user' do
    post :create, :system_notification => { :subject => 'Test', :body => 'A notification', :time => 'week'}
    flash[:notice].should match(/success/)
  end
  
  it 'should assign @system_notification for the view' do
    post :create, :system_notification => { :subject => 'Test', :body => 'A notification', :time => 'week'}
    assigns[:system_notification].should_not be_nil
  end
  
  it 'should get the users based on the Time' do
    SystemNotification.should_receive(:users_since).with('week').and_return(@users)
    post :create, :system_notification => { :subject => 'Test', :body => 'A notification', :time => 'week'}
    assigns[:system_notification].users.should eql(@users)
  end

  it 'should deliver the SystemNotification' do
    @system_notification.should_receive(:deliver).and_return(true)
    post :create, :system_notification => { :subject => 'Test', :body => 'A notification', :time => 'week'}
  end

end
