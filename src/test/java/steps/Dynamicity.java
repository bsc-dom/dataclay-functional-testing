package steps;

import io.cucumber.java.en.Given;
import io.cucumber.java.en.Then;
import io.qameta.allure.Allure;
import model.Person_Stub;

import java.io.IOException;
import java.nio.file.Paths;

public class Dynamicity {

	@Given("{string} starts extra nodes using {string}")
	public void startsExtraNodesUsingDockerComposeExtra(String userName, String dockerComposePath) throws IOException {
		Orchestrator.TestUser testUser = Orchestrator.getOrCreateTestUser(userName);
		Orchestrator.dockerComposeCommand(dockerComposePath, testUser.dockerNetwork, testUser.envVars,"up -d");
		Allure.attachment(dockerComposePath, Utils.readAllBytes(Paths.get(dockerComposePath)));
	}

}