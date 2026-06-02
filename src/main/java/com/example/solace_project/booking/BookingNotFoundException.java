package com.example.solace_project.booking;

public class BookingNotFoundException extends RuntimeException {
	public BookingNotFoundException(String bookingId) {
		super("Booking not found: " + bookingId);
	}
}
