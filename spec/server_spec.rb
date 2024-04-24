require "redis"
require "rspec"
require 'spec_helper'

random_string = (:A..:Z).to_a.shuffle[0,16].join

RSpec.describe RedisServer, "#listen" do
    it 'responds to ping' do
        r = Redis.new(port: 6380)
        expect(r.ping).to eq "PONG"
    end
    
    it 'handles concurrent clients' do
        2.times do |i|
            fork do
                r = Redis.new(port: 6380)
                expect(r.ping).to eq "PONG"
            end
        end
        Process.waitall
    end

    it 'handles the echo command' do
        r = Redis.new(port: 6380)
        expect(r.echo(random_string)).to eq random_string
    end
    
    it 'handles the set and get command' do
        r = Redis.new(port: 6380)
        
        key = random_string
        value = random_string
        
        expect(r.set(key, value)).to eq "OK"
        
        expect(r.get(key)).to eq value
    end
    
    it "handles set and get with expiry" do
        r = Redis.new(port: 6380)
        
        key = random_string
        value = random_string
        expiry = 100 # milliseconds
        half_expiry_in_seconds = expiry/1000.to_f/2 # seconds

        expect(r.set(key, value, px: expiry)).to eq "OK"

        sleep half_expiry_in_seconds
        expect(r.get(key)).to eq value
        
        sleep half_expiry_in_seconds
        expect(r.get(key)).to eq nil
    end
end