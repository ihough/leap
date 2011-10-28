require 'helper'

class TestLeap < Test::Unit::TestCase
  context "A generic person" do
    setup do
      @person = Person.new
    end
    
    # WARNING: calling '@person.traits' more than once clears all reports
    
    should 'naturally receive an International Psychics Association-compliant lucky number' do
      assert_equal 0, @person.deliberations[:traits].characteristics[:lucky_number]
      assert_equal [:ipa], @person.deliberations[:traits].reports.find{ |r| r.committee.name == :lucky_number }.quorum.compliance
    end
    
    # Although the :favorite_food 'from sweet tooth' quorum has the potential to comply with :iga,
    # it should only comply if the :sweet_tooth calculation complied with :iga
    should 'naturally receive a non International Gastronomics Association-compliant favorite food' do
      assert_equal "Ice cream", @person.deliberations[:traits].characteristics[:favorite_food]
      assert_equal [], @person.deliberations[:traits].reports.find{ |r| r.committee.name == :favorite_food }.quorum.compliance
    end
    
    should 'receive only IPA-compliant characteristics if it requests an IPA-compliant lucky number' do
      @person.traits(:comply => :ipa)
      assert_equal(@person.characteristics, {:magic_integer => 0, :lucky_number => 0})
      assert_equal [:ipa], @person.deliberations[:traits].reports.find{ |r| r.committee.name == :magic_integer }.quorum.compliance
      assert_equal [:ipa], @person.deliberations[:traits].reports.find{ |r| r.committee.name == :lucky_number }.quorum.compliance
    end
    
    should 'receive nothing if it requests an IGA-compliant favorite food' do
      @person.traits(:comply => :iga)
      assert_equal(@person.characteristics, {})
    end
  end
  
  context "An aged person" do
    setup do
      @person = Person.new :age => 5
    end
     
    # Although the :lucky_number 'normal magic method' has the potential to comply with :ipa,
    # it should only comply if the :magic_integer calculation complied with :ipa
    should 'naturally receive a non IPA-compliant lucky number' do
      assert_equal 36, @person.deliberations[:traits].characteristics[:lucky_number]
      assert_equal [], @person.deliberations[:traits].reports.find{ |r| r.committee.name == :lucky_number }.quorum.compliance
    end
    
    should 'instead receive an IPA-compliant lucky number if requested' do
      @person.traits(:comply => :ipa)
      assert_equal(@person.characteristics, {:age => 5, :magic_integer => 0, :lucky_number => 0})
      assert_equal [:ipa], @person.deliberations[:traits].reports.find{ |r| r.committee.name == :lucky_number }.quorum.compliance
    end
    
    # WTF?! the :sweet_tooth committee returns true but characteristics[:sweet_tooth] is false
    should 'naturally receive an IGA-compliant favorite food' do
      assert_equal "Pizza", @person.deliberations[:traits].characteristics[:favorite_food]
      assert_equal [:iga], @person.deliberations[:traits].reports.find{ |r| r.committee.name == :favorite_food }.quorum.compliance
    end
    
    # WTF?! why are we using the default committee for :sweet_tooth when :age is available?
    should 'remember how his lucky number and favorite food were determined' do
      assert_equal 'ninja style', @person.deliberations[:traits].reports.find{ |r| r.committee.name == :magic_integer }.quorum.name
      assert_equal 'normal magic method', @person.deliberations[:traits].reports.find{ |r| r.committee.name == :lucky_number }.quorum.name
      assert_equal 'from age', @person.deliberations[:traits].reports.find{ |r| r.committee.name == :sweet_tooth }.quorum.name
      assert_equal 'from sweet tooth', @person.deliberations[:traits].reports.find{ |r| r.committee.name == :favorite_food }.quorum.name
    end
    
    should 'only give quorums what they ask for' do
      assert_equal({}, @person.deliberations[:traits].reports.find{ |r| r.committee.name == :litmus }.conclusion)
    end
  end
  
  context "A clever aged person" do
    setup do
      @person = Person.new :magic_integer => 42, :age => 5
    end
    
    should 'be able to use his own magic integer in determining his lucky number' do
      assert_equal 1764, @person.deliberations[:traits].characteristics[:lucky_number]
    end
  end
  
  context "A named person" do
    setup do
      @person = Person.new :name => 'Matz'
    end
    
    should 'have access to the super magic method' do
      assert_equal 1, @person.deliberations[:traits].characteristics[:lucky_number]
    end
    
    should 'be able to stay in compliance with International Psychics Association guidelines' do
      @person.traits(:comply => :ipa)
      assert_equal 0, @person.characteristics[:lucky_number]
      assert_equal [:ipa], @person.deliberations[:traits].reports.find{ |r| r.committee.name == :lucky_number }.quorum.compliance
    end
  end
  
  context "A generic place" do
    setup do
      @place = Place.new
    end
    
    should 'have decent weather' do
      assert_equal :decent, @place.weather
    end
  end
  
  context "Vermont" do
    setup do
      @place = Place.new :name => 'Vermont', :seasonality => { :summer => :warm, :winter => :cold }
    end
    
    should 'be warm in the summer' do
      assert_equal :warm, @place.weather(:summer)
    end
  end
  
  context "A lazy subject" do
    setup do
      @thing = Thing.new
      @thing.anything rescue nil
    end
    
    should 'have proper implicit characteristics' do
      assert_equal Hash.new, @thing.deliberations[:anything].characteristics
    end
  end
  
  context "An impossible decision" do
    setup do
      @thing = Thing.new
    end
    
    should 'be impossible to make' do
      exception = assert_raise ::Leap::NoSolutionError do
        @thing.anything
      end
      
      assert_match(/No solution was found for "anything"/, exception.message)
    end
  end
  
  # I don't think this test applies any more - a Person's :traits decision doesn't really have a goal
  context "A difficult decision" do
    setup do
      @person = Person.new :name => 'Bozo'
    end
    
    should 'provide details about its apparent impossibility' do
      exception = assert_raise ::Leap::NoSolutionError do
        @person.traits :comply => :zeus
      end
      
      assert_match(/No solution was found for "lucky_number"/, exception.message)
      assert_match(/magic_float: ancient recipe, name: provided as input/, exception.message)
    end
  end
  
  context 'Seamus deciding about whether he can commit to a date' do
    setup do
      @seamus = Seamus.new
    end
    
    should 'work for most people' do
      assert_equal :maybe, @seamus.can_i_commit_to_that_date
    end
    
    should 'work for BenT, who is easygoing' do
      assert_equal :maybe, @seamus.can_i_commit_to_that_date(:comply => :bent)
    end
    
    should 'never work for andy' do
      assert_raise ::Leap::NoSolutionError do
        @seamus.can_i_commit_to_that_date(:comply => :andy)
      end
    end
  end
  
  context 'A committee' do
    setup do
      class Owl
        include Leap
        decide :eye_size do
          committee :eye_size, :measures => :length do
          end
        end
      end
    end
    
    should 'remember options that it was given when it was created' do
      assert_equal :length, Owl.decisions[:eye_size].committees.first.options[:measures]
    end
  end
  
  context 'A decision without a master committee' do
    setup do
      @idea = Idea.new
    end
    
    should 'still compute' do
      @idea.value
      assert_equal({:cost => 0, :benefit => 1}, @idea.deliberations[:value].characteristics)
    end
    
    should 'provide easy access to committee reports' do
      assert_equal 0, @idea.value[:cost]
    end
  end
end
