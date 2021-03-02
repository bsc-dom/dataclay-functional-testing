package steps;

import es.bsc.dataclay.DataClayObject;
import es.bsc.dataclay.api.BackendID;
import es.bsc.dataclay.api.DataClay;
import es.bsc.dataclay.util.ids.DataClayInstanceID;
import io.cucumber.java.en.And;
import io.cucumber.java.en.Given;
import io.cucumber.java.en.Then;
import io.cucumber.java.en.When;
import io.qameta.allure.Allure;
import model.Person_Stub;

import java.io.IOException;
import java.nio.file.Paths;

public class Federation {

	@Given("{string} registers external dataClay with hostname {string} and port {int}")
	public void registerExternalDataClayWithHostnameAndPort(String userName,
															String hostname,
															final int port) {
		Orchestrator.TestUser user = Orchestrator.getOrCreateTestUser(userName);
		Orchestrator.dataClayCMD(user.clientPropertiesPath, user.dockerNetwork,
				"RegisterDataClay " + hostname + " " + port);
	}

	@And("{string} imports models in namespace {string} from dataClay at hostname {string} and port {int}")
	public void importsModelFromDataClayNamed(String userName,
											  String externalNamespace,
											  String hostname, final int port) {
		Orchestrator.TestUser user = Orchestrator.getOrCreateTestUser(userName);
		Orchestrator.dataClayCMD(user.clientPropertiesPath, user.dockerNetwork,
				"ImportModelsFromExternalDataClay " + hostname + " " + port + " " + externalNamespace);
	}


	@When("{string} federates object to dataClay {string}")
	public void federatesObjectToDataClay(String userName, String externalDCName) {
		Orchestrator.TestUser user = Orchestrator.getOrCreateTestUser(userName);
		Person_Stub person = (Person_Stub) user.userObjects.get("person");
		DataClayInstanceID externalDCid = (DataClayInstanceID) user.userObjects.get("external-dc-" + externalDCName);
		person.federate(externalDCid, true);
	}

    @And("{string} gets ID of external dataClay at hostname {string} and port {int} into {string} variable")
    public void getsIDOfExternalDataClayAtHostnameAndPortIntoVariable(String userName, String hostname, int port, String varRef) {
		Orchestrator.TestUser user = Orchestrator.getOrCreateTestUser(userName);
		DataClayInstanceID externalDCid =  DataClay.getDataClayID(hostname, port);
		System.out.println("Obtained external DC id : " + externalDCid);
		user.userObjects.put(varRef, externalDCid);
	}

	@When("{string} federates {string} object to dataClay with ID {string}")
	public void federatesObjectToDataClayWithID(String userName, String objRef, String dcIDRef) {
		Orchestrator.TestUser user = Orchestrator.getOrCreateTestUser(userName);
		DataClayObject obj = (DataClayObject) user.userObjects.get(objRef);
		DataClayInstanceID externalDCid = (DataClayInstanceID) user.userObjects.get(dcIDRef);
		obj.federate(externalDCid);
	}

	@And("{string} unfederates {string} object with dataClay with ID {string}")
	public void unfederatesObjectWithDataClayWithID(String userName, String objRef, String dcIDRef) {
		Orchestrator.TestUser user = Orchestrator.getOrCreateTestUser(userName);
		DataClayObject obj = (DataClayObject) user.userObjects.get(objRef);
		DataClayInstanceID externalDCid = (DataClayInstanceID) user.userObjects.get(dcIDRef);
		obj.unfederate(externalDCid);
	}

	@And("{string} gets ID of {string} backend from external dataClay with ID {string} into {string} variable")
	public void getsIDOfBackendFromExternalDataClayWithIDIntoVariable(String userName,
																	  String backendName, String dcIDRef, String varRef) {
		Orchestrator.TestUser user = Orchestrator.getOrCreateTestUser(userName);
		DataClayInstanceID externalDCid = (DataClayInstanceID) user.userObjects.get(dcIDRef);
		BackendID externalBackendID = DataClay.getExternalJavaBackend(backendName, externalDCid);
		user.userObjects.put(varRef, externalBackendID);
	}

	@When("{string} federates {string} object to external dataClay backend with ID {string}")
	public void federatesObjectToExternalDataClayBackendWithID(String userName, String objRef, String eeID) {
		Orchestrator.TestUser user = Orchestrator.getOrCreateTestUser(userName);
		DataClayObject obj = (DataClayObject) user.userObjects.get(objRef);
		BackendID externalBackendID = (BackendID) user.userObjects.get(eeID);
		obj.federateToBackend(externalBackendID);
	}

	@And("{string} federates {string} object with recursive = {string} to external dataClay backend with ID {string}")
	public void federatesObjectWithRecursiveToExternalDataClayBackendWithID(String userName, String objRef,
																			String recursive, String eeID) {
		Orchestrator.TestUser user = Orchestrator.getOrCreateTestUser(userName);
		DataClayObject obj = (DataClayObject) user.userObjects.get(objRef);
		BackendID externalBackendID = (BackendID) user.userObjects.get(eeID);
		boolean rec = true;
		if (recursive.equals("False")) {
			rec = false;
		}
		obj.federateToBackend(externalBackendID, rec);
	}
}