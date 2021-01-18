package steps;

import io.cucumber.junit.Cucumber;
import io.cucumber.junit.CucumberOptions;
import org.junit.runner.RunWith;

@RunWith(Cucumber.class)
@CucumberOptions(
        features = "src/test/resources/features",
        plugin = {
            "io.qameta.allure.cucumber5jvm.AllureCucumber5Jvm",
            "pretty",
            "summary"
        }
)
public class RunCucumberTest {

}
