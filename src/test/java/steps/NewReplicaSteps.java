package steps;

import es.bsc.dataclay.DataClayObject;
import es.bsc.dataclay.api.BackendID;
import es.bsc.dataclay.api.DataClay;
import es.bsc.dataclay.util.ids.ExecutionEnvironmentID;
import io.cucumber.java.en.And;
import io.cucumber.java.en.Given;
import io.cucumber.java.en.Then;
import io.cucumber.java.en.When;
import model.People_Stub;
import model.Person_Stub;

import java.util.Set;

public class NewReplicaSteps {


	@And("{string} sets {string} object to be read only")
	public void setsObjectToBeReadOnly(String userName, String objectName) {
		Orchestrator.TestUser user = Orchestrator.getOrCreateTestUser(userName);
		DataClayObject obj = (DataClayObject) user.userObjects.get(objectName);
		obj.setReadOnly(true);

	}

	@When("{string} calls new replica for object {string} with destination backend named = {string} and recursive = {string}")
	public void callsNewReplicaForObjectWithDestinationBackendNamedAndRecursive(String userName,
																				String objectName,
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
		obj.newReplica(destBackendID, rec);
	}

	@And("{string} calls get all locations for object {string} and check object is located in {int} locations")
	public void callsGetAllLocationsForObjectAndCheckObjectIsLocatedInLocations(String userName,
																				String objectName, int numLocations) {
		Orchestrator.TestUser user = Orchestrator.getOrCreateTestUser(userName);
		DataClayObject obj = (DataClayObject) user.userObjects.get(objectName);
		Set<BackendID> backends = obj.getAllLocations();
		org.junit.Assert.assertEquals(numLocations, backends.size());
	}

	@And("{string} gets id of {string} backend into {string} variable")
	public void getsIdOfBackendIntoVariable(String userName,
											String backendName, String idVariable) {

		Orchestrator.TestUser user = Orchestrator.getOrCreateTestUser(userName);
		BackendID id = DataClay.getJavaBackend(backendName);
		user.userObjects.put(idVariable, id);
	}

	@And("{string} calls get all locations for object {string} and check object is located in {string} location")
	public void callsGetAllLocationsForObjectAndCheckObjectIsLocatedInLocation(String userName, String objectName, String idVariable) {
		Orchestrator.TestUser user = Orchestrator.getOrCreateTestUser(userName);
		DataClayObject obj = (DataClayObject) user.userObjects.get(objectName);
		ExecutionEnvironmentID id = (ExecutionEnvironmentID) user.userObjects.get(idVariable);
		Set<BackendID> backends = obj.getAllLocations();
		org.junit.Assert.assertTrue(backends.contains(id));
	}

    @And("{string} sets {string} object hint to {string}")
    public void setsObjectHintTo(String userName, String objectName,  String idVariable) {
		Orchestrator.TestUser user = Orchestrator.getOrCreateTestUser(userName);
		DataClayObject obj = (DataClayObject) user.userObjects.get(objectName);
		ExecutionEnvironmentID id = (ExecutionEnvironmentID) user.userObjects.get(idVariable);
		obj.setHint(id);
    }

    @When("{string} calls new replica for object {string}")
    public void callsNewReplicaForObject(String userName, String objectName) {
		Orchestrator.TestUser user = Orchestrator.getOrCreateTestUser(userName);
		DataClayObject obj = (DataClayObject) user.userObjects.get(objectName);
		obj.newReplica();
    }

	@And("{string} calls new replica for object {string} with destination backend named = {string}")
	public void callsNewReplicaForObjectWithDestinationBackendNamed(String userName, String objectName, String backendName) {
		Orchestrator.TestUser user = Orchestrator.getOrCreateTestUser(userName);
		DataClayObject obj = (DataClayObject) user.userObjects.get(objectName);
		BackendID id = DataClay.getJavaBackend(backendName);
		obj.newReplica(id);
	}
}