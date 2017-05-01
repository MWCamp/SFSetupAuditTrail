/**
 * @author      MCAMP
 * @date        1/30/2015
 * @description Test class covering SSVC_SetupAuditTrail
 */

/*
CHANGE LOG
    1/30/2015 MCAMP - initial version
*/
@isTest
private class BAT_SetupAuditTrail_GetLatest_SCH_TEST {

    @isTest
    public static void test_batchProcess() {

        BAT_SetupAuditTrail_GetLatest_SCH tested = new BAT_SetupAuditTrail_GetLatest_SCH();
       	SchedulableContext ctx = null;
	    Test.startTest();
        	tested.execute(ctx);
        Test.stopTest();
     }
}