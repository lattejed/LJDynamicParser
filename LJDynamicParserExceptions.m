//
//  LJDynamicParserExceptions.m
//  LJDynamicParser
//
//  Created by Matthew Smith on 7/7/14.
//
//

#import "LJDynamicParserExceptions.h"

NSString* const kLJDynamicParserExceptionEmtpyLiteral                   = @"LJDynamicParser Empty Literal Exception";
NSString* const kLJDynamicParserExceptionDuplicateRule                  = @"LJDynamicParser Duplicate LHS Rule Exception";
NSString* const kLJDynamicParserExceptionOrphanNonterminal              = @"LJDynamicParser Orphan RHS Nonterminal Exception";
NSString* const kLJDynamicParserExceptionUsedRootSymbol                 = @"LJDynamicParser Root LHS Symbol Exception";

NSString* const kLJDynamicParserExceptionEmtpyLiteralReason             = @"Grammar literals cannot be empty strings. Rule: <%@>";
NSString* const kLJDynamicParserExceptionDuplicateRuleReason            = @"LHS rules cannot be define more than once. Rule: <%@>";
NSString* const kLJDynamicParserExceptionOrphanNonterminalReason        = @"RHS nonterminals must be defined as LHS rules. Nonterminal: <%@>";
NSString* const kLJDynamicParserExceptionUsedRootSymbolReason           = @"Root LHS symbol must not used in a RHS expression: <%@>";
