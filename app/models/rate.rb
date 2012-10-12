class Rate < ActiveRecord::Base
  attr_accessible :movie_id, :rate, :tag_id, :user_id
  belongs_to :movie

  
end
