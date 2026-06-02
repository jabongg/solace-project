# Flight Ticket Booking with Solace Queue

Tiny Spring Boot project that publishes flight booking requests to a Solace PubSub+ JMS queue and consumes them back to confirm the booking.

## Run with Docker

```bash
docker compose up --build
```

The Solace broker takes about a minute to become ready. If the API starts too early, Docker will restart it.

## Try it

Check enabled feature flags:

```bash
curl http://localhost:8081/api/feature-flags
```

Create a booking:

```bash
curl -X POST http://localhost:8081/api/bookings \
  -H "Content-Type: application/json" \
  -d '{
    "passengerName": "Asha Rao",
    "flightNumber": "AI-204",
    "from": "DEL",
    "to": "BOM",
    "travelDate": "2026-06-15"
  }'
```

List bookings:

```bash
curl http://localhost:8081/api/bookings
```

Open Solace PubSub+ Manager at http://localhost:8080 and log in with `admin` / `admin`.

## What is inside

- `POST /api/bookings` stores a booking as `PENDING` and publishes it to `flight.booking.queue`.
- `@JmsListener` receives the queue message and marks the booking as `CONFIRMED`.
- The queue is auto-created through Solace JMS dynamic durables.

## Feature flag profiles

The app has simple LaunchDarkly-style feature flags backed by Spring profiles:

| Profile | publish-bookings-to-solace | auto-confirm-bookings | booking-history |
| --- | --- | --- | --- |
| `local` | off | off | on |
| `demo` | on | on | on |
| `prod` | on | off | off |

Docker Compose runs with `SPRING_PROFILES_ACTIVE=demo`.

Run another profile locally:

```bash
SPRING_PROFILES_ACTIVE=local ./mvnw spring-boot:run
```

Override a single flag:

```bash
APP_FEATURES_AUTO_CONFIRM_BOOKINGS=false docker compose up --build
```
