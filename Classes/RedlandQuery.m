//
//  RedlandQuery.m
//  Redland Objective-C Bindings
//  $Id: RedlandQuery.m 4 2004-09-25 15:49:17Z kianga $
//
//  Copyright 2004 Rene Puls <http://purl.org/net/kianga/>
//	Copyright 2012 Pascal Pfiffner <http://www.chip.org/>
//
//  This file is available under the following three licenses:
//   1. GNU Lesser General Public License (LGPL), version 2.1
//   2. GNU General Public License (GPL), version 2
//   3. Apache License, version 2.0
//
//  You may not use this file except in compliance with at least one of
//  the above three licenses. See LICENSE.txt at the top of this package
//  for the complete terms and further details.
//
//  The most recent version of this software can be found here:
//  <https://github.com/p2/Redland-ObjC>
//
//  For information about the Redland RDF Application Framework, including
//  the most recent version, see <http://librdf.org/>.
//

#import "RedlandQuery.h"
#import "RedlandWorld.h"
#import "RedlandURI.h"
#import "RedlandQueryResults.h"
#import "RedlandModel.h"

NSString * const RedlandRDQLLanguageName = @"rdql";
NSString * const RedlandSPARQLLanguageName = @"sparql";

@implementation RedlandQuery

@dynamic limit, offset;


#pragma mark - Init and Cleanup
/**
 *  Returns an autoreleased RedlandQuery initialized using initWithLanguageName:queryString:.
 */
+ (id)queryWithLanguageName:(NSString *)langName queryString:(NSString *)queryString baseURI:(RedlandURI *)baseURI;
{
	return [[self alloc] initWithLanguageName:langName queryString:queryString baseURI:baseURI];
}

/**
 *  Returns an autoreleased RedlandQuery initialized using initWithLanguageName:languageURI:queryString:.
 */
+ (id)queryWithLanguageName:(NSString *)langName languageURI:(RedlandURI *)langURI queryString:(NSString *)queryString baseURI:(RedlandURI *)baseURI;
{
	return [[self alloc] initWithLanguageName:langName languageURI:langURI queryString:queryString baseURI:baseURI];
}

/**
 *  Initializes a RedlandQuery with the given language name and query string.
 *  @param langName The only supported language name is currently the constant <tt>RedlandRDQLLanguageName</tt>.
 *  @param queryString The query string in the given language
 *  @param baseURI The base URI to use
 */
- (id)initWithLanguageName:(NSString *)langName queryString:(NSString *)queryString baseURI:(RedlandURI *)baseURI;
{
	NSParameterAssert(langName != nil);
	NSParameterAssert(queryString != nil);
	
	return [self initWithLanguageName:langName languageURI:nil queryString:queryString baseURI:baseURI];
}

/**
 *  Initializes a RedlandQuery with the given language name or URI and query string.
 *  @param langName The only supported language name is currently the constant <tt>RedlandRDQLLanguageName</tt>.
 *  @param langURI The URI identifying the requested query language
 *  @param queryString The query string in the given language
 *  @param baseURI The base uri to use
 */
- (id)initWithLanguageName:(NSString *)langName languageURI:(RedlandURI *)langURI queryString:(NSString *)queryString baseURI:(RedlandURI *)baseURI;
{
	NSParameterAssert(langName != nil || langURI != nil);
	NSParameterAssert(queryString != nil);
	
	librdf_query *newQuery = librdf_new_query([RedlandWorld defaultWrappedWorld],
											  [langName UTF8String],
											  [langURI wrappedURI],
											  (unsigned char *)[queryString UTF8String],
											  [baseURI wrappedURI]);
	[[RedlandWorld defaultWorld] handleStoredErrors];
	return [self initWithWrappedObject:newQuery];
}

- (void)dealloc
{
	if (isWrappedObjectOwner) {
		librdf_free_query(wrappedObject);
	}
}

/**
 *  Returns the underlying librdf_query object of the receiver.
 */
- (librdf_query *)wrappedQuery
{
	return wrappedObject;
}



#pragma mark - Query Execution
/**
 *  Run the query on the given model.
 *  @return A RedlandQueryResults object
 */
- (RedlandQueryResults *)executeOnModel:(RedlandModel *)aModel
{
	NSParameterAssert(aModel != nil);
	
	librdf_query_results *results = librdf_query_execute(wrappedObject, [aModel wrappedModel]);
	[[RedlandWorld defaultWorld] handleStoredErrors];
	return [[RedlandQueryResults alloc] initWithWrappedObject:results];
}



#pragma mark - KVC
/**
 *  Get the query-specified limit on results.
 *  @return integer >=0 if a limit is given, otherwise <0
 */
- (int)limit
{
	return librdf_query_get_limit(wrappedObject);
}

/**
 *  Set the query-specified limit on results.
	This is the limit given in the query on the number of results allowed.
 *  @param newLimit the limit on results, >=0 to set a limit, <0 to have no limit
 */
- (void)setLimit:(int)newLimit
{
	librdf_query_set_limit(wrappedObject, newLimit);
}

/**
 *  Get the query-specified offset on results. This is the offset given in the query on the number of results allowed.
 *  @return integer >=0 if a offset is given, otherwise <0
 */
- (int)offset
{
	return librdf_query_get_offset(wrappedObject);
}

/**
 *  Set the query-specified offset on results.
	This is the offset given in the query on the number of results allowed.
 *  @param newOffset offset for results, >=0 to set an offset, <0 to have no offset
 */
- (void)setOffset:(int)newOffset
{
	librdf_query_set_offset(wrappedObject, newOffset);
}


@end


/**
 *  Mapping from clock$UNIX2003() to clock()
 *  @todo There probably is a cleaner solution to this, but it's out of my league.
 */
clock_t clock$UNIX2003(void)
{
	return clock();
}

