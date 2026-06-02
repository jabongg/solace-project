package com.example.solace_project.feature;

import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "app.features")
public record FeatureFlagsProperties(
		boolean publishBookingsToSolace,
		boolean autoConfirmBookings,
		boolean bookingHistory
) {
}
