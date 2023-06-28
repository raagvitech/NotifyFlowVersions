@isTest
public class NotifyUserFlowVersionsTest {
    static testMethod void testPostCallout() {
        Test.setMock(HttpCalloutMock.class, new NotifyUserFlowVersionsMockCallout());  
		notifyUserFlowVersions.notifyuser();
    }
}