package steps;

import es.bsc.dataclay.DataClayObject;
import es.bsc.dataclay.util.structs.Tuple;
import io.qameta.allure.Allure;

import java.io.*;
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

		/** User's docker network. */
		public String dockerNetwork;

		/** User stub factory. */
		public StubFactory stubsFactory;

		/** User objects. */
		public Map<String, Object> userObjects = new HashMap<>();

		public TestUser(final String testUserName) {
			this.name = testUserName;
			this.dockerNetwork = "dataclay-testing-" + testUserName.replace(" ", "_");
		}

	}


	/**
	 * Execute command
	 * @param command
	 *            Command to execute
	 * @param envVariables
	 *            Environment variables for the command.
	 */
	public static void runProcess(final String command,
										final Map<String, String> envVariables) {
		String result = null;
		try {
			String[] commandArgs = command.split(" ");
			final ProcessBuilder pb = new ProcessBuilder(commandArgs);

			// set environment variables
			if (envVariables != null) {
				pb.environment().putAll(envVariables);
			}

			final Process process = pb.start();

			final StreamGobbler errorGobbler = new StreamGobbler(process.getErrorStream(), "ERROR");
			final StreamGobbler outputGobbler = new StreamGobbler(process.getInputStream(), "INFO");

			// kick them off
			errorGobbler.start();
			outputGobbler.start();

			// any error???
			final int exitVal = process.waitFor();
			errorGobbler.join();
			outputGobbler.join();

		} catch (final Throwable e) {
			e.printStackTrace();
			throw new RuntimeException(e);
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
		String command = "/bin/bash resources/utils/clean_scenario.sh";
		System.out.println(command);
		runProcess(command, null);
	}

	/**
	 * Create docker network
	 * @param networkName Name of user
	 */
	public static void createDockerNetwork(final String networkName) {
		if (!networkName.startsWith("dataclay-testing")) {
			throw new RuntimeException("Docker network name must have the prefix 'dataclay-testing'");
		}
		String command = "docker network create " + networkName;
		System.out.println(command);
		runProcess(command, null);
	}

	/**
	 * Connect to docker network
	 * @param networkName Name of network
	 */
	public static void connectToDockerNetwork(final String networkName) {
		if (!networkName.startsWith("dataclay-testing")) {
			throw new RuntimeException("Docker network name must have the prefix 'dataclay-testing'");
		}
		String command = "/bin/bash resources/utils/connect_network.sh " + networkName;
		System.out.println(command);
		runProcess(command, null);
	}


	/**
	 * Disconnect from docker network
	 * @param networkName Name of network
	 */
	public static void disconnectFromDockerNetwork(final String networkName) {
		if (!networkName.startsWith("dataclay-testing")) {
			throw new RuntimeException("Docker network name must have the prefix 'dataclay-testing'");
		}
		String command = "/bin/bash resources/utils/disconnect_network.sh " + networkName;
		System.out.println(command);
		runProcess(command, null);
	}


	/**
	 * Remove docker network
	 * @param networkName Name of network
	 */
	public static void removeDockerNetwork(final String networkName) {
		if (!networkName.startsWith("dataclay-testing")) {
			throw new RuntimeException("Docker network name must have the prefix 'dataclay-testing'");
		}
		String command = "docker network rm " + networkName;
		System.out.println(command);
		runProcess(command, null);
	}

	/**
	 * Run docker-compose command
	 * @param dockerFilePath Docker file path
	 * @param testNetwork Network to be used in docker compose
	 * @param command Command to run
	 */
	public static void dockerComposeCommand(final String dockerFilePath, final String testNetwork,
											final String command) {
		Tuple<String, String> dockerTags = getDockerImagesToUse();
		String javaDockerImage = dockerTags.getFirst();
		String pythonDockerImage = dockerTags.getSecond();
		String pwd = System.getProperty("host_pwd");
		String archImage = System.getProperty("arch", "");

		String dockerComposeCmd = "docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v " + pwd + ":" + pwd
				+ " -e PYCLAY_IMAGE=" + pythonDockerImage + " -e JAVACLAY_IMAGE=" + javaDockerImage
				+ " -e IMAGE_PLATFORM=" + archImage + " -e TESTING_NETWORK=" + testNetwork
				+ " -w=" + pwd + " linuxserver/docker-compose -f " +  dockerFilePath + " " + command;
		System.err.println(dockerComposeCmd);
		runProcess(dockerComposeCmd, null);
	}

	/**
	 * Run dataClay server commands via docker-compose
	 * @param dockerComposeFilePath docker-compose file to use
	 * @param testNetwork Network to be used in docker compose
	 * @param command Command to run
	 */
	public static void dataClaySrv(final String dockerComposeFilePath,  final String testNetwork,
								   final String command) {
		switch (command) {
				case DATACLAYSRV_START_COMMAND:
					dockerComposeCommand(dockerComposeFilePath, testNetwork, "up -d");
					break;
				case DATACLAYSRV_STOP_COMMAND:
					dockerComposeCommand(dockerComposeFilePath, testNetwork, "down");
					break;
				case DATACLAYSRV_KILL_COMMAND:
					dockerComposeCommand(dockerComposeFilePath, testNetwork,"kill");
					dockerComposeCommand(dockerComposeFilePath, testNetwork,"rm -s -f -v");
					break;
			}

	}


	/**
	 * Run dataClay command provided using client docker image
	 * @param clientPropertiesPath Client properties to use
	 * @param dataClayCommand Command to run
	 * @param dockerNetwork test network to use
	 * @param commandMountPoints Docker mount points like models or others
	 */
	public static void dataClayCMD(final String clientPropertiesPath,
								   final String dockerNetwork,
								   final String dataClayCommand,
								   final List<String> commandMountPoints) {
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

		String debugFlag = "";
		if (System.getenv("DEBUG").equals("True")) {
			debugFlag = "--debug";
		}

		// --user " + userID + ":" + groupID + "
		String command = "docker run --rm -e HOST_USER_ID=" + userID + " -e HOST_GROUP_ID=" + groupID + " "
				+ platformParam + " --network=" + dockerNetwork + " " + mountPoints
				+ " bscdataclay/client:" + dockerImage + " " + dataClayCommand + " " + debugFlag;
		System.err.println(command);
		runProcess(command, null);
	}
	/**
	 * Run dataClay command provided using client docker image
	 * @param clientPropertiesPath Client properties to use in command
	 * @param dockerNetwork Network to use
	 * @param dataClayCommand Command to run
	 */
	public static void dataClayCMD(final String clientPropertiesPath, final String dockerNetwork,
								   final String dataClayCommand) {
		dataClayCMD(clientPropertiesPath, dockerNetwork, dataClayCommand, null);
	}

	/**
	 * Clean dataClay
	 * @param dockerCompose Docker-compose file to use
	 * @param testNetwork Network to be used in docker compose

	 */
	public static void cleanDataClay(final String dockerCompose, final String testNetwork) {
		dataClaySrv(dockerCompose, testNetwork, DATACLAYSRV_KILL_COMMAND);
	}

	/**
	 * Start dataClay
	 * @param dockerCompose Docker-compose file to use
	 * @param testNetwork Network to be used in docker compose
	 */
	public static void startDataClay(final String dockerCompose, final String testNetwork) {
		dataClaySrv(dockerCompose, testNetwork, DATACLAYSRV_START_COMMAND);
	}

	/**
	 * Stop dataClay
	 * @param dockerCompose Docker-compose file to use
	 * @param testNetwork Network to be used in docker compose
	 */
	public static void stopDataClay(final String dockerCompose, final String testNetwork) {
		dataClaySrv(dockerCompose, testNetwork, DATACLAYSRV_STOP_COMMAND);
	}

	/**
	 * Get test user with name provided
	 * @param testUserName Name of user
	 * @return Test user
	 */
	public static TestUser getOrCreateTestUser(final String testUserName) {
		TestUser user = TEST_USERS.get(testUserName);
		if (user == null) {
			user = new TestUser(testUserName);
			createDockerNetwork(user.dockerNetwork);
			TEST_USERS.put(testUserName, user);
		}
		connectToDockerNetwork(user.dockerNetwork);
		return user;
	}



}
