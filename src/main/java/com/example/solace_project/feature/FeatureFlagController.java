package com.example.solace_project.feature;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/feature-flags")
public class FeatureFlagController {
	private final FeatureFlagsProperties featureFlags;

	public FeatureFlagController(FeatureFlagsProperties featureFlags) {
		this.featureFlags = featureFlags;
	}

	@GetMapping
	public FeatureFlagsProperties findAll() {
		return featureFlags;
	}
}
