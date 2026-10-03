package demoblaze;

import io.karatelabs.core.Runner;
import io.karatelabs.core.SuiteResult;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;

class DemoblazeTest {

    @Test
    void testDemoblazeApi() {
        SuiteResult result = Runner.path("classpath:demoblaze")
                .tags("~@ignore")
                .outputDir("build/karate-reports")
                .outputJunitXml(true)
                .outputHtmlReport(true)
                .parallel(1);
        assertEquals(0, result.getScenarioFailedCount(), String.join("\n", result.getErrors()));
    }
}
