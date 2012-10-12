class Movie < ActiveRecord::Base
  attr_accessible :title, :id, :created_at, :updated_at

  searchable do 
    text :title
  end

  def self.upload(file)
    ActiveRecord::Base.transaction do 
    IO.readlines(file).each{|line|
      job_id, id, oid, title = line.split("|")
      Movie.create(id: id, title: title)
    }
    end
  end

  def poster
    require "nokogiri"
    require 'open-uri'
    require 'net/http'
    result = naver_movie_url
    doc = Nokogiri::HTML(result)
    img_srcs = doc.css('img').map{ |i| i['src'] }
    img_srcs.select{|i| i.include?("movie.phinf.naver.net")}[0]
  end

  def naver_movie_url
    require 'net/http'
    url = URI.encode("http://movie.naver.com/movie/search/result.nhn?query=#{title.strip}&ie=utf8")
    req = Net::HTTP.get(URI.parse(url))
  end
end