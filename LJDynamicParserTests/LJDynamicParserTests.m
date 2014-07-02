//
//  LJDynamicParserTests.m
//  LJDynamicParserTests
//
//  Created by Matthew Smith on 7/1/14.
//
//

#import <XCTest/XCTest.h>
#import "LJDynamicParser.h"
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

- (void)testOptionalTerms;
{
    LJDynamicParser* parser = [[LJDynamicParser alloc] initWithGrammar:grammar];
    LJDynamicParserASTNode* rootNode = [parser parse:@"12 / 31 / 1972"];
    
    XCTAssertEqualObjects([rootNode valueForSymbol:@"day"], @"31", @"");
    XCTAssertEqualObjects([rootNode valueForSymbol:@"month"], @"12", @"");
    XCTAssertEqualObjects([rootNode valueForSymbol:@"year"], @"1972", @"");
    
    rootNode = [parser parse:@"31 / 12 / 1972"];

    XCTAssertTrue(rootNode, @"");
    XCTAssertEqualObjects([rootNode valueForSymbol:@"day"], @"31", @"");
    XCTAssertEqualObjects([rootNode valueForSymbol:@"month"], @"12", @"");
    XCTAssertEqualObjects([rootNode valueForSymbol:@"year"], @"1972", @"");
    
    rootNode = [parser parse:@"31-12-1972"];
    
    XCTAssertFalse(rootNode, @"");
    
    rootNode = [parser parse:@"31 12 1972"];
    
    XCTAssertTrue(rootNode, @"");
    XCTAssertEqualObjects([rootNode valueForSymbol:@"day"], @"31", @"");
    XCTAssertEqualObjects([rootNode valueForSymbol:@"month"], @"12", @"");
    XCTAssertEqualObjects([rootNode valueForSymbol:@"year"], @"1972", @"");
}

/*
- (void)testEscapedSingleQuote;
{
    //NSString* grammar = @"<terminal_with_quote> ::= '[\\\']'";
    LJDynamicParser* parser = [[LJDynamicParser alloc] initWithGrammar:grammar];
    
    NSArray* expr0 = parser.parseTable[@"terminal_with_quote"][0];
    NSRegularExpression* regex = (NSRegularExpression *)expr0[0];
    NSString* pattern = [regex pattern];
    NSArray* matches = [regex matchesInString:@"'" options:0 range:NSMakeRange(0, 1)];
    
    XCTAssertEqualObjects(pattern, @"^[\\\']$", @"");
    XCTAssert(matches.count == 1, @"");
}
*/

/*
- (void)testOptionalWord;
{
    NSString* grammar = @"                            \n\
    <test_symbol>   ::=  <junk> <test> <junk> <test>  \n\
    <test>          ::= '(test)?'                     \n\
    <junk>          ::= 'junk'                        \n\
    ";
    
    LJDynamicParser* parser = [[LJDynamicParser alloc] initWithGrammar:grammar];
    NSArray* tokens = [@"junk junk" componentsSeparatedByString:@" "];
    LJDynamicParserASTNode* rootNode = [parser parse:tokens];

    XCTAssert(rootNode.children.count == 3, @"");

    XCTAssertEqualObjects([rootNode valueForSymbol:@"test"], @"test", @"");
    XCTAssertEqualObjects([rootNode valueForSymbol:@"junk"], @"junk", @"");

    rootNode = [parser parse:@[@"junk"]];
    
    XCTAssert(rootNode.children.count == 1, @"");

    XCTAssertEqualObjects([rootNode valueForSymbol:@"test"], @"test", @"");
    XCTAssertEqualObjects([rootNode valueForSymbol:@"junk"], @"junk", @"");
    XCTAssertEqualObjects([rootNode valueForSymbol:@"test"], @"test", @"");
}
*/

/*
- (void)testParse;
{
    LJDynamicParser* parser = [[LJDynamicParser alloc] initWithGrammar:dateGrammar];
    NSArray* tokens = [@"31 / 12 / 2014" componentsSeparatedByString:@" "];
    LJDynamicParserASTNode* rootNode = [parser parse:tokens];
    
    XCTAssertEqualObjects([rootNode valueForSymbol:@"day"], @"31", @"");
    XCTAssertEqualObjects([rootNode valueForSymbol:@"month"], @"12", @"");
    XCTAssertEqualObjects([rootNode valueForSymbol:@"year"], @"2014", @"");
}
*/

@end
