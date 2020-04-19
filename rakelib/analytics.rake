require 'date'
require 'json'
require 'pathname'
require 'open-uri'

module Analytics
  extend Rake::DSL

  mac_root = %w[_data/analytics]
  nix_root = %w[_data/analytics-linux]
  periods = %w[30d.json 90d.json 365d.json]
  nix_categories = %w[build-error install install-on-request]
  mac_categories = nix_categories + %w[cask-install]
  to_path = ->(ary) { ary.join("/") }

  MAC = mac_root.product(mac_categories, periods).map(&to_path)
  LINUX = nix_root.product(nix_categories, periods).map(&to_path)

  API = "https://formulae.brew.sh/api"
  DIRS = FileList[MAC, LINUX].pathmap('%d')
  FILE_PATTERN = %r|#{Regexp.union(mac_root + nix_root)}/.*\.json|

  CLOBBER.include DIRS

  namespace :data do
    desc "Dump all analytics data"
    task analytics: %w[analytics:mac analytics:linux]

    namespace :analytics do
      desc "Dump mac analytics data"
      task mac: MAC

      desc "Dump linux analytics data"
      task linux: LINUX

      DIRS.each { |d| directory d }

      rule Regexp.new(API)

      rule FILE_PATTERN => ["%{^_data,#{API}}p", "%d"] do |t, args|
        open(t.name, 'w') do |f|
          f.puts JSON.pretty_generate Rake::Task[t.source].json.tap { |data|
            data["items"].select! { |i| %r{^nodenv/}.match(i["formula"] || i["cask"]) }
          }
        end
      end
    end
  end

  class JsonFileTask < Rake::FileTask
    def timestamp
      JSON.load(Pathname.new name)["end_date"].then { |dt|
        DateTime.parse(dt).next_day.to_time } rescue Rake::LATE
    end
  end
end

class HttpResourceTask < Rake::FileTask
  def read
    resource.read
  end

  def timestamp
    resource.last_modified
  end

  def json
    JSON.load read
  end

  private

  def resource
    @resource ||= URI(name).open
  end
end

class Rake::FileTask
  def self.define_task(name, *args, &block)
    task_class = case name
    when Analytics::FILE_PATTERN then Analytics::JsonFileTask
    when Regexp.new(Analytics::API) then HttpResourceTask
    else self
    end
    Rake.application.define_task(task_class, name, *args, &block)
  end
end
