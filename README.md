# toy-seng
a toy in-memory search-engine as POC

### How to Use

```
make
./run <path_to_the_corpus>
```

### Runtime Performance

### Indexing Performance

For the indexation of the corpus given, a hash whose keys are the keywords that occur in the corpus and whose values are an object of a single integer (which is document frequency of the corresponding term and another hash which is a mapping from the documents containing the corresponding term to the term frequency of the term is built. Furthermore, another separate hash which maps from document ids to the stored fields (in the current implementation, only the title of the documents' of the documents is constructed. This means for a given document, three hash insertion operation is done. Hash insertion operation has constant time complexity. Therefore, given a corpus of *n* documents, the running time will be proportional to *n* meaning indexation have linear time complexity.

Indexing runs in a sequential way in the current implementation. That is, it processes the documents one by one. A parallelized implementation would speed it up. However, the parallel threads would be modifying the same memory space for inserting into the hashes requiring the use of mutexes which would be the limiting factor for the performance. In other words, hash insertion has to be sequential making it the bottleneck of the indexing operation. Preprocessing parts such as stemming, tokenization, etc can benefit parallelism without trouble.

### Querying Performance

Given a query, the performance of the tokenization and stemming operations (preprocessing steps) are proportional to the query length. As for finding the documents that matches the individual query terms, it is proportional to the number of query terms as the for each query term identifying the documents it matches and checking the term frequency in that document is a constant time operation due to the way hashmaps work. For each query term, another hash which maps from the matched documents to how many of the query terms it contained is constructed. This construction includes as many insert operations as there are query, matched document pair is. Thus, it can be bounded by *t x d* where *t* is the number of query terms and *d* is the maximum number of document a search term is contained. After the construction of the mentioned match counts hash, the documents that didn't match the minimum match criteria is eliminated, this means another pass over the hash keys. Finally, sorting the scores calculated for the each document has the *d x log(d)* complexity where *d* is the number of documents satisfying the minimum match criteria.

Taking all the above operations account, querying time can be bounded by a multiple of *t x d + d x log(d)* where *t* is the number of search terms and d is the number of documents that contain at least one of the search term


### Limitations

#### Field-unaware Indexing

In the current implementation, only the description field of the documents are used for building the inverted index. In addition to it, in a separate hash with titles by document ids are stored and when ranking the matched documents. At the query-time, if the query term is occurring in the title of the document, it gets a bonus score for its *tf* score. In other words, the terms appearing in the titles are not taken into account in indexing but they are for ranking. A corner case where this approach fails is when a document has a term that occurs in its title but not in its description, it would not get matched before even ranking in case a query with that term is made.

What would be ideal is to have a schema of the documents to be indexed and queried and then either having different inverted indexes for different fields or having a single one with postingHashes which stores field-specific term queries. This would make it possible to specify the query fields as a query parameter and search only in some certain fields. Moreover, this would allow treating the matches in different fields of the documents differently for better control over the contribution of different field matches to the final score which is a mandatory feature for a real-life search engine.

#### No Phrase Matching

In the current implementation, Query tokenizer splits the text inputted for the query into terms and these query terms are always considered separately. However sometimes, looking at the terms entered next to each other together (phrase) captures the users intent better than checking them one by one. Therefore, ideally if a phrase occurs in a field of the document, this should contribute more to the final score of that document than the contribution of the terms in the phrase separately would. Phrase matching can be very powerful feature especially when implemented with 'entity recognition' which would boost the phrase weight even further in case it detects a named entity. For this feature, an alternative tokenizer which can extract the potential phrases should be implemented.

#### Sequential Stemming and Tokenization during Indexing

As the stemming and tokenization of the documents in the corpus doesn't have interdependencies, these tasks can be parallelized straightforwardly for faster indexing performance.


### Potential Improvements

As discussed in the above section, Field-aware indexing, Phrase Matching and Parallel Stemming and Tokenization are the improvements that would make sense (Listed in the order of priority)
