require "spec_helper"

describe Mongoid::Validations::UniquenessValidator do

  describe "#validate_each" do

    before do
      @document = Person.new
    end

    let(:validator) { Mongoid::Validations::UniquenessValidator.new(:attributes => @document.attributes) }

    context "when a document exists with the attribute value" do

      before do
        @criteria = stub(:empty? => false)
        Person.expects(:where).with(:title => "Sir").returns(@criteria)
        validator.validate_each(@document, :title, "Sir")
      end

      it "adds the errors to the document" do
        @document.errors[:title].should_not be_empty
      end

      it "should translate the error in english" do
        @document.errors[:title][0].should == "is already taken"
      end
    end

    context "when no other document exists with the attribute value" do

      before do
        @criteria = stub(:empty? => true)
        Person.expects(:where).with(:title => "Sir").returns(@criteria)
        validator.validate_each(@document, :title, "Sir")
      end

      it "adds no errors" do
        @document.errors[:title].should be_empty
      end
    end

    context "when defining a single field key" do

      context "when a document exists in the db with the same key" do

        context "when the document being validated is new" do

          let(:login) do
            Login.new(:username => "chitchins")
          end

          before do
            Login.expects(:where).with(:username => "chitchins").returns([ login ])
            validator.validate_each(login, :username, "chitchins")
          end

          it "checks the value of the key field" do
            login.errors[:username].should_not be_empty
          end
        end

        context "when the document being validated is not new" do

          context "when the id has not changed since instantiation" do

            let(:login) do
              login = Login.new(:username => "chitchins")
              login.instance_variable_set(:@new_record, false)
              login
            end

            before do
              Login.expects(:where).with(:username => "chitchins").returns([ login ])
              validator.validate_each(login, :username, "chitchins")
            end

            it "checks the value of the key field" do
              login.errors[:username].should be_empty
            end
          end

          context "when the has changed since instantiation" do

            let(:login) do
              login = Login.new(:username => "rdawkins")
              login.instance_variable_set(:@new_record, false)
              login.username = "chitchins"
              login
            end

            before do
              Login.expects(:where).with(:username => "chitchins").returns([ login ])
              validator.validate_each(login, :username, "chitchins")
            end

            it "checks the value of the key field" do
              login.errors[:username].should_not be_empty
            end
          end
        end
      end
    end
  end

  describe "#validate_each with :scope option given" do

    before do
      @document = Person.new(:employer_id => 3)
      @criteria = stub(:empty? => false)
    end

    let(:validator) { Mongoid::Validations::UniquenessValidator.new(:attributes => @document.attributes, 
                                                                    :scope => :employer_id) }

    it "should query only scoped documents" do
      Person.expects(:where).with(:title => "Sir", 
                                  :employer_id => @document.attributes[:employer_id]).returns(@criteria)
      validator.validate_each(@document, :title, "Sir")
    end
  end
  
  describe "validate :in external collection with custom :field" do
    before do
      UniqExternal.create :unique => "1"
    end
    
    it "should not be valid if not unique in external" do
      UniqIn.new(:ext_unique => "1").valid?.should == false
    end
    
    it "should be valid if unique in external" do
      UniqIn.new(:ext_unique => "2").valid?.should == true
    end
    
    it "should not update if changing to non unique in external" do
      u = UniqIn.new(:ext_unique => "2")
      u.save.should == true
      
      u.ext_unique = "1"
      u.save.should == false
    end
    
    it "should update if changing to unique in external" do
      u = UniqIn.new(:ext_unique => "2")
      u.save.should == true
      
      u.ext_unique = "3"
      u.valid?.should == true
    end
  end
end
