class Rate < ActiveRecord::Base
  attr_accessible :movie_id, :rate, :tag_id, :user_id
  belongs_to :movie
  def self.rates
    [["Hate This!", -1], ["Bad", 2], ["Mediocre", 4], ["OK", 6], ["Good", 8], ["Great!", 10]]
  end
end
