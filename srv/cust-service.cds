using my.customers as my from '../db/schema';
using my.customers.views as vw from '../db/views';

namespace cust_service;

@odata.draft.enabled
service cust_services {

    @cds.redirection.target
    entity Customers   as projection on my.Customers;

    entity Products    as projection on my.Products;

    @cds.redirection.target
    entity Purchases   as projection on my.Purchases;

    @cds.redirection.target
    entity Redemptions as projection on my.Redemptions;

    @readonly entity CustomerSpending          as projection on vw.CustomerSpending;
    @readonly entity PurchaseHistory           as projection on vw.PurchaseHistory;
    @readonly entity ProductSalesSummary       as projection on vw.ProductSalesSummary;
    @readonly entity CustomerRedemptionSummary as projection on vw.CustomerRedemptionSummary;
    @readonly entity HighValueCustomers        as projection on vw.HighValueCustomers;
    @readonly entity CustomerLifetimeValue     as projection on vw.CustomerLifetimeValue;
    @readonly entity ProductPopularity         as projection on vw.ProductPopularity;
    @readonly entity CustomerProductMatrix     as projection on vw.CustomerProductMatrix;
    @readonly entity HighValuePurchases        as projection on vw.HighValuePurchases;
    @readonly entity CustomerEngagementStatus  as projection on vw.CustomerEngagementStatus;
}

