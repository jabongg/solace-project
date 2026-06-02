package com.example.solace_project.booking;

import java.time.Instant;
import java.util.Collection;
import java.util.Comparator;
import java.util.Map;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

import com.example.solace_project.feature.FeatureFlagsProperties;
import org.springframework.stereotype.Service;

@Service
public class FlightBookingService {
	private final Map<String, FlightBooking> bookings = new ConcurrentHashMap<>();
	private final BookingPublisher bookingPublisher;
	private final FeatureFlagsProperties featureFlags;

	public FlightBookingService(BookingPublisher bookingPublisher, FeatureFlagsProperties featureFlags) {
		this.bookingPublisher = bookingPublisher;
		this.featureFlags = featureFlags;
	}

	public FlightBooking create(FlightBookingRequest request) {
		FlightBooking booking = new FlightBooking(
				UUID.randomUUID().toString(),
				request.passengerName(),
				request.flightNumber(),
				request.from(),
				request.to(),
				request.travelDate(),
				BookingStatus.PENDING,
				Instant.now(),
				null
		);
		bookings.put(booking.bookingId(), booking);
		if (featureFlags.publishBookingsToSolace()) {
			bookingPublisher.publish(booking);
		}
		return booking;
	}

	public Collection<FlightBooking> findAll() {
		if (!featureFlags.bookingHistory()) {
			throw new FeatureDisabledException("booking-history");
		}
		return bookings.values().stream()
				.sorted(Comparator.comparing(FlightBooking::createdAt).reversed())
				.toList();
	}

	public FlightBooking confirm(String bookingId) {
		FlightBooking confirmed = bookings.computeIfPresent(bookingId, (id, booking) -> booking.confirm(Instant.now()));
		if (confirmed == null) {
			throw new BookingNotFoundException(bookingId);
		}
		return confirmed;
	}
}
