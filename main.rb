require './toySeng'

corpus = ARGV[0]
seng = ToySeng.new(corpus)

while true
  print 'search> '
  query = $stdin.gets.chomp

  break if query.eql? 'quit'

  begin
    queryResult = seng.query(query, debug = false) { |docId| "#{docId} #{seng.getTitle(docId)}" }

    queryResult.each do |resultItem|
      puts resultItem
    end

  rescue QueryError => e
    puts e
  end

  puts ''
end