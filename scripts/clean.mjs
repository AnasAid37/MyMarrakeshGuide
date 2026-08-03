import { rm } from "node:fs/promises";
import { resolve } from "node:path";

const directories = [".turbo", "coverage", "playwright-report", "test-results"];

await Promise.all(
  directories.map((directory) =>
    rm(resolve(process.cwd(), directory), { recursive: true, force: true }),
  ),
);
