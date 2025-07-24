// frontend/eslint.config.js
import js from '@eslint/js';
import ts from '@typescript-eslint/eslint-plugin';
import tsParser from '@typescript-eslint/parser';
import react from 'eslint-plugin-react';
import reactHooks from 'eslint-plugin-react-hooks';
import prettier from 'eslint-config-prettier';

const browserGlobals = {
  window: 'readonly',
  document: 'readonly',
  navigator: 'readonly',
};

const domGlobals = {
  HTMLDivElement: 'readonly',
  HTMLElement: 'readonly',
};

const es2021Globals = {
  Atomics: 'readonly',
  SharedArrayBuffer: 'readonly',
};

const jestGlobals = {
  jest: 'readonly',
  describe: 'readonly',
  test: 'readonly',
  expect: 'readonly',
  beforeEach: 'readonly',
  afterEach: 'readonly',
  it: 'readonly',
};

export default [
  js.configs.recommended,

  {
    files: ['src/**/*.{js,jsx,ts,tsx}'],
    ignores: ['dist/**', 'build/**'],

    languageOptions: {
      parser: tsParser,
      parserOptions: {
        ecmaVersion: 'latest',
        sourceType: 'module',
        ecmaFeatures: { jsx: true },
        jsxRuntime: 'automatic',
      },
      globals: {
        ...browserGlobals,
        ...domGlobals,
        ...es2021Globals,
      },
    },

    plugins: {
      '@typescript-eslint': ts,
      react,
      'react-hooks': reactHooks,
    },

    settings: {
      react: {
        version: 'detect',
        runtime: 'automatic',
      },
    },

    rules: {
      'no-unused-vars': 'off',
      'react/react-in-jsx-scope': 'off',
      'react-hooks/rules-of-hooks': 'error',
      'react-hooks/exhaustive-deps': 'warn',
      '@typescript-eslint/no-unused-vars': ['error', { argsIgnorePattern: '^_' }],
    },
  },

  {
    files: ['**/*.test.{js,jsx,ts,tsx}'],
    languageOptions: {
      globals: {
        ...jestGlobals,
        ...es2021Globals,
        ...browserGlobals,
        ...domGlobals,
      },
    },
  },

  prettier, // disable ESLint rules that conflict with Prettier
];
