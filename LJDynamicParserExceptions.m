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
NSString* const kLJDynamicParserExceptionUnusedSymbol                   = @"LJDynamicParser Unused LHS Symbol Exception";

NSString* const kLJDynamicParserExceptionEmtpyLiteralReason             = @"Grammar literals cannot be empty strings";
NSString* const kLJDynamicParserExceptionDuplicateRuleReason            = @"LHS rules cannot be define more than once";
NSString* const kLJDynamicParserExceptionOrphanNonterminalReason        = @"RHS nonterminals must be defined as LHS rules";
NSString* const kLJDynamicParserExceptionUsedRootSymbolReason           = @"Root LHS symbol must not used in a RHS expression: <%@>";
NSString* const kLJDynamicParserExceptionUnusedSymbolReason             = @"All LHS symbols must be used in a RHS expression at least once: <%@>";
