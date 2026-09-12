## Kimi coding helper (optional, on top of the normal workflow)

There's a small CLI, already on PATH, for delegating a well-specified piece of
implementation work to an external model instead of writing it yourself:

```
ask-model --role coder "<a precise, self-contained spec of what to implement>"
```

- `coder` role = Kimi K3 via NVIDIA's free-credit API. Fast, no meaningful cost.
- `reviewer` role = Llama 3.3 70B via OpenRouter (paid, fractions of a cent/call) —
  optional second opinion on something tricky, not part of the default loop.
- Script + config: `D:\AppSetup\bin\ask-model.mjs` / `D:\AppSetup\bin\roles.json`.
- Keys live in `D:\AppSetup\bin\.env` and as Windows user env vars
  (`NVIDIA_API_KEY`, `OPENROUTER_API_KEY`) — don't print them, don't commit them.

**How to use it here:**

1. Write the spec yourself first (what file(s), what the function/widget should do, edge
   cases, acceptance criteria) — same rigor as if you were about to implement it directly.
2. Run `ask-model --role coder` with that spec. Treat the output as a first draft, not a
   finished patch — Kimi is not fluent-by-default in this codebase's conventions
   (`impeccable_flutter_lints`, the `PrefsService`/`SharedPreferences`-only rule, the
   plain-Map i18n approach in `lib/l10n/app_strings.dart`, no `Colors.deepPurple`/pure
   black-white, etc.). Point it at the relevant existing file(s) as context so it doesn't
   reinvent patterns that already exist in this repo.
3. Before treating anything Kimi wrote as done, it still has to pass the same gates as
   any other change (CONSTITUTION.md §2.3):
   - `flutter analyze` — must say "No issues found"
   - `dart run custom_lint`
   - `flutter test`
   (Remember: `flutter`/`dart` aren't on PATH here — use the full path,
   `D:\dev\flutter\bin\flutter.bat`.)
4. One branch per feature, same as any other change — don't merge Kimi-authored code to
   `master` without going through the normal review/CI path.

If a generated file fails a gate, either fix it directly or feed the failure back to
`ask-model --role coder` for a second pass — don't relax the gate to make it pass.
