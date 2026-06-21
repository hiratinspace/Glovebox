jest.mock('@react-native-community/netinfo', () =>
  require('@react-native-community/netinfo/jest/netinfo-mock'),
);

jest.mock('llama.rn', () => ({
  initLlama: jest.fn(() => Promise.resolve({ completion: jest.fn() })),
}));

jest.mock('react-native-fs', () => ({
  MainBundlePath: '/mock/bundle',
}));
