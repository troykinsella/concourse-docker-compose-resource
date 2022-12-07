require 'spec_helper'
require 'open3'
require 'json'

describe "integration:input" do

  let(:out_file) { '/opt/resource/out' }
  let(:mockelton_out) { '/resource/spec/fixtures/mockleton.out' }

  after(:each) do
    File.delete mockelton_out if File.exists? mockelton_out
  end

  it "requires a host" do
    stdout, stderr, status = Open3.capture3("#{out_file} .", :stdin_data => "{}")

    expect(status.success?).to be false
    expect(stderr).to eq %(a docker host must be defined\n)

  end

end
