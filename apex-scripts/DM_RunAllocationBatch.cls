// Purchase Invoice
Id batchJobId = Database.executeBatch(new DM_PurchaseAllocationBatch(), 1000);

// Sales Invoice
Id batchJobId = Database.executeBatch(new DM_SalesAllocationBatch(), 1000);