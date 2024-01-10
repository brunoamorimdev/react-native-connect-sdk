import { NativeModules, Platform } from 'react-native';
import type { Spec } from './NativeConnectSdk';

const LINKING_ERROR =
  `The package 'react-native-connect-sdk' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo Go\n';

// @ts-expect-error
const isTurboModuleEnabled = global.__turboModuleProxy != null;

const ConnectSdkModule = isTurboModuleEnabled
  ? require('./NativeConnectSdk').default
  : NativeModules.ConnectSdk;

export const ConnectSdk: Spec = ConnectSdkModule
  ? ConnectSdkModule
  : new Proxy(
      {},
      {
        get() {
          throw new Error(LINKING_ERROR);
        },
      }
    );
