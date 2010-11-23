class SupplierOrderObserver < ActiveRecord::Observer
  def after_create(supplier_order)
    notify(supplier_order)
  end

  private
    def notify(supplier_order)

    end
end

