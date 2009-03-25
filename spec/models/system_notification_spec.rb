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

describe SystemNotification, "valid?" do
  include SystemNotificationSpecHelper

  it 'should be valid with the body, subject, and users' do
    system_notification = SystemNotification.new(valid_attributes)
    system_notification.valid?.should be_true
  end
  
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

describe SystemNotification, ".users_since" do
  it 'should return an array for a valid Time' do
    users = SystemNotification.users_since('week')
    users.should be_an_instance_of(Array)
  end

  it 'should return an empty array for an invalid Time' do
    users = SystemNotification.users_since('invalid')
    users.should be_empty
  end

  describe 'should return all users who have been active since' do
    before(:each) do
      @project1 = mock_model(Project)
      @project2 = mock_model(Project)
      @user1 = mock_model(User)
      @user2 = mock_model(User)
      @user3 = mock_model(User)
      @user_list = [@user1, @user2, @user3]
      @member1 = mock_model(Member, :user => @user1, :project => @project1)
      @member2 = mock_model(Member, :user => @user1, :project => @project2)
      @member3 = mock_model(Member, :user => @user2, :project => @project1)
      @member4 = mock_model(Member, :user => @user3, :project => @project2)
      @member_list = [@member1, @member2, @member3, @member4]
    end

    it 'a week ago' do
      time = 7.days.ago
      SystemNotification.should_receive(:time_frame).at_least(:once).and_return(time)
      
      Member.should_receive(:find).with(:all,
                                        :include => :user,
                                        :conditions => ['1=1 AND (users.status = ?) AND (users.last_login_on > (?))', User::STATUS_ACTIVE, time]).
        and_return(@member_list)
      users = SystemNotification.users_since('week')
      users.should eql(@user_list)
    end
    
    it 'all time' do
      Member.should_receive(:find).with(:all, :include => :user, :conditions => ['1=1 AND (users.status = ?)',User::STATUS_ACTIVE]).and_return(@member_list)
      users = SystemNotification.users_since('all')
      users.should eql(@user_list)
    end
    
  end

  describe 'should allow filtering of users' do
    before(:each) do
      @project1 = mock_model(Project)
      @project2 = mock_model(Project)
      @user1 = mock_model(User)
      @user2 = mock_model(User)
      @user3 = mock_model(User)
      @member1 = mock_model(Member, :user => @user1, :project => @project1)
      @member2 = mock_model(Member, :user => @user1, :project => @project2)
      @member3 = mock_model(Member, :user => @user2, :project => @project1)
      @member4 = mock_model(Member, :user => @user3, :project => @project2)
    end

    it 'based on project' do
      time = 7.days.ago
      projects = [@project1]
      SystemNotification.should_receive(:time_frame).at_least(:once).and_return(time)
      Member.should_receive(:find).
        with(:all, {
               :include => :user,
               :conditions => ["1=1 AND (users.status = ?) AND (users.last_login_on > (?)) AND (project_id IN (?))",
                               User::STATUS_ACTIVE,
                               time,
                               projects]
             }).
        and_return([@member1, @member3])
      
      users = SystemNotification.users_since('week', :projects => projects)
      users.should eql([@user1, @user2])
    end
  end
end
