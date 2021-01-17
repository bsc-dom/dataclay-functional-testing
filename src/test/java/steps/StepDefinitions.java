package steps;

import es.bsc.dataclay.api.BackendID;
import es.bsc.dataclay.api.DataClay;
import es.bsc.dataclay.api.DataClayException;

import io.cucumber.java.After;
import io.cucumber.java.Before;
import io.cucumber.java.Scenario;
import io.cucumber.java.en.Given;
import io.cucumber.java.en.Then;
import io.cucumber.java.en.When;
import io.qameta.allure.Allure;
import io.qameta.allure.Attachment;
import io.qameta.allure.model.Parameter;
import io.qameta.allure.util.ResultsUtils;
import model.People_Stub;
import model.Person_Stub;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;

public class StepDefinitions {

	/** App client properties path. */
	public static String appClientPropertiesPath;

	/** App session properties path. */
	public static String appSessionPropertiesPath;

	/** Account name. */
	public static String testAccount;

	/** Password in use. */
	public static String testPassword;

	/** Stubs path. */
	public static String stubsPath;

	/** String representing model. */
	public static String modelStr = "";

	public static List<Parameter> TEST_PARAMETERS;

	static {
		TEST_PARAMETERS = new ArrayList<>();
		TEST_PARAMETERS.add(ResultsUtils.createParameter("1. test_language", "java"));
		TEST_PARAMETERS.add(ResultsUtils.createParameter("2. jdk_version", System.getProperty("jdk")));
	}

	@Before
	public void beforeScenario() {
		/*Allure.label("1. test_language", "java");
		Allure.label("2. jdk_version", System.getProperty("jdk"));
		Allure.label("3. operating system", System.getProperty("os"));
		Allure.label("4. architecture", System.getProperty("arch"));
		Allure.label("5. docker image", System.getProperty("image"));*/
		Orchestrator.prepareImages();
	}

	@After
	public void afterScenario() {
		Orchestrator.cleanDataClay();
	}

	/**
	 * Return absolute path in host to be used as a docker volume
	 * @param path
	 * @return
	 */
	private static String toAbsolutePathForDockerVolume(String path) {
		return System.getProperty("host_pwd") + "/" + path.toString();
	}

	@Attachment
	@Given("A configuration file {string} to be used in management operations")
	public void aConfigurationFileToBeUsedInManagementOperations(String mgmClientProperties) throws IOException {
		Allure.getLifecycle().updateTestCase(testResult -> testResult.setParameters(StepDefinitions.TEST_PARAMETERS));
		Path path = Paths.get(mgmClientProperties);
		Orchestrator.managementClientPropertiesPath = toAbsolutePathForDockerVolume(mgmClientProperties);
		Allure.attachment("client.properties", Utils.readAllBytes(path));
	}

	@Attachment
	@Given("A docker-compose.yml file for deployment at {string}")
	public void aDockerComposeFileForDeploymentAt(String dockerComposePath) throws IOException {
		Orchestrator.addDockerComposeForDeployment(dockerComposePath);
		Allure.attachment("docker-compose.yml", Utils.readAllBytes(Paths.get(dockerComposePath)));
	}


	@Given("I deploy dataClay with docker-compose")
	public void iDeployDataClayWithDockercomposeyml() throws IOException {
		Orchestrator.cleanDataClay();
		Orchestrator.startDataClay();
		Orchestrator.dataClayCMD("WaitForDataClayToBeAlive 10 5");
	}

	@Attachment
	@Given("A configuration file {string} to be used in test application")
	public void aConfigurationFileToBeUsedInTestApplication(String clientPropertiesPath) throws IOException {
		Path path = Paths.get(clientPropertiesPath);
		appClientPropertiesPath = toAbsolutePathForDockerVolume(clientPropertiesPath);
		Allure.attachment("client.properties", Utils.readAllBytes(path));
	}

	@Attachment
	@Given("A session file {string} to be used in test application")
	public void aSessionFileToBeUsedInTestApplication(String sessionPropertiesPath) throws IOException {
		String actualSessionPropPath = sessionPropertiesPath;
		String testType = System.getenv("TEST_TYPE");
		if (testType != null && testType.equals("local")) {
			int lastBarIdx = sessionPropertiesPath.lastIndexOf("/");
			String firstPart = sessionPropertiesPath.substring(0, lastBarIdx + 1);
			String secondPart = sessionPropertiesPath.substring(lastBarIdx + 1);
			String newSecondPart = "local" + secondPart;
			actualSessionPropPath = firstPart + newSecondPart;
			System.err.println("Actual session props: " + actualSessionPropPath);
			appSessionPropertiesPath = toAbsolutePathForDockerVolume(actualSessionPropPath);
		} else {
			appSessionPropertiesPath = actualSessionPropPath;
		}

		Path path = Paths.get(actualSessionPropPath);
		Allure.attachment("session.properties", Utils.readAllBytes(path));
	}

	@Given("I create an account named {string} and password {string}")
	public void iCreateAnAccountNamedAndPassword(String accountName, String password) {
		Orchestrator.dataClayCMD("NewAccount " + accountName + " " + password);
		testAccount = accountName;
		testPassword = password;
	}
	@Given("I create a dataset named {string}")
	public void iCreateADatasetNamed(String dataSetName) {

	}
	@Given("I create a namespace named {string}")
	public void iCreateANamespaceNamed(String namespaceName) {

	}
	@Given("I create a datacontract allowing access to dataset {string} to user {string}")
	public void iCreateADatacontractAllowingAccessToDatasetToUser(String dataSet, String user) {
		Orchestrator.dataClayCMD("NewDataContract " + testAccount + " " +  testPassword +
				" " + dataSet + " " + user);
	}



	@Attachment
	@Given("I register a model located at {string} into namespace {string}")
	public void iRegisterAModelLocatedAtAndCompiledIntoIntoNamespace(String srcPath, String namespace) throws IOException {
		String modelPath = "target/classes";
		List<String> mountPoints = new ArrayList<String>();
		// do not mount testing directory
		mountPoints.add(toAbsolutePathForDockerVolume(modelPath) + ":/home/dataclayusr/model:rw");
		Orchestrator.dataClayCMD("NewModel " + testAccount + " " + testPassword
				+ " " + namespace + " /home/dataclayusr/model java", mountPoints);
		Files.walk(Paths.get(srcPath))
				.filter(Files::isRegularFile)
				.forEach(Utils::createModelStr);
	}
	@Given("I get stubs from namespace {string} into {string} directory")
	public void iGetStubsFromNamespaceIntoDirectory(String namespace, String stubsPath) {
		List<String> mountPoints = new ArrayList<String>();
		mountPoints.add(toAbsolutePathForDockerVolume(stubsPath) + ":/home/dataclayusr/stubs:rw");
		Orchestrator.dataClayCMD("GetStubs " + testAccount + " " + testPassword
				+ " " + namespace + " /home/dataclayusr/stubs", mountPoints);
		StubsClassLoader.initializeStubsClassLoader(stubsPath);
	}

	@Given("I start extra nodes using {string}")
	public void iStartExtraNodesUsingDockerComposeExtra(String dockerComposePath) throws IOException {
		Orchestrator.dockerComposeCommand(dockerComposePath, "up -d");
		Allure.attachment(dockerComposePath, Utils.readAllBytes(Paths.get(dockerComposePath)));
	}

	@Given("I wait until dataClay has {string} backends")
	public void iWaitUntilDataClayHasBackends(String numBackends) throws IOException {
		Orchestrator.dataClayCMD("WaitForBackends java " + numBackends);
	}

	@Given("I start a new session")
	public void iStartANewSession() throws DataClayException {
		DataClay.setSessionFile(appSessionPropertiesPath);
		DataClay.init();
	}

	@Then("I finish the session")
	public void iFinishTheSession() throws DataClayException {
		DataClay.finish();
	}

	private static Person_Stub person;
	private static BackendID backendID;

	@Then("I run make persistent for an object")
    public void iRunMakePersistentForAnObject() {
    	String pName = "Bob";
    	int pAge = 33;
		person = StubFactory.newPerson(pName, pAge);
		person.makePersistent();
    	
    	People_Stub people = StubFactory.newPeople();
    	people.add(person);
    	people.makePersistent();
    	
    	System.out.println(people);
    	
    }

	@Then("I run make persistent for an object with alias {string}")
	public void iRunMakePersistentForAnObjectWithAlias(String alias) {
		String pName = "Bob";
		int pAge = 33;
		Person_Stub p = StubFactory.newPerson(pName, pAge);
		p.makePersistent(alias);
	}

	@Then("I get the object with alias {string}")
	public void iGetTheObjectWithAlias(String alias) {
		Person_Stub p = StubFactory.getByAlias(alias);
		System.out.println(p);
	}

	@Given("I set object to be read only")
	public void iSetTheObjecToBeReadOnly() {
		person.setObjectReadOnly();
	}

	@When("I call new replica")
	public void iCallNewReplica() {
		backendID = person.newReplica();
	}

	@Then("I get object locations and I see object is located in two locations")
	public void iGetObjectLocationsAndISeeObjectIsLocated() {
		Set<BackendID> backends = person.getAllLocations();
		System.out.println(backends);
		org.junit.Assert.assertEquals(2, backends.size());
		org.junit.Assert.assertTrue(backends.contains(backendID));
	}


}