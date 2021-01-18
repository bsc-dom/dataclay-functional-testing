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

	public static Person_Stub personVersion;

	@When("I create new version of the object in backend {string}")
	public void iCreateNewVersionOfTheObjectInBackend(String backendName) throws StorageException {
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
		String id = CommonSteps.person.getObjectID()
				+ ":" + CommonSteps.person.getHint()
				+ ":" + CommonSteps.person.getMetaClassID();
		System.out.println("Object id " + id);

		String newObjectID = StorageItf.newVersion(id, false, backend2Hostname);
		// get versioned object
		personVersion = (Person_Stub) StorageItf.getByID(newObjectID);

	}


	@And("I update the version object")
	public void iUpdateTheVersionObject() {
		personVersion.setAge(100);
	}
	@Then("I check that the original object was not modified")
	public void iCheckThatTheOriginalObjectWasNotModified() {
		org.junit.Assert.assertEquals(33, CommonSteps.person.getAge());
		org.junit.Assert.assertEquals(100, personVersion.getAge());

	}

	@Then("I consolidate the version")
	public void iConsolidateTheVersion() throws StorageException {
		String id = personVersion.getObjectID()
				+ ":" + personVersion.getMetaClassID()
				+ ":" + personVersion.getHint();
		StorageItf.consolidateVersion(id);
	}

	@And("I check that the original object was modified")
	public void iCheckThatTheOriginalObjectWasModified() {
		org.junit.Assert.assertEquals(100, CommonSteps.person.getAge());
	}
}