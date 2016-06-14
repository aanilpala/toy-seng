require_relative '../lib/indexBuilder'

describe IndexBuilder do

  before :all do

    @invInd = {}
    @mini_corpus = "spec/resources/mini_simplewiki.tsv"

  end

  describe '#insert' do
    context 'given a corpus' do
      it 'should build an inverse index where the summation of values of first level keys (doc-freqs) equal to the count of total posting hash keys' do

        CSV.foreach(@mini_corpus, { :col_sep => "\t", quote_char: "\x00" }) do |docId, title, entry|

          docId = docId.to_i

          terms = Tokenizer.tokenize(entry)
          terms.map! { |term| Stemmer.stem(term) }

          tfHash = terms.inject({}) do |accHash, term|
            accHash[term] = 0 if accHash[term].nil?
            accHash[term] += 1
            accHash
          end

          tfHash.each do |term, tf|
            IndexBuilder.insert(@invInd, term, docId, tf)
          end

        end

        expect(@invInd.keys.inject(0) { |sum, key| sum += @invInd[key][:postingHash].keys.length; sum }).to eql(@invInd.keys.inject(0) { |sum, key| sum += @invInd[key][:df]; sum})
      end
    end
  end

end