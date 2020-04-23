autoload :Date, 'date'
autoload :DateTime, 'date'
autoload :JSON, 'json'

require_relative 'ext'

module Analytics
  extend Rake::DSL

  mac_root = "_data/analytics"
  nix_root = "_data/analytics-linux"
  npm_root = "_data/analytics-npm"
  periods = %w[30d.json 90d.json 365d.json]
  nix_categories = %w[build-error install install-on-request]
  mac_categories = nix_categories + %w[cask-install]
  npm_categories = %w[download]
  to_path = ->(ary) { ary.join("/") }

  MAC = [mac_root].product(mac_categories, periods).map(&to_path)
  LINUX = [nix_root].product(nix_categories, periods).map(&to_path)
  NPM = [npm_root].product(npm_categories, periods).map(&to_path)

  BREW_API = "https://formulae.brew.sh/api"
  NPM_API = "https://api.npmjs.org/downloads/point"
  DIRS = FileList[MAC, LINUX, NPM].pathmap('%d')
  BREW_FILES = %r|#{Regexp.union(mac_root, nix_root)}/.*\.json|
  NPM_FILES = %r|#{npm_root}/.*\.json|

  # excludes nodenv-default-npmrc which isn't published to npm
  PACKAGES = (
    FileList.new("jetbrains-npm") +
    FileList.new(%w[jxcore prerelease update-defs]).pathmap("node-build-%p") +
    FileList.new(%w[aliases default-packages each man npm-migrate package-json-engine package-rehash update vars]).pathmap("nodenv-%p")
  ).pathmap("@nodenv/%p")

  CLOBBER.include DIRS

  namespace :data do
    desc "Dump all analytics data"
    task analytics: %w[analytics:mac analytics:linux analytics:npm]

    namespace :analytics do
      desc "Dump mac analytics data"
      task mac: MAC

      desc "Dump linux analytics data"
      task linux: LINUX

      desc "Dump npm analytics data"
      task npm: NPM

      DIRS.each { |d| directory d }
      rule Regexp.new BREW_API
      rule Regexp.new NPM_API

      rule BREW_FILES => ["%{^_data,#{BREW_API}}p", "%d"] do |t, args|
        open(t.name, 'w') do |f|
          f.puts JSON.pretty_generate Rake::Task[t.source].json.tap { |data|
            data["items"].select! { |i| i["formula"] =~ %r{^nodenv/} }

            data["total_items"] = data["items"].size
            data["total_count"] = data["items"].reduce(0) { |sum, i| sum + i["count"].to_i}
            data["items"].each{ |i| i["percent"] = (i["count"].to_f / data["total_count"] * 100).truncate(2).to_s }
          }
        end
      end

      period = "{30d,last-month;90d,#{Date.today.prev_day(90)}:#{Date.today.prev_day};365d,last-year}"
      rule NPM_FILES => [*PACKAGES.pathmap("#{NPM_API}/%%#{period}n/%p"), "%d"] do |t|
        packages = t.prerequisite_tasks.grep(Rake::JsonFile, &:json)
        total = packages.reduce(0) { |sum, p| sum + p["downloads"] }

        open(t.name, 'w') do |f|
          f.puts JSON.pretty_generate({
            category: "download",
            total_items: packages.size,
            start_date: packages.first["start"],
            end_date: packages.first["end"],
            total_count: total,
            items: packages.map { |p| {
              package: p["package"],
              count: p["downloads"],
              percent: (p["downloads"].to_f / total * 100).truncate(2).to_s
            } }
          })
        end
      end
    end
  end

  class JsonFileTask < Rake::FileTask
    include Rake::JsonFile

    def timestamp
      DateTime.parse(json["end_date"]).next_day.to_time
    end
  end

  class NpmApiTask < Rake::HttpResourceTask
    include Rake::JsonFile

    def timestamp
      DateTime.parse(json["end"]).next_day.to_time || super
    end
  end

  class BrewApiTask < Rake::HttpResourceTask
    include Rake::JsonFile
  end
end

class Rake::FileTask
  def self.define_task(name, *args, &block)
    task_class = case name
    when Analytics::BREW_FILES then Analytics::JsonFileTask
    when Analytics::NPM_FILES then Analytics::JsonFileTask
    when Regexp.new(Analytics::BREW_API) then Analytics::BrewApiTask
    when Regexp.new(Analytics::NPM_API) then Analytics::NpmApiTask
    else self
    end
    Rake.application.define_task(task_class, name, *args, &block)
  end
end
