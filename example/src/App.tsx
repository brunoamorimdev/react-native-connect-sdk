import * as React from 'react';

import { StyleSheet, View } from 'react-native';
import { ConnectSdk } from 'react-native-connect-sdk';

async function ok() {
  await ConnectSdk.startDiscovery();
  await ConnectSdk.openConnectableDevicesPicker();
}

export default function App() {
  React.useEffect(() => {
    ok();
  }, []);

  return <View style={styles.container} />;
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
  },
  box: {
    width: 60,
    height: 60,
    marginVertical: 20,
  },
});
