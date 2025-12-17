namespace my.customers;

using { cuid, Currency } from '@sap/cds/common';

/**
 * Customers earn reward points through purchases
 * and redeem them later.
 */
entity Customers : cuid {

  /** Business-visible customer identifier */
  @assert.unique
  @mandatory
  customerNumber            : Integer @title : 'Customer Number';

  name                       : String(100) @title : 'Customer Name';
  email                      : String(100) @title : 'Customer Email';

  /** Monetary aggregates */
  totalPurchaseValue         : Decimal(11,2)@title : 'Total Purchase Value';

  /** Reward points are COUNTS, not amounts */
  totalRewardPoints          : Integer @title : 'Total Reward Points';
  totalRedeemedRewardPoints  : Integer @title : 'Total Redeemed Reward Points';

  /** Navigational associations */
  purchases                  : Association to many Purchases
                                on purchases.customer = $self @title : 'Purchases made by Customer';

  redemptions                : Association to many Redemptions
                                on redemptions.customer = $self ;
}


/**
 * Products that can be purchased by customers
 */
entity Products : cuid {

  name        : String(100) @title : 'Product Name';
  description : String(500) @title : 'Product Description';

  price       : Decimal(11,2) @title : 'Product Price';
  currency    : Currency;

  /** Reverse navigation */
  purchases   : Association to many Purchases
                  on purchases.selectedProduct = $self;
}


/**
 * Purchase transactions made by customers
 */
entity Purchases : cuid {

  purchaseValue  : Decimal(11,2) @title : 'Purchase Value';
  currency       : Currency;

  /** Reward points earned for this purchase */
  rewardPoints   : Integer @title : 'Reward Points Earned';

  /** Owning customer */
  customer       : Association to Customers @mandatory ;

  /** Purchased product */
  selectedProduct : Association to Products @mandatory;
}


/**
 * Reward redemption transactions
 */
entity Redemptions : cuid {

  redeemedAmount : Decimal(11,2) @title : 'Redeemed Amount';

  /** Customer who redeemed points */
  customer       : Association to Customers @mandatory;
}
