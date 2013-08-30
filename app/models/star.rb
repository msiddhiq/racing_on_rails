class Star < ActiveRecord::Base
  belongs_to :event
  belongs_to :person
  
  validates_presence_of :event
  validates_presence_of :person
end
