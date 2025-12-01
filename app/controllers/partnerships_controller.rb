class PartnershipsController < ApplicationController
  def new
    @partnership = Partnership.new
    authorize @partnership
    @invite_code = current_user.invite_codes.active.first_or_create!
  end

  def create
    @partnership = Partnership.new
    authorize @partnership
    code = params[:invite_code].to_s.upcase
    invite_record = InviteCode.active.find_by(code: code)
    if invite_record.nil?
      return redirect_to new_partnership_path, alert: "Invalid or expired invite code."
    end
    user_a = invite_record.user
    user_b = current_user
    if user_a.id == user_b.id
      return redirect_to new_partnership_path, alert: "You cannot use your own invite code."
    elsif user_b.partnership.present?
      return redirect_to new_partnership_path, alert: "You are already partnered."
    end
    @partnership = Partnership.new(user_one: user_a, user_two: user_b)
    if @partnership.save
      invite_record.update_column(:used, true)
      redirect_to dashboard_path, notice: "Partnership successfully created with #{user_a.name}!"
    else
      redirect_to new_partnership_path, alert: "Failed to create partnership."
    end
  end
end
