const sdkEntry = process.argv[2];
if (!sdkEntry) {
  throw new Error("The Copilot CLI SDK entry path is required.");
}

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
