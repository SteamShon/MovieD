class RatesController < ApplicationController
 
  # GET /rates
  # GET /rates.json
  def index
    #@rates = Rate.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @rates }
    end
  end

  # GET /rates/1
  # GET /rates/1.json
  def show
    @rate = Rate.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @rate }
    end
  end

  # GET /rates/new
  # GET /rates/new.json
  def new
    @rate = Rate.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @rate }
    end
  end

  # GET /rates/1/edit
  def edit
    @rate = Rate.find(params[:id])
  end

  # POST /rates
  # POST /rates.json
  def create
    @rate = Rate.new(params[:rate])
    @rated_movies = Rate.where("user_id = ? and tag_id = ?", current_user.id, @rate.tag_id)
    params[:tag_id] = @rate.tag_id
    #@rate = Rate.new(params[:rate])

    respond_to do |format|
      if @rate.save
        current_user.rates << @rate 
        format.html { redirect_to @rate, notice: 'Rate was successfully created.' }
        format.json { render json: @rate, status: :created, location: @rate }
        format.js {}
      else
        format.html { render action: "new" }
        format.json { render json: @rate.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /rates/1
  # PUT /rates/1.json
  def update
    @rate = Rate.find(params[:id])

    respond_to do |format|
      if @rate.update_attributes(params[:rate])
        format.html { redirect_to @rate, notice: 'Rate was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @rate.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /rates/1
  # DELETE /rates/1.json
  def destroy
    @rate = Rate.find(params[:id])
    params[:tag_id] = @rate.tag_id
    @rate.destroy
    @rated_movies = Rate.where("user_id = ? and tag_id = ?", @rate.user_id, @rate.tag_id)
    respond_to do |format|
      format.html { redirect_to rates_url }
      format.json { head :no_content }
      format.js 
    end
  end

end
