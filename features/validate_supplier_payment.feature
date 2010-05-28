#  Scenario: Do not create a payment when the product has no supplier price
#    Given an agreement exists with seller: the seller, supplier: the supplier, payment_for_supplier_order: "accepted"

#    And a product exists with supplier: the supplier, seller: the seller, cents: 0
#    And a supplier_order exists with id: 154671, supplier: the supplier, status: "unconfirmed", quantity: "4", product: the product

#    When the supplier accepts the supplier_order
#    
#    Then a payment should not exist
