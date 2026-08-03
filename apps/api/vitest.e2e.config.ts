import { defineConfig } from "vitest/config";

export default defineConfig({
  test: {
    environment: "node",
    include: ["test/**/*.e2e-spec.ts"],
    clearMocks: true,
    restoreMocks: true,
    testTimeout: 15_000,
  },
});
