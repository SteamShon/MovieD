require 'redis'
redis = Redis.new
redis.select(0)
IO.foreach("./data/naver_M_100") {|line| 
  row_id, vector = line.split("\t") 
  redis.set(row_id, vector)
}
