require "net/http"
require "json"
require "open-uri"
require "csv"

TARGET_PATH = "/Users/apirakpanatkool/Dropbox/Photos/raw_icon/"

def read_csv(filename)
  applications = []
  csv_text = File.read(filename)
  csv = CSV.parse(csv_text, headers: true)
  csv.each do |row|
    applications.push(
      {
        name: row[0],
        id: row[1].lstrip,
        country: row[2] ? row[2].lstrip : "us",
        tag: row[3] ? row[3].lstrip : row[0],
      },
    )
  end
  return applications
end

def lookup(app_id, country)
  uri =
    URI.parse("https://itunes.apple.com/lookup?id=#{app_id}&country=#{country}")
  response = Net::HTTP.get_response(uri).body
  response_json = ""
  begin
    response_json = JSON.parse(response)
  rescue JSON::ParserError => e
    puts "\e[31mError\e[0m parsing JSON: #{e.message}"
    return nil
  end
  if (response_json["resultCount"] != 0) and (response_json["results"])
    artwork_url = response_json["results"][0]["artworkUrl512"]
    return artwork_url
  else
    puts "\e[33mCan't lookup\e[0m app id: #{app_id}"
    puts "uri: #{uri}"
    return "Deleted"
  end
end

def target_path(artwork_url, name)
  return TARGET_PATH + name + "." + artwork_url.match(/\.(jpg|png)$/)[1]
end

def add_tag(tag, path)
  command = "tag --add '#{tag}' #{path}"
  `#{command}`
end

def download(artwork_url, path)
  download = URI.open(artwork_url)
  File.open(path, "w") { |f| IO.copy_stream(download, f) }
end

def download_list(applications)
  applications.each do |app|
    puts "name: #{app[:name]} id: #{app[:id]} tag: #{app[:tag]} country: #{app[:country]}"
    tries = 0
    artwork_url = nil
    while artwork_url.nil? && tries < 3
      artwork_url = lookup(app[:id], app[:country])
      if artwork_url.nil?
        sleep(10)
        tries += 1
        puts "Retry (#{tries})"
      end
      if artwork_url == "Deleted"
        tries = 3
        artwork_url = nil
      end
    end
    if artwork_url
      path = target_path(artwork_url, app[:name])
      download(artwork_url, path)
      sleep(4)
      add_tag(app[:tag], path)
    end
  end
end

applications = read_csv("icon-downloader-list.csv")
download_list(applications)
