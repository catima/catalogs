class ObjetslittPagesController < PagesController
  def show
    @slug = request[:slug]
    @page = catalog.pages.where(:slug => @slug).first!

    render :show
  end
end
