//
//  PostgresConnectionURLValueTransformer.h
//  Postgres
//
//  Created by Mattt Thompson on 12/04/13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PostgresConnectionURLValueTransformer : NSValueTransformer

@end

#pragma mark -

@interface PostgresPSQLValueTransformer : PostgresConnectionURLValueTransformer
@end

@interface PostgresPGRestoreValueTransformer : PostgresConnectionURLValueTransformer
@end

@interface PostgresActiveRecordValueTransformer : PostgresConnectionURLValueTransformer
@end

@interface PostgresSequelValueTransformer : PostgresConnectionURLValueTransformer
@end

@interface PostgresDataMapperValueTransformer : PostgresConnectionURLValueTransformer
@end

@interface PostgresDjangoValueTransformer : PostgresConnectionURLValueTransformer
@end

//@interface PostgresJDBCURLValueTransformer : PostgresConnectionURLValueTransformer
//@end
//
//@interface PostgresJDBCPropertiesValueTransformer : PostgresConnectionURLValueTransformer
//@end
//
//@interface PostgresPHPValueTransformer : PostgresConnectionURLValueTransformer
//@end



