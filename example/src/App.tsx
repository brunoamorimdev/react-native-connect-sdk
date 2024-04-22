import * as React from 'react';

import { StyleSheet, View, Text, FlatList } from 'react-native';
import { ConnectSDK, type ConnectableDevice } from 'react-native-connect-sdk';

export default function App() {
  const [devicesList, setDevicesList] = React.useState<
    ConnectableDevice[] | undefined
  >();

  async function handleSetDevicesList() {
    try {
      const data = await ConnectSDK.getAllDevices();
      console.log(data);
      setDevicesList(data);
    } catch {
      setDevicesList([]);
    }
  }

  React.useEffect(() => {
    handleSetDevicesList();
    ConnectSDK.startDiscovery();
    const subscription = ConnectSDK.addListener('didUpdateDevice', (data) => {
      if (data) {
        handleSetDevicesList();
      }
    });

    return () => {
      ConnectSDK.stopDiscovery();
      subscription.remove();
    };
  }, []);

  return (
    <View style={styles.container}>
      <FlatList
        data={devicesList}
        renderItem={(data) => (
          <Text
            style={{
              color: 'black',
              padding: 20,
              backgroundColor: 'red',
              fontSize: 20,
            }}
          >
            {data.item?.friendlyName}
          </Text>
        )}
        keyExtractor={(item) => item?.ipAddress ?? ''}
        ItemSeparatorComponent={() => <View style={{ height: 5 }} />}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    padding: 20,
    paddingTop: 50,
  },
});
