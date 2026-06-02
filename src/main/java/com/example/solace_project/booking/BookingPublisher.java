package com.example.solace_project.booking;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.jms.core.JmsTemplate;
import org.springframework.stereotype.Component;
import tools.jackson.core.JacksonException;
import tools.jackson.databind.ObjectMapper;

@Component
public class BookingPublisher {
	private final JmsTemplate jmsTemplate;
	private final ObjectMapper objectMapper;
	private final String bookingQueue;

	public BookingPublisher(
			JmsTemplate jmsTemplate,
			ObjectMapper objectMapper,
			@Value("${app.solace.booking-queue}") String bookingQueue
	) {
		this.jmsTemplate = jmsTemplate;
		this.objectMapper = objectMapper;
		this.bookingQueue = bookingQueue;
	}

	public void publish(FlightBooking booking) {
		try {
			jmsTemplate.convertAndSend(bookingQueue, objectMapper.writeValueAsString(booking));
		} catch (JacksonException exception) {
			throw new IllegalStateException("Unable to serialize booking " + booking.bookingId(), exception);
		}
	}
}
