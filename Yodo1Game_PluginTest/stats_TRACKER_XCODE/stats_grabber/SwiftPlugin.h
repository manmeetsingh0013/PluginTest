#include "SwiftPlugin-Swift.h"
#pragma mark - C interface
extern "C" {
     void _sayHiToUnity(){
          [[SwiftForUnity shared]SayHiToUnity];
     }
}
