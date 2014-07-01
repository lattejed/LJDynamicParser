//
//  LJDynamicParser.h
//  LJDynamicParser
//
//  Created by Matthew Smith on 6/27/14.
//  Copyright (c) 2014 Latte, Jed?. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LJDynamicParserASTNode.h"

@interface LJDynamicParser : NSObject

@property (strong, readonly) NSDictionary* parseTable;

- (instancetype)initWithGrammar:(NSString *)grammar;
- (LJDynamicParserASTNode *)parse:(NSArray *)tokens;

@end
