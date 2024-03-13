#include "SwiftPlugin.h"
#pragma mark - C interface
extern "C" {
     char* _sayHiToUnity() {
          NSString *returnString = "";
          char* cStringCopy(const char* string);
          return cStringCopy([returnString UTF8String]);
     }
}
char* cStringCopy(const char* string){
     if (string == NULL){
          return NULL;
     }
     char* res = (char*)malloc(strlen(string)+1);
     strcpy(res, string);
     return res;
}
