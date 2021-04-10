package steps;

import es.bsc.dataclay.DataClayObject;
import es.bsc.dataclay.util.structs.Tuple;

import java.util.*;

/**
 * This class orchestrates dataClay for BDD and Functional tests. 
 *
 */
public class Orchestrator {

	/** Current user context. */
	public static TestUser userContext;

	/** Original class loader. */
	public static ClassLoader ORIGINAL_CLASS_LOADER = null;

	/** dataClay server command to start dataClay docker instances. */
	private static final String DATACLAYSRV_START_COMMAND = "start";

	/** dataClay server command to stop dataClay docker instances. */
	private static final String DATACLAYSRV_STOP_COMMAND = "stop";

	/** dataClay server command to kill dataClay docker instances. */
	private static final String DATACLAYSRV_KILL_COMMAND = "kill";

	/** All test users. */
	public static Map<String, TestUser> TEST_USERS = null;

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

		/** Environment variables for forked processes. */
		public Map<String, String> envVars = new HashMap<>();

		public TestUser(final String testUserName) {
			this.name = testUserName;
			//this.dockerNetwork = "dataclay-testing-" + testUserName.replace(" ", "_");
			this.dockerNetwork = "dataclay-testing-network";
		}

	}


	/**
	 * Execute command
	 * @param command
	 *            Command to execute
	 * @param envVariables
	 *            Environment variables for the command.
	 * @return Output
	 */
	public static String runProcess(final String command,
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
			return outputGobbler.getResult();
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
			System.out.println("docker pull " + platformParam + " dom-ci.bsc.es/bscdataclay/logicmodule:" + javaDockerImage);
			runProcess("docker pull " + platformParam + " dom-ci.bsc.es/bscdataclay/logicmodule:" + javaDockerImage, null);
			System.out.println("docker pull " + platformParam + " dom-ci.bsc.es/bscdataclay/dsjava:" + javaDockerImage);
			runProcess("docker pull " + platformParam + " dom-ci.bsc.es/bscdataclay/dsjava:" + javaDockerImage, null);
			System.out.println("docker pull " + platformParam + " dom-ci.bsc.es/bscdataclay/dspython:" + pythonDockerImage);
			runProcess("docker pull " + platformParam + " dom-ci.bsc.es/bscdataclay/dspython:" + pythonDockerImage, null);
			System.out.println("docker pull " + platformParam + " dom-ci.bsc.es/bscdataclay/client:" + javaDockerImage);
			runProcess("docker pull " + platformParam + " dom-ci.bsc.es/bscdataclay/client:" + javaDockerImage, null);
		}
	}

	/**
	 * Pull images
	 */
	public static void cleanScenario() {
		String command = "/bin/bash resources/utils/clean_scenario.sh";
		System.out.println(command);
		runProcess(command, null);
		TEST_USERS = null;
		if (ORIGINAL_CLASS_LOADER != null) {
			Thread.currentThread().setContextClassLoader(ORIGINAL_CLASS_LOADER);
		}
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
	 * Get IP of logicmodule at user's network provided
	 * @param userName Name of user
	 * @return Ip of logicmodule
	 */
	public static String getLogicmoduleIPAtUserNetwork(final String userName) {
		String command = "docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "
				+ userName + "_logicmodule";
		System.out.println(command);
		return runProcess(command, null).replace("'","");
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
	 * @param envVars Environment variables in docker compose
	 * @param testNetwork Network to be used in docker compose
	 * @param command Command to run
	 */
	public static void dockerComposeCommand(final String dockerFilePath, final String testNetwork,
											final Map<String, String> envVars, final String command) {
		Tuple<String, String> dockerTags = getDockerImagesToUse();
		String javaDockerImage = dockerTags.getFirst();
		String pythonDockerImage = dockerTags.getSecond();
		String pwd = System.getProperty("host_pwd");
		String archImage = System.getProperty("arch", "");
		String userEnvVars = "";
		for (Map.Entry<String, String> curEnv : envVars.entrySet()) {
			userEnvVars = userEnvVars + " -e " + curEnv.getKey() + "=" + curEnv.getValue();
		}


		String dockerComposeCmd = "docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v " + pwd + ":" + pwd
				+ " -e PYCLAY_IMAGE=" + pythonDockerImage + " -e JAVACLAY_IMAGE=" + javaDockerImage
				+ " -e IMAGE_PLATFORM=" + archImage + " -e TESTING_NETWORK=" + testNetwork + userEnvVars
				+ " -w=" + pwd + " linuxserver/docker-compose -f " +  dockerFilePath + " " + command;
		System.err.println(dockerComposeCmd);
		runProcess(dockerComposeCmd, null);
	}

	/**
	 * Run dataClay server commands via docker-compose
	 * @param dockerComposeFilePath docker-compose file to use
	 * @param testNetwork Network to be used in docker compose
	 * @param envVars Environment variables to use in docker compose
	 * @param command Command to run
	 */
	public static void dataClaySrv(final String dockerComposeFilePath,  final String testNetwork,
								   final Map<String, String> envVars,
								   final String command) {
		switch (command) {
				case DATACLAYSRV_START_COMMAND:
					dockerComposeCommand(dockerComposeFilePath, testNetwork, envVars, "up -d");
					break;
				case DATACLAYSRV_STOP_COMMAND:
					dockerComposeCommand(dockerComposeFilePath, testNetwork, envVars,"down");
					break;
				case DATACLAYSRV_KILL_COMMAND:
					dockerComposeCommand(dockerComposeFilePath, testNetwork, envVars,"kill");
					dockerComposeCommand(dockerComposeFilePath, testNetwork, envVars,"rm -s -f -v");
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
		String userID = System.getProperty("userID");
		String groupID = System.getProperty("groupID");

		String debugFlag = "";
		if (System.getenv("DEBUG").equals("True")) {
			debugFlag = " --debug";
		}

		// --user " + userID + ":" + groupID + "
		String command = "docker run --rm -e HOST_USER_ID=" + userID + " -e HOST_GROUP_ID=" + groupID
				+ " --platform " + archImage + " --network=" + dockerNetwork + " " + mountPoints
				+ " dom-ci.bsc.es/bscdataclay/client:" + dockerImage + " " + dataClayCommand + debugFlag;
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
	 * @param envVars Environment variables used in docker compose

	 */
	public static void cleanDataClay(final String dockerCompose, final String testNetwork, final Map<String, String> envVars) {
		dataClaySrv(dockerCompose, testNetwork, envVars, DATACLAYSRV_KILL_COMMAND);
	}

	/**
	 * Start dataClay
	 * @param dockerCompose Docker-compose file to use
	 * @param testNetwork Network to be used in docker compose
	 * @param envVars Environment variables used in docker compose
	 */
	public static void startDataClay(final String dockerCompose, final String testNetwork, final Map<String, String> envVars) {
		dataClaySrv(dockerCompose, testNetwork, envVars,DATACLAYSRV_START_COMMAND);
	}

	/**
	 * Stop dataClay
	 * @param dockerCompose Docker-compose file to use
	 * @param testNetwork Network to be used in docker compose
	 * @param envVars Environment variables used in docker compose

	 */
	public static void stopDataClay(final String dockerCompose, final String testNetwork, final Map<String, String> envVars) {
		dataClaySrv(dockerCompose, testNetwork, envVars, DATACLAYSRV_STOP_COMMAND);
	}

	/**
	 * Get test user with name provided
	 * @param testUserName Name of user
	 * @return Test user
	 */
	public static TestUser getOrCreateTestUser(final String testUserName) {
		if (TEST_USERS == null) {
			System.err.println("---> Creating test users map ");
			TEST_USERS = new HashMap<>();
			ORIGINAL_CLASS_LOADER = Thread.currentThread().getContextClassLoader();
		}
		TestUser user = TEST_USERS.get(testUserName);
		if (user == null) {
			System.err.println("---> Creating user " + testUserName);
			user = new TestUser(testUserName);
			TEST_USERS.put(testUserName, user);
		}

		if (user.stubsFactory != null) {
			// make sure to use proper class loader
			Thread.currentThread().setContextClassLoader(user.stubsFactory.stubsClassLoader.theClassLoader);
		}
		userContext = user;
		return user;
	}



}
