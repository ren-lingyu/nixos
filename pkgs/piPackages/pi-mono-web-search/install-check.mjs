import {
  existsSync,
  readFileSync,
  readdirSync,
} from "node:fs";

import {
  basename,
  dirname,
  join,
} from "node:path";

const [out] = process.argv.slice(2);

if (out === undefined) {
  throw new Error("Missing output path");
}

const hostPackages = new Set([
  "@earendil-works/pi-ai",
  "@earendil-works/pi-agent-core",
  "@earendil-works/pi-coding-agent",
  "@earendil-works/pi-tui",
  "@sinclair/typebox",
  "typebox",
]);

const requiredPeerDependencies = new Map([
  [ "@earendil-works/pi-coding-agent", "*" ],
  [ "@sinclair/typebox", "*" ],
]);

function readManifest(path) {
  return JSON.parse(readFileSync(path, "utf8"));
}

const manifest = readManifest(join(out, "package.json"));

for (const name of hostPackages) {
  if (Object.hasOwn(manifest.dependencies ?? {}, name)) {
    throw new Error(
      `Pi host-provided package must not appear in dependencies: ${name}`,
    );
  }
}

for (const [ name, range ] of requiredPeerDependencies) {
  const actualRange = manifest.peerDependencies?.[name];

  if (actualRange !== range) {
    throw new Error(
      `Expected peerDependencies.${name} to be ${JSON.stringify(range)}, `
      + `got ${JSON.stringify(actualRange)}`,
    );
  }
}

function isPackageRoot(path) {
  const parent = dirname(path);
  const parentName = basename(parent);
  const name = basename(path);

  if (parentName === "node_modules") {
    return !name.startsWith(".") && !name.startsWith("@");
  }

  return (
    parentName.startsWith("@")
    && basename(dirname(parent)) === "node_modules"
  );
}

function checkPackage(path) {
  const manifestPath = join(path, "package.json");

  if (!existsSync(manifestPath)) {
    return;
  }

  const packageManifest = readManifest(manifestPath);

  if (hostPackages.has(packageManifest.name)) {
    throw new Error(
      `Pi host-provided package was bundled: ${packageManifest.name} at ${path}`,
    );
  }
}

function walk(path) {
  for (const entry of readdirSync(path, {
    withFileTypes: true,
  })) {
    const child = join(path, entry.name);

    if (isPackageRoot(child)) {
      checkPackage(child);
    }

    if (entry.isDirectory()) {
      walk(child);
    }
  }
}

const nodeModules = join(out, "node_modules");

if (!existsSync(nodeModules)) {
  throw new Error("Deployed package does not contain node_modules");
}

walk(nodeModules);
