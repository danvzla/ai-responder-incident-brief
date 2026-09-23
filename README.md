# Responder Incident Brief

**SolTelco concept demo · Unified Communications · DEMO v46**

A responder joins an incident already in progress. Three agents read the radio
traffic, check each fact against the original message, and write a short
catch-up. A person reviews the draft. Nothing is dispatched.

---

## Running it

On a Mac, double-click `start_demo.command`. It opens the page in your browser
on a local port and prints the address in a Terminal window. Leave that window
open while presenting.

If macOS blocks the script, open Terminal in this folder and run
`bash start_demo.command`.

`index.html` is self-contained — the audio is embedded — so you can also open
the file directly. The local server exists only so the page is served over
`http://127.0.0.1` rather than `file://`.

Demo mode needs no key, no network and no setup. Confirm the header pill
tooltip reads **DEMO v46**.

---

## How the page is organised

Three tabs across the top:

| Tab | What's in it |
|---|---|
| **1 Live workflow** | The working demo — setup, the agent run, and the result |
| **2 Architecture & decisions** | Service path, production HLD/LLD, failure & safety, model lifecycle |
| **3 Delivery roadmap** | Four gated phases with named owners |

The Live workflow moves through three screens:

1. **Setup** — pick the incident, pick the model, toggle radio audio, run it.
2. **Run** — a full-screen trace: event intake, Signal, Safety, Briefing,
   responder handoff. Each step lights up as it completes. **Skip to result**
   or **Escape** fast-forwards the remaining steps, cutting any clip that is
   playing; the result opens only once the workflow has finished.
3. **Result** — the briefing with a source link on every fact, the source
   transmissions beside it, trust metrics, and an expandable
   **How this briefing was built** section showing each agent's input, output
   and prompt.

---

## Two-minute walkthrough

1. On the setup screen, choose **Storm response** (5 transmissions, the shorter
   run) or **Warehouse fire** (6). Leave the provider on **Demo**. Press
   **Run the workflow**.
2. The radio clips play in sequence. Each transmission appears with its speaker
   and time as it is received.
3. The three agents run: Signal extracts claims with source IDs, Safety checks
   each claim against its original message, Briefing drafts only from approved
   facts.
4. On the result screen, click any **Source** link to jump to the transmission
   behind that fact, or the play button on a transmission to replay its audio.
5. Point out the amber box. One transmission in each scenario was withheld —
   not because it was tagged unreadable, but because the responder said he
   could not confirm. Play that clip and let people hear the hesitation.
6. Press **Simulate AI outage**, then **Replay workflow**. The briefing is
   withheld; the transmissions remain visible. Restore the service before
   replaying for a normal result.
7. Open **How this briefing was built** and use **View Prompt** on any agent to
   show the exact instructions it runs.

---

## The audio

Eleven synthetic voice clips are embedded in the page: six for the fire
scenario, five for the storm. They were generated with the macOS `say` command
and filtered through a 300–3000 Hz band with bit-crushing to approximate a
narrowband radio channel. `make_radio_audio.sh` regenerates them.

The unconfirmed transmission in each scenario gets a heavier filter and a
hesitant script, so the degraded audio, the transcript and the agent's decision
all agree.

**The transcripts are written in advance. They are not machine-transcribed.**
There is no speech-to-text in this demo. Audio playback can be turned off on
the setup screen; the workflow then runs on timers.

---

## Connecting Claude or OpenAI

1. On the setup screen, select **Claude** or **OpenAI**. An API key field
   appears.
2. Enter your key and press **Connect**. Claude uses
   `claude-haiku-4-5-20251001`, OpenAI uses `gpt-4o-mini`. The key is held in
   page memory only and is cleared on reload. **Connect** does not verify the
   account — the first model call does.
3. Run the workflow. The browser makes three sequential calls: Signal
   extraction, Safety review, Briefing draft. These may incur provider charges.
   Only the visible message text is sent; no audio is transmitted.
4. If a call fails, that agent card shows the provider error and downstream
   agents are marked **Skipped**. The transmissions stay visible.

**For a dependable interview walkthrough, use Demo mode.** Its outputs are
deterministic.

The local launcher serves the page on `127.0.0.1` only. It never receives your
key or the message text. For a customer deployment, replace browser-held keys
with an authenticated server-side gateway.

---

## Present it accurately

**Demo mode and connected mode are not the same thing.** In Demo mode the
agent outputs are scripted and deterministic — the review step is a simulation
of the contract, not a model judging anything. In connected mode the browser
makes three real model calls, and Safety genuinely reviews Signal's output
against the original messages. Say which mode you are showing.

What this demo does:

- Plays synthetic voice clips with transcripts written in advance
- Runs three bounded agents that extract, review and draft
- Links every fact in the briefing to its source transmission
- Withholds facts from a transmission the speaker could not confirm
- Keeps the source transmissions available when the AI is unavailable

What it does **not** do:

- Receive real radio audio, or connect to any Motorola system
- Perform speech-to-text or speaker attribution
- Retrieve anything — there is no RAG pipeline
- Dispatch units, change talkgroups, or take any operational action
- Measure real latency or recognition accuracy

The Safety agent is a second pass of the same model, not independent
verification and not authorization. The final wording is still a model output
and cannot be mechanically checked against every source. A responder must read
the originals.

The Architecture and Delivery tabs are proposed designs for discussion. No
agency systems, model registry, operational telemetry or production rollback
are connected. Confirm real product interfaces, agency approval for audio
access, deployment boundaries, latency targets, data contracts, security
controls and ownership before treating any of it as a specification.

Suggested framing:

> The browser proves the user workflow and the human review step. The
> architecture view shows what it would take to make this a product: approved
> incident data, speech and event models, an independent voice path, release
> gates, measured quality, and a rollback owner.

---

## How the agents hand off

- **Signal** receives the numbered messages and returns individual facts, each
  tied to a message ID.
- **Safety** receives Signal's output *and* the original numbered messages, and
  returns approved facts plus warnings. Approving one fact from a message does
  not approve another from the same message.
- **Briefing** receives only the approved facts and must cite their IDs. The
  browser rejects invalid IDs and withholds the draft when nothing is approved.

**View Prompt** shows an example input before a run and the exact input from the
most recent connected run afterwards. Viewing never calls the provider.

The timeline span shown on the result screen is calculated from the first and
last scripted timestamps. It is not a timer or a measured response time.

---

## Publishing

The folder can be hosted as a static site. `index.html` is self-contained, so
for GitHub Pages copy it into a repository or subdirectory, enable Pages for
that branch, and link it from SolTelco. Verify the live URL and branding before
sharing. Never put an API key in the HTML or in a published repository.
