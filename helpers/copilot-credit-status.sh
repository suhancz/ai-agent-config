#!/usr/bin/env bash
set -euo pipefail

command -v copilot >/dev/null 2>&1 || {
  printf 'GitHub Copilot CLI is required to read Copilot credits.\n' >&2
  exit 127
}
command -v node >/dev/null 2>&1 || {
  printf 'Node.js is required to read Copilot credits.\n' >&2
  exit 127
}

copilot_path="$(readlink -f "$(command -v copilot)")"
copilot_prefix="$(dirname "$(dirname "$copilot_path")")"
sdk_entry="$copilot_prefix/lib/node_modules/@github/copilot/node_modules/@github/copilot-linux-x64/copilot-sdk/index.js"
if [[ ! -r "$sdk_entry" ]] && command -v npm >/dev/null 2>&1; then
  sdk_entry="$(npm root -g)/@github/copilot/node_modules/@github/copilot-linux-x64/copilot-sdk/index.js"
fi
if [[ ! -r "$sdk_entry" ]]; then
  printf 'The Copilot CLI SDK quota API is unavailable at the installed CLI path.\n' >&2
  exit 1
fi

node --input-type=module - "$sdk_entry" <<'NODE'
const sdkEntry = process.argv[2];
const { CopilotClient } = await import(sdkEntry);
const client = new CopilotClient();

try {
  await client.start();
  const auth = await client.getAuthStatus();
  if (!auth.isAuthenticated) {
    console.error("GitHub Copilot CLI is not authenticated; run 'copilot login'.");
    process.exitCode = 1;
  } else {
    const { quotaSnapshots = {} } = await client.rpc.account.getQuota({});
    const snapshots = Object.entries(quotaSnapshots).filter(
      ([, quota]) => quota && quota.hasQuota !== false && Number.isFinite(quota.remainingPercentage),
    );
    const tokenBased = snapshots.some(([, quota]) => quota.tokenBasedBilling === true);
    const selected = tokenBased
      ? snapshots.filter(([name, quota]) => name !== "premium_interactions" && quota.tokenBasedBilling === true)
      : snapshots.filter(([name]) => name === "premium_interactions");

    if (selected.length === 0) {
      console.error("Copilot quota API returned no applicable quota snapshots.");
      process.exitCode = 1;
    } else {
      const formatPercent = (value) =>
        `${Number.isInteger(value) ? value : Number(value.toFixed(1))}%`;
      const describeQuota = ([name, quota]) => {
        const label = name.replaceAll("_", " ");
        return `${label} ${formatPercent(quota.remainingPercentage)} remaining`;
      };
      const resetDates = selected
        .map(([, quota]) => quota.resetDate)
        .filter((value) => typeof value === "string" && Number.isFinite(Date.parse(value)));
      const localResetTime = (timestamp) => {
        const parts = new Intl.DateTimeFormat(undefined, {
          year: "numeric",
          month: "2-digit",
          day: "2-digit",
          hour: "2-digit",
          minute: "2-digit",
          hourCycle: "h23",
          timeZoneName: "short",
        }).formatToParts(new Date(timestamp));
        const values = Object.fromEntries(parts.map(({ type, value }) => [type, value]));
        return `${values.year}-${values.month}-${values.day} ${values.hour}:${values.minute} ${values.timeZoneName} (local time)`;
      };
      const reset =
        resetDates.length > 0
          ? `; resets ${localResetTime(Math.min(...resetDates.map(Date.parse)))}`
          : "";
      const label = tokenBased ? "AI credit quota" : "premium-request quota";
      console.log(`Copilot credits: ${label} — ${selected.map(describeQuota).join(", ")}${reset}.`);
    }
  }
} finally {
  await client.stop();
}
NODE
