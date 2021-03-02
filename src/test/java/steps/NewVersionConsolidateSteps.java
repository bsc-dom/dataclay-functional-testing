package steps;

import es.bsc.dataclay.DataClayObject;
import es.bsc.dataclay.api.Backend;
import es.bsc.dataclay.api.BackendID;
import es.bsc.dataclay.api.DataClay;
import es.bsc.dataclay.api.DataClayException;
import es.bsc.dataclay.commonruntime.ClientManagementLib;
import es.bsc.dataclay.communication.grpc.messages.common.CommonMessages;
import es.bsc.dataclay.util.info.VersionInfo;
import es.bsc.dataclay.util.management.metadataservice.ExecutionEnvironment;
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
import storage.StorageException;
import storage.StorageItf;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;
import java.util.Set;

public class NewVersionConsolidateSteps {

    @When("{string} creates {string} object in host {string} as a version of {string} object")
    public void createsObjectInBackendAsAVersionOfObject(String userName, String objectName, String hostName,
														 String refObjectName) throws StorageException {
		Orchestrator.TestUser user = Orchestrator.getOrCreateTestUser(userName);
		DataClayObject obj = (DataClayObject) user.userObjects.get(refObjectName);

		String theHostName = null;
		if (!hostName.equals("null")) {
			theHostName = hostName;
		}
		String newObjectID = StorageItf.newVersion(obj.getID(), false, theHostName);
		Object versionObj = StorageItf.getByID(newObjectID);
		user.userObjects.put(objectName, versionObj);
	}

	@Then("{string} consolidates {string} version object")
	public void consolidatesVersionObject(String userName, String objectName) throws StorageException {
		Orchestrator.TestUser user = Orchestrator.getOrCreateTestUser(userName);
		DataClayObject obj = (DataClayObject) user.userObjects.get(objectName);
		StorageItf.consolidateVersion(obj.getID());
	}

	@When("{string} creates {string} object as a version of {string} object")
	public void createsAsAVersionOfObject(String userName, String objectName,
										  String refObjectName) throws StorageException {
    	this.createsObjectInBackendAsAVersionOfObject(userName, objectName, "null", refObjectName);
	}
}