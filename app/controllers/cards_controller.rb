class CardsController < ApplicationController

  before_action :authenticate_user!
  # before_action :authorize


  before_action :set_card, only: [:update, :destroy, :take]


  def index
    @cards = Card.all
    @phone_number = session[:phone_number]
    current_user.update(phone: @phone_number["phone_number"])

    
    

  end
  def create
    @card = Card.new(card_params)
    if @card.save
  
      redirect_to cards_path

    else
      
      render :index
    end
  end

  def update
    
    if @card.update(card_params)
      redirect_to cards_path
    else
     
      render :index
    end
  end

  def show
    @cards = Card.all
    @card = Card.find(params[:id])
    @phone_number = session[:phone_number]
    @yournumber = TakeLog.today.find_by(ip_address: @phone_number["phone_number"] ,card_id: @card)
    
    if @card.over?
      redirect_to cards_path, notice: "時段額滿"
    end
    # if @card.points > 6
    #   redirect_to cards_path, notice: "時段額滿"
    # end
    
    if @yournumber != nil
        @yournumber = @yournumber.take_count 
    end
    
    
  end


    def destroy
      
      @card.destroy
     
      redirect_to cards_path, notice: "刪除成功"
    end

    def take
      
      @phone_number = session[:phone_number]
      @yournumber = @card.take_logs.create(ip_address: @phone_number["phone_number"], take_count: @card.take_logs.size+1) 
      unless @yournumber == nil
        message = "您的號碼是: #{@yournumber.take_count}

                   時段: #{@card.title}"
        # @phone = PhoneNumber.find(@phone_number["id"])
        # @phone.send_message(@phone.phone_number, message)


                 
        ContactMailer.say_hello_to(current_user,message).deliver_now

         

        # TwilioTextMessenger.new(message).call
      end
      redirect_to cards_path, notice: "預約成功,請看簡訊或者信箱"
    end

  private

  def card_params
    params.require(:card).permit(:title)
  end

  def set_card
    @card = Card.find(params[:id])
  end


  def authorize
    if session[:phone_number] == nil
      redirect_to root_path, notice: "請電話驗證"
    end
  end

 





end

