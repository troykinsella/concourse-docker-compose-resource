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

  it "exports docker host" do
    stdin = {
        "source" => {
            "host" => "foo"
        },
    }.to_json

    stdout, stderr, status = Open3.capture3("#{out_file} .", :stdin_data => stdin)

    expect(status.success?).to be true

    out = JSON.parse(File.read(mockelton_out))

    expect(out["sequence"].size).to be 2
    expect(out["sequence"][0]["exec-spec"]["env"]["DOCKER_HOST"]).to eq "foo:2376"
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
    expect(stderr).to eq "Unsupported command: nope\nPossible commands: down, kill, restart, start, stop, up\n"
  end

  it "writes .env file from values" do
    stdin = {
        "source" => {
            "host" => "foo"
        },
        "params" => {
            "command" => "down",
            "env" => {
                "FOO" => "BAR",
                "BAR" => "BAZ"
            }
        }
    }.to_json

    stdout, stderr, status = Open3.capture3("#{out_file} .", :stdin_data => stdin)

    expect(status.success?).to be true

    out = File.read(".env")

    expect(out).to eq "FOO=BAR\nBAR=BAZ\n"
  end

  it "copies .env file from file path" do
    stdin = {
        "source" => {
            "host" => "foo"
        },
        "params" => {
            "command" => "down",
            "env_file" => "my_env"
        }
    }.to_json

    File.open("my_env", "w") do |file|
      file.puts "FOO=BAR\nBAR=BAZ\nBAZ=BIZ\n"
    end

    stdout, stderr, status = Open3.capture3("#{out_file} .", :stdin_data => stdin)

    expect(status.success?).to be true

    out = File.read(".env")

    expect(out).to eq "FOO=BAR\nBAR=BAZ\nBAZ=BIZ\n"
  end

  it "does not create .env file unless configured" do
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

    expect(File.exist?(".env")).to be true
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
                                                                "--no-ansi",
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
                  "remove_orphans" => true,
                  "timeout" => 123
              }
          }
      }.to_json

      stdout, stderr, status = Open3.capture3("#{out_file} .", :stdin_data => stdin)

      expect(status.success?).to be true

      out = JSON.parse(File.read(mockelton_out))

      expect(out["sequence"].size).to be 2
      expect(out["sequence"][1]["exec-spec"]["args"]).to eq [
                                                                "docker-compose",
                                                                "--no-ansi",
                                                                "-f",
                                                                "docker-compose.yml",
                                                                "down",
                                                                "--rmi",
                                                                "local",
                                                                "--volumes",
                                                                "--remove-orphans",
                                                                "--timeout",
                                                                "123"
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
                                                                "--no-ansi",
                                                                "-f",
                                                                "docker-compose.yml",
                                                                "down"
                                                            ]
    end

  end



  describe "kill" do

    it "generates default arguments" do
      stdin = {
          "source" => {
              "host" => "foo"
          },
          "params" => {
              "command" => "kill"
          }
      }.to_json

      stdout, stderr, status = Open3.capture3("#{out_file} .", :stdin_data => stdin)

      expect(status.success?).to be true

      out = JSON.parse(File.read(mockelton_out))

      expect(out["sequence"].size).to be 2
      expect(out["sequence"][1]["exec-spec"]["args"]).to eq [
                                                                "docker-compose",
                                                                "--no-ansi",
                                                                "-f",
                                                                "docker-compose.yml",
                                                                "kill"
                                                            ]
    end

    it "generates options" do
      stdin = {
          "source" => {
              "host" => "foo"
          },
          "params" => {
              "command" => "kill",
              "options" => {
                  "signal" => 123
              }
          }
      }.to_json

      stdout, stderr, status = Open3.capture3("#{out_file} .", :stdin_data => stdin)

      expect(status.success?).to be true

      out = JSON.parse(File.read(mockelton_out))

      expect(out["sequence"].size).to be 2
      expect(out["sequence"][1]["exec-spec"]["args"]).to eq [
                                                                "docker-compose",
                                                                "--no-ansi",
                                                                "-f",
                                                                "docker-compose.yml",
                                                                "kill",
                                                                "-s",
                                                                "123"
                                                            ]
    end

    it "supplies services" do
      stdin = {
          "source" => {
              "host" => "foo"
          },
          "params" => {
              "command" => "kill",
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
                                                                "--no-ansi",
                                                                "-f",
                                                                "docker-compose.yml",
                                                                "kill",
                                                                "service_a",
                                                                "service_b"
                                                            ]
    end

  end


  describe "start" do

    it "generates default arguments" do
      stdin = {
          "source" => {
              "host" => "foo"
          },
          "params" => {
              "command" => "start"
          }
      }.to_json

      stdout, stderr, status = Open3.capture3("#{out_file} .", :stdin_data => stdin)

      expect(status.success?).to be true

      out = JSON.parse(File.read(mockelton_out))

      expect(out["sequence"].size).to be 2
      expect(out["sequence"][1]["exec-spec"]["args"]).to eq [
                                                                "docker-compose",
                                                                "--no-ansi",
                                                                "-f",
                                                                "docker-compose.yml",
                                                                "start"
                                                            ]
    end

    it "supplies services" do
      stdin = {
          "source" => {
              "host" => "foo"
          },
          "params" => {
              "command" => "start",
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
                                                                "--no-ansi",
                                                                "-f",
                                                                "docker-compose.yml",
                                                                "start",
                                                                "service_a",
                                                                "service_b"
                                                            ]
    end

  end



  describe "stop" do

    it "generates default arguments" do
      stdin = {
          "source" => {
              "host" => "foo"
          },
          "params" => {
              "command" => "stop"
          }
      }.to_json

      stdout, stderr, status = Open3.capture3("#{out_file} .", :stdin_data => stdin)

      expect(status.success?).to be true

      out = JSON.parse(File.read(mockelton_out))

      expect(out["sequence"].size).to be 2
      expect(out["sequence"][1]["exec-spec"]["args"]).to eq [
                                                                "docker-compose",
                                                                "--no-ansi",
                                                                "-f",
                                                                "docker-compose.yml",
                                                                "stop"
                                                            ]
    end

    it "generates options" do
      stdin = {
          "source" => {
              "host" => "foo"
          },
          "params" => {
              "command" => "stop",
              "options" => {
                  "timeout" => 123
              }
          }
      }.to_json

      stdout, stderr, status = Open3.capture3("#{out_file} .", :stdin_data => stdin)

      expect(status.success?).to be true

      out = JSON.parse(File.read(mockelton_out))

      expect(out["sequence"].size).to be 2
      expect(out["sequence"][1]["exec-spec"]["args"]).to eq [
                                                                "docker-compose",
                                                                "--no-ansi",
                                                                "-f",
                                                                "docker-compose.yml",
                                                                "stop",
                                                                "--timeout",
                                                                "123"
                                                            ]
    end

    it "supplies services" do
      stdin = {
          "source" => {
              "host" => "foo"
          },
          "params" => {
              "command" => "stop",
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
                                                                "--no-ansi",
                                                                "-f",
                                                                "docker-compose.yml",
                                                                "stop",
                                                                "service_a",
                                                                "service_b"
                                                            ]
    end

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
                                                                "--no-ansi",
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
                                                                "--no-ansi",
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
                  "timeout" => 123,
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
                                                                "--no-ansi",
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
                                                                "service_b=4",
                                                                "--timeout",
                                                                "123"
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
                                                                "--no-ansi",
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

end
