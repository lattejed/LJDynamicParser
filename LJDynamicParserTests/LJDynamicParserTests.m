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

static NSString* const grammar1 = @"                                            \n\
<date>              ::= <date_d> | <date_m>                                     \n\
<date_d>            ::= <date_d_slash> | <date_d_no_slash>                      \n\
<date_m>            ::= <date_m_slash> | <date_m_no_slash>                      \n\
<date_d_slash>      ::= <day> <slash> <month> <slash> <year>                    \n\
<date_m_slash>      ::= <month> <slash> <day> <slash> <year>                    \n\
<date_d_no_slash>   ::= <day> <month> <year>                                    \n\
<date_m_no_slash>   ::= <month> <day> <year>                                    \n\
<month>             ::= '12'                                                    \n\
<day>               ::= '31'                                                    \n\
<year>              ::= '1972'                                                  \n\
<slash>             ::= '/'                                                     \n\
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
    NSString* filepath = [[NSBundle bundleForClass:[self class]] pathForResource:@"timex" ofType:@"grammar"];
    NSString* grammar = [NSString stringWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:nil];
    LJDynamicParser* parser = [[LJDynamicParser alloc] initWithGrammar:grammar];
    LJDynamicParserASTNode* rootNode;
    
    rootNode = [parser parse:@"Tuesday" ignoreCase:YES];
    XCTAssertNotNil(rootNode, @"");
    XCTAssertEqualObjects([[rootNode nodeForRule:@"date"] literalValue], @"Tuesday", @"");
    
    rootNode = [parser parse:@"Next Tuesday" ignoreCase:YES];
    
    XCTAssertNotNil(rootNode, @"");
    XCTAssertEqualObjects([[rootNode nodeForRule:@"next_day_of_week"] literalValue], @"Next Tuesday", @"");
    XCTAssertEqualObjects([[rootNode nodeForRule:@"day_of_week"] literalValue], @"Tuesday", @"");
    
    rootNode = [parser parse:@"On Tuesdays" ignoreCase:YES];
    
    XCTAssertNotNil(rootNode, @"");
    XCTAssertEqualObjects([[rootNode nodeForRule:@"frequency"] literalValue], @"On Tuesday s", @"");
}

- (void)testOptionalTermsGrammar1;
{
    LJDynamicParser* parser = [[LJDynamicParser alloc] initWithGrammar:grammar1];
    LJDynamicParserASTNode* rootNode = [parser parse:@"12 / 31 / 1972" ignoreCase:YES];
    
    XCTAssertEqualObjects([[rootNode nodeForRule:@"day"] literalValue], @"31", @"");
    XCTAssertEqualObjects([[rootNode nodeForRule:@"month"] literalValue], @"12", @"");
    XCTAssertEqualObjects([[rootNode nodeForRule:@"year"] literalValue], @"1972", @"");
    
    rootNode = [parser parse:@"31 / 12/1972" ignoreCase:YES];
    
    XCTAssertNotNil(rootNode, @"");
    XCTAssertEqualObjects([[rootNode nodeForRule:@"day"] literalValue], @"31", @"");
    XCTAssertEqualObjects([[rootNode nodeForRule:@"month"] literalValue], @"12", @"");
    XCTAssertEqualObjects([[rootNode nodeForRule:@"year"] literalValue], @"1972", @"");
    
    rootNode = [parser parse:@"31-12 - 1972" ignoreCase:YES];
    
    XCTAssertNil(rootNode, @"");
    
    rootNode = [parser parse:@"31 12 1972" ignoreCase:YES];
    
    XCTAssertNotNil(rootNode, @"");
    XCTAssertEqualObjects([[rootNode nodeForRule:@"day"] literalValue], @"31", @"");
    XCTAssertEqualObjects([[rootNode nodeForRule:@"month"] literalValue], @"12", @"");
    XCTAssertEqualObjects([[rootNode nodeForRule:@"year"] literalValue], @"1972", @"");
}

- (void)testASTLiteralValues;
{
    NSString* grammar = @"         \n\
    <date>   ::= <day> '/' <month> \n\
    <day>    ::= '31'              \n\
    <month>  ::= '12'              \n\
    ";
    
    LJDynamicParser* parser = [[LJDynamicParser alloc] initWithGrammar:grammar];
    
    LJDynamicParserASTNode* rootNode = [parser parse:@"31 / 12" ignoreCase:YES];
    XCTAssertNotNil(rootNode, @"");
    XCTAssertEqualObjects([[rootNode nodeForRule:@"date"] literalValue], @"31 / 12", @"");
}

- (void)testGrammar1Syntax;
{
    LJDynamicParser* parser = [[LJDynamicParser alloc] initWithGrammar:grammar1];
    
    NSArray* day = [[[parser syntax] syntaxTable] objectForKey:@"day"];
    LJDynamicParserLiteral* dayLit = [[day firstObject] firstObject];
    NSArray* maybeSlash = [[[parser syntax] syntaxTable] objectForKey:@"maybe_slash"];
    
    XCTAssertEqualObjects([[[parser syntax] orderedRules] firstObject], @"date", @"");
    XCTAssertEqualObjects([[[parser syntax] orderedRules] lastObject], @"slash", @"");
    XCTAssertEqualObjects(dayLit.value, @"31", @"");
}

@end
