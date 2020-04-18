require "rake"
require "rake/clean"
require 'jekyll'

task default: :formula_and_analytics

desc "Dump macOS formulae data"
task :formulae, [:os, :tap] do |task, args|
  args.with_defaults(:os => "mac", :tap => Jekyll.configuration.dig("taps", "core", "name"))

  ENV["HOMEBREW_FORCE_HOMEBREW_ON_LINUX"] = "1" if args[:os] == "mac"
  ENV["HOMEBREW_NO_COLOR"] = "1"
  sh "brew", "ruby", "script/generate.rb", args[:os], args[:tap]
end
CLOBBER.include FileList[%w[_data/formula api/formula formula
                         _data/formula-linux api/formula-linux formula-linux]]

desc "Dump cask data"
task :cask, [:tap] do |task, args|
  args.with_defaults(:tap => Jekyll.configuration.dig("taps", "cask", "name"))

  ENV["HOMEBREW_FORCE_HOMEBREW_ON_LINUX"] = "1"
  ENV["HOMEBREW_NO_COLOR"] = "1"
  sh "brew", "ruby", "script/generate-cask.rb", args[:tap]
end
CLOBBER.include FileList[%w[_data/cask api/cask cask]]

desc "Dump analytics data"
task :analytics, [:os] do |task, args|
  args.with_defaults(:os => "mac")
  sh "script/fetch-analytics.rb", args[:os]
end
CLOBBER.include FileList[%w[_data/analytics _data/analytics-linux]]

desc "Dump macOS formulae and analytics data"
task formula_and_analytics: %i[formulae analytics]

desc "Dump Linux formulae and analytics data"
task :linux_formula_and_analytics do
  Rake::Task["formulae"].tap(&:reenable).invoke("linux")
  Rake::Task["analytics"].tap(&:reenable).invoke("linux")
end

desc "Dump all formulae (macOS and Linux)"
task all_formulae: :formulae do
  Rake::Task["formulae"].tap(&:reenable).invoke("linux")
end

desc "Dump all analytics (macOS and Linux)"
task all_analytics: :analytics do
  Rake::Task["analytics"].tap(&:reenable).invoke("linux")
end

desc "Build the site"
task build: %i[all_formulae all_analytics cask] do
  Jekyll::Commands::Build.process({})
end
CLEAN.include FileList["_site"]

desc "Serve the site"
task :serve do
  Jekyll::Commands::Serve.process({})
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
  files_to_check = FileList["_site/**/*.json"]
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

task :clean do
  sh *%w[git checkout --], *CLOBBER
end
