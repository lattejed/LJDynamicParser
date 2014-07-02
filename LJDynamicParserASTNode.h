//
//  LJDynamicParserASTNode.h
//  LJDynamicParser
//
//  Created by Matthew Smith on 7/1/14.
//
//

#import <Foundation/Foundation.h>

@interface LJDynamicParserASTNode : NSObject

+ (instancetype)nodeWithValue:(NSString *)value parent:(LJDynamicParserASTNode *)parent;
- (void)addChild:(LJDynamicParserASTNode *)child;
- (void)removeChild:(LJDynamicParserASTNode *)child;
- (NSString *)valueForSymbol:(NSString *)symbol;
- (NSString *)value;
- (LJDynamicParserASTNode *)parent;
- (NSArray *)children;

@end
