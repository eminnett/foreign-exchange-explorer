module.exports = {
  parser: 'babel-eslint',
  extends: [
    'eslint:recommended',
    'prettier',
    'plugin:react/recommended',
    'plugin:jsx-a11y/recommended',
  ],
  plugins: ['prettier', 'react', 'jsx-a11y'],
  env: {
    es6: true,
    browser: true,
    jest: true,
  },
  rules: {
    'prettier/prettier': [
      'error',
      {
        singleQuote: true,
        trailingComma: 'all',
      },
    ],
    eqeqeq: ['error', 'always'], // adding some custom ESLint rules
    'no-unused-vars': ["error", { "args": "none" }]
  },
  parserOptions: {
    ecmaFeatures: {
      jsx: true
    }
  },
  settings: {
    react: {
      version: "16.6.3"
    },
  }
};
