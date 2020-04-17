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


    mkdir = ->(f) { f.pathmap('%d') }

    # matches analytics .json files
    rule %r{_data/.*\.json} => mkdir do |t|
      sh %Q{curl -qsSLf '#{t.name.sub(/_data/, 'https://formulae.brew.sh/api')}' | \
        jq '.items = [.items[] | select(.formula // .cask | test("^nodenv/"))]' > #{t.name}}
    end

    # matches analytics subdirectories
    rule %r{_data/[-/\w]+$} do |t|
      mkdir_p t.name
    end
  end
end
