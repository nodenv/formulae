autoload :JSON, 'json'
autoload :OpenURI, 'open-uri'
autoload :Pathname, 'pathname'

module Rake
  class FileTask
    def to_path
      Pathname.new name
    end

    def read
      to_path.read
    end
  end

  module JsonFile
    def json
      @json ||= JSON.load self
    end
  end

  class HttpResourceTask < Rake::FileTask
    def read
      @read ||= resource.read
    end

    def timestamp
      resource.last_modified || Rake::LATE
    end

    private

    def resource
      return @resource if defined? @resource
      Rake.rake_output_message "get #{name}" if verbose?
      @resource = OpenURI.open_uri(name)
    end

    def verbose?
      (FileUtilsExt.verbose_flag == FileUtilsExt::DEFAULT) || FileUtilsExt.verbose_flag
    end
  end
end
