# LJDynamicParser

**LJDynamicParser creates a recursive descent parser from a Kuroda normal form grammar at runtime and parses an input string into an AST. It is written in Objective-C. It is intended to be easy to use and reason about.**

This parser uses a grammar in [Kuroda normal form](http://en.wikipedia.org/wiki/Kuroda_normal_form). While this term is typically not used as BNF or Backus-Naur form would be, we'll use KNF and describe this in terms of KNF vs BNF. This grammar is a context-sensitive (a.k.a., Type-1), noncontracting grammar, i.e., it is a context-sensitive grammar that does not allow for an empty string. In other words, it is a BNF grammar that does not allow for an empty terminal.

Quotes are interchangeable (`"` and `'`) though no attempt is made to deal with escaped quotes inside literals.Grammars have the following format:

```
<date_month_first>     ::= <month> "/" <day> "/" <year>
<month>                ::= <maybe_zero> <digits_no_zero> |  "1" <digits_one_or_two>
<maybe_zero>           ::=  "0" |  ""
<digits_one_or_two>    ::=  "1" | "2"
<digits_no_zero>       ::= <digits_one_or_two> | "3" | "4" | "5" | "6" | "7" | "8" | "9"
...
```

Whitespace inside literals is parsed exactly as it is defined. Other whitespace is ignored. There is currently no option to disable this though it might be added in the future. The generated parser does not tokenize the input. The input string is scanned character by character and looks for a concrete match (with the exception of whitespace).

This is an early version and there is little error handling in either the syntax generation step or the parsing step. The parsing either succeeds or fails. Generating the syntax may throw an exception.

## Usage notes

After a successful parse, the parser will return the root node of an AST. To simplify extracting information, the method `LJDynamicParserASTNode -nodeForRule:` will walk the AST and return the first node it encounters with a given rule name, whether it is the starting node or one of its children. It walks the tree recursively. The method `LJDynamicParserASTNode -literalValue` will return the literal value of that node concatenated with any literal values of child nodes (recursively).

If you define a grammar 'inline' as an NSString, make sure to add an extra newline to each line (`\n\` vs `\`) so the parser can split the grammar accordingly.

```objective-c
NSString* grammar = @"         \n\
<date>   ::= <day> '/' <month> \n\
<day>    ::= '31'              \n\
<month>  ::= '12'              \n\
";

LJDynamicParser* parser = [[LJDynamicParser alloc] initWithGrammar:grammar];
LJDynamicParserASTNode* rootNode = [parser parse:@"31 / 12"];

if (rootNode)
{
    NSLog(@"Day: %@", [[rootNode nodeForRule:@"day"] literalValue]);
    NSLog(@"Month: %@", [[rootNode nodeForRule:@"month"] literalValue]);
}
```

## Implementation notes

This parser configures itself at runtime by generating a lookup table that corresponds to the expressions defined in a "KNF" grammar (see above). After successfully parsing a set of tokens, it returns an AST.

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


## Motivation

While there are parser generators available for Objective-C, I feel that they are unnecessarily complex and encourage bad behavior, e.g., adding code to grammars. You would use this if 1) you're comfortable with BNF grammars and rewriting them to not use optional terminals, 2) you're comfortable writing recursive descent parsers by hand and 3) you'd rather not bother. While this could have been written as a static generator, I prefer the simplicity of defining the syntax in memory.

## License

MIT
