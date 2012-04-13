//
//  PostgresConnectionURLValueTransformer.m
//  Postgres
//
//  Created by Mattt Thompson on 12/04/13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "PostgresConnectionURLValueTransformer.h"

@implementation PostgresConnectionURLValueTransformer

+ (Class)transformedValueClass {
    return [NSString class];
}

+ (BOOL)allowsReverseTransformation {
    return NO;
}

- (id)transformedValue:(id)value {
    NSURL *url = (NSURL *)value;
    
    return [url absoluteString];
}

@end

#pragma mark -

@implementation PostgresPSQLValueTransformer

- (id)transformedValue:(id)value {
    NSURL *url = (NSURL *)value;
    
    return [NSString stringWithFormat:@"psql -h %@ -p %@", [url host], [url port]];
}

@end

@implementation PostgresPGRestoreValueTransformer

- (id)transformedValue:(id)value {
    NSURL *url = (NSURL *)value;
    
    return [NSString stringWithFormat:@"pg_restore --verbose --clean --no-acl --no-owner -h %@ -p %@ [YOUR_DATA_FILE]", [url host], [url port]];
}

@end

@implementation PostgresActiveRecordValueTransformer

- (id)transformedValue:(id)value {
    NSURL *url = (NSURL *)value;
    
    NSMutableArray *mutableLines = [NSMutableArray array];
    [mutableLines addObject:[NSString stringWithFormat:@"adapter: %@", @"postgresql"]];
    [mutableLines addObject:[NSString stringWithFormat:@"encoding: %@", @"unicode"]];
    [mutableLines addObject:[NSString stringWithFormat:@"host: %@", [url host]]];
    [mutableLines addObject:[NSString stringWithFormat:@"port: %@", [url port]]];
    [mutableLines addObject:[NSString stringWithFormat:@"usename: %@", [url user]]];
    [mutableLines addObject:[NSString stringWithFormat:@"password:"]];
    [mutableLines addObject:[NSString stringWithFormat:@"database: %@", @"[YOUR_DATABASE_NAME]"]];
    
    return [mutableLines componentsJoinedByString:@"\n"];
}

@end

@implementation PostgresSequelValueTransformer

- (id)transformedValue:(id)value {
    return [NSString stringWithFormat:@"Sequel.connect('%@')", [[NSValueTransformer valueTransformerForName:@"PostgresConnectionURLValueTransformer"] transformedValue:value]];
}

@end

@implementation PostgresDataMapperValueTransformer

- (id)transformedValue:(id)value {
    return [NSString stringWithFormat:@"DataMapper.setup(:default, '%@')", [[NSValueTransformer valueTransformerForName:@"PostgresConnectionURLValueTransformer"] transformedValue:value]];
}

@end

@implementation PostgresDjangoValueTransformer

- (id)transformedValue:(id)value {
    NSURL *url = (NSURL *)value;
    
    NSMutableArray *mutableLines = [NSMutableArray array];
    [mutableLines addObject:@"DATABASES = {"];
    [mutableLines addObject:@"  'default': {"];
    [mutableLines addObject:[NSString stringWithFormat:@"    'ENGINE': '%@',", @"django.db.backends.postgresql_psycopg2"]];
    [mutableLines addObject:[NSString stringWithFormat:@"    'HOST': '%@',", [url host]]];
    [mutableLines addObject:[NSString stringWithFormat:@"    'PORT': '%@',", [url port]]];
    [mutableLines addObject:[NSString stringWithFormat:@"    'USER': '%@',", [url user]]];
    [mutableLines addObject:[NSString stringWithFormat:@"    'PASSWORD': '',"]];
    [mutableLines addObject:[NSString stringWithFormat:@"    'NAME': '%@',", @"[YOUR_DATABASE_NAME]"]];
    [mutableLines addObject:@"  }"];
    [mutableLines addObject:@"}"];
    
    return [mutableLines componentsJoinedByString:@"\n"];
}

@end


//@implementation PostgresJDBCURLValueTransformer
//
//- (id)transformedValue:(id)value {
//    NSURL *url = (NSURL *)value;
//    
//    return <# string #>
//}
//
//@end
//
//
//@implementation PostgresJDBCPropertiesValueTransformer
//
//- (id)transformedValue:(id)value {
//    NSURL *url = (NSURL *)value;
//    
//    return <# string #>
//}
//
//@end
//
//@implementation PostgresPHPValueTransformer
//
//- (id)transformedValue:(id)value {
//    NSURL *url = (NSURL *)value;
//    
//    return <# string #>
//}
//
//@end






