/**
 * CI fixture — "build" entrypoint (npm run build).
 *
 * This file intentionally contains a syntax error so the pipeline fails and
 * the notify-n8n-on-failure job can exercise the webhook path.
 *
 * To make the build pass locally while experimenting, comment out the
 * INTENTIONAL FAILURE line and keep only the console.log below.
 */

console.log("hello from js");
console.log("CI fixture build step");

// INTENTIONAL FAILURE: invalid JS (missing quotes) — triggers CI failure → n8n
console.log(this is an intentional bug);
