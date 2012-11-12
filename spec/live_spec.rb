# Ruby-Sesame: a Ruby library to interact with OpenRDF.org's Sesame RDF
# framework via its REST interface.
#
# Copyright (C) 2008 Paul Legato (pjlegato at gmail dot com).
#
# This file is part of Ruby-Sesame.
#
# Ruby-Sesame is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Ruby-Sesame is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Ruby-Sesame.  If not, see <http://www.gnu.org/licenses/>.
#
####
####
#
# This specifies the behavior when a live Sesame 2.0 server is running
# on localhost:8080 with the default configuration and a repository called "test".
#
# The contents of the "test" repository may be altered/erased by these tests.
#
# N.B. It will fail if that is not the case, through no fault of its own.
#

require File.join(File.expand_path(File.dirname(__FILE__)), 'spec_helper')

begin
  require 'xml/libxml' # Doesn't matter if not installed (test will check this)
rescue LoadError => e
end

URL = "http://localhost:8080/openrdf-sesame"

TUPLE_QUERY = <<END
PREFIX rdf:<http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX sys:<http://www.openrdf.org/config/repository#>
SELECT ?id ?p ?o
WHERE {
 ?id sys:repositoryID "SYSTEM" .
 ?id ?p ?o .
}
END

GRAPH_QUERY = <<END
PREFIX rdf:<http://www.w3.org/1999/02/22-rdf-syntax-ns#>
PREFIX sys:<http://www.openrdf.org/config/repository#>
DESCRIBE ?id
WHERE {
 ?id sys:repositoryID "SYSTEM" .
}
END

describe "Live Ruby-Sesame tests (**** N.B. these will fail unless you have a properly configured Sesame server running on localhost!)" do
  it_should_behave_like "shared RubySesame specs"

  before do
    @server = RubySesame::Server.new(URL)
    @system = @server.repository("SYSTEM")
    @test = @server.repository("test")
  end

  it "should be able to query the Sesame server's version number" do
    @server.protocol_version.should == 4
  end

  it "should be able to get a list of repositories" do
    repos = nil
    lambda { repos = @server.repositories }.should_not raise_error
    repos.each {|r| r.class.should == RubySesame::Repository }
    repos.select {|r| r.title == "System configuration repository" }.size.should == 1
    repos.select {|r| r.id == "SYSTEM" }.size.should == 1
  end

  it "should auto-query upon initialization if told to do so" do
    server = nil
    lambda { server = RubySesame::Server.new(URL, true) }.should_not raise_error
    server.protocol_version.should == 4
  end

  it "should be able to run a GET JSON tuple query on the System repository" do
    result = nil

    lambda { result = JSON.parse(@system.query(TUPLE_QUERY)) }.should_not raise_error
    result["head"].should == { "vars" => ["id", "p", "o"] }
    result["results"]["bindings"].size.should == 4

    result["results"]["bindings"].select{|x| x["o"]["value"] == "http://www.openrdf.org/config/repository#Repository"}.first["p"]["value"].should == "http://www.w3.org/1999/02/22-rdf-syntax-ns#type"
    result["results"]["bindings"].select{|x| x["o"]["value"] == "SYSTEM"}.first["p"]["value"].should == "http://www.openrdf.org/config/repository#repositoryID"
    result["results"]["bindings"].select{|x| x["o"]["value"] == "System configuration repository"}.first["p"]["value"].should == "http://www.w3.org/2000/01/rdf-schema#label"
  end

  ## TODO: figure out how to verify that this actually does a POST and not a GET.
  it "should be able to run a POST JSON tuple query on the System repository" do
    result = nil

    lambda { result = JSON.parse(@system.query(TUPLE_QUERY, :method => :post)) }.should_not raise_error

    result["head"].should == { "vars" => ["id", "p", "o"] }
    result["results"]["bindings"].size.should == 4

    result["results"]["bindings"].select{|x| x["o"]["value"] == "http://www.openrdf.org/config/repository#Repository"}.first["p"]["value"].should == "http://www.w3.org/1999/02/22-rdf-syntax-ns#type"
    result["results"]["bindings"].select{|x| x["o"]["value"] == "SYSTEM"}.first["p"]["value"].should == "http://www.openrdf.org/config/repository#repositoryID"
    result["results"]["bindings"].select{|x| x["o"]["value"] == "System configuration repository"}.first["p"]["value"].should == "http://www.w3.org/2000/01/rdf-schema#label"
  end

  it "should be able to get XML tuple results from the System repository" do
    result = nil
    lambda { result = @system.query(TUPLE_QUERY, :result_type => RubySesame::DATA_TYPES[:XML]) }.should_not raise_error

    xml = nil
    lambda { xml = XML::Parser.string(result).parse }
  end

  it "should be able to get binary tuple results from the System repository" do
    result = nil
    lambda { result = @system.query(TUPLE_QUERY, :result_type => RubySesame::DATA_TYPES[:binary]) }.should_not raise_error

    result[0..3].should == "BRTR"
  end

  it "should be able to get RDFXML results for a graph query" do
    result = nil
    lambda { result = @system.query(GRAPH_QUERY, :result_type => RubySesame::DATA_TYPES[:RDFXML]) }.should_not raise_error

    xml = nil
    if Kernel.const_defined?(:XML)
      lambda { xml = XML::Parser.string(result).parse }.should_not raise_error
    end
  end

  it "should be able to get NTriples results for a graph query" do
    result = nil
    lambda { result = @system.query(GRAPH_QUERY, :result_type => RubySesame::DATA_TYPES[:NTriples]) }.should_not raise_error
  end

  it "should be able to get Turtle results for a graph query" do
    result = nil
    lambda { result = @system.query(GRAPH_QUERY, :result_type => RubySesame::DATA_TYPES[:Turtle]) }.should_not raise_error
  end

  it "should be able to get N3 results for a graph query" do
    result = nil
    lambda { result = @system.query(GRAPH_QUERY, :result_type => RubySesame::DATA_TYPES[:N3]) }.should_not raise_error
  end

  it "should be able to get TriX results for a graph query" do
    result = nil
    lambda { result = @system.query(GRAPH_QUERY, :result_type => RubySesame::DATA_TYPES[:TriX]) }.should_not raise_error
  end

  it "should be able to get TriG results for a graph query" do
    result = nil
    lambda { result = @system.query(GRAPH_QUERY, :result_type => RubySesame::DATA_TYPES[:TriG]) }.should_not raise_error
  end

  it "should be able to GET all statements with no arguments and Turtle-format results " do
    result = nil
    lambda { result = @system.get_statements() }.should_not raise_error
    result.should =~ /^@prefix rdf: <http:\/\/www.w3.org\/1999\/02\/22-rdf-syntax-ns#> .\n@prefix sys: <http:\/\/www.openrdf.org\/config\/repository#>/
  end

  it "should be able to GET all statements with RDFXML-format results " do
    result = nil
    lambda { result = @system.get_statements(:result_type => RubySesame::DATA_TYPES[:RDFXML]) }.should_not raise_error
    result.should =~ /^#{Regexp.quote("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<rdf:RDF\n\txmlns:rdf=\"http://www.w3.org/1999/02/22-rdf-syntax-ns#\"")}/
  end

  it "should be able to GET a subset of all statements by predicate" do
    result = nil
    # get a list of repository names
    lambda { result = @system.get_statements(:pred => "<http://www.openrdf.org/config/repository#repositoryID>") }.should_not raise_error

    result.should =~ /SYSTEM/
  end

  it "should be able to GET a subset of all statements by object" do
    result = nil
    # get a list of repository names
    lambda { result = @system.get_statements(:obj => "<http://www.openrdf.org/config/repository#RepositoryContext>") }.should_not raise_error

    result.should =~ / a /
  end

  it "should be able to get a list of contexts with at least 1 entry" do
    c = @system.contexts
    c.size.should >= 1
  end

  it "should be able to get a Hash of all namespaces from the repository" do
    ns = nil
    lambda { ns = @system.namespaces }.should_not raise_error
    ns.should == {
      "sys"=>"http://www.openrdf.org/config/repository#",
      "rdf"=>"http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    }
  end

  it "should be able to look up specific namespaces" do
    @system.namespace("NonExistentNamespace").should == nil
    @system.namespace("rdf").should == "http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    @system.namespace("sys").should == "http://www.openrdf.org/config/repository#"
  end

  it "should be able to create and delete namespaces" do
    @test.namespace("foo").should == nil

    lambda { @test.namespace!("foo", "http://bar.baz/asdf") }.should_not raise_error
    @test.namespace("foo").should == "http://bar.baz/asdf"

    lambda { @test.delete_namespace!("foo") }.should_not raise_error
    @test.namespace("foo").should == nil
  end

  it "should be able to delete all namespaces" do
    lambda { @test.namespace!("foo", "http://bar.baz/asdf") }.should_not raise_error
    lambda { @test.namespace!("bar", "http://bar.asdf.baz/asdf") }.should_not raise_error
    @test.namespace("foo").should == "http://bar.baz/asdf"
    @test.namespace("bar").should == "http://bar.asdf.baz/asdf"

    lambda { @test.delete_all_namespaces! }.should_not raise_error

    @test.namespace("foo").should == nil
    @test.namespace("bar").should == nil
  end


  TEST_DATA = <<END
@prefix rdf: <http://www.w3.org/1999/02/22-rdf-syntax-ns#>.
@prefix contact: <http://www.w3.org/2000/10/swap/pim/contact#>.

<http://www.example.com/test/foo/#{ Time.now.to_i }>
  rdf:type contact:Person;
  contact:fullName "Foo Bar";
  contact:mailbox <mailto:foo@bar.org>;
  contact:personalTitle "Mr.".
END

  it "should be able to add data to the test repository" do
    result = nil
    original_count = @test.size
    lambda { result = @test.add!(TEST_DATA) }.should_not raise_error
    @test.size.should == original_count + 4 # number of statements in TEST_DATA
  end

  it "should refuse to delete all statements if 'safety' is not specified" do
    result = nil
    lambda { @test.delete_statements! }.should raise_error
  end

  it "should delete all statements if 'safety' is false" do
    lambda { @test.add!(TEST_DATA) }.should_not raise_error
    @test.size.should > 0

    lambda { @test.delete_statements!({}, false) }.should_not raise_error
    @test.size.should == 0
  end

  it "should be able to delete all data from the test repository" do
    lambda { @test.add!(TEST_DATA) }.should_not raise_error
    @test.size.should > 0

    lambda { @test.delete_all_statements! }.should_not raise_error
    @test.size.should == 0
  end

  it "should be able to count the entries in the test repository" do
    result = nil
    lambda { result = @test.size }.should_not raise_error
  end

end
