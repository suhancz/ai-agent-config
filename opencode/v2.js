import { execFile } from "node:child_process";
import { realpathSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { promisify } from "node:util";

const run = promisify(execFile);
const repo = resolve(dirname(realpathSync(fileURLToPath(import.meta.url))), "..");
async function refresh(directory) {
  await run("bash", [resolve(repo, "setup.sh"), "--request"], {
    cwd: directory,
    timeout: 30000,
    maxBuffer: 4 * 1024 * 1024,
  });
}

export default {
  id: "ai-agent-config.request-setup",
  async setup(ctx) {
    await ctx.session.hook("prompt", async () => refresh(ctx.location.directory));
  },
};
