package com.connectsdk

import com.facebook.react.bridge.ReactApplicationContext

abstract class ConnectSdkSpec internal constructor(context: ReactApplicationContext) :
  NativeConnectSdkSpec(context) {
}
