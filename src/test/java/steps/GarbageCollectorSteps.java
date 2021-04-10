package steps;

import es.bsc.dataclay.DataClayObject;
import es.bsc.dataclay.api.DataClay;
import es.bsc.dataclay.commonruntime.ClientManagementLib;
import es.bsc.dataclay.util.ids.ObjectID;
import io.cucumber.java.en.And;
import io.cucumber.java.en.Then;
import io.cucumber.java.en.When;

import static org.junit.Assert.*;

public class GarbageCollectorSteps {

    @And("{string} waits {int} seconds")
    public void waitsSeconds(String userName, int seconds) throws InterruptedException {
        Thread.sleep(seconds * 1000L);
    }


    @And("{string} checks that object with id {string} does not exist in dataClay")
    public void checksThatObjectWithIdDoesNotExistInDataClay(String userName, String objIDref) {
        Orchestrator.TestUser testUser = Orchestrator.getOrCreateTestUser(userName);
        ObjectID objectID = (ObjectID) testUser.userObjects.get(objIDref);
        boolean exists = ClientManagementLib.getDataClayClientLib().objectExistsInDataClay(objectID);
        assertFalse(exists);
    }

    @And("{string} checks that object with id {string} exists in dataClay")
    public void checksThatObjectWithIdExistsInDataClay(String userName, String objIDref) {
        Orchestrator.TestUser testUser = Orchestrator.getOrCreateTestUser(userName);
        ObjectID objectID = (ObjectID) testUser.userObjects.get(objIDref);
        boolean exists = ClientManagementLib.getDataClayClientLib().objectExistsInDataClay(objectID);
        assertTrue(exists);
    }

    @When("{string} detaches object {string} from session")
    public void detachesObjectFromSession(String userName, String objRef) {
        Orchestrator.TestUser testUser = Orchestrator.getOrCreateTestUser(userName);
        DataClayObject obj = (DataClayObject) testUser.userObjects.get(objRef);
        obj.sessionDetach();
    }

    @And("{string} checks that number of objects in dataClay is {int}")
    public void checksThatNumberOfObjectsInDataClayIs(String userName, int numObjsToCheck) {
        Orchestrator.TestUser testUser = Orchestrator.getOrCreateTestUser(userName);
        int numObjs = DataClay.getNumObjects();
        assertEquals(numObjsToCheck, numObjs);
    }
}