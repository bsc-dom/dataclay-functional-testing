package steps;

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

	@Given("{string} registers external dataClay named {string} with hostname {string} and port {int}")
	public void registerExternalDataClayWithHostnameAndPort(String userName,
															String externalDCName,
															String hostname,
															final int port) {
		Orchestrator.TestUser user = Orchestrator.getOrCreateTestUser(userName);
		DataClayInstanceID externalDCid = DataClay.registerDataClay(hostname, port);
		user.userObjects.put("external-dc-" + externalDCName, externalDCid);
	}

	@And("{string} imports models in namespace {string} from dataClay named {string}")
	public void importsModelFromDataClayNamed(String userName,
											  String externalNamespace,
											  String externalDCName) {
		Orchestrator.TestUser user = Orchestrator.getOrCreateTestUser(userName);
		DataClayInstanceID externalDCid = (DataClayInstanceID) user.userObjects.get("external-dc-" + externalDCName);
		DataClay.importModelsFromExternalDataClay(externalNamespace, externalDCid);
	}

	@When("{string} federates object to dataClay {string}")
	public void federatesObjectToDataClay(String userName, String externalDCName) {
		Orchestrator.TestUser user = Orchestrator.getOrCreateTestUser(userName);
		Person_Stub person = (Person_Stub) user.userObjects.get("person");
		DataClayInstanceID externalDCid = (DataClayInstanceID) user.userObjects.get("external-dc-" + externalDCName);
		person.federate(externalDCid, true);
	}

}