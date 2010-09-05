Feature: Create supplier orders from an order notification
  In order to keep track of my orders
  As a supplier
  I want a new supplier order to be created when an order notification containing a product that I am supplying is verified and the payment status is completed

  Background:
    Given a seller exists with name: "Mara", email: "mara@example.com"
    And a supplier exists with name: "Dave"
    And a product: "Rubber Dingy" exists with seller: the seller, supplier: the supplier, number: "12345790063", name: "Model Ship - The Rubber Dingy"

  Scenario Outline: The payment status is not completed
    Given an <order_notification> exists with payment_status: "<payment_status>"
    And the <order_notification> has the following params: "<params>"

    When the <order_notification> is verified

    Then a supplier order should not exist

    Examples:
      | order_notification | payment_status | params                    |
      | paypal_ipn         | Pending        | {'item_number1'=>'12345790063', 'item_name1' => 'Model Ship - The Rubber Dingy', 'receiver_email'=>'mara@example.com', 'quantity1'=>'1', 'num_cart_items' => '1'}                              |

  Scenario Outline: The payment status is completed
    Given an <order_notification> exists with payment_status: "<payment_status>"
    And the <order_notification> has the following params: "<params>"

    When the <order_notification> is verified

    Then a seller order should exist
    And a supplier order should exist with product_id: the product, quantity: 1, seller_order_id: the seller order
    And the supplier order should be unconfirmed
    And the supplier order should be amongst the seller_order's supplier_orders
    And the supplier order should be amongst the supplier's supplier_orders

    Examples:
      | order_notification | payment_status | params                       |
      | paypal_ipn         | Completed      | {'item_number1'=>'12345790063', 'item_name1' => 'Model Ship - The Rubber Dingy', 'receiver_email'=>'mara@example.com', 'quantity1'=>'1', 'num_cart_items' => '1'}                                                                       |

  # From here on the payment status is always completed
  Scenario Outline: Both the seller and supplier have verified active mobile numbers
    Given a verified active mobile number: "Mara's number" exists with number: "66354668789", user: the seller
    And a verified active mobile number: "Dave's number" exists with number: "66123555331", user: the supplier
    And an <order_notification> exists with payment_status: "<payment_status>"
    And the <order_notification> has the following params: "<params>"

    When the <order_notification> is verified

    Then the most recent outgoing text message destined for the mobile number: "Mara's number" should be
    """
    Hi Mara, FYI: a new product order for 1 x 12345790063 (Model Ship - The Rubber Dingy) was created and sent to Dave (+66123555331). The item belongs to your customer order: #1
    """
    And the most recent outgoing text message destined for the mobile number: "Dave's number" should be
    """
    Hi Dave, you have a new product order: #1, from Mara (+66354668789) for 1 x 12345790063 (Model Ship - The Rubber Dingy). To accept the order, look up the product verification code for this item and reply with: "apo 1 <product verification code>"
    """

    Examples:
      | order_notification | payment_status | params                       |
      | paypal_ipn         | Completed    | {'item_number1'=>'12345790063', 'item_name1' => 'Model Ship - The Rubber Dingy', 'receiver_email'=>'mara@example.com', 'quantity1'=>'1', 'num_cart_items' => '1'}                                                                       |

  Scenario Outline: The seller has an active and verified mobile number but the supplier's active mobile number is not yet verified
    Given a verified active mobile number: "Mara's number" exists with number: "66354668789", user: the seller
    And an active mobile number: "Dave's number" exists with user: the supplier
    And an <order_notification> exists with payment_status: "<payment_status>"
    And the <order_notification> has the following params: "<params>"

    When the <order_notification> is verified

    Then the most recent outgoing text message destined for the mobile number: "Mara's number" should be
    """
    Hi Mara, FYI: a new product order for 1 x 12345790063 (Model Ship - The Rubber Dingy) was created but not sent to Dave (No verified number!). The item belongs to your customer order: #1
    """
    But an outgoing text message should not exist with mobile_number_id: mobile number: "Dave's number"

    Examples:
      | order_notification | payment_status | params                       |
      | paypal_ipn         | Completed    | {'item_number1'=>'12345790063', 'item_name1' => 'Model Ship - The Rubber Dingy', 'receiver_email'=>'mara@example.com', 'quantity1'=>'1', 'num_cart_items' => '1'}                                                                       |

  Scenario Outline: The seller has an active and verified mobile number but the supplier does not have any mobile numbers
    Given a verified active mobile number exists with number: "66354668789", user: the seller
    And an <order_notification> exists with payment_status: "<payment_status>"
    And the <order_notification> has the following params: "<params>"

    When the <order_notification> is verified

    Then the most recent outgoing text message destined for the mobile number should be
    """
    Hi Mara, FYI: a new product order for 1 x 12345790063 (Model Ship - The Rubber Dingy) was created but not sent to Dave (No verified number!). The item belongs to your customer order: #1
    """

    Examples:
      | order_notification | payment_status | params                       |
      | paypal_ipn         | Completed    | {'item_number1'=>'12345790063', 'item_name1' => 'Model Ship - The Rubber Dingy', 'receiver_email'=>'mara@example.com', 'quantity1'=>'1', 'num_cart_items' => '1'}                                                                       |

  Scenario Outline: The supplier has an active and verified mobile number but the seller's active mobile number is not yet verified
    Given an active mobile number: "Mara's number" exists with user: the seller
    And a verified active mobile number: "Dave's number" exists with user: the supplier
    And an <order_notification> exists with payment_status: "<payment_status>"
    And the <order_notification> has the following params: "<params>"

    When the <order_notification> is verified

    Then the most recent outgoing text message destined for the mobile number: "Dave's number" should be
    """
    Hi Dave, you have a new product order: #1, from Mara (No verified number!) for 1 x 12345790063 (Model Ship - The Rubber Dingy). To accept the order, look up the product verification code for this item and reply with: "apo 1 <product verification code>"
    """
    But an outgoing text message should not exist with mobile_number_id: mobile number: "Mara's number"

    Examples:
      | order_notification | payment_status | params                       |
      | paypal_ipn         | Completed    | {'item_number1'=>'12345790063', 'item_name1' => 'Model Ship - The Rubber Dingy', 'receiver_email'=>'mara@example.com', 'quantity1'=>'1', 'num_cart_items' => '1'}                                                                       |

  Scenario Outline: The supplier has an active and verified mobile number but the seller does not have any mobile numbers
    Given a verified active mobile number exists with user: the supplier
    And an <order_notification> exists with payment_status: "<payment_status>"
    And the <order_notification> has the following params: "<params>"

    When the <order_notification> is verified

    Then the most recent outgoing text message destined for the mobile number should be
    """
    Hi Dave, you have a new product order: #1, from Mara (No verified number!) for 1 x 12345790063 (Model Ship - The Rubber Dingy). To accept the order, look up the product verification code for this item and reply with: "apo 1 <product verification code>"
    """

    Examples:
      | order_notification | payment_status | params                       |
      | paypal_ipn         | Completed      | {'item_number1'=>'12345790063', 'item_name1' => 'Model Ship - The Rubber Dingy', 'receiver_email'=>'mara@example.com', 'quantity1'=>'1', 'num_cart_items' => '1'}                                                                       |

  Scenario Outline: The supplier is also the seller of this product
    Given a product exists with seller: the seller, supplier: the seller, number: "12345790069", name: "Model Ship - The Titanic"
    And an <order_notification> exists with payment_status: "<payment_status>"
    And the <order_notification> has the following params: "<params>"

    When the <order_notification> is verified

    Then a seller_order should exist
    And a supplier_order should exist with product_id: the product, quantity: 1, seller_order_id: the seller_order
    And the supplier_order should be unconfirmed
    And the supplier_order should be amongst the seller_order's supplier_orders
    And the supplier_order should be amongst the seller's supplier_orders

    Examples:
      | order_notification | payment_status | params                       |
      | paypal_ipn         | Completed      | {'item_number1'=>'12345790069', 'item_name1' => 'Model Ship - The Titanic', 'receiver_email'=>'mara@example.com', 'quantity1'=>'1', 'num_cart_items' => '1'}                                 |

  Scenario Outline: The supplier is also the seller of this product and they have a verified active mobile number
    Given a verified active mobile number exists with user: the seller

    And an <order_notification> exists with payment_status: "<payment_status>"
    And the <order_notification> has the following params: "<params>"

    When the <order_notification> is verified

    Then the most recent outgoing text message destined for the mobile number should be
    """
    Hi Mara, the customer bought 1 x 12345790069 (Model Ship - The Titanic) as part of the customer order: #1. A new product order: #1, was created to help you track the progress of this item. To mark this product order as completed, reply with: "cpo"
    """

    Examples:
      | order_notification | payment_status | params                       |
      | paypal_ipn         | Completed      | {'item_number1'=>'12345790069', 'item_name1' => 'Model Ship - The Titanic', 'receiver_email'=>'mara@example.com', 'quantity1'=>'1', 'num_cart_items' => '1'}                                 |

  Scenario Outline: The supplier is also the seller of this product but their active mobile number is not yet verified
    Given an active mobile number exists with user: the seller

    And an <order_notification> exists with payment_status: "<payment_status>"
    And the <order_notification> has the following params: "<params>"

    When the <order_notification> is verified

    Then an outgoing text message should not exist with mobile_number_id: the mobile number

    Examples:
      | order_notification | payment_status | params                       |
      | paypal_ipn         | Completed      | {'item_number1'=>'12345790069', 'item_name1' => 'Model Ship - The Titanic', 'receiver_email'=>'mara@example.com', 'quantity1'=>'1', 'num_cart_items' => '1'}                                 |

  Scenario Outline: The seller has not registered this product
    Given an <order_notification> exists with payment_status: "<payment_status>"
    And the <order_notification> has the following params: "<params>"

    When the <order_notification> is verified

    Then a product should exist with number: "12345790062", name: "Model Ship - The Rubber Ducky", seller_id: the seller, supplier_id: the seller
    And a seller_order should exist
    And a supplier_order should exist with product_id: the product, quantity: 1, seller_order_id: the seller_order
    And the supplier_order should be unconfirmed
    And the supplier_order should be amongst the seller_order's supplier_orders
    And the supplier_order should be amongst the seller's supplier_orders

    Examples:
      | order_notification | payment_status | params                       |
      | paypal_ipn         | Completed      | {'item_number1'=>'12345790062', 'item_name1' => 'Model Ship - The Rubber Ducky', 'receiver_email'=>'mara@example.com', 'quantity1'=>'1', 'num_cart_items'=>'1'}                                   |

  Scenario Outline: The seller has not registered this product but they have a verified active mobile number
    Given a verified active mobile number exists with user: the seller
    And an <order_notification> exists with payment_status: "<payment_status>"
    And the <order_notification> has the following params: "<params>"

    When the <order_notification> is verified

    Then the most recent outgoing text message destined for the mobile number should be
    """
    Hi Mara, the customer bought 1 x 12345790062 (Model Ship - The Rubber Ducky) as part of the customer order: #1. A new product order: #1, was created to help you track the progress of this item. To mark this product order as completed, reply with: "cpo"
    """

  Scenario Outline: The seller has not registered this product and their active mobile number is not yet verified
    Given an active mobile number exists with user: the seller
    And an <order_notification> exists with payment_status: "<payment_status>"
    And the <order_notification> has the following params: "<params>"

    When the <order_notification> is verified

    Then an outgoing text message should not exist with mobile_number_id: the mobile number


  Scenario Outline: The seller has registered this product name but the product number is different
    Given an <order_notification> exists with payment_status: "<payment_status>"
    And the <order_notification> has the following params: "<params>"

    When the <order_notification> is verified

    Then the product's number should be "12345790062"
    And the product's name should be "Model Ship - The Rubber Dingy"
    And a seller_order should exist
    And a supplier_order should exist with product_id: the product, quantity: 1, seller_order_id: the seller_order
    And the supplier_order should be unconfirmed
    And the supplier_order should be amongst the seller_order's supplier_orders
    And the supplier_order should be amongst the supplier's supplier_orders

    Examples:
      | order_notification | payment_status | params                       |
      | paypal_ipn         | Completed      | {'item_number1'=>'12345790062', 'item_name1' => 'Model Ship - The Rubber Dingy', 'receiver_email'=>'mara@example.com', 'quantity1'=>'1', 'num_cart_items'=>'1'}                                   |

  Scenario Outline: The seller has registered this product name but the product number is different and both the seller and supplier have verified active mobile numbers
    Given a verified active mobile number: "Mara's number" exists with number: "66354668789", user: the seller
    And a verified active mobile number: "Dave's number" exists with number: "66123555331", user: the supplier
    And an <order_notification> exists with payment_status: "<payment_status>"
    And the <order_notification> has the following params: "<params>"

    When the <order_notification> is verified

    Then the most recent outgoing text message destined for the mobile number: "Mara's number" should be
    """
    Hi Mara, FYI: a new product order for 1 x 12345790062 (Model Ship - The Rubber Dingy) was created and sent to Dave (+66123555331). The item belongs to your customer order: #1
    """
    And the most recent outgoing text message destined for the mobile number: "Dave's number" should be
    """
    Hi Dave, you have a new product order: #1, from Mara (+66354668789) for 1 x 12345790062 (Model Ship - The Rubber Dingy). To accept the order, look up the product verification code for this item and reply with: "apo 1 <product verification code>"
    """

    Examples:
      | order_notification | payment_status | params                       |
      | paypal_ipn         | Completed      | {'item_number1'=>'12345790062', 'item_name1' => 'Model Ship - The Rubber Dingy', 'receiver_email'=>'mara@example.com', 'quantity1'=>'1', 'num_cart_items'=>'1'}                                   |

  Scenario Outline: The seller has registered this product number but the product name is different
    Given an <order_notification> exists with payment_status: "<payment_status>"
    And the <order_notification> has the following params: "<params>"
    When the <order_notification> is verified

    Then the product's number should be "12345790063"
    And the product's name should be "Model Ship - The Rubber Ducky"
    And a seller_order should exist
    And a supplier_order should exist with product_id: the product, quantity: 1, seller_order_id: the seller_order
    And the supplier_order should be unconfirmed
    And the supplier_order should be amongst the seller_order's supplier_orders
    And the supplier_order should be amongst the supplier's supplier_orders

    Examples:
      | order_notification | payment_status | params                       |
      | paypal_ipn         | Completed      | {'item_number1'=>'12345790063', 'item_name1' => 'Model Ship - The Rubber Ducky', 'receiver_email'=>'mara@example.com', 'quantity1'=>'1', 'num_cart_items'=>'1'}                                   |

  Scenario Outline: The seller has registered this product number but the product name is different and both the seller and supplier have verified active mobile numbers
    Given a verified active mobile number: "Mara's number" exists with number: "66354668789", user: the seller
    And a verified active mobile number: "Dave's number" exists with number: "66123555331", user: the supplier
    And an <order_notification> exists with payment_status: "<payment_status>"
    And the <order_notification> has the following params: "<params>"

    When the <order_notification> is verified

    Then the most recent outgoing text message destined for mobile_number: "Mara's number" should be
    """
    Hi Mara, FYI: a new product order for 1 x 12345790063 (Model Ship - The Rubber Ducky) was created and sent to Dave (+66123555331). The item belongs to your customer order: #1
    """
    And the most recent outgoing text message destined for mobile_number: "Dave's number" should be
    """
    Hi Dave, you have a new product order: #1, from Mara (+66354668789) for 1 x 12345790063 (Model Ship - The Rubber Ducky). To accept the order, look up the product verification code for this item and reply with: "apo 1 <product verification code>"
    """

    Examples:
      | order_notification | payment_status | params                       |
      | paypal_ipn         | Completed      | {'item_number1'=>'12345790063', 'item_name1' => 'Model Ship - The Rubber Ducky', 'receiver_email'=>'mara@example.com', 'quantity1'=>'1', 'num_cart_items'=>'1'}                                   |

  Scenario Outline: The seller has registered this product number with a different product name and has also registered this product name with a different product number
    Given a product: "Titanic" exists with seller: the seller, supplier: the supplier, number: "12345790062", name: "Model Ship - The Titanic"
    And an <order_notification> exists with payment_status: "<payment_status>"
    And the <order_notification> has the following params: "<params>"

    When the <order_notification> is verified

    Then 1 products should exist
    And the product: "Rubber Dingy"'s number should be "12345790063"
    And the product: "Rubber Dingy"'s name should be "Model Ship - The Titanic"
    And a seller_order should exist
    And a supplier_order should exist with product_id: the product, quantity: 1, seller_order_id: the seller_order
    And the supplier_order should be unconfirmed
    And the supplier_order should be amongst the seller_order's supplier_orders
    And the supplier_order should be amongst the supplier's supplier_orders

    Examples:
      | order_notification | payment_status | params                       |
      | paypal_ipn         | Completed      | {'item_number1'=>'12345790063', 'item_name1' => 'Model Ship - The Titanic', 'receiver_email'=>'mara@example.com', 'quantity1'=>'1', 'num_cart_items'=>'1'}                                   |

  Scenario Outline: The seller has registered this product number with a different product name and has also registered this product name with a different product number
    Given a verified active mobile number: "Mara's number" exists with number: "66354668789", user: the seller
    And a verified active mobile number: "Dave's number" exists with number: "66123555331", user: the supplier
    And a product: "Titanic" exists with seller: the seller, supplier: the supplier, number: "12345790062", name: "Model Ship - The Titanic"
    And an <order_notification> exists with payment_status: "<payment_status>"
    And the <order_notification> has the following params: "<params>"

    When the <order_notification> is verified

    Then the most recent outgoing text message destined for mobile_number: "Mara's number" should be
    """
    Hi Mara, FYI: a new product order for 1 x 12345790063 (Model Ship - The Titanic) was created and sent to Dave (+66123555331). The item belongs to your customer order: #1
    """
    And the most recent outgoing text message destined for mobile_number: "Dave's number" should be
    """
    Hi Dave, you have a new product order: #1, from Mara (+66354668789) for 1 x 12345790063 (Model Ship - The Titanic). To accept the order, look up the product verification code for this item and reply with: "apo 1 <product verification code>"
    """

