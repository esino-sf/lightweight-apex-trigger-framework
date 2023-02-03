@isTest
private class OpportunityTriggerHandler2Test {

    @isTest
    static void beforeInsert_OnApplyDefaults_SetsSomeInfo() {
        // HAVING
        Account account = TestFactory.getAccount('Milky Way Corp.', true);
        Opportunity opportunity = TestFactory.generateOpportunity(account.Id, 191818821, 'Smart Integration System 5 Year Contract Oppt.');

        // ...update some data
        opportunity.Some_Custom_Field__c = '5464asdasd';

        // WHEN
        Test.startTest();

        insert opportunity;

        Test.stopTest();

        // THEN
        opportunity = [SELECT Some_Custom_Field__c FROM Opportunity WHERE Id = :opportunity.Id];
        System.assert(String.isNotBlank(opportunity.Some_Custom_Field__c), 'The Some_Custom_Field__c was not set correctly from the beforeInsert trigger.');
    }

    @isTest
    static void beforeInsert_OnValidate_EnsuresSomeFieldsAreSet() {
        // HAVING
        Opportunity opportunity = TestFactory.generateOpportunity(null, 191818821, 'Smart Integration System 5 Year Contract Oppt.');
        opportunity.Type = 'Existing Customer';

        // WHEN
        String exceptionMessage;
        Test.startTest();

        try {
            insert opportunity;
        }
        catch (DMLException dmlE) {
            exceptionMessage = dmlE.getMessage();
        }

        Test.stopTest();

        // THEN
        System.assert(exceptionMessage.contains('You must provide an Account for Opportunities intended for existing Customers.'),
                    'Inserting an Opportunity of type "Existing Customer" did not raise the exception expected.');
    }

    @isTest
    static void beforeUpdate_OnValidate_EnsuresSomeFieldsAreAlwaysSet() {
        // HAVING
        Account account = TestFactory.getAccount('Milky Way Corp.', true);
        Opportunity opportunity = TestFactory.generateOpportunity(account.Id, 191818821, 'Smart Integration System 5 Year Contract Oppt.');
        insert opportunity;

        // Ensure the Some_Custom_Field__c is set properly
        opportunity = [SELECT Some_Custom_Field__c FROM Opportunity WHERE Id = :opportunity.Id];
        System.assert(String.isNotBlank(opportunity.Some_Custom_Field__c), 'The Some_Custom_Field__c was not set properly upon insertion as expected.');

        // WHEN
        String exceptionMessage;
        Test.startTest();

        try {
            opportunity.Some_Custom_Field__c = 'some_other_value';
            update opportunity;
        }
        catch (DMLException dmlE) {
            exceptionMessage = dmlE.getMessage();
        }

        Test.stopTest();

        // THEN
        System.assert(exceptionMessage.contains('You cannot change this Some_Custom_Field__c stamp once it has been set upon Opportunity creation.'),
                    'Inserting an Opportunity of type "Existing Customer" did not raise the exception expected.');
    }

    @isTest
    static void afterInsert_ForAllOpportunities_ShouldUpdateCertainFieldOnRelatedAccount() {
        // HAVING
        Account account = TestFactory.getAccount('Milky Way Corp.', false);
        account.Certain_Custom_Field__c = null;
        insert account;

        Opportunity opportunity = TestFactory.generateOpportunity(account.Id, 191818821, 'Smart Integration System 5 Year Contract Oppt.');

        // WHEN
        Test.startTest();

        insert opportunity;

        Test.stopTest();

        // THEN
        account = [SELECT Certain_Custom_Field__c FROM Account WHERE Id = :account.Id];
        System.assertEquals('Some Expected Value', account.Certain_Custom_Field__c, 'Certain_Custom_Field__c was not set to the expected value, upon opportunity insertion.');
    }
}