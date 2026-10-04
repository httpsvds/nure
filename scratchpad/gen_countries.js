const fs = require("fs");
const path = require("path");

const pkgRes = "C:/Users/Vedik/AppData/Local/Pub/Cache/hosted/pub.dev/country_flags-4.1.2/res/si";
const outFile = "C:/Users/Vedik/nure/lib/onboarding/countries.dart";

// Codes that actually have a bundled flag asset.
const have = new Set(
  fs.readdirSync(pkgRes).map((f) => f.replace(/\.si$/, "").toUpperCase())
);

const dn = new Intl.DisplayNames(["en"], { type: "region" });
const A = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
const rows = [];

for (const a of A) {
  for (const b of A) {
    const code = a + b;
    let name;
    try {
      name = dn.of(code);
    } catch {
      continue;
    }
    if (!name || name === code) continue; // ICU does not recognise it
    if (!have.has(code)) continue; // no flag asset bundled
    if (/^(Unknown|Outlying)/.test(name)) continue;
    rows.push({ code, name });
  }
}

rows.sort((x, y) => x.name.localeCompare(y.name, "en"));

const esc = (s) => s.replace(/\\/g, "\\\\").replace(/'/g, "\\'");
const body = rows.map((r) => `  Country('${r.code}', '${esc(r.name)}'),`).join("\n");

const out = `// GENERATED FILE - do not edit by hand.
//
// Built from ICU region names (Intl.DisplayNames) intersected with the flag
// assets bundled in the country_flags package, so every entry is guaranteed to
// render a flag rather than an empty box. ${rows.length} countries and
// territories, sorted by English name.
//
// Regenerate with: node scratchpad/gen_countries.js

import 'country.dart';

const List<Country> kCountries = [
${body}
];
`;

fs.mkdirSync(path.dirname(outFile), { recursive: true });
fs.writeFileSync(outFile, out, "utf8");

console.log("countries written:", rows.length);
console.log("first 3 :", rows.slice(0, 3).map((r) => `${r.code} ${r.name}`).join(" | "));
console.log("last 3  :", rows.slice(-3).map((r) => `${r.code} ${r.name}`).join(" | "));
console.log("UAE     :", rows.find((r) => r.code === "AE")?.name ?? "MISSING");
console.log("apostrophes:", rows.filter((r) => /'/.test(r.name)).map((r) => r.name).join(", ") || "none");
