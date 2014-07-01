//
//  LJDynamicParser.h
//  LJDynamicParser
//
//  Created by Matthew Smith on 6/27/14.
//  Copyright (c) 2014 Latte, Jed?. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LJDynamicParserASTNode;

@interface LJDynamicParser : NSObject

@property (strong, readonly) NSDictionary* parseTable;

- (instancetype)initWithGrammar:(NSString *)grammar;
- (LJDynamicParserASTNode *)parse:(NSArray *)tokens;

@end

@interface LJDynamicParserASTNode : NSObject

+ (instancetype)nodeWithValue:(NSString *)value parent:(LJDynamicParserASTNode *)parent;
- (void)addChild:(LJDynamicParserASTNode *)child;
- (void)removeChild:(LJDynamicParserASTNode *)child;
- (NSString *)valueForSymbol:(NSString *)symbol;
- (NSString *)value;
- (LJDynamicParserASTNode *)parent;
- (NSArray *)children;

@end