class SupplierOrderObserver < ActiveRecord::Observer
  def after_create(order)
    if supplier = order.supplier
      if send_notification_by_text_message?(supplier)
        OrderNotification.new(:with => supplier).notification_for_new(order)
      end
    end
  end

  def after_accept(order, transition)
    supplier = order.supplier
    OrderNotification.new(:with => supplier).details(order) if
      send_notification_by_text_message?(supplier)
    pay_supplier_and_notify_seller(order, transition)
  end

  def after_reject(order, transition)
    notify_seller(order)
  end

  def after_complete(order, transition)
    pay_supplier_and_notify_seller(order, transition)
  end

  private
    def notify_seller(order)
      seller = order.product.seller
      unless seller == order.supplier
        if send_notification_by_text_message?(seller)
          OrderNotification.new(:with => seller).notify_seller(order)
        end
      end
    end

    def pay_supplier_and_notify_seller(order, transition)
      product = order.product
      seller = product.seller
      supplier = order.supplier
      if seller != supplier
        payment_agreement = find_payment_agreement(product, seller, supplier)
        if payment_agreement &&
           payment_agreement.automatic? &&
           payment_agreement.payment_trigger_on_order == transition.to

          payment = seller.outgoing_payments.build(
            :supplier_order => order,
            :supplier => supplier,
            :amount => order.supplier_total
          )
          if payment.valid?
            if payment_agreement.confirm?
              PaymentNotification.new(:with => seller).confirm(payment)
            else
              payment.save!
              payment_application = seller.payment_application
              if payment_application && payment_application.active?
                payment.build_payment_request(
                  :application_uri => payment_application.uri
                ).save!
              else
                PaymentApplicationNotification.new(
                  :with => seller
                ).invalid(payment_application, payment)
              end
            end
          else
            PaymentNotification.new(:with => seller).invalid(payment)
          end
        else
          notify_seller(order)
        end
      end
    end

    def find_payment_agreement(product, seller, supplier)
      payment_agreement = product.payment_agreement
      payment_agreement = seller.payment_agreements_with_suppliers.where(
        :supplier_id => supplier.id
      ).first if payment_agreement.nil?
      payment_agreement
    end

    def send_notification_by_text_message?(user)
      user.mobile_number # do more here...
    end
end

