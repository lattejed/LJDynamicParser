Pod::Spec.new do |s|
  s.name         = "LJDynamicParser"
  s.version      = "0.0.7"
  s.summary      = "A dynamic parser generator for KNF grammars written in Objective-C"
  s.description  = <<-DESC
                    LJDynamicParser creates a recursive descent parser from a Kuroda normal form grammar at runtime and parses an input string into an AST. It is written in Objective-C. It is intended to be easy to use and reason about.
                   DESC
  s.homepage     = "https://github.com/lattejed/LJDynamicParser"
  s.license      = { :type => 'MIT', :file => 'LICENSE' } 
  s.author       = { "Matthew Smith" => "m@lattejed.com" }
  s.source       = { :git => "https://github.com/lattejed/LJDynamicParser.git", :tag => "v#{s.version}" }
  s.source_files = "*.{h,m}"
  s.requires_arc = true
end
