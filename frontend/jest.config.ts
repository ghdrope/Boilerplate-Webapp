import type { Config } from '@jest/types';

const config: Config.InitialOptions = {
  preset: 'ts-jest/presets/js-with-ts',
  testEnvironment: 'jsdom',
  collectCoverage: true,
  coverageDirectory: 'coverage',
  coverageThreshold: {
    global: {
      branches: 80,
      functions: 80,
      lines: 80,
      statements: 80,
    },
  },
  moduleFileExtensions: ['ts', 'tsx', 'js', 'jsx', 'json', 'node'],
  testMatch: ['**/__tests__/**/*.[jt]s?(x)', '**/?(*.)+(spec|test).[tj]s?(x)'],
  setupFilesAfterEnv: ['<rootDir>/jest.setup.ts'],
  transform: {
    '^.+\\.[tj]sx?$': 'ts-jest',
    '^.+\\.css$': '<rootDir>/jest/cssTransform.cjs',
  },

  moduleNameMapper: {
    '\\.(css|less)$': 'identity-obj-proxy',
  },
  globals: {
    'ts-jest': {
      useESM: true,
      tsconfig: 'tsconfig.json',
    },
  },
};

export default config;
