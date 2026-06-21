import React from 'react';
import { StyleSheet, Text, View } from 'react-native';

export function OfflineIndicator({ isOnline }: { isOnline: boolean }) {
  return (
    <View style={[styles.pill, isOnline ? styles.pillOnline : styles.pillOffline]}>
      <View style={[styles.dot, isOnline ? styles.dotOnline : styles.dotOffline]} />
      <Text style={styles.text}>Offline mode: {isOnline ? 'OFF' : 'ON'}</Text>
    </View>
  );
}

const styles = StyleSheet.create({
  pill: {
    flexDirection: 'row',
    alignItems: 'center',
    alignSelf: 'flex-start',
    borderRadius: 999,
    paddingHorizontal: 10,
    paddingVertical: 5,
  },
  pillOnline: {
    backgroundColor: '#fde2e2',
  },
  pillOffline: {
    backgroundColor: '#dcf5e3',
  },
  dot: {
    width: 8,
    height: 8,
    borderRadius: 4,
    marginRight: 6,
  },
  dotOnline: {
    backgroundColor: '#d33',
  },
  dotOffline: {
    backgroundColor: '#2a9d4f',
  },
  text: {
    fontSize: 12,
    fontWeight: '700',
    color: '#333',
  },
});
