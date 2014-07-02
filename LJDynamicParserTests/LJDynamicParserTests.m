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

static NSString* const grammar1 = @"                                        \n\
<date>          ::= <date_d> | <date_m>                                     \n\
<date_d>        ::= <day> <maybe_slash> <month> <maybe_slash> <year>        \n\
<date_m>        ::= <month> <maybe_slash> <day> <maybe_slash> <year>        \n\
<month>         ::= '12'                                                    \n\
<day>           ::= '31'                                                    \n\
<year>          ::= '1972'                                                  \n\
<maybe_slash>   ::= '/' | ''                                                \n\
";

static NSString* const grammar2 = @"                                                                            \n\
<timex>                 ::= <date>                                                                              \n\
<date>                  ::= <spoken_date>                                                                       \n\
<spoken_date>           ::= <day_of_week>                                                                       \n\
<day_of_week>           ::= <day_of_week_long> | <day_of_week_short> <maybe_dot>                                \n\
<day_of_week_long>      ::= 'monday' | 'tuesday' | 'wednesday' | 'thursday' | 'friday' | 'saturday' | 'sunday'  \n\
<day_of_week_short>     ::= 'mon' | 'tue' | 'wed' | 'weds' | 'thur' | 'thu' | 'thurs' | 'fri' | 'sat' | 'sun'   \n\
<maybe_dot>             ::= '.' | ''                                                                            \n\
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

- (void)testGrammar2Parse;
{
    LJDynamicParser* parser = [[LJDynamicParser alloc] initWithGrammar:grammar2];
    
    LJDynamicParserASTNode* rootNode = [parser parse:@"Tuesday" ignoreCase:YES];
    XCTAssertNotNil(rootNode, @"");
    XCTAssertEqualObjects([rootNode valueForSymbol:@"day_of_week_long"], @"Tuesday", @"");

    rootNode = [parser parse:@"Next Tuesday" ignoreCase:YES];
    XCTAssertNil(rootNode, @"");
}


- (void)testGrammar1Syntax;
{
    LJDynamicParser* parser = [[LJDynamicParser alloc] initWithGrammar:grammar1];
    
    NSArray* day = [[[parser syntax] syntaxTable] objectForKey:@"day"];
    LJDynamicParserLiteral* dayLit = [[day firstObject] firstObject];
    NSArray* maybeSlash = [[[parser syntax] syntaxTable] objectForKey:@"maybe_slash"];
    id maybeSlashLit = [[maybeSlash lastObject] firstObject];
    
    XCTAssertEqualObjects([[[parser syntax] orderedRules] firstObject], @"date", @"");
    XCTAssertEqualObjects([[[parser syntax] orderedRules] lastObject], @"maybe_slash", @"");
    XCTAssertEqualObjects(dayLit.value, @"31", @"");
    XCTAssert([maybeSlashLit isKindOfClass:[LJDynamicParserOptional class]], @"");
}

- (void)testOptionalTermsGrammar1;
{
    LJDynamicParser* parser = [[LJDynamicParser alloc] initWithGrammar:grammar1];
    LJDynamicParserASTNode* rootNode = [parser parse:@"12 / 31 / 1972" ignoreCase:YES];
    
    XCTAssertEqualObjects([rootNode valueForSymbol:@"day"], @"31", @"");
    XCTAssertEqualObjects([rootNode valueForSymbol:@"month"], @"12", @"");
    XCTAssertEqualObjects([rootNode valueForSymbol:@"year"], @"1972", @"");
    
    rootNode = [parser parse:@"31 / 12/1972" ignoreCase:YES];

    XCTAssertNotNil(rootNode, @"");
    XCTAssertEqualObjects([rootNode valueForSymbol:@"day"], @"31", @"");
    XCTAssertEqualObjects([rootNode valueForSymbol:@"month"], @"12", @"");
    XCTAssertEqualObjects([rootNode valueForSymbol:@"year"], @"1972", @"");
    
    rootNode = [parser parse:@"31-12 - 1972" ignoreCase:YES];
    
    XCTAssertNil(rootNode, @"");
    
    rootNode = [parser parse:@"31 12 1972" ignoreCase:YES];
    
    XCTAssertNotNil(rootNode, @"");
    XCTAssertEqualObjects([rootNode valueForSymbol:@"day"], @"31", @"");
    XCTAssertEqualObjects([rootNode valueForSymbol:@"month"], @"12", @"");
    XCTAssertEqualObjects([rootNode valueForSymbol:@"year"], @"1972", @"");
}

@end
