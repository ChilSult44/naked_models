class NakedModelController < ApplicationController

  before_filter :set_model
  
  def index
    @models = model.send(:with_exclusive_scope) { model.paginate(:page => params[:page] || 1, :per_page => params[:per_page] || 100) }
    respond_to do |format|
      format.html { render 'naked_model/index' }
      format.xml  { render :xml => @models }
    end
  end

  def show
    @model = model.send(:with_exclusive_scope) { model.find(params[:id]) }
    respond_to do |format|
      format.html { render 'naked_model/show' }
      format.xml  { render :xml => @model }
    end
  rescue ActiveRecord::RecordNotFound => ex
    @model = model.new()
    @model.errors.add_to_base(ex.message)
    respond_to do |format|
      format.html {
        flash[:message] = ex.message
        redirect_to(:action => 'index')
      }
      format.xml  { render :xml => @model.errors, :status => :not_found }
    end
  end

  def new
    @model = model.new
    respond_to do |format|
      format.html { render 'naked_model/new' }
      format.xml  { render :xml => @model }
    end
  end

  def edit
    @model = model.send(:with_exclusive_scope) { model.find(params[:id]) }
    render 'naked_model/edit'
  end

  def create
    @model = model.new(params[model_sym])
    respond_to do |format|
      if @model.save
        flash[:message] = "#{@model_name.titleize} was successfully created."
        format.html { redirect_to(:action => 'show', :id => @model.id) }
        format.xml  { render :xml => @model, :status => :created, :location => { :action => 'show', :id => @model.id, :format => 'xml' } }
      else
        logger.error "Model has errors: #{@model.errors.inspect}"
        format.html { render 'naked_model/new' }
        format.xml  { render :xml => @model.errors, :status => :unprocessable_entity }
      end
    end
  # rescue Exception => ex
  #   respond_to do |format|
  #     @model ||= model.new()
  #     @model.errors.add_to_base(ex.message)
  #     logger.error "Model has errors: #{@model.errors.inspect}"
  #     format.html { render 'naked_model/new' }
  #     format.xml  { render :xml => @model.errors, :status => :unprocessable_entity }
  #   end
  end

  def update
    @model = model.send(:with_exclusive_scope)  { model.find(params[:id]) }
    respond_to do |format|
      if @model.update_attributes(params[model_sym])
        flash[:message] = "#{@model_name.titleize} was successfully updated."
        format.html { redirect_to(:action => 'show', :id => @model.id) }
        format.xml  { head :ok }
      else
        logger.error "Model has errors: #{@model.errors.inspect}"
        format.html { render 'naked_model/edit' }
        format.xml  { render :xml => @model.errors, :status => :unprocessable_entity }
      end
    end
  rescue Exception => ex
    respond_to do |format|
      @model.errors.add_to_base(ex.message)
      logger.error "Model has errors: #{@model.errors.inspect}"
      format.html { render 'naked_model/edit' }
      format.xml  { render :xml => @model.errors, :status => :unprocessable_entity }
    end
  end

  def destroy
    @model = model.send(:with_exclusive_scope)  { model.find(params[:id]) }
    @model.destroy
    respond_to do |format|
      format.html { redirect_to(:action => 'index') }
      format.xml  { head :ok }
    end
  end
  
  protected
  def set_model
    @model_name = model_name
    @model_klass = model
    @model_sym = model_sym
  end
  
  def model
    model_name.constantize
  end
  
  def model_sym
    model_name.downcase.to_sym
  end
  
  def model_name
    self.class.name.gsub(/Controller$/, '').singularize
  end
    
end