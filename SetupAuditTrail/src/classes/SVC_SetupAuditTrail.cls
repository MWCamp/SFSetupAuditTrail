/**
 * @author      MCAMP
 * @date        12/30/2015
 * @description Service class managing SetupAuditTrail
 */

/*
CHANGE LOG
    12/30/2015 MCAMP - initial version
*/
public with sharing class SVC_SetupAuditTrail {
    private static Integer defaultDaysToRetain = 90;

    /******************************************************************************************************************/
    /* PUBLIC-STATIC METHODS                                                                                          */
    /******************************************************************************************************************/
    
    /******************************************************************************************************************/
    /** getNewEntries
     * @author      MCAMP
     * @date        12/30/2015
     * @description  
     * @param       
     * @return      
     */
    public static void processNewEntries(List<SetupAuditTrail> recentAuditEntries,Boolean updateLastRun)
    {
    	list<Setup_Audit_Trail__c> newEntries = new list<Setup_Audit_Trail__c>();
        Setup_Audit_Trail__c newEntry = new Setup_Audit_Trail__c();
    	dateTime newMostRecent;
        list<ID> newEntryIds =  new list<ID>();
		// Get list of new ID's
        for (SetupAuditTrail thisEntry :recentAuditEntries) {
            newEntryIds.add(thisEntry.Id);
        }
		//query for existing records with thoes Id's
        list<Setup_Audit_Trail__c> existingEntries = [select Id,OriginalId__c from Setup_Audit_Trail__c where OriginalId__c in :newEntryIds];

        //load them into a map using originalID as Key
        map<string,ID> existingIds = new map<string,ID>();
        for (Setup_Audit_Trail__c existingEntry :existingEntries) {
            existingIds.put(existingEntry.OriginalId__c,existingEntry.Id);
        }

		// loop through incomming list
        for (SetupAuditTrail thisEntry :recentAuditEntries) {
			//chek if already exist
            if(!existingIds.containsKey(thisEntry.Id)){
                newEntry = new Setup_Audit_Trail__c();
                newEntry.Action__c = thisEntry.Action;
                newEntry.CreatedBy__c = thisEntry.CreatedById;
                newEntry.CreatedDate__c = thisEntry.CreatedDate;
                newEntry.Display__c = thisEntry.Display;
                newEntry.OriginalId__c = thisEntry.Id;
                newEntry.Section__c = thisEntry.Section;
    
                newEntries.add(newEntry);
            }
            if(updateLastRun) {
                //TODO: check if it is greater than last enty and greater than SATControl
                newMostRecent = thisEntry.CreatedDate;
            }
        }

		//save any new entries
        if(!newEntries.isEmpty()){
        	insert newEntries;
        }

		//update lastRun if needed
        if(updateLastRun) {
			Setup_Audit_Trail_Control__c SATControl = Setup_Audit_Trail_Control__c.getOrgDefaults();
       		SATControl.Most_Recent_Imported_DT__c = newMostRecent;
 			if(SATControl.Id == null){
 				insert SATControl;
 			} else {
	       		Update SATControl;
 			}
       	}

    }
    /******************************************************************************************************************/
    /** processNewEntries
     * @author      MCAMP
     * @date        12/30/2015
     * @description  
     * @param       
     * @return      
     */
    public static void processNewEntries(List<SetupAuditTrail> recentAuditEntries)
    {
        processNewEntries(recentAuditEntries,False);
    }

    /******************************************************************************************************************/
    /** deleteOldEntries
     * @author      MCAMP
     * @date        12/30/2015
     * @description  
     * @param       
     * @return      
     */
    public static void deleteOldEntries(Integer DaysToRetain)
    {
		list<Setup_Audit_Trail__c> deleteEntries = Database.query('Select ID, CreatedDate__c from Setup_Audit_Trail__c where CreatedDate__c != LAST_N_DAYS:' + DaysToRetain + ' ORDER BY CreatedDate__c DESC LIMIT 9500');
 
        if(deleteEntries.size() > 0) {
           delete deleteEntries;
        }
    }

    /******************************************************************************************************************/
    /** deleteOldEntries
     * @author      MCAMP
     * @date        12/30/2015
     * @description  
     * @param       
     * @return      
     */
    public static void deleteOldEntries()
    {
        Setup_Audit_Trail_Control__c SATControl = Setup_Audit_Trail_Control__c.getOrgDefaults();
        if(SATControl.Days_to_Retain__c != null) {
            deleteOldEntries(SATControl.Days_to_Retain__c.intValue());
        } else {
            deleteOldEntries(defaultDaysToRetain);
        }

    }

}
