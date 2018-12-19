require 'spec_helper'
require 'open3'
require 'json'

describe "integration:docker-compose" do

  let(:out_file) { '/opt/resource/out' }
  let(:mockelton_out) { '/resource/mockleton.out' }

  after(:each) do
    File.delete mockelton_out if File.exists? mockelton_out
  end

  it "prints the version" do
    stdin = {
        "source" => {
            "host" => "foo"
        },
    }.to_json

    stdout, stderr, status = Open3.capture3("#{out_file} .", :stdin_data => stdin)

    expect(status.success?).to be true

    out = JSON.parse(File.read(mockelton_out))

    expect(out["sequence"].size).to be 2
    expect(out["sequence"][0]["exec-spec"]["args"]).to eq [
                                                              "docker-compose",
                                                              "-v"
                                                          ]
  end

  it "fails with unsupported command" do
    stdin = {
        "source" => {
            "host" => "foo"
        },
        "params" => {
            "command" => "nope"
        }
    }.to_json

    stdout, stderr, status = Open3.capture3("#{out_file} .", :stdin_data => stdin)

    expect(status.success?).to be false
    expect(stderr).to eq "Unsupported command: nope\nPossible commands: down, up\n"
  end

  describe "up" do

    it "generates default arguments" do
      stdin = {
          "source" => {
              "host" => "foo"
          },
      }.to_json

      stdout, stderr, status = Open3.capture3("#{out_file} .", :stdin_data => stdin)

      expect(status.success?).to be true

      out = JSON.parse(File.read(mockelton_out))

      expect(out["sequence"].size).to be 2
      expect(out["sequence"][1]["exec-spec"]["args"]).to eq [
                                                                "docker-compose",
                                                                "--host",
                                                                "foo:2376",
                                                                "-f",
                                                                "docker-compose.yml",
                                                                "up",
                                                                "-d",
                                                                "--no-build"
                                                            ]
    end

    it "overrides the compose file" do
      stdin = {
          "source" => {
              "host" => "foo"
          },
          "params" => {
              "compose_file" => "wicked.yml"
          }
      }.to_json

      stdout, stderr, status = Open3.capture3("#{out_file} .", :stdin_data => stdin)

      expect(status.success?).to be true

      out = JSON.parse(File.read(mockelton_out))

      expect(out["sequence"].size).to be 2
      expect(out["sequence"][1]["exec-spec"]["args"]).to eq [
                                                                "docker-compose",
                                                                "--host",
                                                                "foo:2376",
                                                                "-f",
                                                                "wicked.yml",
                                                                "up",
                                                                "-d",
                                                                "--no-build"
                                                            ]
    end

    it "generates options" do
      stdin = {
          "source" => {
              "host" => "foo"
          },
          "params" => {
              "options" => {
                  "no_deps" => true,
                  "force_recreate" => true,
                  "no_recreate" => true,
                  "renew_anon_volumes" => true,
                  "remove_orphans" => true,
                  "scale" => {
                      "service_a" => 3,
                      "service_b" => 4
                  }
              }
          }
      }.to_json

      stdout, stderr, status = Open3.capture3("#{out_file} .", :stdin_data => stdin)

      expect(status.success?).to be true

      out = JSON.parse(File.read(mockelton_out))

      expect(out["sequence"].size).to be 2
      expect(out["sequence"][1]["exec-spec"]["args"]).to eq [
                                                                "docker-compose",
                                                                "--host",
                                                                "foo:2376",
                                                                "-f",
                                                                "docker-compose.yml",
                                                                "up",
                                                                "-d",
                                                                "--no-build",
                                                                "--no-deps",
                                                                "--force-recreate",
                                                                "--no-recreate",
                                                                "--renew-anon-volumes",
                                                                "--remove-orphans",
                                                                "--scale",
                                                                "service_a=3",
                                                                "--scale",
                                                                "service_b=4"
                                                            ]
    end


    it "supplies services" do
      stdin = {
          "source" => {
              "host" => "foo"
          },
          "params" => {
              "services" => [
                  "service_a",
                  "service_b"
              ]
          }
      }.to_json

      stdout, stderr, status = Open3.capture3("#{out_file} .", :stdin_data => stdin)

      expect(status.success?).to be true

      out = JSON.parse(File.read(mockelton_out))

      expect(out["sequence"].size).to be 2
      expect(out["sequence"][1]["exec-spec"]["args"]).to eq [
                                                                "docker-compose",
                                                                "--host",
                                                                "foo:2376",
                                                                "-f",
                                                                "docker-compose.yml",
                                                                "up",
                                                                "-d",
                                                                "--no-build",
                                                                "service_a",
                                                                "service_b"
                                                            ]
    end


  end


  describe "down" do

    it "generates default arguments" do
      stdin = {
          "source" => {
              "host" => "foo"
          },
          "params" => {
              "command" => "down"
          }
      }.to_json

      stdout, stderr, status = Open3.capture3("#{out_file} .", :stdin_data => stdin)

      expect(status.success?).to be true

      out = JSON.parse(File.read(mockelton_out))

      expect(out["sequence"].size).to be 2
      expect(out["sequence"][1]["exec-spec"]["args"]).to eq [
                                                                "docker-compose",
                                                                "--host",
                                                                "foo:2376",
                                                                "-f",
                                                                "docker-compose.yml",
                                                                "down"
                                                            ]
    end

    it "generates options" do
      stdin = {
          "source" => {
              "host" => "foo"
          },
          "params" => {
              "command" => "down",
              "options" => {
                  "rmi" => "local",
                  "volumes" => true,
                  "remove_orphans" => true
              }
          }
      }.to_json

      stdout, stderr, status = Open3.capture3("#{out_file} .", :stdin_data => stdin)

      expect(status.success?).to be true

      out = JSON.parse(File.read(mockelton_out))

      expect(out["sequence"].size).to be 2
      expect(out["sequence"][1]["exec-spec"]["args"]).to eq [
                                                                "docker-compose",
                                                                "--host",
                                                                "foo:2376",
                                                                "-f",
                                                                "docker-compose.yml",
                                                                "down",
                                                                "--rmi",
                                                                "local",
                                                                "--volumes",
                                                                "--remove-orphans"
                                                            ]
    end

    it "ignores services" do
      stdin = {
          "source" => {
              "host" => "foo"
          },
          "params" => {
              "command" => "down",
              "services" => [
                  "service_a",
                  "service_b"
              ]
          }
      }.to_json

      stdout, stderr, status = Open3.capture3("#{out_file} .", :stdin_data => stdin)

      expect(status.success?).to be true

      out = JSON.parse(File.read(mockelton_out))

      expect(out["sequence"].size).to be 2
      expect(out["sequence"][1]["exec-spec"]["args"]).to eq [
                                                                "docker-compose",
                                                                "--host",
                                                                "foo:2376",
                                                                "-f",
                                                                "docker-compose.yml",
                                                                "down"
                                                            ]
    end

  end


end
