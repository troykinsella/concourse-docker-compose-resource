require 'spec_helper'
require 'open3'
require 'json'

describe "integration:output" do

  let(:out_file) { '/opt/resource/out' }
  let(:mockelton_out) { '/resource/spec/fixtures/mockleton.out' }

  after(:each) do
    File.delete mockelton_out if File.exists? mockelton_out
  end

  it "should return an empty version" do
    stdin = {
        "source" => {
            "host" => "example.com"
        }
    }.to_json

    stdout, stderr, status = Open3.capture3("#{out_file} .", :stdin_data => stdin)

    expect(status.success?).to be true
    expect(stdout).to eq("{\n  \"version\": {\n    \"digest\": \"sha256:\"\n  }\n}\n")
  end
end
