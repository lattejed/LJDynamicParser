//
//  LJDynamicParserASTNode.h
//  LJDynamicParser
//
//  Created by Matthew Smith on 7/1/14.
//
//

#import <Foundation/Foundation.h>

@interface LJDynamicParserASTNode : NSObject

@property (assign, readonly) BOOL isRule;
@property (assign, readonly) BOOL isLiteral;

+ (instancetype)nodeWithRule:(NSString *)rule parent:(LJDynamicParserASTNode *)parent;
+ (instancetype)nodeWithLiteral:(NSString *)literal parent:(LJDynamicParserASTNode *)parent;

- (void)addChild:(LJDynamicParserASTNode *)child;
- (void)removeChild:(LJDynamicParserASTNode *)child;
- (void)removeAllChildren;
- (LJDynamicParserASTNode *)nodeForRule:(NSString *)rule;
- (NSString *)literalValue;
- (NSString *)rule;
- (LJDynamicParserASTNode *)parent;

@end
