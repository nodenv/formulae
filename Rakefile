require "rake"
require "rake/clean"
require "json"
require "date"
require 'yaml'

def config(*props)
  @config ||= YAML.load_file('_config.yml')
  props.empty? ? @config : @config.dig(*props)
end

task default: :formula_and_analytics

desc "Dump macOS formulae data"
task :formulae, [:os,:tap] do |task, args|
  args.with_defaults(:os => "mac", :tap => config("taps", "core", "name"))

  ENV["HOMEBREW_FORCE_HOMEBREW_ON_LINUX"] = "1" if args[:os] == "mac"
  ENV["HOMEBREW_NO_COLOR"] = "1"
  sh "brew", "ruby", "script/generate.rb", args[:os], args[:tap]
  FileUtils.mkdir_p ["_data/formula", "_data/formula-linux"]
end

desc "Dump cask data"
task :cask, [:tap] do |task, args|
  args.with_defaults(:tap => config("taps", "cask", "name"))

  ENV["HOMEBREW_FORCE_HOMEBREW_ON_LINUX"] = "1"
  ENV["HOMEBREW_NO_COLOR"] = "1"
  sh "brew", "ruby", "script/generate-cask.rb", args[:tap]
  FileUtils.mkdir_p "_data/cask"
end

def fetch_analytics?(os)
  return false if ENV["HOMEBREW_NO_ANALYTICS"]

  json_file = "_data/analytics#{"-linux" if os == "linux"}/build-error/30d.json"
  return true unless File.exist?(json_file)

  json = JSON.parse(IO.read(json_file))
  end_date = Date.parse(json["end_date"])
  end_date < Date.today
end

def fetch_analytics_files(os)
  %w[build-error install cask-install install-on-request].each do |category|
    %w[30 90 365].each do |days|
      next if os == "linux" && %w[cask-install os-version].include?(category)

      path = Pathname.new "analytics#{os == "linux" ? "-linux" : ""}/#{category}/#{days}d.json"
      outpath = Pathname.new "_data/#{path}"

      FileUtils.mkdir_p outpath.dirname
      sh <<~SH
        curl -qsSLf 'https://formulae.brew.sh/api/#{path}' |
          jq '.items = [.items[] | select(.formula // .cask | test("^nodenv/"))]' > #{outpath}
      SH
    end
  end
end

desc "Dump analytics data"
task :analytics, [:os] do |task, args|
  args.with_defaults(:os => "mac")

  next unless fetch_analytics?(args[:os])

  fetch_analytics_files(args[:os])
end

desc "Dump macOS formulae and analytics data"
task formula_and_analytics: %i[formulae analytics]

desc "Dump Linux formulae and analytics data"
task :linux_formula_and_analytics do
  Rake::Task["formulae"].invoke("linux")
  Rake::Task["analytics"].invoke("linux")
end

desc "Build the site"
task build: [:formula_and_analytics, :cask, :linux_formula_and_analytics] do
  sh "bundle", "exec", "jekyll", "build"
end

desc "Run html proofer to validate the HTML output."
task html_proofer: :build do
  require "html-proofer"
  HTMLProofer.check_directory(
    "./_site",
    parallel: { in_threads: 4 },
    favicon: true,
    http_status_ignore: [0, 302, 303, 429, 521],
    assume_extension: true,
    check_external_hash: true,
    check_favicon: true,
    check_opengraph: true,
    check_img_http: true,
    disable_external: true,
    url_ignore: ["http://formulae.brew.sh"]
  ).run
end

desc "Run JSON Lint to validate the JSON output."
task jsonlint: :build do
  require "jsonlint"
  files_to_check = Rake::FileList.new(["./_site/**/*.json"])
  puts "Running JSON Lint on #{files_to_check.flatten.length} files..."

  linter = JsonLint::Linter.new
  linter.check_all(files_to_check)

  if linter.errors?
    linter.display_errors
    abort "JSON Lint found #{linter.errors_count} errors!"
  else
    puts "JSON Lint finished successfully."
  end
end

task test: %i[html_proofer jsonlint]

CLEAN.include FileList["_site"]
