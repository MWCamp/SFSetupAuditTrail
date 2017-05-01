/**
 * @author MCAMP
 * @date 01/04/2016
 * @description scheduled batch class to get the latest Setup audit trails from api
 *              system.schedule('Get SetupAuditTrail', '0 0 3 * * ?', new BAT_SetupAuditTrail_GetLatest_SCH());
 */
/*
CHANGE LOG
	01/04/2016 MCAMP      - initial version
*/
global class BAT_SetupAuditTrail_GetLatest_SCH implements Database.Batchable<sObject>, Schedulable {
	
    /**
    *    you can update only certain contacts by setting query variable before calling start method
    */
	global String query;
	
 	global void execute(SchedulableContext ctx) {
		Database.executeBatch(new BAT_SetupAuditTrail_GetLatest_SCH(), 200);
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		if (query == null){
			query = 'SELECT Id, Action, CreatedById, CreatedDate, Display, Section FROM SetupAuditTrail';
			Setup_Audit_Trail_Control__c SATControl = Setup_Audit_Trail_Control__c.getOrgDefaults();

			if(SATControl.Most_Recent_Imported_DT__c != null) {
				query += ' WHERE CreatedDate >= ' + SATControl.Most_Recent_Imported_DT__c.format('yyyy-MM-dd hh:mm:ssZ').replace(' ','T') ;
			}
			query += ' ORDER BY CreatedDate';
		}
		if (Test.isRunningTest()) {
		  query += ' limit 10';
		}
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		SVC_SetupAuditTrail.processNewEntries(scope,true);
	}
	
	global void finish(Database.BatchableContext BC) {
        SVC_SetupAuditTrail.deleteOldEntries();
	}
	
}