module Unrestful
  class Error < StandardError; end
  class FailError < Error; end
  class AuthError < Error; end 
  class NotLiveError < Error; end 
  class LiveError < Error; end
end