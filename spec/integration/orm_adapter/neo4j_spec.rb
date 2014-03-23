require 'spec_helper'
require 'shared_examples/orm_adapter/example_app_shared'

module Neo4j
  module OrmSpec
    class User
      include Neo4j::ActiveNode

      property :name, :index => :exact
      property :rating, :type => Integer, :index => :exact
      has_n(:notes).to('Neo4j::OrmSpec::Note')
    end
  
    class Note 
      include Neo4j::ActiveNode

      property  :body, :index => :exact
      
      has_one(:owner).from('Neo4j::OrmSpec::User', :notes)
    end
  
    # here be the specs!
    describe '[Neo4j orm adapter]', :type => :integration do
      before :each do
        Neo4j::Session.current._query('MATCH (n) OPTIONAL MATCH (n)-[r]-() DELETE n,r;')
      end

      describe "the OrmAdapter class" do
        subject { Neo4j::ActiveNode::Adapter::OrmAdapter }
  
        specify "#model_classes should return all of the model classes (that are not in except_classes)" do
          subject.model_classes.should include(User, Note)
        end
      end
    
      it_should_behave_like "example app with orm_adapter" do
        let(:user_class) { User }
        let(:note_class) { Note }
      end
    end
  end
end