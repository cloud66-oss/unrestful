module Unrestful
  class Error < StandardError; end
  class FailError < Error; end
  class AuthError < Error; end 
end