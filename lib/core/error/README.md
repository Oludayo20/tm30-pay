# lib/core/error/

How errors travel through the app. Data sources **throw** `DataException`s, `guard()` turns them into typed `Failure`s, and repositories **return** a `Result`. The UI never sees a raw exception.

| File | What it does |
|---|---|
| `exceptions.dart` | Sealed `DataException` hierarchy (`NetworkException`, `InsufficientFundsException`, `NotFoundException`, `UnauthorizedException`). These exceptions are thrown only inside the data layer. |
| `failure.dart` | Sealed `Failure` hierarchy with a user-facing `message`. Because it is sealed, a `switch` over a failure must handle every case. |
| `result.dart` | `Result<T>` is either `Ok(value)` or `Err(failure)`. Every repository method returns one, so the possible failures are part of the method's type. |
| `guard.dart` | `guard(() async {...})` runs a data call and maps each exception to its `Failure`. Unexpected errors are logged and become `UnexpectedFailure`. This is the only place this mapping happens. |
