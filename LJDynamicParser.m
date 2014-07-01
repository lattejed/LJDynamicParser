//
//  LJDynamicParser.m
//  LJDynamicParser
//
//  Created by Matthew Smith on 6/27/14.
//  Copyright (c) 2014 Latte, Jed?. All rights reserved.
//

/*
 
 This parser configures itself at runtime by generating a lookup
 table that corresponds to the expressions defined in a BNF
 grammar. After successfully parsing a set of tokens, it returns
 an AST.
 
 Consider the following grammar capable of parsing December 31st:
 
 <date>         ::= <month_first> | <day_first>
 <month_first>  ::= <month> '/' <day>
 <day_first>    ::= <day>   '/' <month>
 <day>          ::= '31'
 <month>        ::= '12'
 
 This grammar will be parsed into the following format:
 
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
 
 Each symbol resolves to an array of arrays. The outer array
 represents a logical OR while the inner array represents a
 logical AND. The inner arrays are tried in order until one
 is found that matches every element.
 
 When the grammar is parsed, terminals are replaced with regular
 expressions. This maintains the simplicity of BNF while making 
 grammars less verbose.
 
 Consider the following regular expression:
 
 '(0?[1-9]|1[0-2])'
 
 This will detect a *valid* month, with or without a leading 0,
 not just the presence of one or two digits, which a naive
 approach might take. Writing this check for validity in BNF
 would be much more verbose. It would also require more attention
 when tokenizing the input.
 
 <month>                ::= <maybe_zero> <digits_no_zero> | '1' <digits_one_or_two>
 <maybe_zero>           ::= '0' | ''
 <digits_one_or_two>    ::= '1' | '2'
 <digits_no_zero>       ::= <digits_one_or_two> | '3' | '4' | '5' | '6' | '7' | '8' | '9'
 
 */

#import "LJDynamicParser.h"

@interface LJDynamicParser ()

@property (copy) NSArray* tokens;
@property (assign) NSUInteger tokenIdx;
@property (strong) LJDynamicParserASTNode* rootNode;

- (NSDictionary *)buildParserWithGrammar:(NSString *)grammar rootSymbol:(void(^)(NSString* rootSymbol))block;
- (BOOL)parseFromNode:(LJDynamicParserASTNode *)rootNode;

@end

@implementation LJDynamicParser

- (instancetype)initWithGrammar:(NSString *)grammar;
{
    if (self = [super init])
    {
        _parseTable = [self buildParserWithGrammar:grammar rootSymbol:^(NSString *rootSymbol) {
            _rootNode = [LJDynamicParserASTNode nodeWithValue:rootSymbol parent:nil];
        }];
    }
    return self;
}

- (LJDynamicParserASTNode *)parse:(NSArray *)tokens;
{
    _tokenIdx = 0;
    _tokens = tokens;
    BOOL didParse = [self parseFromNode:_rootNode];
    if (didParse)
    {
        return _rootNode;
    }
    return nil;
}

- (BOOL)parseFromNode:(LJDynamicParserASTNode *)currentNode;
{
    BOOL didParse;
    LJDynamicParserASTNode* nextNode;
    NSArray* groups = [_parseTable objectForKey:currentNode.value];
    for (NSArray* group in groups) // Process groups of alternatives: <symbol1> "." | <symbol2> "."
    {
        NSUInteger lastIdx = _tokenIdx; // Store index for backtracking on failure
        for (id symbol in group) // Process sets of symbols: <symbol1> "."
        {
            NSString* nextToken = [_tokens objectAtIndex:_tokenIdx];
            if      ([symbol isKindOfClass:[NSString class]]) // Nonterminal, parse next node
            {
                nextNode = [LJDynamicParserASTNode nodeWithValue:symbol parent:currentNode];
                [currentNode addChild:nextNode];
                didParse = [self parseFromNode:nextNode];
            }
            else if ([symbol isKindOfClass:[NSRegularExpression class]]) // Terminal, create new node on match
            {
                NSRegularExpression* regexp = symbol;
                NSArray* matches = [regexp matchesInString:nextToken options:0 range:NSMakeRange(0, nextToken.length)];
                didParse = (matches.count == 1);
                if (didParse)
                {
                    nextNode = [LJDynamicParserASTNode nodeWithValue:nextToken parent:currentNode];
                    [currentNode addChild:nextNode];
                    _tokenIdx++; // Token consumed, advance stack idx
                }
            }
        }
        if (didParse)   break;                  // Current group ok, stop
        else            _tokenIdx = lastIdx;    // Current group failed, reset stack idx
    }
    if (!didParse && currentNode.parent) [[currentNode parent] removeChild:currentNode]; // Parse failed, prune AST
    return didParse;
}

- (NSDictionary *)buildParserWithGrammar:(NSString *)grammar rootSymbol:(void(^)(NSString* rootSymbol))block;
{
    NSMutableDictionary* output = [NSMutableDictionary dictionary];
    NSCharacterSet* newlines = [NSCharacterSet newlineCharacterSet];
    NSCharacterSet* allwhitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSCharacterSet* delimiters = [NSCharacterSet characterSetWithCharactersInString:@"'|<"];
    
    grammar = [grammar stringByTrimmingCharactersInSet:allwhitespace];
    NSArray* lines = [grammar componentsSeparatedByCharactersInSet:newlines]; // Break grammar into lines
    NSString* rootSymbol = nil;

    for (NSString* line in lines)
    {
        if (!line.length) continue;
     
        NSScanner* scanner = [NSScanner scannerWithString:line];

        NSString* lhs;
        [scanner scanUpToString:@"<" intoString:NULL];
        [scanner scanString:@"<" intoString:NULL];
        [scanner scanUpToString:@">" intoString:&lhs]; // Grab left side symbol: <leftside> ::= <rightside> '123'
        
        if (!rootSymbol) // Root symbol found, send to callback
        {
            rootSymbol = lhs;
            block(rootSymbol);
        }
        
        [scanner scanUpToString:@":" intoString:NULL];
        [scanner scanString:@"::=" intoString:NULL]; // Consume all but rhs

        NSMutableArray* lineTokens = [NSMutableArray array]; // TODO: Rename these. Groups vs Sets?
        NSMutableArray* groupTokens = [NSMutableArray array];

        while ([scanner isAtEnd] == NO)
        {
            NSString* token;
            [scanner scanUpToCharactersFromSet:delimiters intoString:NULL];
            [scanner scanCharactersFromSet:delimiters intoString:NULL];
            NSString* testChar = [NSString stringWithFormat:@"%c",
                                  [scanner.string characterAtIndex:scanner.scanLocation - 1]];
            
            if      ([testChar isEqualToString:@"'"]) // Consume rhs tokens in quotes: '123'
            {
                // TODO: ignore escaped quotes
                [scanner scanUpToString:@"'" intoString:&token];
                [scanner scanString:@"'" intoString:NULL];
                token = [NSString stringWithFormat:@"^%@$", token];
                NSRegularExpression* regexp =
                    [NSRegularExpression regularExpressionWithPattern:token options:0 error:nil];
                [groupTokens addObject:regexp];
            }
            else if ([testChar isEqualToString:@"<"]) // Consume rhs symbol: <rightside>
            {
                [scanner scanUpToString:@">" intoString:&token];
                [scanner scanString:@">" intoString:NULL];
                [groupTokens addObject:token];
            }
            else if ([testChar isEqualToString:@"|"]) // Alternation symbol encountered, create new group
            {
                [lineTokens addObject:groupTokens];
                groupTokens = [NSMutableArray array];
            }
        }
        [lineTokens addObject:groupTokens];
        [output setObject:lineTokens forKey:lhs];
    }
    return [output copy];
}

@end


#pragma mark - LJDynamicParserASTNode

@interface LJDynamicParserASTNode ()

@end

@implementation LJDynamicParserASTNode {
    LJDynamicParserASTNode* _parent;
    NSString* _value;
    NSMutableArray* _children;
}

+ (instancetype)nodeWithValue:(NSString *)value parent:(LJDynamicParserASTNode *)parent;
{
    LJDynamicParserASTNode* node = [LJDynamicParserASTNode new];
    if (node)
    {
        node->_parent = parent;
        node->_value = [value copy];
        node->_children = [NSMutableArray array];
    }
    return node;
}

- (NSString *)valueForSymbol:(NSString *)symbol;
{
    if (_parent && [_parent.value isEqualToString:symbol])
    {
        return self.value;
    }
    else
    {
        for (LJDynamicParserASTNode* node in self.children)
        {
            NSString* value = [node valueForSymbol:symbol];
            if (value) return value;
        }
    }
    return nil;
}

- (void)addChild:(LJDynamicParserASTNode *)child;
{
    [_children addObject:child];
}

- (void)removeChild:(LJDynamicParserASTNode *)child;
{
    [_children removeObject:child];
}

- (NSString *)value;
{
    return [_value copy];
}

- (LJDynamicParserASTNode *)parent;
{
    return _parent;
}

- (NSArray *)children;
{
    return [_children copy];
}

- (NSString *)description;
{
    return [NSString stringWithFormat:@"<%@> %@", NSStringFromClass([self class]), self.value];
}

@end
