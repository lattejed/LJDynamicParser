# LJDynamicParser


**LJDynamicParser creates a recursive descent parser from a BNF-like grammar at runtime and parses sets of tokens into an AST. It is written in Objective-C. It is intended to be very easy to use, reason about and modify if necessary.**


This parser uses a grammar in standard BNF format with one addition: All terminal definitions are treated as regular expressions. While EBNF was created to address the verbosity of BNF, EBNF is more complicated to parse and, in my opinion, reason about. BNF limits the right hand side of grammar rules to sets of symbols (to be parsed as a logical AND) and sets of alternate sets (to be parsed as a logical OR).

With BNF + regex terminals there are exactly two types of symbols: symbols that point to other rules (nonterminals) and regular expressions (terminals). The simplest regex terminal checks for equality, e.g., `ABC` will get transformed into the regular expression `^ABC$` and check for a single match. All other symbols point to other rules.

## Usage notes

Terminals are literals enclosed in single quotes `'`. They are treated as patterns for regular expressions and wrapped in the symbols `^` and `$` when they are parsed. Any single quotes used in the terminal must be triple escaped `\\\'`. This will send the single quote to NSRegularExpression where it will be safely ignored. The 'extra' escape sequence removes ambiguity in the parser, i.e., it is valid to give a non-escaped single quote to NSRegularExpression but in the context of our grammer it causes ambiguity. When parsed, the terminal will be wrapped as `^terminal$` so that it matches the whole token (or does not). The parser will only return YES on a match if the pattern matches exactly one time.

After a successful parse, the parser will return the root node of an AST. To simplify extracting information afterwards, the method `LJDynamicParserASTNode -valueForSymbol:` will walk the AST and return the value of the terminal of the given name.

If you define a grammar 'inline' as an NSString, make sure to add an extra newline to each line (`\n\` vs `\`) so the parser can split the grammar accordingly.

```objective-c
NSString* grammar = @"         \n\
<date>   ::= <day> '/' <month> \n\
<day>    ::= '31'              \n\
<month>  ::= '12               \n\
";

LJDynamicParser* parser = [[LJDynamicParser alloc] initWithGrammar:grammar];
NSArray* tokens = [@"31 / 12" componentsSeparatedByString:@" "];
LJDynamicParserASTNode* rootNode = [parser parse:tokens];

if (rootNode)
{
    NSLog(@"Day: %@", [rootNode valueForSymbol:@"day"]);
    NSLog(@"Month: %@", [rootNode valueForSymbol:@"month"]);
}
```

The parser does not tokenize the input. How the input is tokenized will depend on the use case, but it is expected that there is a one to one relationship between input tokens and terminals in the grammar.

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

This grammar will be parsed into the following format:

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

When the grammar is parsed, terminals are replaced with regular expressions. This maintains the simplicity of BNF while making grammars less verbose.

Consider the following regular expression:

```
'(0?[1-9]|1[0-2])'
```

This will detect a *valid* month, with or without a leading 0, not just the presence of one or two digits, which a naive approach might take. Writing this check for validity in BNF would be much more verbose. It would also require more attention when tokenizing the input.

```
<month>                ::= <maybe_zero> <digits_no_zero> | '1' <digits_one_or_two>
<maybe_zero>           ::= '0' | ''
<digits_one_or_two>    ::= '1' | '2'
<digits_no_zero>       ::= <digits_one_or_two> | '3' | '4' | '5' | '6' | '7' | '8' | '9'
```
