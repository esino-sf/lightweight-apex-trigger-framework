/**
 * Description:
 *
 * Domain class implementation for the Opportunity object aiming to streamline and standardize the
 * trigger implementation and handling for the respective object.
 *
 * Domain (software engineering). “a set of common requirements, terminology, and functionality
 * for any software program constructed to solve a problem in that field”,
 * http://en.wikipedia.org/wiki/Domain_(software_engineering)
 *
 * Domain Model, “An object model of the domain that incorporates both behavior and data.”,
 * “At its worst business logic can be very complex. Rules and logic describe many different "
 * "cases and slants of behavior, and it's this complexity that objects were designed to work with...”
 * Martin Fowler, EAA Patterns
 * http://martinfowler.com/eaaCatalog/domainModel.html
 *
 * Inspiration: Apex Enterprise Patterns
 * https://github.com/apex-enterprise-patterns/fflib-apex-common
 *
 * 
 * Notes:
 * 
 * Domain classes like this one are initialised with a concrete list of SObjects to enforce bulkification.
 **/
public with sharing class OpportunityTriggerHandler2 extends SObjectDomain {

    public OpportunityTriggerHandler2(List<Opportunity> sObjectList) {
        super(sObjectList);
    }

    public override void onApplyDefaults() {
        for(Opportunity opp : (List<Opportunity>) this.records) {
            if(String.isBlank(opp.Some_Custom_Field__c)) {
                opp.Some_Custom_Field__c = '' + System.now().getTime();
            }
        }
    }

    public override void onValidate() {
        for(Opportunity opp : (List<Opportunity>) this.records) {
            if(opp.Type != null && opp.Type.startsWith('Existing') && opp.AccountId == null){
                opp.AccountId.addError('You must provide an Account for Opportunities intended for existing Customers.');
            }
        }
    }

    public override void onValidate(Map<Id,SObject> existingRecords) {
        for(Opportunity opp : (List<Opportunity>) this.records) {
            Opportunity existingOpp = (Opportunity) existingRecords.get(opp.Id);
            if(opp.Some_Other_Custom_Field__c != existingOpp.Some_Other_Custom_Field__c){
                opp.Some_Other_Custom_Field__c.addError('You cannot change this Some_Other_Custom_Field__c field once it has been set upon Opportunity creation.');
            }
        }
    }

    public override void onAfterInsert() {
        updateSomeFieldOnRelatedAccount();
    }

    private void updateSomeFieldOnRelatedAccount() {
        List<Account> accounts = new List<Account>();
        for (Opportunity opp : (List<Opportunity>) this.records) {
            if (opp.AccountId == null) {
                continue;
            }
            accounts.add(new Account(
                Id = opp.AccountId,
                Certain_Custom_Field__c = Date.today().addDays(7)
            ));
        }
        update accounts;
    }

    public class Constructor implements SObjectDomain.IConstructable {
        public SObjectDomain construct(List<SObject> sObjectList) {
            return new OpportunityTriggerHandler2(sObjectList);
        }
    }
}