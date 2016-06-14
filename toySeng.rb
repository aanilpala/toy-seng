require './lib/tokenizer'
require './lib/stemmer'
require './lib/indexBuilder'
require './lib/queryError'
require 'csv'
require 'ruby-progressbar'

class ToySeng

  attr_reader :docId2title, :invInd

  TITLE_WEIGHT = 4
  DESC_WEIGHT = 1

  def initialize(corpus)

    @docId2title = {}
    @invInd = {}


    @corpus_size = `wc -l #{corpus}`.to_i
    progressbar = ProgressBar.create(:format => '%a %e %P% Indexing in Progress: %c from %C', :total => @corpus_size)

    CSV.foreach(corpus, { :col_sep => "\t", quote_char: "\x00" }) do |docId, title, entry|

      docId = docId.to_i

      @docId2title[docId] = title

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

      progressbar.increment
    end

  end

  def getTitle(docId)
    @docId2title[docId]
  end

  def parse(query)
    terms = Tokenizer.tokenize(query)
    terms.map! { |term| Stemmer.stem(term) }
    terms.uniq!

    raise QueryError.new, 'Bad Query' if terms.empty?

    terms
  end

  def match(queryTerms) # match criteria exact match for the queries up to two terms. for bigger queries, match at least 60% of the query terms.

    minMatch = queryTerms.length > 2 ? (queryTerms.length*0.60).ceil : queryTerms.length

    docsByTerms = {}

    queryTerms.each do |term|
      docsByTerms[term] = invInd[term][:postingHash] unless invInd[term].nil?
    end

    raise QueryError.new, 'No Match' if docsByTerms.empty?

    matchCounts = docsByTerms.keys.inject({}) do |accHash, term|
      docsByTerms[term].keys.each do |docId|
        accHash[docId] = 0 if accHash[docId].nil?
        accHash[docId] += 1
      end
      accHash
    end

    matchedDocs = []

    matchCounts.keys.each do |docId|
      matchedDocs << docId if matchCounts[docId] >= minMatch
    end

    raise QueryError.new, 'No Match' if matchedDocs.empty?

    matchedDocs
  end

  def rank(queryTerms, matchedDocs)

    rankedDocs = {}

    queryTerms.each do |term|

      next if invInd[term].nil?

      df = invInd[term][:df]

      idf_score = Math.log10(@corpus_size.to_f/df)

      matchedDocs.each do |docId|

        tf = @invInd[term][:postingHash][docId]

        next if tf.nil?

        tf *= DESC_WEIGHT

        tf += getTitle(docId).count(term) * TITLE_WEIGHT # title match bonus

        tf_score = 1 + Math.log10(tf)
        tf_idf_score = tf_score * idf_score

        rankedDocs[docId] = 0.0 if rankedDocs[docId].nil?
        rankedDocs[docId] += tf_idf_score

      end

    end
    rankedDocs
  end

  def query(query, debug = false)
    raise QueryError.new, 'No formatting block given' unless block_given?

    terms = parse(query)
    matchedDocs = match(terms)
    rankedDocs = rank(terms, matchedDocs)

    orderedDocIds = rankedDocs.keys.sort_by { |docId| -1*rankedDocs[docId] } # -1 to reverse the ascending order

    debug ? orderedDocIds.map { |docId| "#{yield docId} <#{rankedDocs[docId]}>" } : orderedDocIds.map { |docId| yield docId }

  end

end

