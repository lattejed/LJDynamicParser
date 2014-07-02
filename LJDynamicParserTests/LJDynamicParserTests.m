//
//  LJDynamicParserTests.m
//  LJDynamicParserTests
//
//  Created by Matthew Smith on 7/1/14.
//
//

#import <XCTest/XCTest.h>
#import "LJDynamicParser.h"
#import "LJDynamicParserSyntax.h"
#import "LJDynamicParserASTNode.h"

static NSString* const grammar = @"                                         \n\
<date>          ::= <date_d> | <date_m>                                     \n\
<date_d>        ::= <day> <maybe_slash> <month> <maybe_slash> <year>        \n\
<date_m>        ::= <month> <maybe_slash> <day> <maybe_slash> <year>        \n\
<month>         ::= '12'                                                    \n\
<day>           ::= '31'                                                    \n\
<year>          ::= '1972'                                                  \n\
<maybe_slash>   ::= '/' | ''                                                \n\
";

@interface LJDynamicParserTests : XCTestCase

@property (strong) LJDynamicParser* parser;

@end

@implementation LJDynamicParserTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testSyntax;
{
    LJDynamicParser* parser = [[LJDynamicParser alloc] initWithGrammar:grammar];
    
    NSArray* day = [[[parser syntax] syntaxTable] objectForKey:@"day"];
    LJDynamicParserLiteral* dayLit = [[day firstObject] firstObject];
    NSArray* maybeSlash = [[[parser syntax] syntaxTable] objectForKey:@"maybe_slash"];
    id maybeSlashLit = [[maybeSlash lastObject] firstObject];
    
    XCTAssertEqualObjects([[[parser syntax] orderedRules] firstObject], @"date", @"");
    XCTAssertEqualObjects([[[parser syntax] orderedRules] lastObject], @"maybe_slash", @"");
    XCTAssertEqualObjects(dayLit.value, @"31", @"");
    XCTAssert([maybeSlashLit isKindOfClass:[LJDynamicParserOptional class]], @"");
}

- (void)testOptionalTerms;
{
    LJDynamicParser* parser = [[LJDynamicParser alloc] initWithGrammar:grammar];
    LJDynamicParserASTNode* rootNode = [parser parse:@"12 / 31 / 1972"];
    
    XCTAssertEqualObjects([rootNode valueForSymbol:@"day"], @"31", @"");
    XCTAssertEqualObjects([rootNode valueForSymbol:@"month"], @"12", @"");
    XCTAssertEqualObjects([rootNode valueForSymbol:@"year"], @"1972", @"");
    
    rootNode = [parser parse:@"31 / 12/1972"];

    XCTAssertTrue(rootNode, @"");
    XCTAssertEqualObjects([rootNode valueForSymbol:@"day"], @"31", @"");
    XCTAssertEqualObjects([rootNode valueForSymbol:@"month"], @"12", @"");
    XCTAssertEqualObjects([rootNode valueForSymbol:@"year"], @"1972", @"");
    
    rootNode = [parser parse:@"31-12 - 1972"];
    
    XCTAssertFalse(rootNode, @"");
    
    rootNode = [parser parse:@"31 12 1972"];
    
    XCTAssertTrue(rootNode, @"");
    XCTAssertEqualObjects([rootNode valueForSymbol:@"day"], @"31", @"");
    XCTAssertEqualObjects([rootNode valueForSymbol:@"month"], @"12", @"");
    XCTAssertEqualObjects([rootNode valueForSymbol:@"year"], @"1972", @"");
}

@end
