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

	@And("{string} gets ID of external dataClay named {string} at hostname {string} and port {int}")
	public void getExternalDataClayIDAt(String userName,
										String externalDCName,
											  String hostname,
											  final int port) {
		Orchestrator.TestUser user = Orchestrator.getOrCreateTestUser(userName);
		DataClayInstanceID externalDCid =  DataClay.getDataClayID(hostname, port);
		System.out.println("Obtained external DC id : " + externalDCid);
		user.userObjects.put("external-dc-" + externalDCName, externalDCid);
	}



	@When("{string} federates object to dataClay {string}")
	public void federatesObjectToDataClay(String userName, String externalDCName) {
		Orchestrator.TestUser user = Orchestrator.getOrCreateTestUser(userName);
		Person_Stub person = (Person_Stub) user.userObjects.get("person");
		DataClayInstanceID externalDCid = (DataClayInstanceID) user.userObjects.get("external-dc-" + externalDCName);
		person.federate(externalDCid, true);
	}
}