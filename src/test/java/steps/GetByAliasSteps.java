package steps;

import es.bsc.dataclay.DataClayObject;
import es.bsc.dataclay.api.BackendID;
import es.bsc.dataclay.api.DataClay;
import io.cucumber.java.en.And;
import io.cucumber.java.en.Given;
import io.cucumber.java.en.Then;
import io.cucumber.java.en.When;
import model.People_Stub;
import model.Person_Stub;

import javax.xml.crypto.Data;
import java.util.Set;

import static org.junit.Assert.assertTrue;

public class GetByAliasSteps {


    @Then("{string} creates {string} of class {string} using alias {string}")
    public void createsObjectOfClassUsingAlias(String userName, String objectName,
											   String className, String alias) {
		Orchestrator.TestUser testUser = Orchestrator.getOrCreateTestUser(userName);
		testUser.userObjects.put(objectName,
				testUser.stubsFactory.getByAlias(className, alias));
    }

    @And("{string} checks that there is no object of class {string} with alias {string}")
    public void checksThatThereIsNoObjectOfClassWithAlias(String userName, String className, String alias) {
        Orchestrator.TestUser testUser = Orchestrator.getOrCreateTestUser(userName);
        boolean exceptionRaised = false;
        try {
            testUser.stubsFactory.getByAlias(className, alias);
        } catch (Exception e) {
            exceptionRaised = true;
        }
        assertTrue(exceptionRaised);
    }

    @When("{string} deletes alias {string} from object {string}")
    public void deletesAlias(String userName, String alias, String objRef) {
        Orchestrator.TestUser testUser = Orchestrator.getOrCreateTestUser(userName);
        DataClayObject obj = (DataClayObject) testUser.userObjects.get(objRef);
        obj.deleteAlias();
    }
}