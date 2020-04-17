#!/usr/bin/env ruby
require 'date'
require 'json'
require 'pathname'

os = ARGV.first

def fetch_analytics?(os)
  return false if ENV["HOMEBREW_NO_ANALYTICS"]

  json_file = Pathname.new "_data/analytics#{"-linux" if os == "linux"}/build-error/30d.json"
  return true unless json_file.file?

  json_file.open do |file|
    Date.parse(JSON.load(file)["end_date"]) < Date.today
  end
end

def fetch_analytics_files(os)
  %w[build-error install cask-install install-on-request].each do |category|
    %w[30 90 365].each do |days|
      next if os == "linux" && %w[cask-install os-version].include?(category)

      path = Pathname.new "analytics#{os == "linux" ? "-linux" : ""}/#{category}/#{days}d.json"
      outpath = Pathname.new "_data/#{path}"

      FileUtils.mkdir_p outpath.dirname
      system <<~SH
        curl -qsSLf 'https://formulae.brew.sh/api/#{path}' |
          jq '.items = [.items[] | select(.formula // .cask | test("^nodenv/"))]' > #{outpath}
      SH
    end
  end
end

fetch_analytics_files(os) if fetch_analytics?(os)
