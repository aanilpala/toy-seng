module IndexBuilder

  def self.insert(invInd, term, docId, tf)

    invInd[term] = {:df => 0, :postingHash => {}} if invInd[term].nil?

    invInd[term][:df] += 1
    invInd[term][:postingHash][docId] = tf

  end

end