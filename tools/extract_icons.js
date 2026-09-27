/* Ekstrak simbol SVG dari sprite mockup (design/index.html) → assets/icons/*.svg */
const fs = require("fs");
const path = require("path");

const root = path.resolve(__dirname, "..");
const html = fs.readFileSync(path.join(root, "design", "index.html"), "utf8");
const outDir = path.join(root, "assets", "icons");
fs.mkdirSync(outDir, { recursive: true });

const re = /<symbol id="([^"]+)"([^>]*)>([\s\S]*?)<\/symbol>/g;
let m;
let n = 0;
while ((m = re.exec(html))) {
  const [, id, attrs, inner] = m;
  if (!id.startsWith("i-")) continue;
  const a = {};
  for (const am of attrs.matchAll(/([\w-]+)="([^"]*)"/g)) a[am[1]] = am[2];
  const svgAttrs = [
    'xmlns="http://www.w3.org/2000/svg"',
    a.viewBox ? `viewBox="${a.viewBox}"` : 'viewBox="0 0 24 24"',
    a.fill ? `fill="${a.fill}"` : 'fill="none"',
    a.stroke ? `stroke="${a.stroke}"` : "",
    a["stroke-width"] ? `stroke-width="${a["stroke-width"]}"` : "",
    a["stroke-linecap"] ? `stroke-linecap="${a["stroke-linecap"]}"` : "",
    a["stroke-linejoin"] ? `stroke-linejoin="${a["stroke-linejoin"]}"` : "",
  ]
    .filter(Boolean)
    .join(" ");
  const svg = `<svg ${svgAttrs}>${inner.trim()}</svg>\n`;
  fs.writeFileSync(path.join(outDir, `${id}.svg`), svg, "utf8");
  n++;
}
console.log(`extracted ${n} icons -> assets/icons/`);
