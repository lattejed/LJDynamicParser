//
//  LJDynamicParserSyntax.m
//  LJDynamicParser
//
//  Created by Matthew Smith on 7/2/14.
//
//

#import "LJDynamicParserSyntax.h"
#import "LJDynamicParserExceptions.h"

@implementation LJDynamicParserSyntax

- (instancetype)initWithTable:(NSDictionary *)syntax andRules:(NSArray *)rules;
{
    if (self = [super init])
    {
        _syntaxTable = syntax;
        _orderedRules = rules;
    }
    return self;
}

- (NSString *)description;
{
    NSString* description = @"";
    for (NSString* rule in _orderedRules)
    {
        NSString* ruleString = [NSString stringWithFormat:@"\n<%@> ::= ", rule];
        NSArray* expression = [_syntaxTable objectForKey:rule];
        NSMutableArray* expressionStrings = [NSMutableArray array];
        for (NSArray* termList in expression)
        {
            NSMutableArray* termListStrings = [NSMutableArray array];
            for (id term in termList)
            {
                if      ([term isKindOfClass:[LJDynamicParserRule class]])
                {
                    LJDynamicParserRule* rule = term;
                    [termListStrings addObject:[NSString stringWithFormat:@"<%@>", rule.name]];
                }
                else if ([term isKindOfClass:[LJDynamicParserLiteral class]])
                {
                    LJDynamicParserLiteral* literal = term;
                    [termListStrings addObject:[NSString stringWithFormat:@"'%@'", literal.value]];
                }
            }
            [expressionStrings addObject:[termListStrings componentsJoinedByString:@" "]];
        }
        ruleString = [ruleString stringByAppendingString:[expressionStrings componentsJoinedByString:@" | "]];
        description = [description stringByAppendingString:ruleString];
    }
    return description;
}

- (void)validate;
{
    NSCountedSet* testSet = [NSCountedSet setWithArray:_orderedRules];
    NSString* rootSymbol = [_orderedRules firstObject];
    for (NSString* rule in _orderedRules)
    {
        NSArray* expression = [_syntaxTable objectForKey:rule];
        for (NSArray* termList in expression)
        {
            for (id term in termList)
            {
                if      ([term isKindOfClass:[LJDynamicParserRule class]])
                {
                    LJDynamicParserRule* rule = term;
                    if (![_orderedRules containsObject:rule.name])
                    {
                        @throw [NSException exceptionWithName:kLJDynamicParserExceptionOrphanNonterminal
                                                       reason:[NSString stringWithFormat:kLJDynamicParserExceptionOrphanNonterminalReason, rule.name]
                                                     userInfo:nil];
                    }
                    if ([rule.name isEqualToString:rootSymbol])
                    {
                        @throw [NSException exceptionWithName:kLJDynamicParserExceptionUsedRootSymbol
                                                       reason:[NSString stringWithFormat:kLJDynamicParserExceptionUsedRootSymbolReason, rootSymbol]
                                                     userInfo:nil];
                    }
                }
                else if ([term isKindOfClass:[LJDynamicParserLiteral class]])
                {
                    LJDynamicParserLiteral* literal = term;
                    if (literal.value.length == 0)
                    {
                        @throw [NSException exceptionWithName:kLJDynamicParserExceptionEmtpyLiteral
                                                       reason:[NSString stringWithFormat:kLJDynamicParserExceptionEmtpyLiteralReason, rule]
                                                     userInfo:nil];
                    }
                }
            }
        }
        if ([testSet countForObject:rule] > 1)
        {
            @throw [NSException exceptionWithName:kLJDynamicParserExceptionDuplicateRule
                                           reason:[NSString stringWithFormat:kLJDynamicParserExceptionDuplicateRuleReason, rule]
                                         userInfo:nil];
        }
    }
}

@end

@implementation LJDynamicParserRule

- (instancetype)initWithName:(NSString *)name;
{
    if (self = [super init])
    {
        _name = name;
    }
    return self;
}

- (NSString *)description;
{
    return [NSString stringWithFormat:@"<LJDynamicParserRule> %@", _name];
}

@end

@implementation LJDynamicParserLiteral

- (instancetype)initWithValue:(NSString *)value;
{
    if (self = [super init])
    {
        _value = value;
    }
    return self;
}

- (NSString *)description;
{
    return [NSString stringWithFormat:@"<LJDynamicParserLiteral> %@", _value];
}

@end
