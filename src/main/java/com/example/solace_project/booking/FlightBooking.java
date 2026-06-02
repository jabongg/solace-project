package com.example.solace_project.booking;

import java.time.Instant;

public record FlightBooking(
		String bookingId,
		String passengerName,
		String flightNumber,
		String from,
		String to,
		String travelDate,
		BookingStatus status,
		Instant createdAt,
		Instant confirmedAt
) {
	public FlightBooking confirm(Instant confirmedAt) {
		return new FlightBooking(
				bookingId,
				passengerName,
				flightNumber,
				from,
				to,
				travelDate,
				BookingStatus.CONFIRMED,
				createdAt,
				confirmedAt
		);
	}
}
