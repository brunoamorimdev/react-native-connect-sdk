import { NativeModules, Platform, NativeEventEmitter } from 'react-native';
import type { EmitterSubscription } from 'react-native';

const LINKING_ERROR =
  `The package 'react-native-connect-sdk' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({ ios: "- You have run 'pod install'\n", default: '' }) +
  '- You rebuilt the app after installing the package\n' +
  '- You are not using Expo Go\n';

// @ts-expect-error
const isTurboModuleEnabled = global.__turboModuleProxy != null;

const ConnectSdkModule = isTurboModuleEnabled
  ? require('./NativeConnectionManager').default
  : NativeModules.ConnectionManager;

export interface ConnectableDevice {
  ipAddress: string | null;
  friendlyName: string | null;
}

export type ConnectsEvents =
  | 'didFindDevice'
  | 'didLoseDevice'
  | 'didFailWithError'
  | 'didUpdateDevice';

export interface ConnectSDK extends NativeEventEmitter {
  startDiscovery(): Promise<void>;
  stopDiscovery(): Promise<void>;
  connect(ipAddress: string): Promise<string>;
  getAllDevices(): Promise<ConnectableDevice[]>;
  removeListeners(): void;
  addListener(
    eventType: ConnectsEvents,
    listener?: (event: any) => void,
    context?: Object
  ): EmitterSubscription;
}

const Module: ConnectSDK = ConnectSdkModule
  ? ConnectSdkModule
  : new Proxy(
      {},
      {
        get() {
          throw new Error(LINKING_ERROR);
        },
      }
    );

const { addListener, removeAllListeners } = new NativeEventEmitter(Module);

export const ConnectSDK = Object.assign(Module, {
  addListener,
  removeAllListeners,
});
