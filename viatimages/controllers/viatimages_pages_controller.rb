class ViatimagesPagesController < PagesController
  def show
    if request[:slug] == 'geosearch'
      page = catalog.pages.where(:slug => 'geosearch').first

      unless page.nil?
        @container = page.containers.where(:page_id => page.id, :locale => I18n.locale.to_s).first!
      end
    end

    super
  end
end
