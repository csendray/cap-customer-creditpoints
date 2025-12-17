namespace my.customers.views;

using { my.customers as db } from './schema';


/**
 * =========================================================
 * 1. Customer Spending & Loyalty Summary
 * =========================================================
 */
@readonly
entity CustomerSpending as
  select from db.Customers {

    ID,
    customerNumber,
    name,
    email,

    concat(
      cast(customerNumber as String),
      concat(' - ', name)
    ) as customerDisplayName : String(120),

    totalPurchaseValue,
    totalRewardPoints,
    totalRedeemedRewardPoints,

    (totalRewardPoints - totalRedeemedRewardPoints)
      as availableRewardPoints : Integer,

    case
      when totalPurchaseValue >= 1500 then 'PLATINUM'
      when totalPurchaseValue >= 1000 then 'GOLD'
      when totalPurchaseValue >= 500  then 'SILVER'
      else 'BRONZE'
    end as customerTier : String(20)
  };


/**
 * =========================================================
 * 2. Purchase History (Flattened)
 * =========================================================
 */
@readonly
entity PurchaseHistory as
  select from db.Purchases {

    ID,
    purchaseValue,
    rewardPoints,

    concat(
      selectedProduct.name,
      concat(' (', concat(currency.code, ')'))
    ) as productLabel : String(150),

    customer.ID             as customerID,
    customer.customerNumber as customerNumber,
    customer.name           as customerName,

    selectedProduct.ID      as productID,
    selectedProduct.name    as productName,
    selectedProduct.price   as productPrice
  };


/**
 * =========================================================
 * 3. Product Sales Performance
 * =========================================================
 */
@readonly
@Analytics.query: true
entity ProductSalesSummary as
  select from db.Purchases {

    selectedProduct.ID   as productID,
    selectedProduct.name as productName,
    currency.code        as currencyCode,

    sum(purchaseValue)   as totalRevenue   : Decimal(15,2),
    count(ID)            as totalPurchases : Integer,

    case
      when sum(purchaseValue) >= 5000 then 'HIGH REVENUE'
      when sum(purchaseValue) >= 2000 then 'MEDIUM REVENUE'
      else 'LOW REVENUE'
    end as revenueCategory : String(20)
  }
  group by
    selectedProduct.ID,
    selectedProduct.name,
    currency.code;


/**
 * =========================================================
 * 4. Customer Redemption Summary
 * =========================================================
 */
@readonly
entity CustomerRedemptionSummary as
  select from db.Redemptions {

    customer.ID             as customerID,
    customer.customerNumber as customerNumber,
    customer.name           as customerName,

    sum(redeemedAmount)     as totalRedeemedAmount : Decimal(15,2),
    count(ID)               as redemptionCount     : Integer
  }
  group by
    customer.ID,
    customer.customerNumber,
    customer.name;


/**
 * =========================================================
 * 5. High-Value Customers
 * =========================================================
 */
@readonly
entity HighValueCustomers as
  select from CustomerSpending
  where totalPurchaseValue >= 1000;


/**
 * =========================================================
 * 6. Customer Engagement Status
 * =========================================================
 */
@readonly
entity CustomerEngagementStatus as
  select from CustomerSpending {

    ID,
    customerNumber,
    name,
    totalPurchaseValue,
    availableRewardPoints,

    case
      when totalPurchaseValue < 300
           and availableRewardPoints > 0
        then 'AT RISK'
      when totalPurchaseValue < 300
        then 'LOW ENGAGEMENT'
      else 'ACTIVE'
    end as engagementStatus : String(20)
  };


/**
 * =========================================================
 * 7. Product Popularity Ranking
 * =========================================================
 */
@readonly
entity ProductPopularity as
  select from ProductSalesSummary {

    productID,
    productName,
    currencyCode,
    totalRevenue,
    totalPurchases
  }
  order by totalPurchases desc;


/**
 * =========================================================
 * 8. Customer Lifetime Value (CLV)
 * =========================================================
 */
@readonly
entity CustomerLifetimeValue as
  select from db.Customers {

    ID,
    customerNumber,
    name,

    totalPurchaseValue        as lifetimeSpend,
    totalRewardPoints         as lifetimePointsEarned,
    totalRedeemedRewardPoints as lifetimePointsRedeemed,

    (
      totalPurchaseValue - (totalRedeemedRewardPoints * 0.01)
    ) as estimatedNetValue : Decimal(15,2)
  };


/**
 * =========================================================
 * 9. Customer × Product Purchase Matrix
 * =========================================================
 */
@readonly
@Analytics.query: true
entity CustomerProductMatrix as
  select from db.Purchases {

    customer.customerNumber as customerNumber,
    customer.name           as customerName,

    selectedProduct.name    as productName,
    currency.code           as currencyCode,

    count(ID)               as purchaseCount,
    sum(purchaseValue)      as totalSpend : Decimal(15,2)
  }
  group by
    customer.customerNumber,
    customer.name,
    selectedProduct.name,
    currency.code;


/**
 * =========================================================
 * 10. Recent High-Value Purchases
 * =========================================================
 */
@readonly
entity HighValuePurchases as
  select from db.Purchases {

    ID,
    purchaseValue,
    rewardPoints,
    currency.code           as currencyCode,

    customer.customerNumber as customerNumber,
    customer.name           as customerName,

    selectedProduct.name    as productName
  }
  where purchaseValue >= 1000;
