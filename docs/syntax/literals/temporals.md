# Date, Time, DateTime

Rip has a literal syntax for Date, Time and DateTime objects. A subset of ISO8601 is supported. All dates and times are taken to be in UTC, regardless of the system timezone, unless a timezone is specified.

```rip
2026-01-01

12:34

# NOTE includes a timezone offset
2026-01-01T12:34:00-0400
```
