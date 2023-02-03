trigger OpportunityTrigger2 on Opportunity (after delete,
                                            after insert,
                                            after update,
                                            before delete,
                                            before insert,
                                            before update) {
    SObjectDomain.triggerHandler(OpportunityTriggerHandler2.class);
}