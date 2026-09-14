# Pulse

Expense tracker for the PebbleScore Flutter take-home. It lists your expenses with a running total in naira, and lets you add, view and delete them.

Flutter 3.44.2, Dart 3.12.2.

## Running it

```bash
flutter pub get
cp env.example.json env.json
```

Fill in `env.json`:

- `API_BASE`: the API host, e.g. `https://pebblescore-api.dev.pebblescore.com`
- `BUCKET`: any name, used to keep your data separate
- `USE_LOCAL_STUB`: set to `"true"` to run on in-memory sample data instead of the API

Then:

```bash
flutter run --dart-define-from-file=env.json
```

If you use VS Code, F5 works too, since `.vscode/settings.json` passes the file.

Tests:

```bash
flutter test
```

About the API: it was returning 502 on every route from 11 Sept, so I emailed PebbleScore and kept building against a local stub that behaves like the documented API (same operations, same validation and not-found errors). The HTTP implementation is there, and setting `USE_LOCAL_STUB` to `"false"` switches to it.

## State management

I went with Riverpod.

The main reason is `AsyncNotifier`. Its state is already loading, data or error, which is pretty much what the brief asks the list screen to handle. I didn't have to keep my own `isLoading` and `error` fields in sync.

The other reason is testing. The controller gets its repository from a provider, so in tests I just override that provider with the stub. No mocking package needed.


## Structure

```
lib/
  core/      api client, env, failures, models, money helpers, theme
  data/      repository interface, http version, local stub
  features/  expenses list, add expense, expense detail
```

`features` depends on `data`, and `data` depends on `core`, never the other way round.

Some choices I made along the way:

- Amounts are stored as `int` kobo everywhere. Doubles can't hold values like 0.07 exactly, so I only convert when the user types or when showing `NGN 1,500.00`.
- After adding an expense I don't reload the list. The brief mentions new items can take a moment to show up in `GET`, so reloading could make the new expense appear and then disappear. I insert the expense from the 201 response instead.
- The API layer turns status codes into typed failures (validation, not found, server, network). The screens decide what message to show.
- I turned off Riverpod's automatic retry so the user sees the error and taps Retry themselves.

## Tests

- **Money parsing and formatting.** Easy to get wrong and users notice straight away (0.07, commas, too many decimals, very large numbers).
- **List controller.** Loading and sorting, load errors, adding without a reload, a failed save leaving the list alone, and delete. I checked the "no reload" test actually fails if I change `addExpense` to refetch.
- **Detail by id.** Finds the expense, and an unknown id gives a not found failure.
- **Widget test for Retry.** The brief says the error state must let the user retry, so I test that the button shows up and loads again.


## Trade-offs I'm not happy with

- If you add an expense and pull to refresh straight away, it can drop out of the list until the server catches up.
- Delete waits for the server before the row goes away, so it feels slow on a bad connection.
- No offline data. With no connection you get the error screen, not your last list.

## With more time

- Optimistic delete with rollback
- Offline cache
- A way to send the `X-Force-Error` and `X-Delay` headers for demoing error and loading states
- Tests for the HTTP repository with `MockClient`, and an integration test for add, view and delete
