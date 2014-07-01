//
//  LJDynamicParser.m
//  LJDynamicParser
//
//  Created by Matthew Smith on 6/27/14.
//  Copyright (c) 2014 Latte, Jed?. All rights reserved.
//

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

        NSMutableArray* lineTokens = [NSMutableArray array]; // All alternate sets in expression
        NSMutableArray* groupTokens = [NSMutableArray array]; // Sets of tokens

        while ([scanner isAtEnd] == NO)
        {
            NSString* token;
            [scanner scanUpToCharactersFromSet:delimiters intoString:NULL];
            [scanner scanCharactersFromSet:delimiters intoString:NULL];
            NSString* testChar = [NSString stringWithFormat:@"%c",
                                  [scanner.string characterAtIndex:scanner.scanLocation - 1]];
            
            if      ([testChar isEqualToString:@"'"]) // Consume rhs tokens in quotes: '123'
            {
                token = @"";
                while (YES)
                {
                    NSString* fragment;
                    [scanner scanUpToString:@"'" intoString:&fragment];
                    token = [token stringByAppendingString:fragment];
                    testChar = [NSString stringWithFormat:@"%c",
                                [scanner.string characterAtIndex:scanner.scanLocation - 1]];
                    if ([testChar isEqualToString:@"\\"]) // Escaped single quote in expression, continue
                    {
                        [scanner scanString:@"'" intoString:&fragment];
                        token = [token stringByAppendingString:fragment];
                    }
                    else
                    {
                        break;
                    }
                }
                token = [NSString stringWithFormat:@"^%@$", token];
                [scanner scanString:@"'" intoString:NULL];
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
