package demoblaze;

import io.karatelabs.core.Runner;
import io.karatelabs.core.SuiteResult;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;

class DemoblazeTest {

    @Test
    void testDemoblazeApi() {
        // -Dkarate.tags=@login ejecuta solo los escenarios con ese tag (por defecto, toda la suite)
        String tags = System.getProperty("karate.tags");
        SuiteResult result = Runner.path("classpath:demoblaze")
                .tags(tags == null || tags.isBlank() ? new String[]{"~@ignore"} : new String[]{tags, "~@ignore"})
                .httpClientFactory(new RetryingHttpClientFactory())
                .outputDir("build/karate-reports")
                .outputJunitXml(true)
                .outputHtmlReport(true)
                .parallel(1);
        assertEquals(0, result.getScenarioFailedCount(), String.join("\n", result.getErrors()));
    }
}
