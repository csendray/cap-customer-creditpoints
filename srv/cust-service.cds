using my.customers as my from '../db/schema';
using my.customers.views as vw from '../db/views';

service cust_services {

    /* =====================================================
     * Transactional Entities (Draft Enabled)
     * ===================================================== */

    @cds.redirection.target
    @odata.draft.enabled
    entity Customers                 as projection on my.Customers;

    @odata.draft.enabled
    entity Products                  as projection on my.Products;

    @cds.redirection.target
    @odata.draft.enabled
    entity Purchases                 as projection on my.Purchases;

    @cds.redirection.target
    @odata.draft.enabled
    entity Redemptions               as projection on my.Redemptions;


    /* =====================================================
     * Analytical / Read-Only Views
     * ===================================================== */

    @readonly
    entity CustomerSpending          as projection on vw.CustomerSpending;

    @readonly
    entity PurchaseHistory           as projection on vw.PurchaseHistory;

    @readonly
    entity ProductSalesSummary       as projection on vw.ProductSalesSummary;

    @readonly
    entity CustomerRedemptionSummary as projection on vw.CustomerRedemptionSummary;


    @readonly
    entity HighValueCustomers        as projection on vw.HighValueCustomers;

    @readonly
    entity CustomerLifetimeValue     as projection on vw.CustomerLifetimeValue;

    @readonly
    entity ProductPopularity         as projection on vw.ProductPopularity;

    @readonly
    entity CustomerProductMatrix     as projection on vw.CustomerProductMatrix;

    @readonly
    entity HighValuePurchases        as projection on vw.HighValuePurchases;

    @readonly
    entity CustomerEngagementStatus  as projection on vw.CustomerEngagementStatus;
}
