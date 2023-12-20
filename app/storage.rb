require 'singleton'
require 'date'

class Storage
    include Singleton
  
    def initialize
      @store = {}
    end
  
    def set_value(key, value, exp = nil)
      millisecond_now = DateTime.now.strftime('%Q').to_i
      expiry_time = millisecond_now + exp.to_i
      @store[key] = exp ? { value:, exp: expiry_time } : { value: }
    end
  
    def get_value(key)
      @store[key]
    end
  end