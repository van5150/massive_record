require 'spec_helper'

describe MassiveRecord::ORM::Table do
  
  before do
    @connection ||= MassiveRecord::Connection.new(:host => MR_CONFIG['host'], :port => MR_CONFIG['port'])
  end
  
  describe "Init" do
    
  end
  
end
