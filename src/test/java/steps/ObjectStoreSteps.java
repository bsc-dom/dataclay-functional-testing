package steps;

import es.bsc.dataclay.DataClayObject;
import es.bsc.dataclay.api.BackendID;
import es.bsc.dataclay.api.DataClay;
import io.cucumber.java.en.And;

public class ObjectStoreSteps {


    @And("{string} runs dcPut for object {string} with alias = {string}, backend name = {string} and recursive = {string}")
    public void runsDcPutForObjectWithBackendIdAndRecursive(String userName,
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
        obj.dcPut(thealias, destBackendID, rec);
    }


    @And("{string} runs dcPut for object {string} with alias {string}")
    public void runsDcPutForObjectWithAlias(String userName, String objectName, String alias) {
        Orchestrator.TestUser user = Orchestrator.getOrCreateTestUser(userName);
        DataClayObject obj = (DataClayObject) user.userObjects.get(objectName);
        obj.dcPut(alias);
    }

    @And("{string} runs dcPut for object {string} with alias = {string} and backend name = {string}")
    public void runsDcPutForObjectWithBackendName(String userName, String objectName, String alias, String backendName) {
        Orchestrator.TestUser user = Orchestrator.getOrCreateTestUser(userName);
        DataClayObject obj = (DataClayObject) user.userObjects.get(objectName);
        BackendID destBackendID = null;
        if (!backendName.equals("null")) {
            destBackendID =  DataClay.getJavaBackend(backendName);
        }
        obj.dcPut(alias, destBackendID);
    }

    @And("{string} runs dcUpdate in object {string} with {string} parameter")
    public void runsDcUpdateForObject(String userName, String objectName, String paramobj) {
        Orchestrator.TestUser testUser = Orchestrator.getOrCreateTestUser(userName);
        DataClayObject obj = (DataClayObject) testUser.userObjects.get(objectName);
        DataClayObject origObj = (DataClayObject) testUser.userObjects.get(paramobj);
        obj.dcUpdate(origObj);
    }

    @And("{string} runs dcClone in object {string} and store result into {string}")
    public void runsDcClone(String userName, String objectName, String resultRef) {
        Orchestrator.TestUser testUser = Orchestrator.getOrCreateTestUser(userName);
        DataClayObject obj = (DataClayObject) testUser.userObjects.get(objectName);
        DataClayObject cloneObj = obj.dcClone();
        testUser.userObjects.put(resultRef, cloneObj);
    }
}