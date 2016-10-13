RSpec.describe Lurch::Query do
  let(:json_api_headers) { { "Content-Type" => "application/vnd.api+json", "Accept" => "application/vnd.api+json" } }

  let(:url) { "http://example.com" }
  let(:store) { Lurch::Store.new(url: url) }
  let(:type) { :people }
  let(:query) { Lurch::Query.new(store) }

  describe "#from" do
    before { query.from(type) }

    it "adds the specified type to the query" do
      expect(query.inspect).to eq "#<Lurch::Query[Person]>"
    end
  end

  describe "#filter" do
    before { query.filter(name: "John") }

    it "adds the specified filter to the query" do
      expect(query.inspect).to eq "#<Lurch::Query \"filter[name]=John\">"
    end
  end

  describe "#find" do
    context "when the specified resource isn't in the store" do
      before do
        stub_request(:get, "example.com/people/1")
          .with(headers: json_api_headers)
          .to_return(File.new(File.expand_path("../../responses/find.txt", __FILE__)))
      end

      it "sends a GET request to the server, stores the returned resource in the store and responds with the resource" do
        person = query.from(:people).find(1)
        expect(person.id).to eq 1
        expect(store.peek(:people, 1)).to eq person
      end
    end
  end

  describe "#all" do
    before do
      stub_request(:get, "example.com/people")
        .with(headers: json_api_headers)
        .to_return(File.new(File.expand_path("../../responses/all.txt", __FILE__)))
    end

    it "sends a GET request to the server, stores the returned resources in the store and responds with the resources" do
      people = query.from(:people).all
      expect(people.count).to eq 2
      expect(store.peek(:people, 1)).to be
      expect(store.peek(:people, 2)).to be
    end
  end

  describe "#inspect" do
    subject { query.inspect }
    it { is_expected.to be_a(String) }
  end
end