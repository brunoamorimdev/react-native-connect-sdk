import type { TurboModule } from 'react-native';
import { TurboModuleRegistry } from 'react-native';

export interface Spec extends TurboModule {
  startDiscovery(): Promise<void>;
  stopDiscovery(): Promise<void>;
  openConnectableDevicesPicker(): Promise<void>;
}

export default TurboModuleRegistry.getEnforcing<Spec>('ConnectSdk');
