---
title: Date, Time, DateTime
sidebar: { order: 5 }
---

Rip has a literal syntax for `Date`, `Time` and `DateTime` objects. The literal syntax is based on a subset of ISO8601. All dates and times literals are taken to be in UTC, regardless of the system timezone, unless a timezone is specified.

## 1. Date

```rip
2026-01-01
```

## 2. Time

```rip
12:34
```

## 3. DateTime

```rip
# NOTE includes a timezone offset
2026-01-01T12:34:00-0400
```
