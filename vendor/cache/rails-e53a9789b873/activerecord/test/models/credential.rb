require 'models/credential_usage'

class Credential < ActiveRecord::Base
  has_many :credential_usages
end
