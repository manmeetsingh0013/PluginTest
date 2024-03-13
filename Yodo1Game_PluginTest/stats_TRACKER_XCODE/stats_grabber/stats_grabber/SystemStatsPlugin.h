// SystemStatsPlugin.h

#ifndef SystemStatsPlugin_h
#define SystemStatsPlugin_h

@interface SystemStatsPlugin : NSObject

+ (double)getGPUUsage;
+ (double)getCPUUsage;

@end

#endif /* SystemStatsPlugin_h */
