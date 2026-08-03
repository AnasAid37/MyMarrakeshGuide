import { randomBytes } from "node:crypto";
import { existsSync, readFileSync, writeFileSync } from "node:fs";
import { resolve } from "node:path";

const target = resolve(process.cwd(), ".env");
const template = resolve(process.cwd(), ".env.example");

if (existsSync(target)) {
  console.error(".env already exists. Refusing to overwrite local secrets.");
  process.exit(1);
}

const secret = () => randomBytes(48).toString("base64url");
const password = () => randomBytes(24).toString("base64url");
const postgresPassword = password();
const redisPassword = password();

const source = readFileSync(template, "utf8")
  .replaceAll("local-development-only-password", postgresPassword)
  .replaceAll("local-development-only-redis-password", redisPassword)
  .replace(
    "local-development-csrf-secret-change-with-bootstrap-env-64chars",
    secret(),
  )
  .replace(
    "local-development-access-secret-change-with-bootstrap-env-64chars",
    secret(),
  )
  .replace(
    "local-development-refresh-secret-change-with-bootstrap-env-64chars",
    secret(),
  );

writeFileSync(target, source, { encoding: "utf8", mode: 0o600 });
console.log("Created .env with randomly generated local credentials and signing secrets.");
