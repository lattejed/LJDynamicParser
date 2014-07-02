//
//  LJDynamicParser.h
//  LJDynamicParser
//
//  Created by Matthew Smith on 6/27/14.
//  Copyright (c) 2014 Latte, Jed?. All rights reserved.
//

#import <Foundation/Foundation.h>

@class LJDynamicParserSyntax;
@class LJDynamicParserASTNode;

@interface LJDynamicParser : NSObject

@property (strong, readonly) LJDynamicParserSyntax* syntax;

- (instancetype)initWithGrammar:(NSString *)grammar;
- (LJDynamicParserASTNode *)parse:(NSString *)inputString;

@end
