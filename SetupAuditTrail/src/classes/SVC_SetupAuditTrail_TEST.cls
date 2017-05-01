/**
 * @author		MCAMP
 * @date		1/30/2015
 * @description	Test class covering SSVC_SetupAuditTrail
 */

/*
CHANGE LOG
	1/30/2015 MCAMP - initial version
*/
@isTest
private class SVC_SetupAuditTrail_TEST {
	@isTest static void test_processNewEntries() {
		//TODO: might replace this section with cutom created records if possible
		// get a single entry
		List<SetupAuditTrail> auditTrail = 
			[SELECT Id, Action, CreatedById, CreatedDate, Display, Section FROM SetupAuditTrail ORDER BY CreatedDate limit 1];
		//get two entries
		List<SetupAuditTrail> auditTrail2 = 
			[SELECT Id, Action, CreatedById, CreatedDate, Display, Section FROM SetupAuditTrail ORDER BY CreatedDate limit 2];
		//make sure we have something
		system.assertEquals(auditTrail.size(), 1,'Audit trail 2 wrong size');
		system.assertEquals(auditTrail2.size(), 2,'Audit trail 2 wrong size');
		test.startTest();
			//send single - test adding entry and inserting Setup_Audit_Trail_Control__c
			SVC_SetupAuditTrail.processNewEntries(auditTrail,true);
			//get Setup_Audit_Trail_Control__c for aserting against later
			Setup_Audit_Trail_Control__c SATControl = Setup_Audit_Trail_Control__c.getOrgDefaults();

			//send same single to test not passing update and skipping record that exist
			SVC_SetupAuditTrail.processNewEntries(auditTrail);
			//send two records, testing adding aditional, skipping record and updating Setup_Audit_Trail_Control__c
			SVC_SetupAuditTrail.processNewEntries(auditTrail2,true);
		test.stopTest();
		//get Setup_Audit_Trail_Control__c again for aserting against
		Setup_Audit_Trail_Control__c SATControl2 = Setup_Audit_Trail_Control__c.getOrgDefaults();
		//get entries created
		List<Setup_Audit_Trail__c> newEntry = [select Id,OriginalId__c from Setup_Audit_Trail__c ORDER BY CreatedDate__c];
		// Assertions
		//there were only 2 records created
		system.assertEquals(newEntry.size(), 2,'more or less than 2 entries saved');
		//the Id's match
		system.assertEquals(auditTrail.get(0).id, newEntry.get(0).OriginalId__c,'1st IDs did not match');
		system.assertEquals(auditTrail2.get(1).id, newEntry.get(1).OriginalId__c,'2nd IDs did not match');
		//the timestamps match
		system.assertEquals(auditTrail.get(0).CreatedDate, SATControl.Most_Recent_Imported_DT__c,'1st dates did not match');
		system.assertEquals(auditTrail2.get(1).CreatedDate, SATControl2.Most_Recent_Imported_DT__c,'2nd dates did not match');

		//TODO: add test for out of order dates
	}	
}