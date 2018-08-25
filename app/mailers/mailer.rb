class Mailer < ApplicationMailer
  layout false, only: [ :weekly_report ]

  def purchase_order(purchase_order_id)
    @purchase_order = PurchaseOrder.find(purchase_order_id).decorate
    attachments['purchase_order.pdf'] = WickedPdf.new.pdf_from_string(pdf_html)

    mail(to: @purchase_order.vendor.email, cc: cc_recipients, subject: "PO #{@purchase_order.number} | #{@purchase_order.property.name }")
  end

  def send_approval_request senders, request_id
    @request = PurchaseRequest.find request_id
    senders.each do |to|
      mail(to: to, subject: "Lodgistics | Request for Approval").deliver
    end
  end

  def send_request_checked request_id, state, user_id
    @request = PurchaseRequest.find request_id
    @state = state
    mail(to: User.find(user_id).email, subject: "Lodgistics | Request (#{@request.number}) #{state.humanize}.")
  end

  def join_invitation(invitation_id)
    @invitation = JoinInvitation.find invitation_id
    mail(to: @invitation.invitee.email, subject: "Lodgistics | Invitation to join #{@invitation.target_type} #{@invitation.targetable.name}").deliver
  end

  def send_invitation(user_id, property_id)
    @user = User.find user_id
    @property = Property.find property_id
    mail(to: @user.email, subject: 'Lodgistics | Invitation to join')
  end

  def weekly_report(report_data, user_id)
    @data = report_data
    @user = User.find user_id
    attachments.inline['logo.png'] = File.read( File.join(Rails.root, 'app/assets/images/logo_text.png') )
    mail(to: @user.email, subject: "Lodgistics | Weekly Report for #{@data[:name]}")
  end

  private
  def pdf_html 
    render_to_string(layout: 'layouts/pdf.html.haml',
                     template: 'purchase_orders/pdf.html.slim',
                     formats: :html)
  end

  def cc_recipients 
    @purchase_order.purchase_request.user.email
  end
end
