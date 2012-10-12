class User < ActiveRecord::Base 
  attr_accessible :email, :name, :password, :password_confirmation
  has_many :tags
  has_many :rates

  has_secure_password
  before_save { self.email = self.email.downcase }
  before_save :create_remember_token
  
  validate :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX },
  uniqueness: { case_sensitive: false }
  validates :password, presence: true, length: { minimum: 6 }
  validates :password_confirmation, presence: true


  def self.insert_ratings(user_id, tag_id)
    puts user_id, tag_id
    require 'redis'
    rates = Rate.where("user_id = ? and tag_id = ?", user_id, tag_id)
    rate_vector = rates.collect{|rate| "#{rate.movie_id}:#{rate.rate}"}.join(",")
    redis = Redis.new
    redis.select(2)
    redis.set(user_id.to_s, rate_vector);
  end

  def self.select_ratings(user_id)
    require 'net/http'
    url = URI.parse("http://0.0.0.0:20008/?user_id=#{user_id}")
    result = Net::HTTP.get(url)
    result.split(",").collect do |t|
      id, score = t.split(":")
      {"id" => id, "score" => score }
    end
  end



  private
    def create_remember_token
      self.remember_token = SecureRandom.urlsafe_base64
    end
end
