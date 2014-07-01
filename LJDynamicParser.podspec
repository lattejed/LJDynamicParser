Pod::Spec.new do |s|
  s.name         = "LJDynamicParser"
  s.version      = "0.0.2"
  s.summary      = "A dynamic parser generater for BNF-like grammars written in Objective-C"
  s.description  = <<-DESC
                    LJDynamicParser creates a recursive descent parser from a BNF-like grammar at runtime and parses sets of tokens into an AST. It is written in Objective-C. It is intended to be very easy to use, reason about and modify if necessary.
                   DESC
  s.homepage     = "https://github.com/lattejed/LJDynamicParser"
  s.license      = { :type => 'MIT', :file => 'LICENSE' } 
  s.author       = { "Matthew Smith" => "m@lattejed.com" }
  s.source       = { :git => "https://github.com/lattejed/LJDynamicParser.git", :tag => "v#{s.version}" }
  s.source_files = "{LJDynamicParser,LJDynamicParserASTNode}.{h,m}"
  s.requires_arc = true
end
