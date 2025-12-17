using cust_service as Srv from './cust-service';

// -------------------------------------------------------------------------
// 1. CUSTOMERS: Master Data & Object Page
// -------------------------------------------------------------------------
annotate Srv.cust_services.Customers with @(
    UI.HeaderInfo: {
        TypeName: 'Customer',
        TypeNamePlural: 'Customers',
        Title: { Value: name },
        Description: { Value: customerNumber }
    },
    UI.SelectionFields: [ customerNumber, email ],
    UI.LineItem: [
        { Value: customerNumber },
        { Value: name },
        { Value: email },
        { Value: totalPurchaseValue },
        { Value: totalRewardPoints, Criticality: #Positive, Label: 'Points Balance' }
    ],
    UI.Facets: [
        {
            $Type: 'UI.CollectionFacet',
            Label: 'General Information',
            ID: 'GeneralInfo',
            Facets: [
                { $Type: 'UI.ReferenceFacet', Label: 'Profile', Target: '@UI.FieldGroup#Profile' },
                { $Type: 'UI.ReferenceFacet', Label: 'Loyalty Metrics', Target: '@UI.FieldGroup#Metrics' }
            ]
        },
        { $Type: 'UI.ReferenceFacet', Label: 'Purchase History', Target: 'purchases/@UI.LineItem' },
        { $Type: 'UI.ReferenceFacet', Label: 'Redemption History', Target: 'redemptions/@UI.LineItem' }
    ],
    UI.FieldGroup #Profile: {
        Data: [
            { Value: customerNumber },
            { Value: name },
            { Value: email }
        ]
    },
    UI.FieldGroup #Metrics: {
        Data: [
            { Value: totalPurchaseValue },
            { Value: totalRewardPoints },
            { Value: totalRedeemedRewardPoints }
        ]
    }
) {
    ID @Common.Text: name @Common.TextArrangement: #TextFirst;
};

// -------------------------------------------------------------------------
// 2. PRODUCTS: Catalog Management
// -------------------------------------------------------------------------
annotate Srv.cust_services.Products with @(
    UI.HeaderInfo: {
        TypeName: 'Product',
        TypeNamePlural: 'Products',
        Title: { Value: name },
        Description: { Value: description }
    },
    UI.LineItem: [
        { Value: name },
        { Value: price },
        { Value: currency_code },
        { Value: description }
    ],
    UI.Facets: [
        { $Type: 'UI.ReferenceFacet', Label: 'Product Details', Target: '@UI.FieldGroup#Details' }
    ],
    UI.FieldGroup #Details: {
        Data: [
            { Value: name },
            { Value: price },
            { Value: currency_code },
            { Value: description }
        ]
    }
) {
    ID @Common.Text: name @Common.TextArrangement: #TextFirst;
};

// -------------------------------------------------------------------------
// 3. PURCHASES: Transactional Logic
// -------------------------------------------------------------------------
annotate Srv.cust_services.Purchases with @(
    UI.HeaderInfo: {
        TypeName: 'Purchase',
        TypeNamePlural: 'Purchases',
        Title: { Value: selectedProduct.name },
        Description: { Value: purchaseValue }
    },
    UI.LineItem: [
        { Value: customer_ID, Label: 'Customer' },
        { Value: selectedProduct_ID, Label: 'Product' },
        { Value: purchaseValue },
        { Value: rewardPoints, Criticality: #Information }
    ],
    UI.FieldGroup #Transaction: {
        Data: [
            { Value: customer_ID },
            { Value: selectedProduct_ID },
            { Value: purchaseValue },
            { Value: rewardPoints }
        ]
    }
) {
    customer @Common.ValueList: {
        CollectionPath: 'Customers',
        Parameters: [
            { $Type: 'Common.ValueListParameterInOut', LocalDataProperty: customer_ID, ValueListProperty: 'ID' },
            { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'name' }
        ]
    };
    selectedProduct @Common.ValueList: {
        CollectionPath: 'Products',
        Parameters: [
            { $Type: 'Common.ValueListParameterInOut', LocalDataProperty: selectedProduct_ID, ValueListProperty: 'ID' },
            { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'name' },
            { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'price' }
        ]
    };
};

// -------------------------------------------------------------------------
// 4. REDEMPTIONS: Transactional Logic
// -------------------------------------------------------------------------
annotate Srv.cust_services.Redemptions with @(
    UI.HeaderInfo: {
        TypeName: 'Redemption',
        TypeNamePlural: 'Redemptions',
        Title: { Value: customer.name },
        Description: { Value: redeemedAmount }
    },
    UI.LineItem: [
        { Value: customer_ID, Label: 'Customer' },
        { Value: redeemedAmount, Criticality: #Target }
    ]
) {
    customer @Common.ValueList: {
        CollectionPath: 'Customers',
        Parameters: [
            { $Type: 'Common.ValueListParameterInOut', LocalDataProperty: customer_ID, ValueListProperty: 'ID' },
            { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'name' },
            { $Type: 'Common.ValueListParameterDisplayOnly', ValueListProperty: 'totalRewardPoints' }
        ]
    };
};



// -------------------------------------------------------------------------
// 1. CUSTOMER SPENDING: Loyalty & Tiering
// -------------------------------------------------------------------------
annotate Srv.cust_services.CustomerSpending with @(
    UI.SelectionFields: [ customerNumber, customerTier ],
    UI.LineItem: [
        { Value: customerDisplayName, Label: 'Customer' },
        { 
            Value: customerTier, 
            Criticality: #Positive, // High tier = Green
            Label: 'Membership Tier' 
        },
        { Value: totalPurchaseValue },
        { Value: availableRewardPoints, Label: 'Points Available' }
    ],
    // KPI for a Dashboard
    UI.DataPoint #AvailablePoints: {
        Value: availableRewardPoints,
        Title: 'Net Points Balance',
        Visualization: #Number
    }
);

// -------------------------------------------------------------------------
// 2. PRODUCT SALES SUMMARY: Revenue Performance
// -------------------------------------------------------------------------
annotate Srv.cust_services.ProductSalesSummary with @(
    UI.Chart: {
        Title: 'Revenue by Product',
        ChartType: #Bar,
        Dimensions: [ productName ],
        Measures: [ totalRevenue ],
        MeasureAttributes: [{ Measure: totalRevenue, Role: #Axis1 }]
    },
    UI.LineItem: [
        { Value: productName },
        { Value: totalRevenue },
        { 
            Value: revenueCategory, 
            Criticality: #Positive, 
            Label: 'Performance' 
        },
        { Value: totalPurchases, Label: 'Transaction Count' }
    ]
);

// -------------------------------------------------------------------------
// 3. CUSTOMER ENGAGEMENT: Risk Analysis
// -------------------------------------------------------------------------
annotate Srv.cust_services.CustomerEngagementStatus with @(
    UI.LineItem: [
        { Value: name },
        { 
            Value: engagementStatus, 
            Criticality: engagementStatus, // Maps 'AT RISK' to red automatically via CSS if configured, or use:
            // Criticality: engagementStatus = 'ACTIVE' ? #Positive : (engagementStatus = 'AT RISK' ? #Negative : #Critical)
        },
        { Value: availableRewardPoints }
    ]
);

// -------------------------------------------------------------------------
// 4. CUSTOMER LIFETIME VALUE: Financial Insights
// -------------------------------------------------------------------------
annotate Srv.cust_services.CustomerLifetimeValue with @(
    UI.HeaderInfo: {
        TypeName: 'Customer Lifetime Value',
        Title: { Value: name }
    },
    UI.LineItem: [
        { Value: customerNumber },
        { Value: name },
        { Value: lifetimeSpend },
        { 
            Value: estimatedNetValue, 
            Label: 'Net Lifetime Value',
            Criticality: #Positive 
        }
    ],
    UI.DataPoint #CLV: {
        Value: estimatedNetValue,
        Title: 'Avg. Net Value',
        Visualization: #Number
    }
);

// -------------------------------------------------------------------------
// 5. PRODUCT POPULARITY: Rankings
// -------------------------------------------------------------------------
annotate Srv.cust_services.ProductPopularity with @(
    UI.SelectionFields: [ productName ],
    UI.LineItem: [
        { 
            Value: totalPurchases, 
            Label: 'Popularity Rank (Units Sold)',
            Criticality: #Information 
        },
        { Value: productName },
        { Value: totalRevenue }
    ]
);

// -------------------------------------------------------------------------
// 6. CUSTOMER PRODUCT MATRIX: Cross-Sell Analysis
// -------------------------------------------------------------------------
annotate Srv.cust_services.CustomerProductMatrix with @(
    UI.Chart: {
        Title: 'Customer vs Product Spend',
        ChartType: #HeatMap, // Excellent for Matrix views
        Dimensions: [ customerName, productName ],
        Measures: [ totalSpend ],
        MeasureAttributes: [{ Measure: totalSpend, Role: #Axis1 }]
    },
    UI.LineItem: [
        { Value: customerName },
        { Value: productName },
        { Value: purchaseCount },
        { Value: totalSpend }
    ]
);