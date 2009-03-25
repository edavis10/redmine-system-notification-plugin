require File.dirname(__FILE__) + '/../spec_helper'

describe SystemNotificationController do
  it 'should allow administrator access' do
    admin = mock_model(User, :admin? => true, :logged? => true, :language => :en)
    User.should_receive(:current).at_least(:once).and_return(admin)
    get :index
    response.should be_success
  end
  
  it 'should deny anonymous users' do
    get :index
    response.should_not be_success
  end

  it 'should deny non-administrator users' do
    user = mock_model(User, :admin? => false, :logged? => true, :language => :en)
    User.should_receive(:current).at_least(:once).and_return(user)
    get :index
    response.should_not be_success
  end
end

describe SystemNotificationController,'#create with valid SystemNotification' do
  before(:each) do
    admin = mock_model(User, :admin? => true, :logged? => true, :language => :en)
    User.stub!(:current).at_least(:once).and_return(admin)
    
    user1 = mock_model(User)
    user2 = mock_model(User)
    @users = [user1, user2]

    @system_notification = mock_model(SystemNotification, :subject => 'Test', :body => 'A notification', :time => 'week', :users => @users)
    @system_notification.stub!(:deliver).and_return(true)
    @system_notification.stub!(:users=)
    SystemNotification.stub!(:new).and_return(@system_notification)
    SystemNotification.stub!(:users_since).with('week', :projects => nil).and_return(@users)
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
    SystemNotification.should_receive(:users_since).with('week', :projects => nil).and_return(@users)
    post :create, :system_notification => { :subject => 'Test', :body => 'A notification', :time => 'week'}
    assigns[:system_notification].users.should eql(@users)
  end

  it 'should optionally add a project filter' do
    SystemNotification.should_receive(:users_since).with('week', {:projects => ['10']}).and_return(@users)
    post :create, :system_notification => { :subject => 'Test', :body => 'A notification', :time => 'week', :projects => ['10']}
  end

  
  it 'should deliver the SystemNotification' do
    @system_notification.should_receive(:deliver).and_return(true)
    post :create, :system_notification => { :subject => 'Test', :body => 'A notification', :time => 'week'}
  end

end

describe SystemNotificationController,'#create with an invalid SystemNotification' do
  before(:each) do
    admin = mock_model(User, :admin? => true, :logged? => true, :language => :en)
    User.stub!(:current).at_least(:once).and_return(admin)
    
    user1 = mock_model(User)
    user2 = mock_model(User)
    @users = [user1, user2]

    @system_notification = mock_model(SystemNotification, :subject => 'Test', :body => 'A notification', :time => 'week', :users => @users)
    @system_notification.stub!(:deliver).and_return(false)
    @system_notification.stub!(:users=)
    SystemNotification.stub!(:new).and_return(@system_notification)
    SystemNotification.stub!(:users_since).with('week', :projects => nil).and_return(@users)
  end
  

  it 'should display the #index' do
    post :create, :system_notification => { :subject => 'Test', :body => 'A notification', :time => 'week'}
    response.should be_success
    response.should render_template('index')
  end
  
  it 'should display a message to the user' do
    post :create, :system_notification => { :subject => 'Test', :body => 'A notification', :time => 'week'}
    flash[:error].should match(/not/)
  end
  
  it 'should assign @system_notification for the view' do
    post :create, :system_notification => { :subject => 'Test', :body => 'A notification', :time => 'week'}
    assigns[:system_notification].should_not be_nil
  end
  
end

describe SystemNotificationController,'#users_since using HTML posts' do
  before(:each) do
    admin = mock_model(User, :admin? => true, :logged? => true, :language => :en)
    User.stub!(:current).at_least(:once).and_return(admin)
  end

  it 'should redirect to #index' do
    post :users_since, :time => 'week'
    response.should be_redirect
    response.should redirect_to(:controller => 'system_notification', :action => 'index')
  end
end

describe SystemNotificationController,'#users_since using JavaScript posts' do
  def do_js_post(time='week', filters={})
    request.env["HTTP_ACCEPT"] = "text/javascript" 
    post :users_since, {:system_notification => { :time => time}.merge(filters) }
  end
  
  before(:each) do
    admin = mock_model(User, :admin? => true, :logged? => true, :language => :en)
    User.stub!(:current).at_least(:once).and_return(admin)
  end

  it 'should respond to js requests' do
    do_js_post
    response.should be_success
  end

  it 'should render the user partial' do
    do_js_post
    response.should render_template('_users')
  end

  it 'should find the users since a time' do
    SystemNotification.should_receive(:users_since).with('week', {:projects => nil}).and_return([])
    do_js_post
  end

  it 'should optionally add a project filter' do
    SystemNotification.should_receive(:users_since).with('week', {:projects => ['10']}).and_return([])
    do_js_post('week', :projects => ['10'])
  end

  it 'should set @users for the view' do
    do_js_post
    assigns[:users].should_not be_nil
  end

  it 'should handle empty strings for the time' do
    SystemNotification.should_not_receive(:users_since)
    do_js_post('')
    response.should be_success
  end

  it 'should handle nil strings for the time' do
    SystemNotification.should_not_receive(:users_since)
    do_js_post('')
    response.should be_success
  end
end
