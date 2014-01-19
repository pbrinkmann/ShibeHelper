//
//  DCMMiningPool.m
//  DogecoinManager
//
//  Created by Paul Brinkmann on 1/18/14.
//  Copyright (c) 2014 Paul Brinkmann. All rights reserved.
//

#import "DCMMiningPool.h"

@interface DCMMiningPool ()

// private stuff here I guess

@end

@implementation DCMMiningPool

-(id)init
{
    self = [super init];
    if(self) {
        //       self.address = @"DLFXSX5e258mjURmEB7hZDVL5W5bCTerui";
 
        self.poolURL = @"http://teamdoge.com/";
        self.apiKey  = @"042942b4863c05351976f0e779dc15a076e70a12a1d75371a3c512c0c33872d7";
        
        [self updatePoolInfo];
        
    }
    
    return self;
}

-(void)updatePoolInfo
{
    NSString* apiMethod = @"getestimatedtime";
    NSURL *url = [NSURL URLWithString:
                                      [NSString stringWithFormat:@"%@?page=api&action=%@&api_key=%@",
                                            self.poolURL,
                                            apiMethod,
                                            self.apiKey
                                      ]
                 ];
    
    NSData *data = [NSData dataWithContentsOfURL:url];
    
    if( data == nil) {
        NSLog(@"could not fetch data from pool API");
        return;
    }
    
    NSError *error;
    
    NSMutableDictionary  * dict = [NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingMutableContainers error: &error];
    
    NSLog(@"dict: %@",dict);
    NSLog(@"error: %@", error);
    
    NSMutableDictionary *eta = [dict objectForKey:@"getestimatedtime"];
    
    NSLog(@"eta dict: %@",eta);
   
    NSString *estimatedTimeInSeconds = (NSString*)[eta objectForKey:@"data"];
    
    NSLog(@"etis: %@", estimatedTimeInSeconds);
    
    self.estimatedSecondsPerBlock = [NSNumber numberWithInt:[estimatedTimeInSeconds intValue]];
}



/*

NSURL * url=[NSURL URLWithString:@"http://api.geonames.org/citiesJSON?north=44.1&south=-9.9&east=-22.4&west=55.2&lang=de&username=demo"];   // pass your URL  Here.

NSData * data=[NSData dataWithContentsOfURL:url];

NSError * error;

NSMutableDictionary  * json = [NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingMutableContainers error: &error];

NSLog(@"%@",json);


NSMutableArray * referanceArray=[[NSMutableArray alloc]init];

NSMutableArray * periodArray=[[NSMutableArray alloc]init];

NSArray * responseArr = json[@"days"];

for(NSDictionary * dict in responseArr)
{
    
    [referanceArray addObject:[dict valueForKey:@"reference"]];
    [periodArray addObject:[dict valueForKey:@"period"]];
    
}


NSLog(@"%@",referanceArray);   // Here you get the Referance data
NSLog(@"%@",periodArray);      // Here you get the Period data


*/

@end