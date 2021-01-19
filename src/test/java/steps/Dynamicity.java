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
		Orchestrator.TestUser testUser = Orchestrator.getTestUser(userName);
		Orchestrator.dockerComposeCommand(dockerComposePath, "up -d");
		Allure.attachment(dockerComposePath, Utils.readAllBytes(Paths.get(dockerComposePath)));
	}

}