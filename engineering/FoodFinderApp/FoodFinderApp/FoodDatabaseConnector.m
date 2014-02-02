//
//  FoodDatabaseConnector.m
//  FoodFinderApp
//
//  Created by Student on 1/31/14.
//  Copyright (c) 2014 bjd. All rights reserved.
//

#import "FoodDatabaseConnector.h"

@implementation FoodDatabaseConnector
{
    NSMutableArray* _restaurauntList;
    NSMutableArray* _menuList;
    
    Menu* _menu;
}

-(id)init
{
    self = [super init];
    _restaurauntList = [[NSMutableArray alloc] initWithCapacity:4];
    _restaurauntList[ 0 ] = [[Restaurant alloc] initWithName:@"Blakes" description:@"My Place" address:@"Kimball Dr" idFSRestaraunt:@"4ad42b" globalRating:4 priceRating:1];
    _restaurauntList[ 1 ] = [[Restaurant alloc] initWithName:@"Dustins" description:@"My Place" address:@"Kimball Dr" idFSRestaraunt:@"4ad42c" globalRating:3 priceRating:2];
    _restaurauntList[ 2 ] = [[Restaurant alloc] initWithName:@"Joes" description:@"My Place" address:@"Kimball Dr" idFSRestaraunt:@"4ad42e" globalRating:2 priceRating:3];
    _restaurauntList[ 3 ] = [[Restaurant alloc] initWithName:@"Matts" description:@"My Place" address:@"Kimball Dr" idFSRestaraunt:@"4ad42f" globalRating:1 priceRating:4];
    
    _menuList = [[NSMutableArray alloc] initWithCapacity:3];
    _menuList[ 0 ] = [[NSMutableArray alloc] initWithCapacity:2];
    _menuList[ 1 ] = [[NSMutableArray alloc] initWithCapacity:2];
    _menuList[ 2 ] = [[NSMutableArray alloc] initWithCapacity:2];
    
    _menuList[ 0 ][ 0 ] = @"Breakfast";
    _menuList[ 0 ][ 1 ] = [NSArray arrayWithObjects:@"Tortilla Soup", @"Avacado Chilli", nil];
    
    _menuList[ 1 ][ 0 ] = @"Lunch";
    _menuList[ 1 ][ 1 ] = [NSArray arrayWithObjects:@"Bacon Burger", @"Turnip Juice", @"Ribs", nil];
    
    _menuList[ 2 ][ 0 ] = @"Dinner";
    _menuList[ 2 ][ 1 ] = [NSArray arrayWithObjects:@"Steak", @"Meatballs", @"Pasghetii", nil];
    return self;
}
-(void) createRestaurauntObjects : (NSArray*) restauraunts
{
    _restaurauntList = [[NSMutableArray alloc] initWithCapacity:[restauraunts count]];
    NSDictionary* currentRestauraunt;
    for( int i = 0; i < [restauraunts count]; ++i )
    {
        currentRestauraunt = restauraunts[ i ];
        NSString* name = currentRestauraunt[@"name"];
        NSString* description = currentRestauraunt[@"description"];
        NSString* address = currentRestauraunt[@"location"];
        NSString* idFSRestauraunt = currentRestauraunt[@"id"];
        int globalRating = [ currentRestauraunt[@"rating"] intValue ];
        int priceRating = [ currentRestauraunt[@"price"][@"tier"] intValue];
        //_restaurauntList[ i ] = [[Restauraunt alloc] initWithName:<#(NSString *)#> description:<#(NSString *)#> address:<#(NSString *)#> idFSRestaraunt:(int) globalRating:<#(int)#> priceRating:<#(int)#>]
    }
}

-(NSArray*) getRestaurauntList: (NSString*) username: (NSString*) password: (double)latitude: (double)longitude
{
    NSArray * restaurantList = [[NSArray alloc ] init];
    
    NSString * latString = [ [ NSNumber numberWithDouble : latitude ] stringValue ];
    NSString * longString = [ [ NSNumber numberWithDouble : longitude ] stringValue ];
    
    NSDictionary *getParams =
    @{
      @"username" : username,
      @"password" : password,
      @"latitude" : latString,
      @"longitude" : longString
    };
    
    NSString *recievedData = [self callPHPScript:@"getNearbyRestaurants" :getParams];
    
    NSData * jsonData = [recievedData dataUsingEncoding:NSUTF8StringEncoding];
    NSError * e;
    NSArray * jsonRestaurantList = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&e];
    
    for( int i = 0; i < [jsonRestaurantList count]; ++i)
    {
        NSDictionary curRestaurant = jsonRestaurantList[ i ];
        
    }
    
    return _restaurauntList;
}

-(NSArray*) getMenuWithUsername : (NSString*) username password : (NSString*) password restaurantID : (NSString*) idFSRestaurant;
{
    NSMutableString *requestString = [NSMutableString stringWithString:DATABASE_URL_];
    requestString = [requestString stringByAppendingString:MENU_SCRIPT];
    
    NSString *parameters = [NSString stringWithFormat:@"?username=%@&password=%@&idFSRestaurant=%@", username, password, @"4a5125dcf964a520acb01fe3"];
    requestString = [requestString stringByAppendingString:parameters];
    
    NSString* responseString = [self getDataFrom:requestString];
    
    _menu = [[Menu alloc] initWithMenuItems:responseString];
    return _menuList;
}

-(BOOL) registerWithUsernameAndPassword : (NSString*) username : (NSString*) password;
{
    NSDictionary *getParams =
    @{
      @"username" : username,
      @"password" : password
    };
    
    NSString *recievedData = [self callPHPScript:@"registerUser" :getParams];
    
    return [recievedData isEqualToString:@"1"];
}

-(BOOL)validateWithUsernameAndPassword:(NSString*) username : (NSString*) password
{
    NSDictionary *getParams =
    @{
      @"username" : username,
      @"password" : password
    };
    
    NSString *recievedData = [self callPHPScript:@"validateUser" :getParams];
    
    return [recievedData isEqualToString:@"1"];
}

- (NSString *) callPHPScript : (NSString *)scriptName : (NSDictionary *) getParams
{
    //Initialize to [url].php
    NSString *requestString = [NSString stringWithFormat:@"%@script.%@.php", DATABASE_URL_, scriptName];
    
    //Add [url].php? if there are get params
    if ( getParams.count > 0 )
    {
        requestString = [NSString stringWithFormat:@"%@?", requestString];
    }
    
    //Append the get params
    for( id key in getParams )
    {
        requestString = [NSString stringWithFormat:@"%@%@=%@&", requestString, key, [getParams objectForKey:( key ) ] ];
    }
    
    //Remove the last ampersand
    requestString = [ requestString substringWithRange:NSMakeRange(0, [requestString length] - 1 ) ];
    
    //Call the script and get the response
    return [ self getDataFrom: requestString ];
}

//http://stackoverflow.com/questions/9404104/simple-objective-c-get-request
- (NSString *) getDataFrom:(NSString *)url
{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"GET"];
    [request setURL:[NSURL URLWithString:url]];
    
    NSError *error = [[NSError alloc] init];
    NSHTTPURLResponse *responseCode = nil;
    
    NSData *oResponseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];
    
    if([responseCode statusCode] != 200)
    {
        NSLog(@"Error getting %@, HTTP status code %i", url, [responseCode statusCode]);
        return nil;
    }
    
    return [[NSString alloc] initWithData:oResponseData encoding:NSUTF8StringEncoding];
}


@end
