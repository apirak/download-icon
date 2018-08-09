#!/usr/bin/ruby
# encoding: utf-8

require 'net/http'
require 'json'
require "open-uri"
require 'csv'

TARGET_PATH = "/Users/apirakpanatkool/Dropbox/Photos/raw_icon/"

def read_csv(filename)
  apps = []
  csv_text = File.read(filename)
  csv = CSV.parse(csv_text, :headers => true)
  csv.each do |row|
    apps.push({
      :name => row[0],
      :id => row[1].lstrip,
      :country => row[2] ? row[2].lstrip : "us",
      :tag => row[3] ? row[3].lstrip : row[0]
    })
  end
  return apps
end

def find(app_id, country)
  uri = URI.parse("https://itunes.apple.com/lookup?id=#{app_id}&country=#{country}")
  response = Net::HTTP.get_response(uri).body
  response_json = JSON.parse(response)
  if (response_json["resultCount"] != 0) and (response_json["results"])
    artwork_url = response_json["results"][0]["artworkUrl512"]
    return artwork_url
  else
    puts "Can't find app id: #{app_id}"
    puts "uri: #{uri}"
    return nil
  end
end

def target_path(artwork_url, name)
  return TARGET_PATH+ name + "." + artwork_url.match(/\.(jpg|png)$/)[1]
end

def add_tag(tag, path)
  command = "tag --add '#{tag}' #{path}"
  %x[#{command}]
end

def download(artwork_url, path)
  download = open(artwork_url)
  File.open(path, "w") do |f|
    IO.copy_stream(download, f)
  end
end

def download_list(apps)
  apps.each do |app|
    puts "---"
    puts "name: #{app[:name]} id: #{app[:id]} tag: #{app[:tag]} country: #{app[:country]}"
    artwork_url = find(app[:id], app[:country])
    if artwork_url
      path = target_path(artwork_url, app[:name])
      download(artwork_url, path)
      sleep(4)
      add_tag(app[:tag], path)
    end
    puts "---"
  end
end

apps = read_csv("app_list.csv")
download_list(apps)
