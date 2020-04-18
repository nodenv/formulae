require 'open-uri'

PERIODS = %w[30d.json 90d.json 365d.json]
NIX_CATEGORIES = %w[build-error install install-on-request]
MAC_CATEGORIES = NIX_CATEGORIES + %w[cask-install]

to_path = ->(p) { Pathname.new p.join("/") }

MACALYTICS = ["_data/analytics"].product(MAC_CATEGORIES, PERIODS).map(&to_path)
NIXALYTICS = ["_data/analytics-linux"].product(NIX_CATEGORIES, PERIODS).map(&to_path)

namespace :data do
  desc "Dump all analytics data"
  task :analytics => %w[analytics:mac analytics:linux]

  namespace :analytics do
    desc "Dump mac analytics data"
    task :mac => MACALYTICS

    desc "Dump linux analytics data"
    task :linux => NIXALYTICS


    rule %r{/api/analytics}
    api_url = ->(f) { f.pathmap('%{^_data,https://formulae.brew.sh/api}p') }

    rule %r{_data/analytics.*\.json} => [api_url, '%d'] do |t, args|
      open(t.name, 'w') do |f|
        JSON.load(Rake::Task[t.source]).tap { |data|
          data["items"].select! { |i| %r{^nodenv/}.match(i["formula"] || i["cask"]) }
        }.then { |obj|
          f.puts JSON.pretty_generate(obj)
        }
      end
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

  private

  def resource
    @resource ||= URI(name).open
  end
end

class AnalyticsFileTask < Rake::FileTask
  def timestamp
    JSON.load(Pathname.new name)["end_date"].then { |dt|
      DateTime.parse(dt).next_day.to_time } rescue Rake::LATE
  end
end

class Rake::FileTask
  def self.define_task(name, *args, &block)
    task_class = case name
    when %r{_data/.*json} then AnalyticsFileTask
    when %r{https:.*json} then HttpResourceTask
    else self
    end
    Rake.application.define_task(task_class, name, *args, &block)
  end
end
