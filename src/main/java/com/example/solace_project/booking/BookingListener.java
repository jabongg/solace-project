package com.example.solace_project.booking;

import com.example.solace_project.feature.FeatureFlagsProperties;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.jms.annotation.JmsListener;
import org.springframework.stereotype.Component;
import tools.jackson.core.JacksonException;
import tools.jackson.databind.ObjectMapper;

@Component
public class BookingListener {
	private static final Logger log = LoggerFactory.getLogger(BookingListener.class);

	private final FlightBookingService bookingService;
	private final ObjectMapper objectMapper;
	private final FeatureFlagsProperties featureFlags;

	public BookingListener(
			FlightBookingService bookingService,
			ObjectMapper objectMapper,
			FeatureFlagsProperties featureFlags
	) {
		this.bookingService = bookingService;
		this.objectMapper = objectMapper;
		this.featureFlags = featureFlags;
	}

	@JmsListener(destination = "${app.solace.booking-queue}")
	public void receive(String payload) throws JacksonException {
		log.info("<==================inside receive() method=================>");
		// Never let consumer die. because of bad/poisoned message
		try {
		log.info("RAW PAYLOAD: {}", payload);

		FlightBooking booking = objectMapper.readValue(payload, FlightBooking.class);

		log.info("Received booking {}", booking.bookingId());

		if (!featureFlags.autoConfirmBookings()) {
			log.info("Received booking {}, but auto confirmation feature flag is disabled", booking.bookingId());
			return;
		}

		FlightBooking confirmed = bookingService.confirm(booking.bookingId());
		log.info("Confirmed flight booking {} for passenger {} on flight {}",
				confirmed.bookingId(),
				confirmed.passengerName(),
				confirmed.flightNumber());
		} catch (Exception e) {
			log.error("Invalid message payload: {}", payload, e);
		}
	}
}
