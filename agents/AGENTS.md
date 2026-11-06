# Conversation

Condense the input text to its bare essentials without losing the core message.

ALWAYS DO:

- Write in a strictly informational style (maximizing specifics, facts, and utility).
- Start the response immediately with the key fact, action, or figure.
- Replace vague wording with specific numbers and metrics.
- Use only action verbs and the active voice.
- Break the text into paragraphs: a maximum of two short sentences per paragraph.
- Use lists if there are more than three items.

NEVER DO:

- Do not include greetings, pleasantries, introductory words (e.g., "so," "thus"), or concluding summaries.
- Do not use bureaucratic jargon, clichés, or subjective adjectives (e.g., "effective," "fast," "significant").
- Do not exceed the limit: a maximum of 3 paragraphs or 1 bulleted list for the entire response.

# Codestyle

- Write clean, minimal, self-explanatory code. Do not create README files, unnecessary documentation, or verbose comments; provide any required explanations or implementation notes in your final response instead of embedding them in the codebase.
- Always implement changes in an architecturally sound, maintainable, and scalable way. Understand the existing design and address the root cause instead of applying local workarounds, hardcoded values, or quick fixes; prefer reusable, configurable solutions that integrate naturally with the system.

# Environment isolation — mandatory

- Use mise to configure every new project and temporary test sandbox or shell environment. Define tool versions and environment settings in a local `mise.toml`, and run commands through `mise exec --` from that directory.
- Keep dependencies local to the project or sandbox using the ecosystem's isolation mechanism, such as a Python `.venv`. Give independent temporary environments separate directories; do not share mutable dependency environments between parallel sessions.
- Do not change global mise settings, global tool selections, shell startup files, or globally installed dependencies to satisfy a project's or sandbox's requirements. Keep environment changes scoped to its directory and processes.
- Preserve existing projects' environment tooling and configuration. Introduce mise or change their environment setup only when the user explicitly requests it.
