//
//  LJDynamicParserSyntax.m
//  LJDynamicParser
//
//  Created by Matthew Smith on 7/2/14.
//
//

#import "LJDynamicParserSyntax.h"

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
                else if ([term isKindOfClass:[LJDynamicParserOptional class]])
                {
                    [termListStrings addObject:@"''"];
                }
            }
            [expressionStrings addObject:[termListStrings componentsJoinedByString:@" "]];
        }
        ruleString = [ruleString stringByAppendingString:[expressionStrings componentsJoinedByString:@" | "]];
        description = [description stringByAppendingString:ruleString];
    }
    return description;
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

@end

@implementation LJDynamicParserOptional

@end
