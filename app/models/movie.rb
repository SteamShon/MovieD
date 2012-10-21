class Movie < ActiveRecord::Base
  attr_accessible :title, :id, :created_at, :updated_at, :original_id, :image

  searchable do 
    text :title
  end

  def self.upload(file)
    ActiveRecord::Base.transaction do 
    IO.readlines(file).each{|line|
      #job_id, id, oid, title = line.split("|")
      id, oid, title, img = line.split(",")
      Movie.create(id: id, title: title, original_id: oid, image: img)
    }
    end
  end
  def self.all_posters(outfile)
    of = File.new(outfile, "w")
    cnt = 0
    self.all.each{|movie|
        cnt += 1
        if cnt % 1000 == 0
           puts cnt
        end
    	of.write("#{movie.id},#{movie.original_id},#{movie.poster}\n")
    }
    of.close
  end
  def poster
    require "nokogiri"
    require 'open-uri'
    require 'net/http'
    result = naver_movie_url
    doc = Nokogiri::HTML(result)
    begin
       img_src = doc.css('div[class="wide_info_area"] div[class="poster"] img')[0]['src']
    rescue
       ""
    end    
  end

  def naver_movie_url
    require 'net/http'
    url = URI.encode("http://movie.naver.com/movie/bi/mi/basic.nhn?code=#{original_id}")
    req = Net::HTTP.get(URI.parse(url))
  end

  def self.top_movies(page)
    require 'net/http'
    url = URI.encode("http://movie.naver.com/movie/sdb/rank/rmovie.nhn?sel=pnt&date=#{DateTime.now.strftime('%Y%m%d')}&page=#{page}")
    ret = Net::HTTP.get(URI.parse(url))
    doc = Nokogiri::HTML(ret)
    tops = doc.css('tbody a').map{ |t| t['title'] }
    movies = []
    tops.select{|t| t != nil}.each{|t| 
      #movies << Movie.where("title like ?", "#{t}%")[0]
      m = Movie.search{ fulltext t }.results
      if m.size > 0
        movies << m[0]
      end
    }
    movies
  end
end
