# RSpec files aren't included, as they depend on the Pdf files,
# which will make the gem filesize irritatingly large
Gem::Specification.new do |spec|
  spec.name = "pdf-reader2"
  spec.version = "2.10.0"
  spec.summary = "A library for accessing the content of Pdf files"
  spec.description = "The Pdf::Reader2 library implements a Pdf parser conforming as much as possible to the Pdf specification from Adobe"
  spec.license = "MIT"
  spec.files =  Dir.glob("{examples,lib,rbi}/**/**/*") + ["Rakefile"]
  spec.executables << "pdf_object"
  spec.executables << "pdf_text"
  spec.executables << "pdf_callbacks"
  spec.extra_rdoc_files = %w{README.md TODO CHANGELOG MIT-LICENSE }
  spec.rdoc_options << '--title' << 'Pdf::Reader2 Documentation' <<
                       '--main'  << 'README.md' << '-q'
  spec.authors = ["James Healy"]
  spec.email   = ["james@yob.id.au"]
  spec.homepage = "https://github.com/yob/pdf-reader2"
  spec.required_ruby_version = ">=2.0"

  if spec.respond_to?(:metadata)
    spec.metadata = {
      "bug_tracker_uri"   => "https://github.com/yob/pdf-reader2/issues",
      "changelog_uri"     => "https://github.com/yob/pdf-reader2/blob/v#{spec.version}/CHANGELOG",
      "documentation_uri" => "https://www.rubydoc.info/gems/pdf-reader2/#{spec.version}",
      "source_code_uri"   => "https://github.com/yob/pdf-reader2/tree/v#{spec.version}",
    }
  end

  spec.add_development_dependency("rake", "< 13.0")
  spec.add_development_dependency("rspec", "~> 3.5")
  spec.add_development_dependency("cane", "~> 3.0")
  spec.add_development_dependency("morecane", "~> 0.2")
  spec.add_development_dependency("pry")
  spec.add_development_dependency("rdoc")

  spec.add_dependency('Ascii85', '~> 1.0')
  spec.add_dependency('ruby-rc4')
  spec.add_dependency('hashery', '~> 2.0')
  spec.add_dependency('ttfunk')
  spec.add_dependency('afm', '~> 0.2.1')
end
