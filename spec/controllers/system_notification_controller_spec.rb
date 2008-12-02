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
