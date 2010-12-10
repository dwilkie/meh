class PartnershipsController < ApplicationController
  # POST /partnerships
  def create
    @partnership = current_user.supplier_partnerships.build(
      :supplier_id => params[:supplier_id]
    )
    flash[:notice] = @partnership.save ?
    "Partnership was created. Pending confirmation" :
    @partnership.errors.full_messages.to_sentence
    redirect_to suppliers_path
  end

  # DELETE /partnerships/1
  def destroy
    @partnership = current_user.supplier_partnerships.find(params[:id])
    @partnership.destroy
    flash[:notice] = "Partnership successfully destroyed"
    redirect_to suppliers_path
  end
end

