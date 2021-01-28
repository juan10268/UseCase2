@IsTest
public class OrderProductsTest {
    
    static testmethod void testProducts(){
        List<Product2> products = new List<Product2>{
            new Product2(Name = 'Test', IsActive = true),
            new Product2(Name = 'Test 1', IsActive = true),
            new Product2(Name = 'Test 2', IsActive = true)
        };
        insert products;
        System.assertEquals(3, OrderProducts.getProducts().size());
    }

    static testmethod void testGetProducts(){
        Account account = new Account(
            Name = 'Test'
        );
        insert account;
        Contract contract = new Contract(
            Status = 'Draft',
            AccountId = account.Id
        );
        insert contract;
        Order order = new Order(
            ContractId = contract.Id,
            AccountId = account.Id,
            EffectiveDate = System.today(),
            Pricebook2Id = Test.getStandardPricebookId(),
            EndDate = System.today().addDays(3),
            Status = 'Draft'
        );
        insert order;
        List<Product2> products = new List<Product2>{
            new Product2(Name = 'Test', IsActive = true),
            new Product2(Name = 'Test 1', IsActive = true),
            new Product2(Name = 'Test 2', IsActive = true)
        };
        insert products;
        List<PricebookEntry> pricebookEntries = new List<PricebookEntry>{
            new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = products[0].Id, UnitPrice = 1.0, IsActive = true),
            new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = products[1].Id, UnitPrice = 1.0, IsActive = true),
            new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = products[2].Id, UnitPrice = 1.0, IsActive = false)
        };
        insert pricebookEntries;
        List<OrderItem> orderItems = new List<OrderItem>{
            new OrderItem(EndDate = order.EndDate, Description = 'Test', OrderId = order.Id, Product2Id = products[0].Id, PricebookEntryId = pricebookEntries[0].Id,
                Quantity = 1, ServiceDate = order.EffectiveDate, Status__c = 'Draft', UnitPrice = pricebookEntries[0].UnitPrice),
            new OrderItem(EndDate = order.EndDate, Description = 'Test', OrderId = order.Id, Product2Id = products[1].Id, PricebookEntryId = pricebookEntries[1].Id,
                Quantity = 1, ServiceDate = order.EffectiveDate, Status__c = 'Draft', UnitPrice = pricebookEntries[1].UnitPrice),
            new OrderItem(EndDate = order.EndDate, Description = 'Test', OrderId = order.Id, Product2Id = products[2].Id, PricebookEntryId = pricebookEntries[2].Id,
                Quantity = 1, ServiceDate = order.EffectiveDate, Status__c = 'Draft', UnitPrice = pricebookEntries[2].UnitPrice)
        };
        insert orderItems;

        Test.startTest();
        System.assertEquals(3, OrderProducts.getAllOrderItems(order.Id).size());
        System.assertEquals(2, OrderProducts.getOrderItems(order.Id).size());
        Test.stopTest();
    }

    static testmethod void testOrderActive(){
        Account account = new Account(
            Name = 'Test'
        );
        insert account;
        Contract contract = new Contract(
            Status = 'Draft',
            AccountId = account.Id
        );
        insert contract;
        Order order = new Order(
            ContractId = contract.Id,
            AccountId = account.Id,
            EffectiveDate = System.today(),
            Pricebook2Id = Test.getStandardPricebookId(),
            EndDate = System.today().addDays(3),
            Status = 'Draft'
        );
        insert order;

        Test.startTest();
        System.assertEquals(false, OrderProducts.isOrderActive(order.Id));
        Test.stopTest();
    }

    static testmethod void testInsertAndUpdateOrderItems(){
        Account account = new Account(
            Name = 'Test'
        );
        insert account;
        Contract contract = new Contract(
            Status = 'Draft',
            AccountId = account.Id
        );
        insert contract;
        Order order = new Order(
            ContractId = contract.Id,
            AccountId = account.Id,
            EffectiveDate = System.today(),
            Pricebook2Id = Test.getStandardPricebookId(),
            EndDate = System.today().addDays(3),
            Status = 'Draft'
        );
        insert order;
        List<Product2> products = new List<Product2>{
            new Product2(Name = 'Test', IsActive = true),
            new Product2(Name = 'Test 1', IsActive = true),
            new Product2(Name = 'Test 2', IsActive = true),
            new Product2(Name = 'Test 3', IsActive = true)
        };
        insert products;
        List<PricebookEntry> pricebookEntries = new List<PricebookEntry>{
            new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = products[0].Id, UnitPrice = 1.0, IsActive = true),
            new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = products[1].Id, UnitPrice = 1.0, IsActive = true),
            new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = products[2].Id, UnitPrice = 1.0, IsActive = false),
            new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = products[3].Id, UnitPrice = 1.0, IsActive = true)
        };
        insert pricebookEntries;
        List<OrderItem> orderItems = new List<OrderItem>{
            new OrderItem(EndDate = order.EndDate, Description = 'Test', OrderId = order.Id, Product2Id = products[0].Id, PricebookEntryId = pricebookEntries[0].Id,
                Quantity = 1, ServiceDate = order.EffectiveDate, Status__c = 'Draft', UnitPrice = pricebookEntries[0].UnitPrice),
            new OrderItem(EndDate = order.EndDate, Description = 'Test', OrderId = order.Id, Product2Id = products[1].Id, PricebookEntryId = pricebookEntries[1].Id,
                Quantity = 1, ServiceDate = order.EffectiveDate, Status__c = 'Draft', UnitPrice = pricebookEntries[1].UnitPrice),
            new OrderItem(EndDate = order.EndDate, Description = 'Test', OrderId = order.Id, Product2Id = products[2].Id, PricebookEntryId = pricebookEntries[2].Id,
                Quantity = 1, ServiceDate = order.EffectiveDate, Status__c = 'Draft', UnitPrice = pricebookEntries[2].UnitPrice)
        };
        insert orderItems;

        Test.startTest();
        OrderProducts.insertOrUpdateNewProduct(products[0].Id, order.Id, orderItems[0].Id);
        System.assertEquals(2, [SELECT Id, Quantity FROM OrderItem WHERE Id =: orderItems[0].Id].Quantity);
        OrderProducts.insertOrUpdateNewProduct(products[3].Id, order.Id, '');
        System.assertEquals(products[3].Id, [SELECT Id, Product2Id FROM OrderItem WHERE Product2Id =: products[3].Id].Product2Id);
        Test.stopTest();
    }

    static testmethod void testActivateOrder(){
        Account account = new Account(
            Name = 'Test'
        );
        insert account;
        Contact contact = new Contact(
            LastName = 'Test'
        );
        insert contact;
        Contract contract = new Contract(
            Status = 'Draft',
            AccountId = account.Id,
            ContractTerm = 12
        );
        insert contract;
        Order order = new Order(
            ContractId = contract.Id,
            AccountId = account.Id,
            EffectiveDate = System.today(),
            Pricebook2Id = Test.getStandardPricebookId(),
            EndDate = System.today().addDays(3),
            Status = 'Draft'
        );
        insert order;
        List<Product2> products = new List<Product2>{
            new Product2(Name = 'Test', IsActive = true),
            new Product2(Name = 'Test 1', IsActive = true),
            new Product2(Name = 'Test 2', IsActive = true),
            new Product2(Name = 'Test 3', IsActive = true)
        };
        insert products;
        List<PricebookEntry> pricebookEntries = new List<PricebookEntry>{
            new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = products[0].Id, UnitPrice = 1.0, IsActive = true),
            new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = products[1].Id, UnitPrice = 1.0, IsActive = true),
            new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = products[2].Id, UnitPrice = 1.0, IsActive = false),
            new PricebookEntry(Pricebook2Id = Test.getStandardPricebookId(), Product2Id = products[3].Id, UnitPrice = 1.0, IsActive = true)
        };
        insert pricebookEntries;
        List<OrderItem> orderItems = new List<OrderItem>{
            new OrderItem(EndDate = order.EndDate, Description = 'Test', OrderId = order.Id, Product2Id = products[0].Id, PricebookEntryId = pricebookEntries[0].Id,
                Quantity = 1, ServiceDate = order.EffectiveDate, Status__c = 'Draft', UnitPrice = pricebookEntries[0].UnitPrice),
            new OrderItem(EndDate = order.EndDate, Description = 'Test', OrderId = order.Id, Product2Id = products[1].Id, PricebookEntryId = pricebookEntries[1].Id,
                Quantity = 1, ServiceDate = order.EffectiveDate, Status__c = 'Draft', UnitPrice = pricebookEntries[1].UnitPrice),
            new OrderItem(EndDate = order.EndDate, Description = 'Test', OrderId = order.Id, Product2Id = products[2].Id, PricebookEntryId = pricebookEntries[2].Id,
                Quantity = 1, ServiceDate = order.EffectiveDate, Status__c = 'Draft', UnitPrice = pricebookEntries[2].UnitPrice)
        };
        insert orderItems;
        
        contract.CompanySignedDate = System.today();
        contract.CustomerSignedDate = System.today();
        contract.CustomerSignedId = contact.Id;
        contract.CustomerSignedTitle = 'Test';
        contract.Pricebook2Id = Test.getStandardPricebookId();
        contract.Status = 'Activated';
        update contract;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new OrderProductsMocker());
        OrderProducts.activateOrder(order.Id);
        System.assertEquals('Activated', [SELECT Id, Status FROM Order WHERE Id =: order.Id].Status);
        Test.stopTest();
    }
}
