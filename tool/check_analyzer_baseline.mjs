// Fails when `flutter analyze` reports more issues than tool/analyzer_baseline.txt allows.
// Usage: node tool/check_analyzer_baseline.mjs <analyze-output-file>
import { readFileSync } from 'node:fs';

const [outputFile] = process.argv.slice(2);
if (!outputFile) {
  console.error('Usage: node tool/check_analyzer_baseline.mjs <analyze-output-file>');
  process.exit(2);
}

const output = readFileSync(outputFile, 'utf8');
const baseline = Number(readFileSync('tool/analyzer_baseline.txt', 'utf8').trim());
const summary = output.match(/(\d+) issues? found/);
const count = summary ? Number(summary[1]) : /No issues found/.test(output) ? 0 : NaN;

if (!Number.isInteger(count) || !Number.isInteger(baseline)) {
  console.error('Could not read the analyzer summary line or the baseline.');
  process.exit(2);
}
if (count > baseline) {
  console.error(
    `Analyzer reported ${count} issues; tool/analyzer_baseline.txt allows ${baseline}. Fix the new issues.`,
  );
  process.exit(1);
}
console.log(`Analyzer issues: ${count} (baseline ${baseline}).`);
if (count < baseline) {
  console.log(`Lower tool/analyzer_baseline.txt to ${count} to lock in the improvement.`);
}
