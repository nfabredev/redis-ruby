require "redis"
require "rspec"
require 'spec_helper'

RSpec.describe RedisServer, "#listen" do
    it 'responds to ping' do
        r = Redis.new(port: 6380)
        expect(r.ping).to eq "PONG"
    end
end
