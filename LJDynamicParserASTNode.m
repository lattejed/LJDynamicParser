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
    NSString* _rule;
    NSString* _literal;
    NSMutableArray* _children;
}

+ (instancetype)nodeWithRule:(NSString *)rule parent:(LJDynamicParserASTNode *)parent;
{
    LJDynamicParserASTNode* node = [LJDynamicParserASTNode new];
    if (node)
    {
        node->_isRule = YES;
        node->_parent = parent;
        node->_rule = [rule copy];
        node->_children = [NSMutableArray array];
    }
    return node;
}

+ (instancetype)nodeWithLiteral:(NSString *)literal parent:(LJDynamicParserASTNode *)parent;
{
    LJDynamicParserASTNode* node = [LJDynamicParserASTNode new];
    if (node)
    {
        node->_isLiteral = YES;
        node->_parent = parent;
        node->_literal = [literal copy];
        node->_children = [NSMutableArray array];
    }
    return node;
}

- (LJDynamicParserASTNode *)nodeForRule:(NSString *)rule;
{
    if (_isRule && [_rule isEqualToString:rule])
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
    NSString* literal = @"";
    for (LJDynamicParserASTNode* node in _children)
    {
        if ([node isRule])
        {
            literal = [@[literal, [node literalValue]] componentsJoinedByString:@" "];
        }
        else
        {
            literal = [@[literal, node->_literal] componentsJoinedByString:@" "];
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

- (NSString *)rule;
{
    return [_rule copy];
}

- (LJDynamicParserASTNode *)parent;
{
    return _parent;
}

- (NSString *)description;
{
    return [NSString stringWithFormat:@"<%@> %@", NSStringFromClass([self class]), self.value];
}

@end
