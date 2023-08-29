const config = {
  // collectCoverage: true,
  // coverageDirectory: "coverage",
  clearMocks: true,
  moduleDirectories: ['node_modules', '<rootDir>/'],
  moduleNameMapper: {
    '\\.(css|less)$': 'identity-obj-proxy',
  },
  // modulePathIgnorePatterns: [],
  preset: 'ts-jest',
  setupFilesAfterEnv: ['<rootDir>/jest.setup.js'],
  testEnvironment: 'jsdom',
  transform: { '^.+\\.(ts|tsx)?$': 'ts-jest' },
}

export default config