module ApplicationHelper
  def full_title(page_title)
    base_title = ""
    if page_title.empty?
      base_title
    else
      "#{base_title} | #{page_title}"
    end
  end
  def naver_movie_url(query)
  	"http://movie.naver.com/movie/search/result.nhn?query=#{query}&ie=utf8"
  end
  def naver_movie(movie_id)
    "http://movie.naver.com/movie/bi/mi/basic.nhn?code=#{movie_id}"
  end
end
