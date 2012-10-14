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
    response = Net::HTTP.get(url)
    result = {}
    response.split(",").collect do |t|
      id, score = t.split(":")
      result[id.to_i] = score.to_f
    end
    result
  end

  def self.recommendations(user_id, tag_id)
    require 'redis'
    require 'net/http'
    redis = Redis.new
    redis.select(2)
    pos_rates = Rate.where("user_id = ? and tag_id = ? and rate > 0", user_id, tag_id)
    neg_rates = Rate.where("user_id = ? and tag_id = ? and rate < 0", user_id, tag_id)
    
    pos_vector = pos_rates.collect{|rate| "#{rate.movie_id}:#{rate.rate}"}.join(",")
    redis.set(user_id.to_s, pos_vector)
    pos_response = self.select_ratings(user_id)
    result = {}
    if pos_rates.size > 0 and neg_rates.size > 0
      neg_vector = neg_rates.collect{|rate| "#{rate.movie_id}:10"}.join(",")
      redis.set(user_id.to_s, neg_vector)
      neg_response = self.select_ratings(user_id)
      pos_response.each_pair{|k, v|
        cur = v
        if neg_response.has_key?(k)
          cur -= neg_response[k]
        end
        if cur > 0
          result[k] = cur
        end
      }
    elsif pos_rates.size > 0
      result = pos_response
    elsif neg_rates.size > 0
      neg_vector = neg_rates.collect{|rate| "#{rate.movie_id}:10"}.join(",")
      redis.set(user_id.to_s, neg_vector)
      result = self.select_ratings(user_id)
    end
    result.sort_by{|k, v| v}.reverse    
  end

  private
    def create_remember_token
      self.remember_token = SecureRandom.urlsafe_base64
    end
end
