//
//  LJDynamicParser.m
//  LJDynamicParser
//
//  Created by Matthew Smith on 6/27/14.
//  Copyright (c) 2014 Latte, Jed?. All rights reserved.
//

#import "LJDynamicParser.h"
#import "LJDynamicParserSyntax.h"
#import "LJDynamicParserASTNode.h"

@interface LJDynamicParser ()

@property (strong) NSScanner* inputScanner;

- (LJDynamicParserSyntax *)parseSyntaxFromGrammar:(NSString *)grammar;
- (BOOL)parseFromNode:(LJDynamicParserASTNode *)rootNode;

@end

@implementation LJDynamicParser

- (instancetype)initWithGrammar:(NSString *)grammar;
{
    if (self = [super init])
    {
        _syntax = [self parseSyntaxFromGrammar:grammar];
    }
    return self;
}

- (LJDynamicParserASTNode *)parse:(NSString *)inputString ignoreCase:(BOOL)ignoreCase;
{
    _inputScanner = [NSScanner scannerWithString:inputString];
    _inputScanner.charactersToBeSkipped = nil;
    _inputScanner.caseSensitive  = !ignoreCase;
    
    NSString* firstRule = [[_syntax orderedRules] firstObject];
    LJDynamicParserASTNode* rootNode = [LJDynamicParserASTNode nodeWithRule:firstRule parent:nil];
    
    BOOL didParse = [self parseFromNode:rootNode];
    return (didParse && _inputScanner.scanLocation == _inputScanner.string.length) ? rootNode : nil;
}

- (BOOL)parseFromNode:(LJDynamicParserASTNode *)currentNode;
{
    BOOL didParse;
    NSCharacterSet* whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSArray* expression = [[_syntax syntaxTable] objectForKey:currentNode.rule];
    for (NSArray* termList in expression)
    {
        NSUInteger lastLocation = _inputScanner.scanLocation;
        for (id term in termList)
        {
            if      ([term isKindOfClass:[LJDynamicParserRule class]])
            {
                LJDynamicParserRule* rule = term;
                LJDynamicParserASTNode* nextNode = [LJDynamicParserASTNode nodeWithRule:rule.name parent:currentNode];
                [currentNode addChild:nextNode];
                didParse = [self parseFromNode:nextNode];
            }
            else if ([term isKindOfClass:[LJDynamicParserLiteral class]])
            {
                NSString* string;
                LJDynamicParserLiteral* literal = term;
                [_inputScanner scanCharactersFromSet:whitespace intoString:NULL];
                didParse = [_inputScanner scanString:literal.value intoString:&string];
                if (didParse)
                {
                    LJDynamicParserASTNode* nextNode = [LJDynamicParserASTNode nodeWithLiteral:string parent:currentNode];
                    [currentNode addChild:nextNode];
                }
            }
            if (!didParse) break;
        }
        if (didParse)   break;
        else            [_inputScanner setScanLocation:lastLocation];
    }
    if (!didParse && currentNode.parent) [[currentNode parent] removeChild:currentNode];
    return didParse;
}

- (LJDynamicParserSyntax *)parseSyntaxFromGrammar:(NSString *)grammar;
{
    NSCharacterSet* delimiters = [NSCharacterSet characterSetWithCharactersInString:@"\"'|<\n"];
    NSScanner* scanner = [NSScanner scannerWithString:grammar];
    scanner.charactersToBeSkipped = nil;
    NSMutableDictionary* syntax = [NSMutableDictionary dictionary];
    NSMutableArray* orderedRules = [NSMutableArray array];

    while ([scanner isAtEnd] == NO)
    {
        NSString* rule;
        [scanner scanUpToString:@"<" intoString:NULL];
        [scanner scanString:@"<" intoString:NULL];
        [scanner scanUpToString:@">" intoString:&rule];
        [scanner scanUpToString:@"::=" intoString:NULL];
        [scanner scanString:@"::=" intoString:NULL];

        if ([scanner isAtEnd]) break;
        
        [orderedRules addObject:rule];
        NSMutableArray* expression = [NSMutableArray array];
        NSMutableArray* termList = [NSMutableArray array];
        while ([scanner isAtEnd] == NO)
        {
            NSString* term = nil;
            [scanner scanUpToCharactersFromSet:delimiters intoString:NULL];
            
            if ([scanner isAtEnd]) break;

            NSString* testChar = [NSString stringWithFormat:@"%c",
                                  [scanner.string characterAtIndex:scanner.scanLocation]];

            if      ([testChar isEqualToString:@"<"])
            {
                [scanner scanString:@"<" intoString:NULL];
                [scanner scanUpToString:@">" intoString:&term];
                [scanner scanString:@">" intoString:NULL];
                [termList addObject:[[LJDynamicParserRule alloc] initWithName:term]];
            }
            else if ([testChar isEqualToString:@"'"] || [testChar isEqualToString:@"\""])
            {
                [scanner scanString:testChar intoString:NULL];
                [scanner scanUpToString:testChar intoString:&term];
                [scanner scanString:testChar intoString:NULL];
                if ([term length]) [termList addObject:[[LJDynamicParserLiteral alloc] initWithValue:term]];
                else @throw [NSException exceptionWithName:@"Empty Literal Exception"
                                                    reason:@"Grammar literals cannot be empty strings"
                                                  userInfo:nil];
            }
            else if ([testChar isEqualToString:@"|"])
            {
                [scanner scanString:@"|" intoString:NULL];
                [expression addObject:termList];
                termList = [NSMutableArray array];
            }
            else if ([testChar isEqualToString:@"\n"])
            {
                break;
            }
        }
        [expression addObject:termList];
        [syntax setObject:expression forKey:rule];
    }
    return [[LJDynamicParserSyntax alloc] initWithTable:syntax andRules:orderedRules];
}

@end
