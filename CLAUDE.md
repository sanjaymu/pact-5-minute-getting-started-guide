# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Runnable companion code for the Pact "5 minute getting started guide" (https://docs.pact.io/5-minute-getting-started-guide). `README.md` is the guide itself and quotes the source files inline, so code changes to the consumer/provider usually need the matching README snippet updated too.

## Commands

```bash
npm install
npm run test:consumer   # consumer Pact test; (re)writes pacts/GettingStartedOrderWeb-GettingStartedOrderApi.json
npm run test:provider   # verifies the provider against the local pact file
npm test                # consumer, then provider verification with PACT_URL pointing at the local pact file
npm run pact:show       # pretty-print the pact file (needs jq)
npm run pact:publish    # publish.sh: needs PACT_BROKER_BASE_URL / _USERNAME / _PASSWORD
```

There is no lint or build step. Each test side has a single spec, so "run a single test" means running `test:consumer` or `test:provider`. CI (`.github/workflows/test.yml`) runs `scripts/ci/test.sh` on Node 20/22/24 across Linux, macOS and Windows.

## Architecture

- **Consumer** (`consumer/`): `orderClient.js` fetches `GET /orders` from `127.0.0.1:$API_PORT` and maps results to `Order` objects. `consumer.spec.js` defines the interaction on the shared PactV3 instance from `pact.js`; Pact's mock server sets `API_PORT`, and running the test writes the pact file to `pacts/`.
- **Provider** (`provider/`): an Express app serving `GET /orders` from the in-memory array in `provider/data/orders.js`. `provider.spec.js` starts it on port 3000 and runs the Pact `Verifier`. Where the pacts come from depends on env vars: `PACT_URL` (a specific pact), else `PACT_BROKER_BASE_URL` (broker with consumer version selectors, pending and WIP pacts), else the local pact file.
- **`pact.js`** holds the consumer/provider names (`GettingStartedOrderWeb` / `GettingStartedOrderApi`), the pact file path, and the PactV3 provider (logs go to `logs/pact.log`). Paths resolve from `process.cwd()`, so run scripts from the repo root.
- **`runTest.js`** builds a Mocha instance programmatically from every `*spec.js` in `consumer/` or `provider/` (45s timeout); `runConsumerTest.js`, `runProviderTest.js` and `index.js` just call it.
- Module styles are mixed: the spec files use ESM `import`, everything else uses CommonJS `require`, and there is no `"type"` in `package.json`. Keep each file's existing style.
- `pacts/` is gitignored except the committed pact file, which `npm test` and the provider test read. Regenerate it with `npm run test:consumer` rather than editing it by hand.
- `.replit`, `replit.nix`, `.bashrc` and `index.html` support running in Replit. `test:broker` and `get:broker` assume a Replit-hosted broker (`$REPL_OWNER`).

## Gotchas

- **Provider verification failures don't fail the test.** `provider.spec.js` catches the `verifyProvider()` rejection and only logs "Pact verification failed :(", so `npm run test:provider` and CI stay green. Read the log output to see whether verification actually passed.
- In Claude Code cloud containers, the egress proxy intercepts the verifier's requests to `127.0.0.1:3000` and answers with 403, so verification fails there even though the test reports passing. Setting `NO_PROXY` doesn't help. Verify provider behavior on a local machine or in CI.
