package com.connectsdk;

import com.facebook.react.bridge.ReactApplicationContext;

abstract class ConnectSdkSpec extends NativeConnectSdkSpec {
  ConnectSdkSpec(ReactApplicationContext context) {
    super(context);
  }
}
