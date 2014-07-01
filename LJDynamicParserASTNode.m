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
