//
//  LJDynamicParserASTNode.m
//  LJDynamicParser
//
//  Created by Matthew Smith on 7/1/14.
//
//

#import "LJDynamicParserASTNode.h"

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

- (LJDynamicParserASTNode *)nodeForRule:(NSString *)rule;
{
    if (_children && [_value isEqualToString:rule])
    {
        return self;
    }
    else
    {
        for (LJDynamicParserASTNode* node in _children)
        {
            LJDynamicParserASTNode* child = [node nodeForRule:rule];
            if (child) return child;
        }
    }
    return nil;
}

- (NSString *)literalValue;
{
    NSString* literal;
    for (LJDynamicParserASTNode* node in _children)
    {
        if ([[node children] count])
        {
            literal = [@[literal ?: @"", [node literalValue]] componentsJoinedByString:@" "];
        }
        else
        {
            literal = [@[literal ?: @"", node.value] componentsJoinedByString:@" "];
        }
    }
    return [literal stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
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
