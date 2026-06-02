package com.example.solace_project.booking;

public class FeatureDisabledException extends RuntimeException {
	public FeatureDisabledException(String featureName) {
		super("Feature disabled: " + featureName);
	}
}
