require_relative '../../lib/tire-mock_client'

describe Tire::Http::Client::MockClient do

  before do
    described_class.logger = lambda { |a|}
  end

  context 'head response' do
    subject { described_class.head 'url' }
    its(:code) { should be(200) }
  end

  context 'response of posting new objects to be indexed' do
    let(:index) { 'questions_of_the_day' }
    let(:type) { 'question_of_the_day' }
    let(:id) { '4edd1353f956f718aa000001' }
    let(:object) { %[{"text":"Am I tomorrow's question?","choices_text":[],"display_date":"2011-12-06"}] }
    subject { described_class.post "http://url/#{index}/#{type}/#{id}", object }

    its(:code) { should be(201) }
    its(:body) { should == %[{"ok":true,"_index":"#{index}","_type":"#{type}","_id":"#{id}","_version":1}] }
  end

  describe 'getting search results for something we put in' do
    #MockTireTracker.get http://localhost:9200/_search, {"query":{"query_string":{"query":"other_user"}},"filter":{"or":[{"missing":{"field":"display_date"}},{"range":{"display_date":{"from":"2011-11-05T18:54:36Z","to":"2011-12-05"}}}]},"size":10,"from":0}
    #MockTireTracker.get response = 200 : {"took":6,"timed_out":false,"_shards":{"total":20,"successful":20,"failed":0},"hits":{"total":1,"max_score":2.2448173,"hits":[{"_index":"profiles","_type":"profile","_id":"4edd135cf956f718aa000020","_score":2.2448173, "_source" : {"_id":"4edd135cf956f718aa000020","user_id":"4edd135cf956f718aa00001b","nickname":"other_user","avatar_url":null,"gender":null,"tags_array":[]}}]}}

    let(:id1) { "4edd135cf956f718aa000020" }
    let(:index1) { "profiles" }
    let(:type1) { "profile" }
    let(:object1) { %[{"_id":"#{id1}","user_id":"4edd135cf956f718aa00001b","nickname":"other_user","avatar_url":null,"gender":null,"tags_array":[]}] }

    let(:id2) { '4edd1353f956f718aa000001' }
    let(:index2) { 'questions_of_the_day' }
    let(:type2) { 'question_of_the_day' }
    let(:object2) { %[{"text":"Am I tomorrow's question, other_user","choices_text":[],"display_date":"2011-12-06"}] }

    before do
      described_class.post "http://url/#{index1}/#{type1}/#{id1}", object1
      described_class.post "http://url/#{index2}/#{type2}/#{id2}", object2
    end

    context 'searching everything' do
      let(:query) { %[{"query":{"query_string":{"query":"other_user"}},"filter":{"or":[{"missing":{"field":"display_date"}},{"range":{"display_date":{"from":"2011-11-05T18:54:36Z","to":"2011-12-05"}}}]},"size":10,"from":0}] }

      after do
        described_class.delete "http://url/profiles"
      end

      subject { described_class.get "http://url/_search", query }

      its(:body) { should == %[{"took":0,"timed_out":false,"_shards":{"total":20,"successful":20,"failed":0},"hits":{"total":2,"max_score":10.0,"hits":[{"_index":"#{index1}","_type":"#{type1}","_id":"#{id1}","_score":1.0,"_source":#{object1}},{"_index":"#{index2}","_type":"#{type2}","_id":"#{id2}","_score":1.0,"_source":#{object2}}]}}] }
      its(:code) { should be(200) }
    end
    
    context 'searching a specific index' do
      let(:query) { %[{"query":{"query_string":{"query":"other_user"}},"filter":{"or":[{"missing":{"field":"display_date"}},{"range":{"display_date":{"from":"2011-11-05T18:54:36Z","to":"2011-12-05"}}}]},"size":10,"from":0}] }

      after do
        described_class.delete "http://url/profiles"
      end

      subject { described_class.get "http://url/#{index1}/_search", query }

      its(:body) { should == %[{"took":0,"timed_out":false,"_shards":{"total":20,"successful":20,"failed":0},"hits":{"total":1,"max_score":10.0,"hits":[{"_index":"#{index1}","_type":"#{type1}","_id":"#{id1}","_score":1.0,"_source":#{object1}}]}}] }
      its(:code) { should be(200) }
    end
  end

  describe 'deleting an index' do
    let(:id) { "4edd135cf956f718aa000020" }
    let(:index) { "profiles" }
    let(:type) { "profile" }
    let(:object) { %[{"_id":"#{id}","user_id":"4edd135cf956f718aa00001b","nickname":"other_user","avatar_url":null,"gender":null,"tags_array":[]}] }
    let(:query) { %[{"query":{"query_string":{"query":"other_user"}},"filter":{"or":[{"missing":{"field":"display_date"}},{"range":{"display_date":{"from":"2011-11-05T18:54:36Z","to":"2011-12-05"}}}]},"size":10,"from":0}] }

    before do
      described_class.post "http://url/#{index}/#{type}/#{id}", object
    end

    describe 'it clears the data' do
      before do
        described_class.delete "http://url/profiles"
      end
      
      subject { described_class }

      its(:words_to_ids) { should == {} }
      its(:ids_to_json) { should == {} }
    end

    describe 'its response' do
      subject { described_class.delete "http://url/profiles" }

      its(:code) { should be(200) }
      its(:body) { should == %[{"ok":true,"acknowledged":true}] }
    end
  end

  #MockTireTracker.post http://localhost:9200/questions_of_the_day/question_of_the_day/4edd1353f956f718aa000001, {"text":"Am I tomorrow's question?","choices_text":["I don't know","yes","no"],"display_date":"2011-12-06"}
  #MockTireTracker.post response = 200 : {"ok":true,"_index":"questions_of_the_day","_type":"question_of_the_day","_id":"4edd1353f956f718aa000001","_version":2}

  #MockTireTracker.get http://localhost:9200/_search, {"query":{"query_string":{"query":"other_user"}},"filter":{"or":[{"missing":{"field":"display_date"}},{"range":{"display_date":{"from":"2011-11-05T18:54:36Z","to":"2011-12-05"}}}]},"size":10,"from":0}
  #MockTireTracker.get response = 200 : {"took":6,"timed_out":false,"_shards":{"total":20,"successful":20,"failed":0},"hits":{"total":1,"max_score":2.2448173,"hits":[{"_index":"profiles","_type":"profile","_id":"4edd135cf956f718aa000020","_score":2.2448173, "_source" : {"_id":"4edd135cf956f718aa000020","user_id":"4edd135cf956f718aa00001b","nickname":"other_user","avatar_url":null,"gender":null,"tags_array":[]}}]}}


end