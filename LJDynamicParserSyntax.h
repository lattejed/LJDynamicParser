//
//  LJDynamicParserSyntax.h
//  LJDynamicParser
//
//  Created by Matthew Smith on 7/2/14.
//
//

#import <Foundation/Foundation.h>

@interface LJDynamicParserSyntax : NSObject

- (instancetype)initWithTable:(NSDictionary *)syntax andRules:(NSArray *)rules;
- (void)validate;

@property (strong, readonly) NSDictionary* syntaxTable;
@property (strong, readonly) NSArray* orderedRules;

@end

@interface LJDynamicParserRule : NSObject

- (instancetype)initWithName:(NSString *)name;

@property (copy, readonly) NSString* name;

@end

@interface LJDynamicParserLiteral : NSObject

- (instancetype)initWithValue:(NSString *)value;

@property (copy, readonly) NSString* value;

@end
