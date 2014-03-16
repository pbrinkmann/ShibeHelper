//
//  DCMCGMiner.m
//  DogecoinManager
//
//  Created by Paul Brinkmann on 3/11/14.
//  Copyright (c) 2014 Paul Brinkmann. All rights reserved.
//

#import "DCMCGMiner.h"

@interface DCMCGMiner()

@property (atomic) BOOL updateInProgress;
@property (atomic, copy) void (^updateCompleteCallback)() ;

@end


@implementation DCMCGMiner

-(instancetype)init {
    self = [super init];
    if(self) {
        self.ipAddress = @"192.168.0.110";
        self.port = 4028;
        self.updateInProgress = FALSE;
    }
    
    return self;
}

-(void)fetchyDoShit:(void(^)())updateCompleteCallback
{
    if(self.updateInProgress) {
        DLog(@"CGMiner Update already in progress");
        return;
    }
 
    self.updateCompleteCallback = updateCompleteCallback;
    
    CFReadStreamRef readStream;
    CFWriteStreamRef writeStream;
    
    // Connect to the IP address/port
    CFStreamCreatePairWithSocketToHost(NULL, (__bridge CFStringRef)(self.ipAddress), self.port, &readStream, &writeStream);
    
    _reader  = (__bridge NSInputStream*)readStream;
    _writer  = (__bridge NSOutputStream*)writeStream;
    
    [_reader setDelegate:self];
    [_writer setDelegate:self];
    
    [_reader scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [_writer scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    [_reader open];
    [_writer open];
    
    // Send request
    
    NSLog(@"writing command");
    NSString *cmdString  = @"{\"command\":\"summary\"}\n";
    NSData *data = [[NSData alloc] initWithData:[cmdString dataUsingEncoding:NSASCIIStringEncoding]];
    NSInteger r = [_writer write:[data bytes] maxLength:[data length]];
    
    if ( r == -1 ) {
        ALog(@"Unable to send request to cgminer: %@", [[_writer streamError] localizedDescription]);
    }
    else if (r != [data length]) {
        DLog(@"Uh oh, only set %lu bytes of %lu", (unsigned long)r, (unsigned long)[data length]);
    }
    
    [_writer close];
    [_writer removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    self.updateInProgress = TRUE;
    
}

- (void)stream:(NSStream *)theStream handleEvent:(NSStreamEvent)streamEvent {
    typedef  enum {
        NSStreamEventNone = 0,
        NSStreamEventOpenCompleted = 1 << 0,
        NSStreamEventHasBytesAvailable = 1 << 1,
        NSStreamEventHasSpaceAvailable = 1 << 2,
        NSStreamEventErrorOccurred = 1 << 3,
        NSStreamEventEndEncountered = 1 << 4
    } StreamEveents;
    uint8_t buffer[1024];
    NSInteger len;
    
    switch (streamEvent) {
            
        case NSStreamEventOpenCompleted:
           // NSLog(@"Stream opened now");
            break;
        case NSStreamEventHasBytesAvailable:
            //NSLog(@"has bytes");
            if (theStream == _reader) {
                NSMutableString *output = [NSMutableString stringWithString:@""];
                while ([_reader hasBytesAvailable]) {
                    len = [_reader read:buffer maxLength:sizeof(buffer)];
                    //DLog(@"read %lu bytes", len);
                    if (len > 0) {
                        
                        // If last byte is null byte, strip it
                        if ( buffer[len - 1] == '\0' ) {
                            len--;
                        }
                        
                        NSString *nsbuffer = [[NSString alloc] initWithBytes:buffer length:len encoding:NSASCIIStringEncoding];
                       // DLog(@"server added: >>>>> %@ <<<<<", nsbuffer);
                        [output appendString:nsbuffer];
                    }
                }
                if( ! [output isEqualToString:@""] ) {
                    //DLog(@"server said: >>>>> %@ <<<<<", output);
                    [self handleCGMinerResponseWithString:output];
                }

            } else {
                ALog(@"it is NOT theStream == inputStream");
            }
            break;
            
        case NSStreamEventHasSpaceAvailable:
            //NSLog(@"Stream has space available now");
            break;
            
            
        case NSStreamEventErrorOccurred:
            ALog(@"Can not connect to the host!");
            self.updateInProgress = FALSE;

            break;
            
            
        case NSStreamEventEndEncountered:
            DLog(@"closing stream event");
            [theStream close];
            [theStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
            
            self.updateInProgress = FALSE;
            break;
            
        default:
            break;
            //NSLog(@"Unknown event %i", streamEvent);
    }
}

-(void)handleCGMinerResponseWithString:(NSString*)datastr
{
    
    NSError *error;
    NSDictionary  * dict = [NSJSONSerialization JSONObjectWithData:[datastr dataUsingEncoding:NSUTF8StringEncoding]
                                                           options: NSJSONReadingMutableContainers
                                                             error: &error];
    
    if(error != nil) {
        DLog(@"error: %@", error);
        return;
    }
    
    // "STATUS" => [0] => "Description"
    NSArray *a1 = [dict objectForKey:@"STATUS"];
    NSDictionary *d1 = a1[0];
    self.cgminerVersion = [d1 objectForKey:@"Description"];
    
    
    // "SUMMARY" => [0] => "MHS 5s"
    a1 = [dict objectForKey:@"SUMMARY"];
    d1 = a1[0];
    self.cgminerHashrate = [[d1 objectForKey:@"MHS 5s"] floatValue] * 1000;
    
    DLog(@"updated with cgminer version %@ and 5s hashrate %lu", self.cgminerVersion, self.cgminerHashrate);
    self.updateCompleteCallback();
}


@end
