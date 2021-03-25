package steps;

import es.bsc.dataclay.DataClayObject;
import io.cucumber.java.en.And;
import io.cucumber.java.en.Then;

public class ExecutionSteps {



	@And("{string} creates {string} object of class {string} with constructor params {string}")
	public void createsObjectOfClassWithConstructorParams(String userName,
														  String objectName,
														  String className,
														  String constructorParams) {
		Orchestrator.TestUser testUser = Orchestrator.getOrCreateTestUser(userName);
		testUser.userObjects.put(objectName,
				testUser.stubsFactory.newInstance(className, constructorParams));
	}


	@And("{string} runs {string} method with params {string} in object {string} and checks that result is {string}")
	public void runsMethodWithParamsInObjectAndChecksThatResultIs(String userName,
																  String methodName,
																  String params,
																  String objectName,
																  String checkResult) {
		Orchestrator.TestUser testUser = Orchestrator.getOrCreateTestUser(userName);
		DataClayObject obj = (DataClayObject) testUser.userObjects.get(objectName);
		Object result = testUser.stubsFactory.runMethod(obj, methodName, params);
		if (checkResult.equals("null")) {
			org.junit.Assert.assertEquals(null, result);
		} else if (checkResult.equals("True")) {
			org.junit.Assert.assertEquals(true, result);
		} else if (checkResult.equals("False")) {
			org.junit.Assert.assertEquals(false, result);
		} else {
			org.junit.Assert.assertEquals(checkResult, result.toString());
		}
	}

	@And("{string} runs {string} method with params {string} in object {string} and store result into {string} variable")
	public void runsMethodWithParamsInObjectAndStoreResultIntoVariable(String userName,
																	   String methodName,
																	   String params,
																	   String objectName,
																	   String resultVar) {
		Orchestrator.TestUser testUser = Orchestrator.getOrCreateTestUser(userName);
		DataClayObject obj = (DataClayObject) testUser.userObjects.get(objectName);
		Object result = testUser.stubsFactory.runMethod(obj, methodName, params);
		testUser.userObjects.put(resultVar, result);
	}

	@And("{string} runs {string} method in object {string} and checks that result is {string}")
	public void runsMethodInObjectAndChecksThatResultIs(String userName, String methodName, String objectName,
														String checkResult) {
		this.runsMethodWithParamsInObjectAndChecksThatResultIs(userName, methodName, "", objectName, checkResult);
	}

	@And("{string} creates {string} object of class {string}")
	public void createsObjectOfClass(String userName,
									 String objectName,
									 String className) {
		Orchestrator.TestUser testUser = Orchestrator.getOrCreateTestUser(userName);
		testUser.userObjects.put(objectName,
				testUser.stubsFactory.newInstance(className, null));
	}

	@And("{string} runs {string} method with params {string} in object {string}")
	public void runsMethodWithParamsInObject(String userName, String methodName, String params, String objectName) {
		this.runsMethodWithParamsInObjectAndChecksThatResultIs(userName, methodName, params, objectName, "null");

	}
}