package com.example.solace_project;

import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;

@SpringBootTest(properties = "spring.jms.listener.auto-startup=false")
class SolaceProjectApplicationTests {

	@Test
	void contextLoads() {
	}

}
