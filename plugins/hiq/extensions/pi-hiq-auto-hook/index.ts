import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";
import { existsSync, readFileSync } from "node:fs";
import { join } from "node:path";
import { spawnSync } from "node:child_process";

type CurrentState = {
  autoStatus?: string;
  goalPath?: string | null;
  hostAutomationLevel?: string;
};

type ExecResult = {
  ok: boolean;
  stdout: string;
  stderr: string;
  code: number | null;
};

const HIQ_STATUS_ID = "hiq-auto-hook";

function hasHiQProjectRule(cwd: string): boolean {
  const agents = join(cwd, "AGENTS.md");
  const config = join(cwd, ".hiq", "config.yaml");
  if (!existsSync(agents) || !existsSync(config)) return false;
  try {
    const text = readFileSync(agents, "utf8");
    return text.includes("# HiQ Project Rule") && text.includes("hiq-auto");
  } catch {
    return false;
  }
}

function readCurrentState(cwd: string): CurrentState | null {
  const path = join(cwd, ".hiq", "current-change.json");
  if (!existsSync(path)) return null;
  try {
    return JSON.parse(readFileSync(path, "utf8")) as CurrentState;
  } catch {
    return null;
  }
}

function normalizePrompt(prompt: string): string {
  return prompt.replace(/\s+/g, " ").trim().slice(0, 400);
}

function runHiQScript(cwd: string, scriptName: string, args: string[]): ExecResult {
  const home = process.env.USERPROFILE || process.env.HOME || "";
  const hiqHome = process.env.HIQ_HOME_DIR || join(home, ".hiq");
  const scriptsDir = join(hiqHome, "scripts");

  if (process.platform === "win32") {
    const scriptPath = join(scriptsDir, `${scriptName}.cmd`);
    if (!existsSync(scriptPath)) {
      return { ok: false, stdout: "", stderr: `missing ${scriptPath}`, code: 127 };
    }
    const command = process.env.COMSPEC || "cmd.exe";
    const result = spawnSync(command, ["/d", "/c", scriptPath, cwd, ...args], {
      cwd,
      encoding: "utf8",
      stdio: "pipe",
    });
    return {
      ok: result.status === 0,
      stdout: result.stdout || "",
      stderr: result.stderr || "",
      code: result.status,
    };
  }

  const scriptPath = join(scriptsDir, `${scriptName}.sh`);
  if (!existsSync(scriptPath)) {
    return { ok: false, stdout: "", stderr: `missing ${scriptPath}`, code: 127 };
  }
  const result = spawnSync("bash", [scriptPath, cwd, ...args], {
    cwd,
    encoding: "utf8",
    stdio: "pipe",
  });
  return {
    ok: result.status === 0,
    stdout: result.stdout || "",
    stderr: result.stderr || "",
    code: result.status,
  };
}

function ensurePreSessionHook(cwd: string): ExecResult {
  return runHiQScript(cwd, "hiq-hook", ["pre-session", "--host=pi", "--adapter=pi"]);
}

function ensurePreFinalHook(cwd: string): ExecResult {
  return runHiQScript(cwd, "hiq-hook", ["pre-final", "--host=pi", "--adapter=pi"]);
}

function ensureAutoActivation(cwd: string, prompt: string): ExecResult | null {
  const current = readCurrentState(cwd);
  if (current?.autoStatus === "active" && current.goalPath) {
    return null;
  }

  const normalized = normalizePrompt(prompt);
  const goal = normalized || "Resume truthful HiQ coordination";
  const acceptance = normalized || "Restore truthful HiQ state and choose the next owner honestly";
  const owner = current?.autoStatus === "handoff" ? "hiq-session" : "hiq-grill";
  const phase = owner === "hiq-session" ? "idle" : "grill";
  const nextStep = owner === "hiq-session"
    ? "rebuild pointer and resume the truthful current owner step"
    : "clarify scope, confirm acceptance target, and choose the truthful next owner lane";

  return runHiQScript(cwd, "hiq-activate", [
    "--mode=auto",
    "--if-needed",
    `--goal-title=${goal}`,
    `--goal-now=${goal}`,
    `--acceptance=${acceptance}`,
    `--owner=${owner}`,
    `--phase=${phase}`,
    `--next-skill=${owner}`,
    `--next-step=${nextStep}`,
    "--resume-source=session",
    "--host=pi",
    `--host-level=${current?.hostAutomationLevel || "instruction-only"}`,
    "--hook-adapter=pi",
    "--reason=Pi loaded the HiQ auto entry contract for this project turn",
  ]);
}

export default function (pi: ExtensionAPI) {
  let sessionHooked = false;

  pi.on("session_start", async (_event, ctx) => {
    sessionHooked = false;
    if (!ctx.isProjectTrusted() || !hasHiQProjectRule(ctx.cwd)) return;
    const result = ensurePreSessionHook(ctx.cwd);
    if (result.ok) {
      sessionHooked = true;
      if (ctx.hasUI) ctx.ui.setStatus(HIQ_STATUS_ID, "HiQ: pre-session hook ok");
    } else if (ctx.hasUI) {
      ctx.ui.setStatus(HIQ_STATUS_ID, `HiQ hook failed (${result.code ?? "?"})`);
    }
  });

  pi.on("before_agent_start", async (event, ctx) => {
    if (!ctx.isProjectTrusted() || !hasHiQProjectRule(ctx.cwd)) return;
    if (!sessionHooked) {
      const hookResult = ensurePreSessionHook(ctx.cwd);
      if (hookResult.ok) sessionHooked = true;
    }
    const activation = ensureAutoActivation(ctx.cwd, event.prompt || "");
    if (activation && ctx.hasUI) {
      ctx.ui.setStatus(
        HIQ_STATUS_ID,
        activation.ok ? "HiQ: auto state activated" : `HiQ activate failed (${activation.code ?? "?"})`,
      );
    }
  });

  pi.on("agent_settled", async (_event, ctx) => {
    if (!ctx.isProjectTrusted() || !hasHiQProjectRule(ctx.cwd)) return;
    const result = ensurePreFinalHook(ctx.cwd);
    if (result.ok && ctx.hasUI) {
      ctx.ui.setStatus(HIQ_STATUS_ID, "HiQ: pre-final hook ok");
    }
  });
}
