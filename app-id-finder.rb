#!/usr/bin/ruby
# encoding: utf-8

require 'net/http'
require 'json'
require "open-uri"
require 'csv' 
require 'cgi'

TARGET_PATH = "/Users/apirakpanatkool/Dropbox/Photos/raw_icon/"

def read_csv(filename)
  apps = []
  csv_text = File.read(filename)
  csv = CSV.parse(csv_text, :headers => true)
  csv.each do |row|
    apps.push({
      :name => row[0],
      :country => row[1] ? row[1].lstrip : "us"
    })
  end
  return apps
end

def find_trackID(app_name, country)
  search_url = "https://itunes.apple.com/search?term=#{CGI.escape(app_name)}&country=#{country}&entity=software"
  uri = URI.parse(search_url)
  response = Net::HTTP.get_response(uri).body
  puts **********
  response_json = JSON.parse(response)
  puts **********

  sleep(4)

  if response_json["resultCount"] != 0
    track_id = response_json["results"][0]["trackId"]
    return track_id
  else
    puts "-- Can't find #{app_name} in #{country}"
    return nil
  end

end

def find_trackID_by_many_country(app_name, default_country)
  all_country = ["th", "us", "jp", "cn", "kr", "fr", "ru"] 

  if default_country
    all_country = all_country - [default_country]
    all_country = [default_country] << all_country
    all_country.flatten!
  end

  all_country.each do |country|
    track_id = find_trackID(app_name, country)
    if track_id 
      return track_id, country
    end
  end
end

def filename(app_name)
  filename = app_name.tr('()', '')
  filename = filename.tr(' ', '-')
end

def search_list(apps)
  apps.each do |app|
    tranck_id, country = find_trackID_by_many_country(app[:name], app[:country])
    puts "#{filename(app[:name])}, #{tranck_id}, #{country}"
  end
end

apps = read_csv("app-id-finder-list.csv")
search_list(apps)
