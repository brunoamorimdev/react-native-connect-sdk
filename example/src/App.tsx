import * as React from 'react';

import { StyleSheet, View, Text } from 'react-native';
import { nativeEvent } from 'react-native-connect-sdk';

export default function App() {
  React.useEffect(() => {
    const subscription = nativeEvent.addListener('didFindDevice', (event) => {
      console.log('didFindDevice Event Emmiter', event);
    });

    return () => {
      subscription.remove();
    };
  }, []);

  return (
    <View style={styles.container}>
      <Text />
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
