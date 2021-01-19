package steps;

import es.bsc.dataclay.DataClayObject;
import es.bsc.dataclay.util.structs.Tuple;
import io.qameta.allure.Allure;

import java.io.BufferedReader;
import java.io.File;
import java.io.IOException;
import java.io.InputStreamReader;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.*;

/**
 * This class orchestrates dataClay for BDD and Functional tests. 
 *
 */
public class Orchestrator {


	/** dataClay server command to start dataClay docker instances. */
	private static final String DATACLAYSRV_START_COMMAND = "start";

	/** dataClay server command to stop dataClay docker instances. */
	private static final String DATACLAYSRV_STOP_COMMAND = "stop";

	/** dataClay server command to kill dataClay docker instances. */
	private static final String DATACLAYSRV_KILL_COMMAND = "kill";

	/** All docker files used in test. */
	public static Set<String> ALL_DOCKER_FILES_USED = new HashSet<>();

	/** All test users. */
	public static Map<String, TestUser> TEST_USERS = new HashMap<>();

	/** Test user. **/
	public static class TestUser {

		/** User name. */
		public String name;

		/** Client properties path. */
		public String clientPropertiesPath;

		/** Session properties path. */
		public String sessionPropertiesPath;

		/** Account name. */
		public String testAccount;

		/** Account password. */
		public String testPassword;

		/** User stub factory. */
		public StubFactory stubsFactory;

		/** User objects. */
		public Map<String, Object> userObjects = new HashMap<>();

		public TestUser(final String testUserName) {
			this.name = testUserName;
		}

	}


	/**
	 * Run a command-line process
	 * @param command Command to run
	 * @param environmentVariables Environment variables applied
	 */
	private static void runProcess(final String command, final String[] environmentVariables) { 
		try { 
			// -- Linux --

			// Run a shell command
			Process process = Runtime.getRuntime().exec(command, environmentVariables);

			// Run a shell script
			// Process process = Runtime.getRuntime().exec("path/to/hello.sh");

			// -- Windows --
			// Run a command
			//Process process = Runtime.getRuntime().exec("cmd /c dir C:\\Users\\mkyong");
			BufferedReader err = new BufferedReader(new InputStreamReader(process.getErrorStream()));
			BufferedReader input = new BufferedReader(new InputStreamReader(process.getInputStream()));
			String line;
			while ((line = input.readLine()) != null) {
				System.out.println(line);
			}
			while ((line = err.readLine()) != null) {
				System.err.println(line);
			}
			System.out.flush();
			System.err.flush();
			try {
				process.waitFor();  // wait for process to complete
			} catch (InterruptedException e) {
				System.err.println(e);  // "Can'tHappen"
				return;
			}
			/*int exitVal = process.waitFor();
			if (exitVal == 0) {
				System.out.println("Success!");
			} else {
				//abnormal...
			}*/

		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	/**
	 * Get tags of docker images to use
	 * @return Tuple of java docker images and python docker images
	 */
	public static Tuple<String, String> getDockerImagesToUse() {
		String dockerJDK = System.getProperty("jdk","8");
		String dockerImage = System.getProperty("image", "");
		String archImage = System.getProperty("arch", "");
		String javaDockerImg = "";
		String pythonDockerImg = "";
		if (dockerImage.equals("normal")) {
			pythonDockerImg = "develop";
			javaDockerImg = "develop.jdk" + dockerJDK;
		} else {
			pythonDockerImg = "develop-" + dockerImage;
			javaDockerImg = "develop.jdk" + dockerJDK + "-" +  dockerImage;
		}
		return new Tuple<>(javaDockerImg, pythonDockerImg);
	}

	/**
	 * Pull images
	 */
	public static void prepareImages() {
		// Pull images first
		String archImage = System.getProperty("arch", "");
		Tuple<String, String> dockerTags = getDockerImagesToUse();
		String javaDockerImage = dockerTags.getFirst();
		String pythonDockerImage = dockerTags.getSecond();
		// Do not force pull linux/amd64 images to allow local testing
		if (!archImage.equals("linux/amd64")) {
			String platformParam = "--platform " + archImage;
			System.out.println("docker pull " + platformParam + " bscdataclay/logicmodule:" + javaDockerImage);
			runProcess("docker pull " + platformParam + " bscdataclay/logicmodule:" + javaDockerImage, null);
			System.out.println("docker pull " + platformParam + " bscdataclay/dsjava:" + javaDockerImage);
			runProcess("docker pull " + platformParam + " bscdataclay/dsjava:" + javaDockerImage, null);
			System.out.println("docker pull " + platformParam + " bscdataclay/dspython:" + pythonDockerImage);
			runProcess("docker pull " + platformParam + " bscdataclay/dspython:" + pythonDockerImage, null);
			System.out.println("docker pull " + platformParam + " bscdataclay/client:" + javaDockerImage);
			runProcess("docker pull " + platformParam + " bscdataclay/client:" + javaDockerImage, null);
		}
	}

	/**
	 * Pull images
	 */
	public static void cleanScenario() {
		for (String dockerComposePath : Orchestrator.ALL_DOCKER_FILES_USED) {
			Orchestrator.cleanDataClay(dockerComposePath);
		}
		String command = "/bin/bash resources/clean_scenario.sh";
		System.out.println(command);
		runProcess(command, null);
	}

	/**
	 * Create docker network
	 * @param networkName Name of network
	 */
	public static void createDockerNetwork(final String networkName) {
		String command = "docker network create dataclay-testing-" + networkName;
		System.out.println(command);
		runProcess(command, null);
	}

	/**
	 * Remove docker network
	 * @param networkName Name of network
	 */
	public static void removeDockerNetwork(final String networkName) {
		String command = "docker network rm dataclay-testing-" + networkName;
		System.out.println(command);
		runProcess(command, null);
	}

	/**
	 * Run docker-compose command
	 * @param dockerFilePath Docker file path
	 * @param command Command to run
	 */
	public static void dockerComposeCommand(final String dockerFilePath, final String command) {
		Tuple<String, String> dockerTags = getDockerImagesToUse();
		String javaDockerImage = dockerTags.getFirst();
		String pythonDockerImage = dockerTags.getSecond();
		String pwd = System.getProperty("host_pwd");
		if (!ALL_DOCKER_FILES_USED.contains(dockerFilePath)) {
			ALL_DOCKER_FILES_USED.add(dockerFilePath);
		}
		String dockerComposeCmd = "docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v " + pwd + ":" + pwd
				+ " -e PYCLAY_IMAGE=" + pythonDockerImage + " -e JAVACLAY_IMAGE=" + javaDockerImage
				+ " -w=" + pwd + " linuxserver/docker-compose -f " +  dockerFilePath + " " + command;
		System.err.println(dockerComposeCmd);
		runProcess(dockerComposeCmd, null);
	}

	/**
	 * Run dataClay server commands via docker-compose
	 * @param dockerComposeFilePath docker-compose file to use
	 * @param command Command to run
	 */
	public static void dataClaySrv(final String dockerComposeFilePath, final String command) {
		if (!ALL_DOCKER_FILES_USED.contains(dockerComposeFilePath)) {
			ALL_DOCKER_FILES_USED.add(dockerComposeFilePath);
		}
		switch (command) {
				case DATACLAYSRV_START_COMMAND:
					dockerComposeCommand(dockerComposeFilePath, "up -d");
					break;
				case DATACLAYSRV_STOP_COMMAND:
					dockerComposeCommand(dockerComposeFilePath, "down");
					break;
				case DATACLAYSRV_KILL_COMMAND:
					dockerComposeCommand(dockerComposeFilePath, "kill");
					dockerComposeCommand(dockerComposeFilePath, "rm -s -f -v");
					break;
			}

	}


	/**
	 * Run dataClay command provided using client docker image
	 * @param clientPropertiesPath Client properties to use
	 * @param dataClayCommand Command to run
	 * @param commandMountPoints Docker mount points like models or others
	 */
	public static void dataClayCMD(final String clientPropertiesPath, final String dataClayCommand, final List<String> commandMountPoints) {
		String dockerNetwork = System.getProperty("test_network");
		String archImage = System.getProperty("arch", "");
		String mountPoints = "-v " + clientPropertiesPath + ":/home/dataclayusr/dataclay/cfgfiles/client.properties:ro";
		if (commandMountPoints != null) { 
			for (String mountPoint : commandMountPoints) { 
				mountPoints += " -v " + mountPoint;
			}
		}
		Tuple<String, String> dockerTags = getDockerImagesToUse();
		String dockerImage = dockerTags.getSecond();

		// Do not force pull linux/amd64 images to allow local testing
		String platformParam = "";
		if (!archImage.equals("linux/amd64")) {
			platformParam = "--platform " + archImage;
		}
		String userID = System.getProperty("userID");
		String groupID = System.getProperty("groupID");
		// --user " + userID + ":" + groupID + "
		String command = "docker run --rm -e HOST_USER_ID=" + userID + " -e HOST_GROUP_ID=" + groupID + " "
				+ platformParam + " --network=" + dockerNetwork + " " + mountPoints
				+ " bscdataclay/client:" + dockerImage + " " + dataClayCommand;
		System.err.println(command);
		runProcess(command, null);
	}
	/**
	 * Run dataClay command provided using client docker image
	 * @param clientPropertiesPath Client properties to use in command
	 * @param dataClayCommand Command to run
	 */
	public static void dataClayCMD(final String clientPropertiesPath, final String dataClayCommand) {
		dataClayCMD(clientPropertiesPath, dataClayCommand, null);
	}

	/**
	 * Clean dataClay
	 * @param dockerCompose Docker-compose file to use
	 */
	public static void cleanDataClay(final String dockerCompose) {
		dataClaySrv(dockerCompose, DATACLAYSRV_KILL_COMMAND);
	}

	/**
	 * Start dataClay
	 * @param dockerCompose Docker-compose file to use

	 */
	public static void startDataClay(final String dockerCompose) {
		dataClaySrv(dockerCompose, DATACLAYSRV_START_COMMAND);
	}

	/**
	 * Stop dataClay
	 * @param dockerCompose Docker-compose file to use

	 */
	public static void stopDataClay(final String dockerCompose) {
		dataClaySrv(dockerCompose, DATACLAYSRV_STOP_COMMAND);
	}

	/**
	 * Get or create test user with name provided
	 * @param testUserName Name of user
	 * @return Test user
	 */
	public static TestUser createTestUser(final String testUserName) {
		TestUser user = new TestUser(testUserName);
		TEST_USERS.put(testUserName, user);
		return user;
	}

	/**
	 * Get test user with name provided
	 * @param testUserName Name of user
	 * @return Test user
	 */
	public static TestUser getTestUser(final String testUserName) {
		return TEST_USERS.get(testUserName);
	}



}
