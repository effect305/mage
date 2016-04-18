module Mage
  class MageStep < ActiveRecord::Base
    belongs_to :object, polymorphic: true
  end
end
