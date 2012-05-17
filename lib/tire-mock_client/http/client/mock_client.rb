require 'rest_client'
require 'tire/http/response'
require 'tire/http/client'
require 'active_support/json'

module Tire
  module Http
    module Client
      class MockClient
        def initialize(*args)
          raise "MockClient - initialized with #{args.inspect}"
        end

        def method_missing(*args)
          raise "MockClient - instance method called: #{args.inspect}"
        end

        def self.method_missing(*args)
          raise "MockClient - class method called: #{args.inspect}"
        end

        #when specs fail you must have this implemented
        def self.to_ary
          [self.to_s]
        end

        def self.head(address)
          # Tire calls this to determine if the index needs to be created. If it returns 200, it assumes that the index has already been created.
          Tire::HTTP::Response.new('', 200)
        end

        def self.post(address, json)
          self.log "MockClient.post #{address}, #{json}"
          request = address.split('/')
          id = request.pop
          type = request.pop
          index = request.pop
          words = ActiveSupport::JSON.decode(json).values.flatten.map { |value| value.to_s.split(' ') }.flatten
          self.log "MockClient.post words = #{words.inspect}"
          ids_to_json[id] = ActiveSupport::JSON.decode(json)
          words.each do |word|
            hash = {:id => id, :type => type, :index => index}
            if words_to_ids[word]
              words_to_ids[word] << hash unless words_to_ids[word].include?(hash)
            else
              words_to_ids[word] = [hash]
            end
          end
          Tire::HTTP::Response.new(%({"ok":true,"_index":"#{index}","_type":"#{type}","_id":"#{id}","_version":1}), 201).tap do |response|
            self.log "MockClient.post response = #{response}"
          end
        end

        def self.get(address, json)
          split_address = address.gsub('http://','').split("/")

          the_filter = split_address[-2] if split_address[0] != split_address[-2]
          self.log "MockClient.get #{address}, #{json}"
          query = ActiveSupport::JSON.decode(json)['query']['query_string']['query']
          ids = words_to_ids[query]

          results = Array(ids).inject([]) do |collector, id|
            if the_filter.nil? || id[:index] == the_filter
              collector << {_index: id[:index], _type: id[:type], _id: id[:id], _score: 1.0, _source: ids_to_json[id[:id]]}
            else
              collector
            end
          end

          Tire::HTTP::Response.new(%({"took":0,"timed_out":false,"_shards":{"total":20,"successful":20,"failed":0},"hits":{"total":#{results.size},"max_score":10.0,"hits":#{results.to_json}}}), 200).tap do |response|
            self.log "MockClient.get response = #{response}"
          end
        end

        def self.delete(address)
          @words_to_ids = {}
          @ids_to_json = {}
          Tire::HTTP::Response.new('{"ok":true,"acknowledged":true}', 200)
        end

        def self.put(address, json)
          raise "MockClient.put #{address}, #{json}"
        end

        def self.log(text)
          logger.call text
        end

        private

        def self.words_to_ids
          @words_to_ids ||= {}
        end

        def self.ids_to_json
          @ids_to_json ||= {}
        end

        def self.logger
          @logger ||= Tire::Configuration.logger.public_method(:write)
        end

        def self.logger=(val)
          @logger = val
        end
      end
    end
  end
end
