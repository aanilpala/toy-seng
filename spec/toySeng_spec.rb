require_relative '../toySeng'
require 'csv'

describe ToySeng do

  before :all do

    mini_corpus = "spec/resources/mini_simplewiki.tsv"
    @seng = ToySeng.new(mini_corpus)
    @query = "first president"
    @nomatch_query = "thisshouldnotmatchanything"
    @bad_query = "how about this? 1234 @?±"

  end


  describe '#query' do
    context 'given a query with non-sense queryterms we know for sure that don\'t occur in the corpus' do
      it 'should raise \'No Match\' error' do
        expect{@seng.query(@nomatch_query) { |docId| "#{docId}" }}.to raise_error(QueryError,'No Match')
      end
    end

    context 'given a query with all stop-word or non-numerical queryterms' do
      it 'should raise \'Bad Query\' error' do
        expect{@seng.query(@bad_query) { |docId| "#{docId}" }}.to raise_error(QueryError,'Bad Query')
      end
    end

    context 'given a query (that\'s supposed to match some documents)' do
      it 'should return an array of documents which are in descending order of their score' do

        queryResult = @seng.query(@query, debug = true) { |docId| "#{docId}" }

        queryResultRanks = queryResult.map { |str| str.match(/<(.*?)>/)[1].to_f }

        expect(queryResultRanks).to eq(queryResultRanks.sort.reverse)
      end
    end
  end

end