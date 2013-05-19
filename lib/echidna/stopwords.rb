require "echidna/stopwords/version"

module Echidna
  module Stopwords
    CHINESE_DICT_PATH = File.join(File.dirname(__FILE__), '../../dicts/chinese_stopwords.txt')
    ENGLISH_DICT_PATH = File.join(File.dirname(__FILE__), '../../dicts/english_stopwords.txt')

    class <<self
      def load
        load_dict(CHINESE_DICT_PATH)
        load_dict(ENGLISH_DICT_PATH)
      end

      def reject(words)
        # for every word that is not single character and not a username and is not a stopword
        words.select { |word| !single_character?(word) && !username?(word) && !is?(word) }
      end

      # add a stopword (TODO: rename)
      def add(word)
        $redis.sadd key, word
      end

      # remove all the stopwords by removing the set
      def flush
        $redis.del key
      end

      # is this a stopword?
      def is?(word)
        $redis.sismember key, word
      end

      # is this a single character word?
      def single_character?(word)
        word.length == 1
      end

      # tencent usernames start with @
      def username?(word)
        word[0] == '@'
      end

      private
      def key
        "stopwords"
      end

      def load_dict(filename)
        File.open(filename, 'r') do |file|
          file.each_line do |line|
            Stopword.add(line.strip)
          end
        end
      end
    end
  end
end
