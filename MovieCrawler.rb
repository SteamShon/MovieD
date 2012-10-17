require 'net/http'
require 'nokogiri'

IO.readlines(ARGV[0]).each do |line|
  id, nid, title = line.strip().split(",")
  
  uri = URI.parse("http://movie.naver.com/movie/bi/mi/basic.nhn?code=#{nid}")
  req = Net::HTTP::Get.new(uri.request_uri)
  req.basic_auth 'shom83', '83shon'
  
  result = Net::HTTP.get(uri)
 
  doc = Nokogiri::HTML(result)
  info = doc.css('div[class="wide_info_area"]')[0]
  if info
    imgs = info.css('div[class="poster"] img')
    img = imgs.size > 0 ? imgs[0]['src'] : ""
    t = info.css('div[class="mv_info"] h3[class="h_movie"]')  
    movie_name = t.css('a')[0].content
    movie_en = t.css('strong[class="h_movie2"]')[0]['title'].gsub(/(\n|\t|\r)/, ' ').gsub(/>\s*</, '><').squeeze(' ')
    tmp = {}
    info.css('p[class="info_spec"] a').each do |a|
      k, v = a['href'].split("?")[-1].split("=")[0], a.content
      if a['class'] == "more" or a['class'] == "btn_help"
        next
      end
      if tmp.has_key?(k) == false
        tmp[k] = ""
      else 
        tmp[k] += "|"
      end
      tmp[k] += v
    end
    puts "#{id},#{nid},#{movie_name},#{movie_en},#{tmp.values.join(",")},#{img}"
  end
end
