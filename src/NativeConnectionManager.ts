import type { TurboModule } from 'react-native';
import { TurboModuleRegistry } from 'react-native';

export interface Spec extends TurboModule {
  startDiscovery(): Promise<void>;
  stopDiscovery(): Promise<void>;
  connect(ipAddress: string): Promise<string>;
  getAllDevices(): Promise<any>;
}

export default TurboModuleRegistry.getEnforcing<Spec>('ConnectionManager');
