package steps;

import es.bsc.dataclay.DataClayObject;
import es.bsc.dataclay.api.BackendID;
import es.bsc.dataclay.api.DataClay;
import es.bsc.dataclay.api.DataClayException;
import io.cucumber.java.After;
import io.cucumber.java.Before;
import io.cucumber.java.en.And;
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

public class MakePersistentSteps {

	@And("{string} runs make persistent for object {string} with alias = {string}, backend name = {string} and recursive = {string}")
	public void runsMakePersistentForObjectWithBackendIdAndRecursive(String userName,
																	 String objectName,
																	 String alias,
																	 String backendName,
																	 String recursive) {
		Orchestrator.TestUser user = Orchestrator.getOrCreateTestUser(userName);
		DataClayObject obj = (DataClayObject) user.userObjects.get(objectName);
		BackendID destBackendID = null;
		if (!backendName.equals("null")) {
			destBackendID =  DataClay.getJavaBackend(backendName);
		}
		boolean rec = true;
		if (recursive.equals("False")) {
			rec = false;
		}
		String thealias = alias;
		if (alias.equals("null")) {
			thealias = null;
		}
		obj.makePersistent(thealias, destBackendID, rec);
	}


    @And("{string} runs make persistent for object {string}")
    public void runsMakePersistentForObject(String userName, String objectName) {
		Orchestrator.TestUser user = Orchestrator.getOrCreateTestUser(userName);
		DataClayObject obj = (DataClayObject) user.userObjects.get(objectName);
		obj.makePersistent();
    }

	@And("{string} runs make persistent for object {string} with alias = {string}")
	public void runsMakePersistentForObjectWithAlias(String userName, String objectName, String alias) {
		Orchestrator.TestUser user = Orchestrator.getOrCreateTestUser(userName);
		DataClayObject obj = (DataClayObject) user.userObjects.get(objectName);
		obj.makePersistent(alias);
	}

	@And("{string} runs make persistent for object {string} with backend name = {string}")
	public void runsMakePersistentForObjectWithBackendName(String userName, String objectName, String backendName) {
		Orchestrator.TestUser user = Orchestrator.getOrCreateTestUser(userName);
		DataClayObject obj = (DataClayObject) user.userObjects.get(objectName);
		BackendID destBackendID = null;
		if (!backendName.equals("null")) {
			destBackendID =  DataClay.getJavaBackend(backendName);
		}
		obj.makePersistent(destBackendID);
	}
}