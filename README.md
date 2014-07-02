# LJDynamicParser

**LJDynamicParser creates a recursive descent parser from a BNF grammar at runtime and parses an input string into an AST. It is written in Objective-C. It is intended to be easy to use.**

This parser uses a grammar in strict [BNF format](http://en.wikipedia.org/wiki/Backus%E2%80%93Naur_Form). Quotes are interchangeable (`"` and `'`) though no attempt is made to deal with escaped quotes inside literals. Optional terms are designated by an empty string `''` or `""`. Grammars have the following format:

```
<date_month_first>     ::= <month> "/" <day> "/" <year>
<month>                ::= <maybe_zero> <digits_no_zero> |  "1" <digits_one_or_two>
<maybe_zero>           ::=  "0" |  ""
<digits_one_or_two>    ::=  "1" | "2"
<digits_no_zero>       ::= <digits_one_or_two> | "3" | "4" | "5" | "6" | "7" | "8" | "9"
...
```

Whitespace inside literals is parsed exactly as it is defined. Other whitespace is ignored. There is currently no option to disable this thought it might be added in the future. The generated parser does not tokenize the input. The input string is scanned character by character and looks for a concrete match with the exception of whitespace in the input string and optional terminals.

This is an early version and there is little error handling in either the syntax generation step or the parsing step. The parsing either succeeds or fails.

## Usage notes

After a successful parse, the parser will return the root node of an AST. To simplify extracting information afterwards, the method `LJDynamicParserASTNode -valueForSymbol:` will walk the AST and return the value of the terminal of the given name. If the parse fails, `parse:` will return `nil`.

If you define a grammar 'inline' as an NSString, make sure to add an extra newline to each line (`\n\` vs `\`) so the parser can split the grammar accordingly.

```objective-c
NSString* grammar = @"         \n\
<date>   ::= <day> '/' <month> \n\
<day>    ::= '31'              \n\
<month>  ::= '12               \n\
";

LJDynamicParser* parser = [[LJDynamicParser alloc] initWithGrammar:grammar];
LJDynamicParserASTNode* rootNode = [parser parse:@"31 / 12"];

if (rootNode)
{
    NSLog(@"Day: %@", [rootNode valueForSymbol:@"day"]);
    NSLog(@"Month: %@", [rootNode valueForSymbol:@"month"]);
}
```

## Implementation notes

This parser configures itself at runtime by generating a lookup table that corresponds to the expressions defined in a BNF grammar. After successfully parsing a set of tokens, it returns an AST.

Consider the following grammar capable of parsing December 31st:

```
<date>         ::= <month_first> | <day_first>
<month_first>  ::= <month> '/' <day>
<day_first>    ::= <day>   '/' <month>
<day>          ::= '31'
<month>        ::= '12'
```

This grammar will in essence be parsed into the following format:

```
@{
    @"date"         :   @[
                            @[ 
                                @"month_first" 
                            ],
                            @[ 
                                @"day_first" 
                            ]
                        ],
    @"month_first"  :   @[
                            @[ 
                                @"month", 
                                "/", 
                                @"day" 
                            ]
                        ]
    ...

    @"day"          :   @[
                            @[
                                @"31"
                            ],
                        ],
    ...
}
```

Each symbol resolves to an array of arrays. The outer array represents a logical OR while the inner array represents a logical AND. The inner arrays are tried in order until one is found that matches every element.
