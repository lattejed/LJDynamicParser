//
//  LJDynamicParserTests.m
//  LJDynamicParserTests
//
//  Created by Matthew Smith on 7/1/14.
//
//

#import <XCTest/XCTest.h>
#import "LJDynamicParser.h"

static NSString* const dateGrammar = @"           \n\
<date>      ::= <date_d> | <date_m>               \n\
<date_d>    ::= <day> '/' <month> '/' <year>      \n\
<date_m>    ::= <month> '/' <day> '/' <year>      \n\
<month>     ::= '(0?[1-9]|1[0-2])'                \n\
<day>       ::= '(0?[1-9]|[12]\\d|3[01])'         \n\
<year>      ::= '(19|20)\\d{2}'                   \n\
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

- (void)testEscapedSingleQuote;
{
    NSString* grammar = @"<terminal_with_quote> ::= '[\\\']'";
    LJDynamicParser* parser = [[LJDynamicParser alloc] initWithGrammar:grammar];
    
    NSArray* expr0 = parser.parseTable[@"terminal_with_quote"][0];
    NSRegularExpression* regex = (NSRegularExpression *)expr0[0];
    NSString* pattern = [regex pattern];
    NSArray* matches = [regex matchesInString:@"'" options:0 range:NSMakeRange(0, 1)];
    
    XCTAssertEqualObjects(pattern, @"^[\\\']$", @"");
    XCTAssert(matches.count == 1, @"");
}

- (void)testParse;
{
    LJDynamicParser* parser = [[LJDynamicParser alloc] initWithGrammar:dateGrammar];
    NSArray* tokens = [@"31 / 12 / 2014" componentsSeparatedByString:@" "];
    LJDynamicParserASTNode* rootNode = [parser parse:tokens];
    
    XCTAssertEqualObjects([rootNode valueForSymbol:@"day"], @"31", @"");
    XCTAssertEqualObjects([rootNode valueForSymbol:@"month"], @"12", @"");
    XCTAssertEqualObjects([rootNode valueForSymbol:@"year"], @"2014", @"");
}

@end
