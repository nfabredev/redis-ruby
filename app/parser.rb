class Parser
    SKIPPED_STRING_DESCRIPTOR = /[*$]\d+/
  
    def initialize(message)
      @message = message
    end
  
    def parse
      @message.split("\r\n").reject { |element| (element =~ SKIPPED_STRING_DESCRIPTOR) }
    end
end