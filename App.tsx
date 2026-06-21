/**
 * Glovebox — offline AI copilot for stranded drivers.
 *
 * @format
 */

import { StatusBar, useColorScheme } from 'react-native';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import { ChatScreen } from './src/chat/ChatScreen';

function App() {
  const isDarkMode = useColorScheme() === 'dark';

  return (
    <SafeAreaProvider>
      <StatusBar barStyle={isDarkMode ? 'light-content' : 'dark-content'} />
      <ChatScreen />
    </SafeAreaProvider>
  );
}

export default App;
