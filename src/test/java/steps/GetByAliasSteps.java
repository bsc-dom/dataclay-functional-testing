package steps;

import es.bsc.dataclay.api.BackendID;
import io.cucumber.java.en.And;
import io.cucumber.java.en.Given;
import io.cucumber.java.en.Then;
import io.cucumber.java.en.When;
import model.People_Stub;
import model.Person_Stub;

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
}