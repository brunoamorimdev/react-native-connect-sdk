import * as React from 'react';

import { Button, StyleSheet, View } from 'react-native';
import { ConnectSdk } from 'react-native-connect-sdk';

export default function App() {
  React.useEffect(() => {}, []);

  return (
    <View style={styles.container}>
      <Button title="Start Discovery" onPress={ConnectSdk.startDiscovery} />
      <Button title="Stop Discovery" onPress={ConnectSdk.stopDiscovery} />
      <Button
        title="Open Connectable Devices Picker"
        onPress={ConnectSdk.openConnectableDevicesPicker}
      />
    </View>
  );
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
