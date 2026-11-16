import { execFile } from "node:child_process";
import { existsSync, realpathSync } from "node:fs";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import { promisify } from "node:util";

const run = promisify(execFile);
const repo = resolve(dirname(realpathSync(fileURLToPath(import.meta.url))), "..");
async function refresh(directory) {
  const ps1 = resolve(repo, "setup.ps1");
  if (process.platform === "win32" && existsSync(ps1)) {
    await run(
      "powershell",
      ["-NoProfile", "-ExecutionPolicy", "Bypass", "-File", ps1, "--request"],
      { cwd: directory, timeout: 30000, maxBuffer: 4 * 1024 * 1024 },
    );
    return;
  }
  await run("bash", [resolve(repo, "setup.sh"), "--request"], {
    cwd: directory,
    timeout: 30000,
    maxBuffer: 4 * 1024 * 1024,
  });
}

export const SharedSetup = async ({ directory }) => ({
  "chat.message": async () => refresh(directory),
});
