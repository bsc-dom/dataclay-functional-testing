package steps;

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


	@When("{string} creates new version of the object in backend {string}")
	public void createsNewVersionOfTheObjectInBackend(final String userName, String backendName) throws StorageException {
		Orchestrator.TestUser user = Orchestrator.getTestUser(userName);
		Person_Stub person = (Person_Stub) user.userObjects.get("person");

		String backend2Hostname = null;
		for (ExecutionEnvironment b : DataClay.getCommonLib().getExecutionEnvironmentsInfo(CommonMessages.Langs.LANG_JAVA).values()) {
			if (b.getName().equals(backendName)) {
				backend2Hostname = b.getHostname();
				break;
			}
		}
		org.junit.Assert.assertNotNull(backend2Hostname);
		System.out.println("Backend hostname : " + backend2Hostname);
		System.out.println("BACKENDS: " + DataClay.getBackends().values());
		String id = person.getObjectID()
				+ ":" + person.getHint()
				+ ":" + person.getMetaClassID();
		System.out.println("Object id " + id);

		String newObjectID = StorageItf.newVersion(id, false, backend2Hostname);
		// get versioned object
		Person_Stub personVersion = (Person_Stub) StorageItf.getByID(newObjectID);
		user.userObjects.put("personVersion", personVersion);

	}


	@And("{string} updates the version object")
	public void updatesTheVersionObject(final String userName) {
		Orchestrator.TestUser user = Orchestrator.getTestUser(userName);
		Person_Stub personVersion = (Person_Stub) user.userObjects.get("personVersion");
		personVersion.setAge(100);
	}
	@Then("{string} checks that the original object was not modified")
	public void checksThatTheOriginalObjectWasNotModified(final String userName) {
		Orchestrator.TestUser user = Orchestrator.getTestUser(userName);
		Person_Stub person = (Person_Stub) user.userObjects.get("person");
		Person_Stub personVersion = (Person_Stub) user.userObjects.get("personVersion");
		org.junit.Assert.assertEquals(33, person.getAge());
		org.junit.Assert.assertEquals(100, personVersion.getAge());

	}

	@Then("{string} consolidates the version")
	public void consolidatesTheVersion(final String userName) throws StorageException {
		Orchestrator.TestUser user = Orchestrator.getTestUser(userName);
		Person_Stub personVersion = (Person_Stub) user.userObjects.get("personVersion");
		String id = personVersion.getObjectID()
				+ ":" + personVersion.getMetaClassID()
				+ ":" + personVersion.getHint();
		StorageItf.consolidateVersion(id);
	}

	@And("{string} checks that the original object was modified")
	public void checksThatTheOriginalObjectWasModified(final String userName) {
		Orchestrator.TestUser user = Orchestrator.getTestUser(userName);
		Person_Stub person = (Person_Stub) user.userObjects.get("person");
		org.junit.Assert.assertEquals(100, person.getAge());
	}
}