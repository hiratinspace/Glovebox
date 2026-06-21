import { useEffect, useState } from 'react';
import NetInfo from '@react-native-community/netinfo';

// Drives the on-stage "Offline mode: ON/OFF" indicator from real network
// state (not an app-level flag), so it's credible proof the app isn't
// quietly calling out during the demo.
export function useOnlineStatus(): boolean {
  const [isOnline, setIsOnline] = useState(false);

  useEffect(() => {
    const unsubscribe = NetInfo.addEventListener(state => {
      setIsOnline(Boolean(state.isConnected && state.isInternetReachable !== false));
    });
    return unsubscribe;
  }, []);

  return isOnline;
}
