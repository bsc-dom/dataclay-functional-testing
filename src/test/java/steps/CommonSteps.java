package steps;

import es.bsc.dataclay.api.BackendID;
import es.bsc.dataclay.api.DataClay;
import es.bsc.dataclay.api.DataClayException;
import io.cucumber.java.After;
import io.cucumber.java.Before;
import io.cucumber.java.en.And;
import io.cucumber.java.en.Given;
import io.cucumber.java.en.Then;
import io.qameta.allure.Allure;
import io.qameta.allure.model.Parameter;
import io.qameta.allure.util.ResultsUtils;
import model.Person_Stub;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;

public class CommonSteps {

	public static List<Parameter> TEST_PARAMETERS;

	static {
		TEST_PARAMETERS = new ArrayList<>();
		TEST_PARAMETERS.add(ResultsUtils.createParameter("1. test_language", "java"));
		TEST_PARAMETERS.add(ResultsUtils.createParameter("2. jdk_version", System.getProperty("jdk")));
	}

	@Before
	public void beforeScenario() {
		Orchestrator.cleanScenario();
	}

	@After
	public void afterScenario() {
		Orchestrator.cleanScenario();
	}

	/**
	 * Return absolute path in host to be used as a docker volume
	 *
	 * @param path
	 * @return
	 */
	private static String toAbsolutePathForDockerVolume(String path) {
		return System.getProperty("host_pwd") + "/" + path.toString();
	}

	@And("{string} has a configuration file {string} to be used to connect to dataClay")
	public void hasAConfigurationFileToBeUsedToConnectToDataClay(String userName, String clientPropertiesPath) throws IOException {
		Allure.getLifecycle().updateTestCase(testResult -> testResult.setParameters(CommonSteps.TEST_PARAMETERS));
		Path path = Paths.get(clientPropertiesPath);
		Orchestrator.TestUser testUser = Orchestrator.getOrCreateTestUser(userName);
		testUser.clientPropertiesPath = toAbsolutePathForDockerVolume(clientPropertiesPath);
		Allure.attachment("client.properties", Utils.readAllBytes(path));
	}

	@And("{string} deploys dataClay with docker-compose.yml file {string}")
	public void deploysDataClayWithDockerComposeYmlFile(String userName, String dockerComposePath) throws IOException {
		Orchestrator.TestUser testUser = Orchestrator.getOrCreateTestUser(userName);
		Orchestrator.startDataClay(dockerComposePath, testUser.dockerNetwork);
		Orchestrator.dataClayCMD(testUser.clientPropertiesPath, testUser.dockerNetwork,
				"WaitForDataClayToBeAlive 10 5");
		Allure.attachment("docker-compose.yml", Utils.readAllBytes(Paths.get(dockerComposePath)));
	}


	@And("{string} has a session file {string} to be used in test application")
	public void hasASessionFileToBeUsedInTestApplication(String userName, String sessionPropertiesPath) throws IOException {
		String actualSessionPropPath = sessionPropertiesPath;
		String testType = System.getenv("TEST_TYPE");
		Orchestrator.TestUser testUser = Orchestrator.getOrCreateTestUser(userName);

		if (testType != null && testType.equals("local")) {
			int lastBarIdx = sessionPropertiesPath.lastIndexOf("/");
			String firstPart = sessionPropertiesPath.substring(0, lastBarIdx + 1);
			String secondPart = sessionPropertiesPath.substring(lastBarIdx + 1);
			String newSecondPart = "local" + secondPart;
			actualSessionPropPath = firstPart + newSecondPart;
			System.err.println("Actual session props: " + actualSessionPropPath);
			testUser.sessionPropertiesPath = toAbsolutePathForDockerVolume(actualSessionPropPath);
		} else {
			testUser.sessionPropertiesPath = actualSessionPropPath;
		}

		Path path = Paths.get(actualSessionPropPath);
		Allure.attachment("session.properties", Utils.readAllBytes(path));
	}

	@And("{string} creates an account named {string} with password {string}")
	public void createsAnAccountNamedWithPassword(String userName, String accountName, String password) {
		Orchestrator.TestUser user = Orchestrator.getOrCreateTestUser(userName);
		Orchestrator.dataClayCMD(user.clientPropertiesPath, user.dockerNetwork,
				"NewAccount " + accountName + " " + password);
		user.testAccount = accountName;
		user.testPassword = password;
	}

	@And("{string} creates a dataset named {string}")
	public void createsADatasetNamed(String arg0, String arg1) {
	}

	@And("{string} creates a namespace named {string}")
	public void createsANamespaceNamed(String arg0, String arg1) {
	}

	@And("{string} creates a datacontract allowing access to dataset {string} to user {string}")
	public void createsADatacontractAllowingAccessToDatasetToUser(String userName, String dataSet, String userSubscriber) {
		Orchestrator.TestUser user = Orchestrator.getOrCreateTestUser(userName);
		Orchestrator.dataClayCMD(user.clientPropertiesPath, user.dockerNetwork,
				"NewDataContract " + user.testAccount + " " + user.testPassword +
						" " + dataSet + " " + userSubscriber);

	}

	@And("{string} registers a model located at {string} into namespace {string}")
	public void registersAModelLocatedAtIntoNamespace(String userName, String srcPath, String namespace) throws IOException {
		Orchestrator.TestUser user = Orchestrator.getOrCreateTestUser(userName);
		String modelPath = "target/classes";
		List<String> mountPoints = new ArrayList<String>();
		// do not mount testing directory
		mountPoints.add(toAbsolutePathForDockerVolume(modelPath) + ":/home/dataclayusr/model:rw");
		Orchestrator.dataClayCMD(user.clientPropertiesPath, user.dockerNetwork,
				"NewModel " + user.testAccount + " " + user.testPassword
						+ " " + namespace + " /home/dataclayusr/model java", mountPoints);
		Files.walk(Paths.get(srcPath))
				.filter(Files::isRegularFile)
				.forEach(Utils::createModelStr);
	}

	@And("{string} get stubs from namespace {string} into {string} directory")
	public void getStubsFromNamespaceIntoDirectory(String userName, String namespace, String stubsPath) {
		Orchestrator.TestUser user = Orchestrator.getOrCreateTestUser(userName);

		List<String> mountPoints = new ArrayList<String>();
		mountPoints.add(toAbsolutePathForDockerVolume(stubsPath) + ":/home/dataclayusr/stubs:rw");
		Orchestrator.dataClayCMD(user.clientPropertiesPath, user.dockerNetwork,
				"GetStubs " + user.testAccount + " " + user.testPassword
						+ " " + namespace + " /home/dataclayusr/stubs", mountPoints);
		user.stubsFactory = new StubFactory(stubsPath);
	}


	@Given("{string} waits until dataClay has {int} backends of {string} language")
	public void waitsUntilDataClayHasBackends(final String userName, int numBackends,
											  String language) throws IOException {
		Orchestrator.TestUser user = Orchestrator.getOrCreateTestUser(userName);
		Orchestrator.dataClayCMD(user.clientPropertiesPath, user.dockerNetwork,
				"WaitForBackends " + language + " " + numBackends);
	}

	@Given("{string} starts a new session")
	public void startsANewSession(String userName) throws DataClayException {
		Orchestrator.TestUser user = Orchestrator.getOrCreateTestUser(userName);
		DataClay.setSessionFile(user.sessionPropertiesPath);
		DataClay.init();
	}

	@Then("{string} finishes the session")
	public void finishesTheSession(String userName) throws DataClayException {
		DataClay.finish();
	}

}

