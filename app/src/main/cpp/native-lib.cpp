#include <jni.h>
#include <string>
#include <android/log.h>

#include "client/linux/handler/exception_handler.h"

extern "C" JNIEXPORT jstring JNICALL
Java_app_android_breakpad_MainActivity_stringFromJNI(
        JNIEnv *env,
        jobject /* this */) {
    std::string hello = "Hello from C++";
    env = NULL;
    return env->NewStringUTF(hello.c_str());
}

static bool CreshCallback(const google_breakpad::MinidumpDescriptor &descriptor,
                          void *context,
                          bool succeeded) {
    __android_log_print(ANDROID_LOG_DEBUG, __FILE_NAME__, "path = %s; successed = %d",
                        descriptor.path(), succeeded);
    return true;
}

extern "C"
JNIEXPORT void JNICALL
Java_app_android_breakpad_MainActivity_initBreakpad(JNIEnv *env, jclass clazz, jstring path) {
    auto p = env->GetStringUTFChars(path, JNI_FALSE);
    google_breakpad::MinidumpDescriptor descriptor(p);
    static google_breakpad::ExceptionHandler exceptionHandler(descriptor, NULL, CreshCallback, NULL,
                                                              true, -1);
    env->ReleaseStringUTFChars(path, p);
}