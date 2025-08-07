import type { Config } from '@jest/types';

const config: Config.InitialOptions = {
  preset: 'ts-jest/presets/js-with-ts',
  testEnvironment: 'jsdom',
  collectCoverage: true,
  collectCoverageFrom: ['src/**/*.{ts,tsx}', '!src/App.tsx', '!src/index.tsx'],
  coverageDirectory: 'coverage',
  coverageThreshold: {
    global: {
      branches: 75,
      functions: 75,
      lines: 75,
      statements: 75,
    },
  },
  moduleFileExtensions: ['ts', 'tsx', 'js', 'jsx', 'json', 'node'],
  testMatch: ['**/__tests__/**/*.[jt]s?(x)', '**/?(*.)+(spec|test).[tj]s?(x)'],
  setupFilesAfterEnv: ['<rootDir>/jest.setup.ts'],
  transform: {
    '^.+\\.[tj]sx?$': [
      'ts-jest',
      {
        useESM: true,
        tsconfig: 'tsconfig.json',
      },
    ],
    '^.+\\.css$': '<rootDir>/jest/cssTransform.cjs',
  },
  transformIgnorePatterns: ['/node_modules/'],
  moduleNameMapper: {
    '\\.(css|less)$': 'identity-obj-proxy',
  },

  testPathIgnorePatterns: ['/node_modules/'],
};

export default config;
