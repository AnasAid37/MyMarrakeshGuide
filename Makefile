.PHONY: setup dev check build test infra-up infra-down compose-up compose-down db-migrate db-seed

setup:
	corepack enable
	pnpm install
	pnpm bootstrap:env
	pnpm infra:up
	pnpm db:generate
	pnpm db:migrate
	pnpm db:seed

dev:
	pnpm dev

check:
	pnpm check

build:
	pnpm build

test:
	pnpm test

infra-up:
	pnpm infra:up

infra-down:
	pnpm infra:down

compose-up:
	pnpm compose:up

compose-down:
	pnpm compose:down

db-migrate:
	pnpm db:migrate

db-seed:
	pnpm db:seed
