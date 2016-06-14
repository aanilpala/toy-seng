require_relative '../lib/tokenizer'

describe Tokenizer do

  before :all do
    @empty_string = ''
    @two_term_string_with_a_stopword_containing_apostrophe = 'you\'ll see'
    @non_letter_term = '1928'
    @string_with_a_non_letter_term = 'overture' + ' ' + @non_letter_term
    @string_with_consecutive_spaces_and_non_letter_chars = 'weird    string    ?!??'
    @string_full_of_stop_words = 'it\'s below the both'
  end

  describe '#tokenize' do
    context 'given an empty string' do
      it 'should return empty array' do
        expect(Tokenizer.tokenize(@empty_string)).to eql([])
      end
    end

    context 'given a two-term string with a stopword containing apostrophe' do
      it 'should return an array with single term' do
        expect(Tokenizer.tokenize(@two_term_string_with_a_stopword_containing_apostrophe).length).to eql(1)
      end
    end

    context 'given a string with a non-letter term' do
      it 'should return an array without that non-letter term' do
        expect(Tokenizer.tokenize(@string_with_a_non_letter_term).include?(@non_letter_term)).to be false
      end
    end

    context 'given a string with contagious non-letter chars' do
      it 'should return an array without empty string elements' do
        expect(Tokenizer.tokenize(@string_with_consecutive_spaces_and_non_letter_chars).include?(@empty_string)).to be false
      end
    end

    context 'given a string with only stop words' do
      it 'should return empty array' do
        expect(Tokenizer.tokenize(@string_full_of_stop_words)).to eql([])
      end
    end

  end

end