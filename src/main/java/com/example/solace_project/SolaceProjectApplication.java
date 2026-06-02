package com.example.solace_project;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.context.properties.ConfigurationPropertiesScan;
import org.springframework.jms.annotation.EnableJms;

@EnableJms
@ConfigurationPropertiesScan
@SpringBootApplication
public class SolaceProjectApplication {

	public static void main(String[] args) {
		SpringApplication.run(SolaceProjectApplication.class, args);
	}

}
