//
//  LJDynamicParserTests.m
//  LJDynamicParserTests
//
//  Created by Matthew Smith on 7/1/14.
//
//

#import <XCTest/XCTest.h>
#import "LJDynamicParser.h"

static NSString* const grammarFull = @"           \n\
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

- (void)testSingleExpression;
{
    NSString* grammar = @"<terminal_with_quote> ::= '[\']'";
    LJDynamicParser* parser = [[LJDynamicParser alloc] initWithGrammar:grammar];
    
    NSArray* expr0 = parser.parseTable[@"terminal_with_quote"][0];
    
    //XCTAssertEqualObjects(expr0[0], @"day", @"");
    //XCTAssertEqualObjects([(NSRegularExpression *)expr0[1] pattern], @"^/$", @"");
    //XCTAssertEqualObjects(expr0[2], @"month", @"");
}

@end
