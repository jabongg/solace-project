package com.example.solace_project.booking;

public record FlightBookingRequest(
		String passengerName,
		String flightNumber,
		String from,
		String to,
		String travelDate
) {
}
