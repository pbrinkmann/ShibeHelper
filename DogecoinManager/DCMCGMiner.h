//
//  DCMCGMiner.h
//  DogecoinManager
//
//  Created by Paul Brinkmann on 3/11/14.
//  Copyright (c) 2014 Paul Brinkmann. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DCMCGMiner : NSObject <NSStreamDelegate>

// In Parameters
@property NSString* ipAddress;
@property int port;

// Out Parameters
@property NSString* cgminerVersion;
@property NSInteger cgminerHashrate;
@property NSInteger gpuCount;
@property NSInteger poolCount;
@property NSString* poolStrategy;
@property NSString* os;
@property NSArray* gpus;
@property NSArray* pools;

-(void)updateStats:(void(^)())updateCompleteCallback;


@end

// CGMiner messages #defines:

#define CGMINER_MSG_INVGPU 1
#define CGMINER_MSG_ALRENA 2
#define CGMINER_MSG_ALRDIS 3
#define CGMINER_MSG_GPUMRE 4
#define CGMINER_MSG_GPUREN 5
#define CGMINER_MSG_GPUNON 6
#define CGMINER_MSG_POOL 7
#define CGMINER_MSG_NOPOOL 8
#define CGMINER_MSG_DEVS 9
#define CGMINER_MSG_NODEVS 10
#define CGMINER_MSG_SUMM 11
#define CGMINER_MSG_GPUDIS 12
#define CGMINER_MSG_GPUREI 13
#define CGMINER_MSG_INVCMD 14
#define CGMINER_MSG_MISID 15
#define CGMINER_MSG_GPUDEV 17
#define CGMINER_MSG_NUMGPU 20
#define CGMINER_MSG_VERSION 22
#define CGMINER_MSG_INVJSON 23
#define CGMINER_MSG_MISCMD 24
#define CGMINER_MSG_MISPID 25
#define CGMINER_MSG_INVPID 26
#define CGMINER_MSG_SWITCHP 27
#define CGMINER_MSG_MISVAL 28
#define CGMINER_MSG_NOADL 29
#define CGMINER_MSG_NOGPUADL 30
#define CGMINER_MSG_INVINT 31
#define CGMINER_MSG_GPUINT 32
#define CGMINER_MSG_MINECONFIG 33
#define CGMINER_MSG_GPUMERR 34
#define CGMINER_MSG_GPUMEM 35
#define CGMINER_MSG_GPUEERR 36
#define CGMINER_MSG_GPUENG 37
#define CGMINER_MSG_GPUVERR 38
#define CGMINER_MSG_GPUVDDC 39
#define CGMINER_MSG_GPUFERR 40
#define CGMINER_MSG_GPUFAN 41
#define CGMINER_MSG_MISFN 42
#define CGMINER_MSG_BADFN 43
#define CGMINER_MSG_SAVED 44
#define CGMINER_MSG_ACCDENY 45
#define CGMINER_MSG_ACCOK 46
#define CGMINER_MSG_ENAPOOL 47
#define CGMINER_MSG_DISPOOL 48
#define CGMINER_MSG_ALRENAP 49
#define CGMINER_MSG_ALRDISP 50
#define CGMINER_MSG_DISLASTP 51
#define CGMINER_MSG_MISPDP 52
#define CGMINER_MSG_INVPDP 53
#define CGMINER_MSG_TOOMANYP 54
#define CGMINER_MSG_ADDPOOL 55
#define CGMINER_MSG_NUMPGA 59
#define CGMINER_MSG_NOTIFY 60
#define CGMINER_MSG_REMLASTP 66
#define CGMINER_MSG_ACTPOOL 67
#define CGMINER_MSG_REMPOOL 68
#define CGMINER_MSG_DEVDETAILS 69
#define CGMINER_MSG_MINESTATS 70
#define CGMINER_MSG_MISCHK 71
#define CGMINER_MSG_CHECK 72
#define CGMINER_MSG_POOLPRIO 73
#define CGMINER_MSG_DUPPID 74
#define CGMINER_MSG_MISBOOL 75
#define CGMINER_MSG_INVBOOL 76
#define CGMINER_MSG_FOO 77
#define CGMINER_MSG_MINECOIN 78
#define CGMINER_MSG_DEBUGSET 79
#define CGMINER_MSG_PGAIDENT 80
#define CGMINER_MSG_PGANOID 81
#define CGMINER_MSG_SETCONFIG 82
#define CGMINER_MSG_UNKCON 83
#define CGMINER_MSG_INVNUM 84
#define CGMINER_MSG_CONPAR 85
#define CGMINER_MSG_CONVAL 86
#define CGMINER_MSG_USBSTA 87
#define CGMINER_MSG_NOUSTA 88
#define CGMINER_MSG_ZERMIS 94
#define CGMINER_MSG_ZERINV 95
#define CGMINER_MSG_ZERSUM 96
#define CGMINER_MSG_ZERNOSUM 97
#define CGMINER_MSG_PGAUSBNODEV 98
#define CGMINER_MSG_INVHPLG 99
#define CGMINER_MSG_HOTPLUG 100
#define CGMINER_MSG_DISHPLG 101
#define CGMINER_MSG_NOHPLG 102
#define CGMINER_MSG_MISHPLG 103
#define CGMINER_MSG_NUMASC 104
#define CGMINER_MSG_ASCUSBNODEV 115
#define CGMINER_MSG_INVNEG 121
#define CGMINER_MSG_SETQUOTA 122
#define CGMINER_MSG_LOCKOK 123
#define CGMINER_MSG_LOCKDIS 124